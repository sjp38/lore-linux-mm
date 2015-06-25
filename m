Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5E06B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 19:05:57 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so62222492pdb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 16:05:56 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id o8si47300641pdp.62.2015.06.25.16.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 16:05:56 -0700 (PDT)
Date: Thu, 25 Jun 2015 16:05:48 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 07/36] HMM: add per mirror page table v3.
In-Reply-To: <1432236705-4209-8-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.DEB.2.00.1506251557480.28614@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-8-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1873183555-1435273554=:28614"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "j.glisse@gmail.com" <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

--8323329-1873183555-1435273554=:28614
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT



On Thu, 21 May 2015, j.glisse@gmail.com wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> [...]
>  
> +	/* update() - update device mmu following an event.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 * @event: The event that triggered the update.
> +	 * Returns: 0 on success or error code {-EIO, -ENOMEM}.
> +	 *
> +	 * Called to update device page table for a range of address.
> +	 * The event type provide the nature of the update :
> +	 *   - Range is no longer valid (munmap).
> +	 *   - Range protection changes (mprotect, COW, ...).
> +	 *   - Range is unmapped (swap, reclaim, page migration, ...).
> +	 *   - Device page fault.
> +	 *   - ...
> +	 *
> +	 * Thought most device driver only need to use pte_mask as it reflects
> +	 * change that will happen to the HMM page table ie :
> +	 *   new_pte = old_pte & event->pte_mask;

Documentation request: It would be useful to break down exactly what is 
required from the driver for each event type here, and what extra 
information is provided by the type that isn't provided by the pte_mask.

> +	 *
> +	 * Device driver must not update the HMM mirror page table (except the
> +	 * dirty bit see below). Core HMM will update HMM page table after the
> +	 * update is done.
> +	 *
> +	 * Note that device must be cache coherent with system memory (snooping
> +	 * in case of PCIE devices) so there should be no need for device to
> +	 * flush anything.
> +	 *
> +	 * When write protection is turned on device driver must make sure the
> +	 * hardware will no longer be able to write to the page otherwise file
> +	 * system corruption may occur.
> +	 *
> +	 * Device must properly set the dirty bit using hmm_pte_set_bit() on
> +	 * each page entry for memory that was written by the device. If device
> +	 * can not properly account for write access then the dirty bit must be
> +	 * set unconditionaly so that proper write back of file backed page can
> +	 * happen.
> +	 *
> +	 * Device driver must not fail lightly, any failure result in device
> +	 * process being kill.
> +	 *
> +	 * Return 0 on success, error value otherwise :
> +	 * -ENOMEM Not enough memory for performing the operation.
> +	 * -EIO    Some input/output error with the device.
> +	 *
> +	 * All other return value trigger warning and are transformed to -EIO.
> +	 */
> +	int (*update)(struct hmm_mirror *mirror,const struct hmm_event *event);
>  };
>  
>  
> @@ -142,6 +223,7 @@ int hmm_device_unregister(struct hmm_device *device);
>   * @kref: Reference counter (private to HMM do not use).
>   * @dlist: List of all hmm_mirror for same device.
>   * @mlist: List of all hmm_mirror for same process.
> + * @pt: Mirror page table.
>   *
>   * Each device that want to mirror an address space must register one of this
>   * struct for each of the address space it wants to mirror. Same device can
> @@ -154,6 +236,7 @@ struct hmm_mirror {
>  	struct kref		kref;
>  	struct list_head	dlist;
>  	struct hlist_node	mlist;
> +	struct hmm_pt		pt;

Documentation request: Why does each mirror have its own separate set of 
page tables rather than the hmm keeping one set for all devices? This is 
so different devices can have different permissions for the same address 
range, correct?

>  };
>  
> [...]
> +
> +static inline int hmm_event_init(struct hmm_event *event,
> +				 struct hmm *hmm,
> +				 unsigned long start,
> +				 unsigned long end,
> +				 enum hmm_etype etype)
> +{
> +	event->start = start & PAGE_MASK;
> +	event->end = min(end, hmm->vm_end);

start is rounded down to a page boundary. Should end be rounded also?


> [...]
> +
> +static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
> +				 struct hmm_event *event)
> +{
> +	unsigned long addr;
> +	struct hmm_pt_iter iter;
> +
> +	hmm_pt_iter_init(&iter);
> +	for (addr = event->start; addr != event->end;) {
> +		unsigned long end, next;
> +		dma_addr_t *hmm_pte;
> +
> +		hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
> +		if (!hmm_pte) {
> +			addr = hmm_pt_iter_next(&iter, &mirror->pt,
> +						addr, event->end);
> +			continue;
> +		}
> +		end = hmm_pt_level_next(&mirror->pt, addr, event->end,
> +					 mirror->pt.llevel - 1);
> +		/*
> +		 * The directory lock protect against concurrent clearing of
> +		 * page table bit flags. Exceptions being the dirty bit and
> +		 * the device driver private flags.
> +		 */
> +		hmm_pt_iter_directory_lock(&iter, &mirror->pt);
> +		do {
> +			next = hmm_pt_level_next(&mirror->pt, addr, end,
> +						 mirror->pt.llevel);
> +			if (!hmm_pte_test_valid_pfn(hmm_pte))
> +				continue;
> +			if (hmm_pte_test_and_clear_dirty(hmm_pte) &&
> +			    hmm_pte_test_write(hmm_pte)) {

If the pte is dirty, why bother checking that it's writable?

Could there be a legitimate case in which the page was dirtied in the 
past, but was made read-only later for some reason? In that case the page 
would still need to be be dirtied correctly even though the hmm_pte isn't 
currently writable.

Or is this check trying to protect against a driver setting the dirty bit 
without the write bit being set? If that happens, that's a driver bug, 
right?

> +				struct page *page;
> +
> +				page = pfn_to_page(hmm_pte_pfn(*hmm_pte));
> +				set_page_dirty(page);
> +			}
> +			*hmm_pte &= event->pte_mask;
> +			if (hmm_pte_test_valid_pfn(hmm_pte))
> +				continue;
> +			hmm_pt_iter_directory_unref(&iter, mirror->pt.llevel);
> +		} while (addr = next, hmm_pte++, addr != end);
> +		hmm_pt_iter_directory_unlock(&iter, &mirror->pt);
> +	}
> +	hmm_pt_iter_fini(&iter, &mirror->pt);
> +}
--8323329-1873183555-1435273554=:28614--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
