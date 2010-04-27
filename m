Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E7E6C6B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:28:11 -0400 (EDT)
Date: Tue, 27 Apr 2010 17:27:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
In-Reply-To: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004271723090.24133@router.home>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010, Mel Gorman wrote:

> The problem is that there are some races that either allow migration PTEs to
> be copied or a migration PTE to be left behind. Migration still completes and
> the page is unlocked but later a fault will call migration_entry_to_page()
> and BUG() because the page is not locked. This series aims to close some
> of these races.

In general migration ptes were designed to cause the code encountering
them to go to sleep until migration is finished and a regular pte is
available. Looks like we are tolerating the handling of migration entries.

Never imagined copying page table with this. There could be recursion
issues of various kinds because page migration requires operations on the
page tables while performing migration. A simple fix would be to *not*
migrate page table tables.

> Patch 1 alters fork() to restart page table copying when a migration PTE is
> 	encountered.

Can we simply wait like in the fault path?

> Patch 3 notes that while a VMA is moved under the anon_vma lock, the page
> 	tables are not similarly protected. Where migration PTEs are
> 	encountered, they are cleaned up.

This means they are copied / moved etc and "cleaned" up in a state when
the page was unlocked. Migration entries are not supposed to exist when
a page is not locked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
