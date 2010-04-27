Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 817366B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:36:10 -0400 (EDT)
Date: Tue, 27 Apr 2010 17:35:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100427163549.GG4895@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie> <1272321478-28481-3-git-send-email-mel@csn.ul.ie> <20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com> <20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com> <20100427085951.GB4895@csn.ul.ie> <20100427180949.673350f2.kamezawa.hiroyu@jp.fujitsu.com> <20100427102905.GE4895@csn.ul.ie> <20100427153759.GZ8860@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100427153759.GZ8860@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 27, 2010 at 05:37:59PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 27, 2010 at 11:29:05AM +0100, Mel Gorman wrote:
> > It could have been in both but the vma lock should have been held across
> > the rmap_one. It still reproduces but it's still the right thing to do.
> > This is the current version of patch 2/2.
> 
> Well, keep in mind I reproduced the swapops bug with 2.6.33 anon-vma
> code, it's unlikely that focusing on patch 2 you'll fix bug in
> swapops.h. If this is a bug in the new anon-vma code, it needs fixing
> of course! But I doubt this bug is related to swapops in execve on the
> bprm->p args.
> 

Why do you doubt it's unrelated to execve? From what I've seen during the day,
there is a race in execve where the VMA gets moved (under the anon_vma lock)
before the page-tables are copied with move_ptes (without a lock). In that
case, execve can encounter and copy migration ptes before migration removes
them. This also applies to mainline because it is only taking the RCU lock
and not the anon_vma->lock.

I have a prototype that "handles" the situation with the new anon_vma
code by removing the migration ptes it finds while moving page tables
but it needs more work before releasing.

An alternative would be to split vma_adjust() into locked and unlocked
versions. shift_arg_pages() could then take the anon_vma lock to lock
both the VMA move and the pagetable copy here.

        /*
         * cover the whole range: [new_start, old_end)
         */
        if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
                return -ENOMEM;

        /*
         * move the page tables downwards, on failure we rely on
         * process cleanup to remove whatever mess we made.
         */
        if (length != move_page_tables(vma, old_start,
                                       vma, new_start, length))
                return -ENOMEM;

It'd be messy to split up the locking of vma_adjust like this though and
exec() will hold the anon_vma locks for longer just to guard against
migration. It's not clear this is better than having move_ptes handle
the

> I've yet to check in detail patch 1 sorry, I'll let you know my
> opinion about it as soon as I checked it in detail.
> 

No problem. I still need to revisit all of these patches once I am
confident the swapops bug cannot be triggered any more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
