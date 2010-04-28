Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC146B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 05:16:18 -0400 (EDT)
Date: Wed, 28 Apr 2010 10:15:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100428091555.GB15815@csn.ul.ie>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie> <1272403852-10479-3-git-send-email-mel@csn.ul.ie> <20100427231007.GA510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100427231007.GA510@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 01:10:07AM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 27, 2010 at 10:30:51PM +0100, Mel Gorman wrote:
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index f90ea92..61d6f1d 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -578,6 +578,9 @@ again:			remove_next = 1 + (end > next->vm_end);
> >  		}
> >  	}
> >  
> > +	if (vma->anon_vma)
> > +		spin_lock(&vma->anon_vma->lock);
> > +
> >  	if (root) {
> >  		flush_dcache_mmap_lock(mapping);
> >  		vma_prio_tree_remove(vma, root);
> > @@ -620,6 +623,9 @@ again:			remove_next = 1 + (end > next->vm_end);
> >  	if (mapping)
> >  		spin_unlock(&mapping->i_mmap_lock);
> >  
> > +	if (vma->anon_vma)
> > +		spin_unlock(&vma->anon_vma->lock);
> > +
> >  	if (remove_next) {
> >  		if (file) {
> >  			fput(file);
> 
> The old code did:
> 
>     /*
>      * When changing only vma->vm_end, we don't really need
>      * anon_vma lock.
>      */
>     if (vma->anon_vma && (insert || importer || start !=  vma->vm_start))
> 	anon_vma = vma->anon_vma;
>     if (anon_vma) {
>         spin_lock(&anon_vma->lock);
> 
> why did it become unconditional? (and no idea why it was removed)
> 

It became unconditional because I wasn't sure of the optimisation versus the
new anon_vma changes (doesn't matter, should have been safe). At the time
the patch was introduced, the bug looked like a race in VMA's in the list
having their details modified. I thought vma_address was returning -EFAULT
when it shouldn't and while this may still be possible, it wasn't the prime
cause of the bug.

The more important race was in execve between when a VMA got moved and the
page tables copied. The anon_vma locks are fine for the VMA move but the
page table copy happens later. What the patch did was alter the timing of
the race. rmap_walk() was finding the VMA of the new stack being set up by
exec, failing to lock it and backing off. By the time it would restart and
get back to that VMA, it was already moved making the bug simply harder to
reproduce because the race window was so small.

So, the VMA list does not appear to be messed up but there still needs
to be protection against modification of VMA details that are already on
the list. For that, the seq counter would have been enough and
lighter-weight than acquiring the anon_vma->lock every time in
vma_adjust().

I'll drop this patch again as the execve race looks the most important.

> But I'm not sure about this part.... this is really only a question, I
> may well be wrong, I just don't get it.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
