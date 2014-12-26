Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id D99D86B006E
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 02:20:39 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so7171626qcv.1
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 23:20:39 -0800 (PST)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id z3si31123432qaj.112.2014.12.25.23.20.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 23:20:38 -0800 (PST)
Received: by mail-qc0-f182.google.com with SMTP id r5so7253526qcx.27
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 23:20:38 -0800 (PST)
Date: Fri, 26 Dec 2014 02:20:32 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 2/7] mmu_notifier: keep track of active invalidation
 ranges v2
Message-ID: <20141226071112.GA4408@gmail.com>
References: <1419266940-5440-1-git-send-email-j.glisse@gmail.com>
 <1419266940-5440-3-git-send-email-j.glisse@gmail.com>
 <549BCAF8.1070500@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <549BCAF8.1070500@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Dec 25, 2014 at 10:29:44AM +0200, Haggai Eran wrote:
> On 22/12/2014 18:48, j.glisse@gmail.com wrote:
> >  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > -						       unsigned long start,
> > -						       unsigned long end,
> > -						       enum mmu_event event)
> > +						       struct mmu_notifier_range *range)
> >  {
> > +	/*
> > +	 * Initialize list no matter what in case a mmu_notifier register after
> > +	 * a range_start but before matching range_end.
> > +	 */
> > +	INIT_LIST_HEAD(&range->list);
> 
> I don't see how can an mmu_notifier register after a range_start but
> before a matching range_end. The mmu_notifier registration locks all mm
> locks, and that should prevent any invalidation from running, right?

File invalidation (like truncation) can lead to this case.

> 
> >  	if (mm_has_notifiers(mm))
> > -		__mmu_notifier_invalidate_range_start(mm, start, end, event);
> > +		__mmu_notifier_invalidate_range_start(mm, range);
> >  }
> 
> ...
> 
> >  void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > -					   unsigned long start,
> > -					   unsigned long end,
> > -					   enum mmu_event event)
> > +					   struct mmu_notifier_range *range)
> >  
> >  {
> >  	struct mmu_notifier *mn;
> > @@ -185,21 +183,36 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> >  	id = srcu_read_lock(&srcu);
> >  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> >  		if (mn->ops->invalidate_range_start)
> > -			mn->ops->invalidate_range_start(mn, mm, start,
> > -							end, event);
> > +			mn->ops->invalidate_range_start(mn, mm, range);
> >  	}
> >  	srcu_read_unlock(&srcu, id);
> > +
> > +	/*
> > +	 * This must happen after the callback so that subsystem can block on
> > +	 * new invalidation range to synchronize itself.
> > +	 */
> > +	spin_lock(&mm->mmu_notifier_mm->lock);
> > +	list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
> > +	mm->mmu_notifier_mm->nranges++;
> > +	spin_unlock(&mm->mmu_notifier_mm->lock);
> >  }
> >  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
> 
> Don't you have a race here because you add the range struct after the
> callback?
> 
> -------------------------------------------------------------------------
> Thread A                    | Thread B
> -------------------------------------------------------------------------
> call mmu notifier callback  |
>   clear SPTE                |
>                             | device page fault
>                             |   mmu_notifier_range_is_valid returns true
>                             |   install new SPTE
> add event struct to list    |
> mm clears/modifies the PTE  |
> -------------------------------------------------------------------------
> 
> So we are left with different entries in the host page table and the
> secondary page table.
> 
> I would think you'd want the event struct to be added to the list before
> the callback is run.
> 

Yes you right, but the comment i left trigger memory that i did that on
purpose a one point probably with a different synch mecanism inside hmm.
I will try to medidate a bit see if i can bring back memory why i did it
that way in respect to previous design.

In all case i will respin with that order modified. Can i add you review
by after doing so ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
