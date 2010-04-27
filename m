Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 46A336B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:23:49 -0400 (EDT)
Date: Wed, 28 Apr 2010 00:22:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm,migration: During fork(), wait for migration to
 end if migration PTE is encountered
Message-ID: <20100427222245.GE8860@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272403852-10479-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Ok I had a first look:

On Tue, Apr 27, 2010 at 10:30:50PM +0100, Mel Gorman wrote:
> 	CPUA			CPU B
> 				do_fork()
> 				copy_mm() (from process 1 to process2)
> 				insert new vma to mmap_list (if inode/anon_vma)

Insert to the tail of the anon_vma list...

> 	pte_lock(process1)
> 	unmap a page
> 	insert migration_entry
> 	pte_unlock(process1)
> 
> 	migrate page copy
> 				copy_page_range
> 	remap new page by rmap_walk()

rmap_walk will walk process1 first! It's at the head, the vmas with
unmapped ptes are at the tail so process1 is walked before process2.

> 	pte_lock(process2)
> 	found no pte.
> 	pte_unlock(process2)
> 				pte lock(process2)
> 				pte lock(process1)
> 				copy migration entry to process2
> 				pte unlock(process1)
> 				pte unlokc(process2)
> 	pte_lock(process1)
> 	replace migration entry
> 	to new page's pte.
> 	pte_unlock(process1)

rmap_walk has to lock down process1 before process2, this is the
ordering issue I already mentioned in earlier email. So it cannot
happen and this patch is unnecessary.

The ordering is fundamental and as said anon_vma_link already adds new
vmas to the _tail_ of the anon-vma. And this is why it has to add to
the tail. If anon_vma_link would add new vmas to the head of the list,
the above bug could materialize, but it doesn't so it cannot happen.

In mainline anon_vma_link is called anon_vma_chain_link, see the
list_add_tail there to provide this guarantee.

Because process1 is walked first by CPU A, the migration entry is
replaced by the final pte before copy-migration-entry
runs. Alternatively if copy-migration-entry runs before before
process1 is walked, the migration entry will be copied and found in
process 2.

Comments welcome.
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
