Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C5F196001DA
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 14:22:49 -0500 (EST)
Date: Mon, 1 Feb 2010 13:22:47 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP 3/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100201192247.GL6653@sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
 <20100128195634.798620000@alcatraz.americas.sgi.com>
 <20100129130820.1544eb1f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129130820.1544eb1f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 01:08:20PM -0800, Andrew Morton wrote:
> On Thu, 28 Jan 2010 13:56:30 -0600
> Robin Holt <holt@sgi.com> wrote:
...
> This is a mushroom patch.  This patch (and the rest of the patchset)
> fails to provide any reason for making any change to anything.
> 
> I understand that it has something to do with xpmem?  That needs to be
> spelled out in some detail please, so we understand the requirements
> and perhaps can suggest alternatives.  If we have enough information we
> can perhaps even suggest alternatives _within xpmem_.  But right now, we
> have nothing.

I have a much better description of what XPMEM needs in the next version.

> > +extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > +			    unsigned long start, unsigned long end, int atomic);
> 
> Perhaps `atomic' could be made bool.

Done.

> > @@ -1018,12 +1019,17 @@ unsigned long unmap_vmas(struct mmu_gath
...
> > -	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> > +	ret = mmu_notifier_invalidate_range_start(mm, start_addr,
> > +					end_addr, (i_mmap_lock == NULL));
> > +	if (ret)
> > +		goto out;
> > +
> 
> afaict, `ret' doesn't get used for anything.

Removed 'ret'

> > +	struct mmu_gather *tlb == NULL;
> 
> This statement doesn't do what you thought it did.  Didn't the compiler warn?

That was wrong.  I had not compiled the patchset.

> >  	spin_unlock(details->i_mmap_lock);
> > +	if (need_unlocked_invalidate) {
> > +		mmu_notifier_invalidate_range_start(vma->mm, start, end, 0);
> > +		mmu_notifier_invalidate_range_end(vma->mm, start, end);
> > +	}
> 
> This is the appropriate place at which to add a comment explaining to
> the reader what the code is doing.

Added a comment.

> > -void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > -				  unsigned long start, unsigned long end)
> > +int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > +			     unsigned long start, unsigned long end, int atomic)
> 
> The implementation would be considerably less ugly if we could do away
> with the `atomic' thing altogether and just assume `atomic=false'
> throughout?

In order to do the atomic=false, we would either need to convert the
_range_start/_range_end to multiple _page callouts or take Andreas
series of patches which convert the i_mmap_lock to an i_mmap_sem and then
implement a method to ensure the vma remains consistent while sleeping
in the invalidate_range_start callout.

Over the weekend, I think I got fairly close to the point in XPMEM where
I can comfortably say the callouts with the i_mmap_lock unlocked will be
unneeded.  I will still need to have the flag (currently called atomic but
should be renamed in that case) to indicate that asynchronous clearing
of the page tables is acceptable.  In that circumstance, XPMEM would
queue up the clearing much as we currently do for the _invalidate_page()
callouts and process them later with a seperate xpmem kernel thread.
I need to do some more thinking and checking with the MPI library folks
to see if we can caveat that behavior.

Another version will be posted shortly.  I will test the synchronous
clearing and follow up with those results.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
