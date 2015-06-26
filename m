Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 90F1E6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 12:43:44 -0400 (EDT)
Received: by qcbcf1 with SMTP id cf1so31034775qcb.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:43:44 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id w68si33467667qha.74.2015.06.26.09.43.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 09:43:43 -0700 (PDT)
Received: by qkei195 with SMTP id i195so19523644qke.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:43:43 -0700 (PDT)
Date: Fri, 26 Jun 2015 12:43:39 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 07/36] HMM: add per mirror page table v3.
Message-ID: <20150626164338.GB3748@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-8-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506251557480.28614@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506251557480.28614@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Thu, Jun 25, 2015 at 04:05:48PM -0700, Mark Hairgrove wrote:
> On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > [...]
> >  
> > +	/* update() - update device mmu following an event.
> > +	 *
> > +	 * @mirror: The mirror that link process address space with the device.
> > +	 * @event: The event that triggered the update.
> > +	 * Returns: 0 on success or error code {-EIO, -ENOMEM}.
> > +	 *
> > +	 * Called to update device page table for a range of address.
> > +	 * The event type provide the nature of the update :
> > +	 *   - Range is no longer valid (munmap).
> > +	 *   - Range protection changes (mprotect, COW, ...).
> > +	 *   - Range is unmapped (swap, reclaim, page migration, ...).
> > +	 *   - Device page fault.
> > +	 *   - ...
> > +	 *
> > +	 * Thought most device driver only need to use pte_mask as it reflects
> > +	 * change that will happen to the HMM page table ie :
> > +	 *   new_pte = old_pte & event->pte_mask;
> 
> Documentation request: It would be useful to break down exactly what is 
> required from the driver for each event type here, and what extra 
> information is provided by the type that isn't provided by the pte_mask.

Mostly event tell you if you need to free or not the device page table for
the range, which is not something you can infer from the pte_mask reliably.
Difference btw migration and munmap for instance, same pte_mask but range
is still valid in the migration case it will just be backed by a new set of
pages.


[...]
> > @@ -142,6 +223,7 @@ int hmm_device_unregister(struct hmm_device *device);
> >   * @kref: Reference counter (private to HMM do not use).
> >   * @dlist: List of all hmm_mirror for same device.
> >   * @mlist: List of all hmm_mirror for same process.
> > + * @pt: Mirror page table.
> >   *
> >   * Each device that want to mirror an address space must register one of this
> >   * struct for each of the address space it wants to mirror. Same device can
> > @@ -154,6 +236,7 @@ struct hmm_mirror {
> >  	struct kref		kref;
> >  	struct list_head	dlist;
> >  	struct hlist_node	mlist;
> > +	struct hmm_pt		pt;
> 
> Documentation request: Why does each mirror have its own separate set of 
> page tables rather than the hmm keeping one set for all devices? This is 
> so different devices can have different permissions for the same address 
> range, correct?

Several reasons, first and mostly dma mapping, while i have plan to allow
to share dma mapping directory btw devices this require work in the dma
layer first. Second reasons is, like you point out, different permissions,
like one device requesting atomic access ie the device will be the only
one with write permission and HMM need somewhere to store that information
per device per address. It also helps to avoid calling device driver on a
range that one device does not mirror.


> > [...]
> > +
> > +static inline int hmm_event_init(struct hmm_event *event,
> > +				 struct hmm *hmm,
> > +				 unsigned long start,
> > +				 unsigned long end,
> > +				 enum hmm_etype etype)
> > +{
> > +	event->start = start & PAGE_MASK;
> > +	event->end = min(end, hmm->vm_end);
> 
> start is rounded down to a page boundary. Should end be rounded also?

Something went wrong while i was re-organizing the patches, final code is:
	event->start = start & PAGE_MASK;
	event->end = PAGE_ALIGN(min(end, hmm->vm_end));

I will make sure this happen in this patch instead of a latter patch.


> > [...]
> > +
> > +static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
> > +				 struct hmm_event *event)
> > +{
> > +	unsigned long addr;
> > +	struct hmm_pt_iter iter;
> > +
> > +	hmm_pt_iter_init(&iter);
> > +	for (addr = event->start; addr != event->end;) {
> > +		unsigned long end, next;
> > +		dma_addr_t *hmm_pte;
> > +
> > +		hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
> > +		if (!hmm_pte) {
> > +			addr = hmm_pt_iter_next(&iter, &mirror->pt,
> > +						addr, event->end);
> > +			continue;
> > +		}
> > +		end = hmm_pt_level_next(&mirror->pt, addr, event->end,
> > +					 mirror->pt.llevel - 1);
> > +		/*
> > +		 * The directory lock protect against concurrent clearing of
> > +		 * page table bit flags. Exceptions being the dirty bit and
> > +		 * the device driver private flags.
> > +		 */
> > +		hmm_pt_iter_directory_lock(&iter, &mirror->pt);
> > +		do {
> > +			next = hmm_pt_level_next(&mirror->pt, addr, end,
> > +						 mirror->pt.llevel);
> > +			if (!hmm_pte_test_valid_pfn(hmm_pte))
> > +				continue;
> > +			if (hmm_pte_test_and_clear_dirty(hmm_pte) &&
> > +			    hmm_pte_test_write(hmm_pte)) {
> 
> If the pte is dirty, why bother checking that it's writable?
> 
> Could there be a legitimate case in which the page was dirtied in the 
> past, but was made read-only later for some reason? In that case the page 
> would still need to be be dirtied correctly even though the hmm_pte isn't 
> currently writable.
> 
> Or is this check trying to protect against a driver setting the dirty bit 
> without the write bit being set? If that happens, that's a driver bug, 
> right?

This is to catch driver bug, i should have add a comment and a debug msg
for that. The dirty bit can not be set if the write bit isn't. So if device
driver do that it is a bug, a bad one. Will add proper warning message.


Thanks for the review,
Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
