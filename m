Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0679E6B0038
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 13:49:27 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id i13so13460412qae.10
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 10:49:26 -0800 (PST)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id ik1si61409149qab.22.2015.01.05.10.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 10:49:25 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id l89so15570831qgf.40
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 10:49:25 -0800 (PST)
Date: Mon, 5 Jan 2015 13:49:15 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 2/7] mmu_notifier: keep track of active invalidation
 ranges v2
Message-ID: <20150105184914.GA8012@gmail.com>
References: <AMSPR05MB48272339639F199CA876C4FC1500@AMSPR05MB482.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AMSPR05MB48272339639F199CA876C4FC1500@AMSPR05MB482.eurprd05.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>, Dave Airlie <airlied@redhat.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, "joro@8bytes.org" <joro@8bytes.org>, Greg Stoner <Greg.Stoner@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Cameron Buschardt <cabuschardt@nvidia.com>, Rik van Riel <riel@redhat.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Lucien Dunning <ldunning@nvidia.com>, Johannes Weiner <jweiner@redhat.com>, Michael Mantor <Michael.Mantor@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Larry Woodman <lwoodman@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Brendan Conoboy <blc@redhat.com>, John Bridgman <John.Bridgman@amd.com>, Subhash Gutti <sgutti@nvidia.com>, Roland Dreier <roland@purestorage.com>, Duncan Poole <dpoole@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Deucher <Alexander.Deucher@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Sherry Cheung <SCheung@nvidia.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Ben Sander <ben.sander@amd.com>, Joe Donohue <jdonohue@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>

On Sun, Dec 28, 2014 at 08:46:42AM +0000, Haggai Eran wrote:
> 
> On Dec 26, 2014 9:20 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > On Thu, Dec 25, 2014 at 10:29:44AM +0200, Haggai Eran wrote:
> > > On 22/12/2014 18:48, j.glisse@gmail.com wrote:
> > > >  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > > > -                                                  unsigned long start,
> > > > -                                                  unsigned long end,
> > > > -                                                  enum mmu_event event)
> > > > +                                                  struct mmu_notifier_range *range)
> > > >  {
> > > > +   /*
> > > > +    * Initialize list no matter what in case a mmu_notifier register after
> > > > +    * a range_start but before matching range_end.
> > > > +    */
> > > > +   INIT_LIST_HEAD(&range->list);
> > >
> > > I don't see how can an mmu_notifier register after a range_start but
> > > before a matching range_end. The mmu_notifier registration locks all mm
> > > locks, and that should prevent any invalidation from running, right?
> >
> > File invalidation (like truncation) can lead to this case.
> 
> I thought that the fact that mm_take_all_locks locked the i_mmap_mutex of
> every file would prevent this from happening, because the notifier is added
> when the mutex is locked, and the truncate operation also locks it. Am I
> missing something?

No you right again, i was convince in my mind that mmu_notifier register was
only taking the mmap semaphore in write mode for some reasons while it is
in fact also calling mm_take_all_locks(). So yes this protect registration
from all concurrent invalidation.

> 
> >
> > >
> > > >      if (mm_has_notifiers(mm))
> > > > -           __mmu_notifier_invalidate_range_start(mm, start, end, event);
> > > > +           __mmu_notifier_invalidate_range_start(mm, range);
> > > >  }
> > >
> > > ...
> > >
> > > >  void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > > > -                                      unsigned long start,
> > > > -                                      unsigned long end,
> > > > -                                      enum mmu_event event)
> > > > +                                      struct mmu_notifier_range *range)
> > > >
> > > >  {
> > > >      struct mmu_notifier *mn;
> > > > @@ -185,21 +183,36 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> > > >      id = srcu_read_lock(&srcu);
> > > >      hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> > > >              if (mn->ops->invalidate_range_start)
> > > > -                   mn->ops->invalidate_range_start(mn, mm, start,
> > > > -                                                   end, event);
> > > > +                   mn->ops->invalidate_range_start(mn, mm, range);
> > > >      }
> > > >      srcu_read_unlock(&srcu, id);
> > > > +
> > > > +   /*
> > > > +    * This must happen after the callback so that subsystem can block on
> > > > +    * new invalidation range to synchronize itself.
> > > > +    */
> > > > +   spin_lock(&mm->mmu_notifier_mm->lock);
> > > > +   list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
> > > > +   mm->mmu_notifier_mm->nranges++;
> > > > +   spin_unlock(&mm->mmu_notifier_mm->lock);
> > > >  }
> > > >  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
> > >
> > > Don't you have a race here because you add the range struct after the
> > > callback?
> > >
> > > -------------------------------------------------------------------------
> > > Thread A                    | Thread B
> > > -------------------------------------------------------------------------
> > > call mmu notifier callback  |
> > >   clear SPTE                |
> > >                             | device page fault
> > >                             |   mmu_notifier_range_is_valid returns true
> > >                             |   install new SPTE
> > > add event struct to list    |
> > > mm clears/modifies the PTE  |
> > > -------------------------------------------------------------------------
> > >
> > > So we are left with different entries in the host page table and the
> > > secondary page table.
> > >
> > > I would think you'd want the event struct to be added to the list before
> > > the callback is run.
> > >
> >
> > Yes you right, but the comment i left trigger memory that i did that on
> > purpose a one point probably with a different synch mecanism inside hmm.
> > I will try to medidate a bit see if i can bring back memory why i did it
> > that way in respect to previous design.
> >
> > In all case i will respin with that order modified. Can i add you review
> > by after doing so ?
> 
> Sure, go ahead.
> 
> Regards,
> Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
