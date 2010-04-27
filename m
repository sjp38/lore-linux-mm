Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B8626B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 23:54:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R3sj0v026039
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 12:54:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B921045DE68
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:54:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80C6C45DE51
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:54:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62B501DB8042
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:54:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FBA11DB803B
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:54:44 +0900 (JST)
Date: Tue, 27 Apr 2010 12:50:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>
	<20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 09:07:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 26 Apr 2010 23:37:58 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > vma_adjust() is updating anon VMA information without any locks taken.
> > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > locking can result in races with page migration. During rmap_walk(),
> > vma_address() can return -EFAULT for an address that will soon be valid.
> > This leaves a dangling migration PTE behind which can later cause a BUG_ON
> > to trigger when the page is faulted in.
> > 
> > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > that can be taken in a anon_vma_chain but a second lock cannot be spinned
> > upon in case of deadlock. Instead, the rmap walker tries to take locks of
> > different anon_vma's. If the attempt fails, the operation is restarted.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Ok, acquiring vma->anon_vma->spin_lock always sounds very safe.
> (but slow.)
> 
> I'll test this, too.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Sorry. reproduced. It seems the same bug before patch. 
mapcount 1 -> unmap -> remap -> mapcount 0. And it was SwapCache.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
