Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 148C16B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 23:02:16 -0400 (EDT)
Received: by padev16 with SMTP id ev16so77331340pad.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 20:02:15 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h9si53267991pat.186.2015.06.26.20.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 20:02:13 -0700 (PDT)
Date: Fri, 26 Jun 2015 20:02:03 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 07/36] HMM: add per mirror page table v3.
In-Reply-To: <20150626164338.GB3748@gmail.com>
Message-ID: <alpine.DEB.2.00.1506261958010.22464@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-8-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506251557480.28614@mdh-linux64-2.nvidia.com> <20150626164338.GB3748@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-557262299-1435374131=:22464"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

--8323329-557262299-1435374131=:22464
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT



On Fri, 26 Jun 2015, Jerome Glisse wrote:

> On Thu, Jun 25, 2015 at 04:05:48PM -0700, Mark Hairgrove wrote:
> > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > From: Jerome Glisse <jglisse@redhat.com>
> > > [...]
> > >  
> > > +	/* update() - update device mmu following an event.
> > > +	 *
> > > +	 * @mirror: The mirror that link process address space with the device.
> > > +	 * @event: The event that triggered the update.
> > > +	 * Returns: 0 on success or error code {-EIO, -ENOMEM}.
> > > +	 *
> > > +	 * Called to update device page table for a range of address.
> > > +	 * The event type provide the nature of the update :
> > > +	 *   - Range is no longer valid (munmap).
> > > +	 *   - Range protection changes (mprotect, COW, ...).
> > > +	 *   - Range is unmapped (swap, reclaim, page migration, ...).
> > > +	 *   - Device page fault.
> > > +	 *   - ...
> > > +	 *
> > > +	 * Thought most device driver only need to use pte_mask as it reflects
> > > +	 * change that will happen to the HMM page table ie :
> > > +	 *   new_pte = old_pte & event->pte_mask;
> > 
> > Documentation request: It would be useful to break down exactly what is 
> > required from the driver for each event type here, and what extra 
> > information is provided by the type that isn't provided by the pte_mask.
> 
> Mostly event tell you if you need to free or not the device page table for
> the range, which is not something you can infer from the pte_mask reliably.
> Difference btw migration and munmap for instance, same pte_mask but range
> is still valid in the migration case it will just be backed by a new set of
> pages.

Given that event->pte_mask and event->type provide redundant information, 
are they both necessary?

With or without pte_mask, the below table would be helpful to have in the 
comments for the ->update callback:

Event type          Driver action
HMM_NONE            N/A (driver will never get this)

HMM_FORK            Same as HMM_WRITE_PROTECT

HMM_ISDIRTY         Same as HMM_WRITE_PROTECT

HMM_MIGRATE         Make device PTEs invalid and use hmm_pte_set_dirty or
                    hmm_mirror_range_dirty if applicable

HMM_MUNMAP          Same as HMM_MIGRATE, but the driver may take this as a
                    hint to free device page tables and other resources
                    associated with this range

HMM_DEVICE_RFAULT   Read hmm_ptes using hmm_pt_iter and write them on the
                    device

HMM_DEVICE_WFAULT   Same as HMM_DEVICE_RFAULT

HMM_WRITE_PROTECT   Remove write permission from device PTEs and use
                    hmm_pte_set_dirty or hmm_mirror_range_dirty if
                    applicable


> 
> 
> [...]
> > > @@ -142,6 +223,7 @@ int hmm_device_unregister(struct hmm_device *device);
> > >   * @kref: Reference counter (private to HMM do not use).
> > >   * @dlist: List of all hmm_mirror for same device.
> > >   * @mlist: List of all hmm_mirror for same process.
> > > + * @pt: Mirror page table.
> > >   *
> > >   * Each device that want to mirror an address space must register one of this
> > >   * struct for each of the address space it wants to mirror. Same device can
> > > @@ -154,6 +236,7 @@ struct hmm_mirror {
> > >  	struct kref		kref;
> > >  	struct list_head	dlist;
> > >  	struct hlist_node	mlist;
> > > +	struct hmm_pt		pt;
> > 
> > Documentation request: Why does each mirror have its own separate set of 
> > page tables rather than the hmm keeping one set for all devices? This is 
> > so different devices can have different permissions for the same address 
> > range, correct?
> 
> Several reasons, first and mostly dma mapping, while i have plan to allow
> to share dma mapping directory btw devices this require work in the dma
> layer first. Second reasons is, like you point out, different permissions,
> like one device requesting atomic access ie the device will be the only
> one with write permission and HMM need somewhere to store that information
> per device per address. It also helps to avoid calling device driver on a
> range that one device does not mirror.

Sure, that makes sense. Can you put this in the documentation somewhere, 
perhaps in the header comments for struct hmm_mirror?

Thanks!
--8323329-557262299-1435374131=:22464--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
