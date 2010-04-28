Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2C5A26B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:07:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S073MG017515
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 09:07:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DB9045DE4D
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:07:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6AAB45DE53
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:07:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A7B371DB8051
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:07:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56E921DB804C
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:07:02 +0900 (JST)
Date: Wed, 28 Apr 2010 09:03:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs when
 page tables are being moved after the VMA has already moved
Message-Id: <20100428090302.5e69721f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	<1272403852-10479-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 22:30:52 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> During exec(), a temporary stack is setup and moved later to its final
> location. There is a race between migration and exec whereby a migration
> PTE can be placed in the temporary stack. When this VMA is moved under the
> lock, migration no longer knows where the PTE is, fails to remove the PTE
> and the migration PTE gets copied to the new location.  This later causes
> a bug when the migration PTE is discovered but the page is not locked.
> 
> This patch handles the situation by removing the migration PTE when page
> tables are being moved in case migration fails to find them. The alternative
> would require significant modification to vma_adjust() and the locks taken
> to ensure a VMA move and page table copy is atomic with respect to migration.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Mel, I don't like this fix. Consider following,

 1. try_to_unmap(oldpage)
 2. copy and replace
 3. remove_migration_ptes(oldpage, newpage)

What this patch handles is "3: remove_migration_ptes fails to remap it and
migration_pte will remain there case....The fact "new page is not mapped" means
"get_page() is not called against the new page".
So, the new page have been able to be freed until we restart move_ptes.

I bet calling __get_user_pages_fast() before vma_adjust() is the way to go. 
When page_count(page) != page_mapcount(page) +1, migration skip it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
