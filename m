Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 242C8900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 23:29:34 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so6129241pdj.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 20:29:33 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id fn10si8846740pab.103.2015.06.04.20.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 20:29:32 -0700 (PDT)
Date: Thu, 4 Jun 2015 20:29:30 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 02/36] mmu_notifier: keep track of active invalidation
 ranges v3
In-Reply-To: <20150603171500.GB2602@gmail.com>
Message-ID: <alpine.LNX.2.03.1506042024090.18025@nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-3-git-send-email-j.glisse@gmail.com> <alpine.LNX.2.03.1506020214160.17700@nvidia.com> <20150603171500.GB2602@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-1647376294-1433474971=:18025"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

--279739828-1647376294-1433474971=:18025
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT

On Wed, 3 Jun 2015, Jerome Glisse wrote:

> On Tue, Jun 02, 2015 at 02:32:01AM -0700, John Hubbard wrote:
> > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > 
> > > From: Jerome Glisse <jglisse@redhat.com>
> > > 
> > > The mmu_notifier_invalidate_range_start() and mmu_notifier_invalidate_range_end()
> > > can be considered as forming an "atomic" section for the cpu page table update
> > > point of view. Between this two function the cpu page table content is unreliable
> > > for the address range being invalidated.
> > > 
> > > Current user such as kvm need to know when they can trust the content of the cpu
> > > page table. This becomes even more important to new users of the mmu_notifier
> > > api (such as HMM or ODP).
> > > 
> > > This patch use a structure define at all call site to invalidate_range_start()
> > > that is added to a list for the duration of the invalidation. It adds two new
> > > helpers to allow querying if a range is being invalidated or to wait for a range
> > > to become valid.
> > > 
> > > For proper synchronization, user must block new range invalidation from inside
> > > there invalidate_range_start() callback, before calling the helper functions.
> > > Otherwise there is no garanty that a new range invalidation will not be added
> > > after the call to the helper function to query for existing range.
> > 
> > Hi Jerome,
> > 
> > Most of this information will make nice block comments for the new helper 
> > routines. I can help tighten up the writing slightly, but first:
> > 
> > Question: in hmm.c's hmm_notifier_invalidate function (looking at the 
> > entire patchset, for a moment), I don't see any blocking of new range 
> > invalidations, even though you point out, above, that this is required. Am 
> > I missing it, and if so, where should I be looking instead?
> 
> This is a 2 sided synchronization:
> 
> - hmm_device_fault_start() will wait for active invalidation that conflict
>   to be done
> - hmm_wait_device_fault() will block new invalidation until
>   active fault that conflict back off.
>


OK. I'll wait until those patches to talk about those, then.
 
> 
> > [...]
> > 
> > > -					   enum mmu_event event)
> > > +					   struct mmu_notifier_range *range)
> > >  
> > >  {
> > >  	struct mmu_notifier *mn;
> > >  	int id;
> > >  
> > > +	spin_lock(&mm->mmu_notifier_mm->lock);
> > > +	list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
> > > +	mm->mmu_notifier_mm->nranges++;
> > 
> > 
> > Is this missing a call to wake_up(&mm->mmu_notifier_mm->wait_queue)? If 
> > not, then it would be helpful to explain why that's only required for 
> > nranges--, and not for the nranges++ case. The helper routine is merely 
> > waiting for nranges to *change*, not looking for greater than or less 
> > than.
> 
> This is on purpose, as the waiting side only wait for active invalidation
> to be done ie for mm->mmu_notifier_mm->nranges-- so there is no reasons to
> wake up when a new invalidation is starting. Also the test need to be a not
> equal because other non conflicting range might be added/removed meaning
> that wait might finish even if mm->mmu_notifier_mm->nranges > saved_nranges.
> 


OK, I convinced myself that this works as intended. So I don't see 
anything wrong with this approach.

thanks,
john h

> 
> [...]
> > > +static bool mmu_notifier_range_is_valid_locked(struct mm_struct *mm,
> > > +					       unsigned long start,
> > > +					       unsigned long end)
> > 
> > 
> > This routine is named "_range_is_valid_", but it takes in an implicit 
> > range (start, end), and also a list of ranges (buried in mm), and so it's 
> > a little confusing. I'd like to consider *maybe* changing either the name, 
> > or the args (range* instead of start, end?), or something.
> > 
> > Could you please say a few words about the intent of this routine, to get 
> > us started there?
> 
> It is just the same as mmu_notifier_range_is_valid() but it expects locks
> to be taken. This is for the benefit of mmu_notifier_range_wait_valid()
> which need to test if a range is valid (ie no conflicting invalidation)
> or not. I added a comment to explain this 3 function and to explain how
> the 2 publics helper needs to be use.
> 
> Cheers,
> Jerome
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--279739828-1647376294-1433474971=:18025--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
