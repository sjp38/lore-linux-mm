Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f173.google.com (mail-yw0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id 272446B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:25:42 -0400 (EDT)
Received: by mail-yw0-f173.google.com with SMTP id h129so14468986ywb.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:25:42 -0700 (PDT)
Received: from mail-qg0-x243.google.com (mail-qg0-x243.google.com. [2607:f8b0:400d:c04::243])
        by mx.google.com with ESMTPS id p123si639638ywp.426.2016.03.23.04.25.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 04:25:41 -0700 (PDT)
Received: by mail-qg0-x243.google.com with SMTP id y89so975899qge.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:25:41 -0700 (PDT)
Date: Wed, 23 Mar 2016 12:25:32 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v12 08/29] HMM: add device page fault support v6.
Message-ID: <20160323112532.GB2888@gmail.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
 <1457469802-11850-9-git-send-email-jglisse@redhat.com>
 <87h9fxu1nc.fsf@linux.vnet.ibm.com>
 <20160323100919.GA2888@gmail.com>
 <87egb1trlf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87egb1trlf.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jatin Kumar <jakumar@nvidia.com>

On Wed, Mar 23, 2016 at 03:59:32PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:

[...]

> >>  +static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
> >> > +				 struct hmm_event *event,
> >> > +				 struct vm_area_struct *vma,
> >> > +				 struct hmm_pt_iter *iter,
> >> > +				 pmd_t *pmdp,
> >> > +				 struct hmm_mirror_fault *mirror_fault,
> >> > +				 unsigned long start,
> >> > +				 unsigned long end)
> >> > +{
> >> > +	struct page *page;
> >> > +	unsigned long addr, pfn;
> >> > +	unsigned flags = FOLL_TOUCH;
> >> > +	spinlock_t *ptl;
> >> > +	int ret;
> >> > +
> >> > +	ptl = pmd_lock(mirror->hmm->mm, pmdp);
> >> > +	if (unlikely(!pmd_trans_huge(*pmdp))) {
> >> > +		spin_unlock(ptl);
> >> > +		return -EAGAIN;
> >> > +	}
> >> > +	flags |= event->etype == HMM_DEVICE_WFAULT ? FOLL_WRITE : 0;
> >> > +	page = follow_trans_huge_pmd(vma, start, pmdp, flags);
> >> > +	pfn = page_to_pfn(page);
> >> > +	spin_unlock(ptl);
> >> > +
> >> > +	/* Just fault in the whole PMD. */
> >> > +	start &= PMD_MASK;
> >> > +	end = start + PMD_SIZE - 1;
> >> > +
> >> > +	if (!pmd_write(*pmdp) && event->etype == HMM_DEVICE_WFAULT)
> >> > +			return -ENOENT;
> >> > +
> >> > +	for (ret = 0, addr = start; !ret && addr < end;) {
> >> > +		unsigned long i, next = end;
> >> > +		dma_addr_t *hmm_pte;
> >> > +
> >> > +		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
> >> > +		if (!hmm_pte)
> >> > +			return -ENOMEM;
> >> > +
> >> > +		i = hmm_pt_index(&mirror->pt, addr, mirror->pt.llevel);
> >> > +
> >> > +		/*
> >> > +		 * The directory lock protect against concurrent clearing of
> >> > +		 * page table bit flags. Exceptions being the dirty bit and
> >> > +		 * the device driver private flags.
> >> > +		 */
> >> > +		hmm_pt_iter_directory_lock(iter);
> >> > +		do {
> >> > +			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
> >> > +				hmm_pte[i] = hmm_pte_from_pfn(pfn);
> >> > +				hmm_pt_iter_directory_ref(iter);
> >> 
> >> I looked at that and it is actually 
> >> static inline void hmm_pt_iter_directory_ref(struct hmm_pt_iter *iter)
> >> {
> >> 	BUG_ON(!iter->ptd[iter->pt->llevel - 1]);
> >> 	hmm_pt_directory_ref(iter->pt, iter->ptd[iter->pt->llevel - 1]);
> >> }
> >> 
> >> static inline void hmm_pt_directory_ref(struct hmm_pt *pt,
> >> 					struct page *ptd)
> >> {
> >> 	if (!atomic_inc_not_zero(&ptd->_mapcount))
> >> 		/* Illegal this should not happen. */
> >> 		BUG();
> >> }
> >> 
> >> what is the mapcount update about ?
> >
> > Unlike regular CPU page table we do not rely on unmap to prune HMM mirror
> > page table. Rather we free/prune it aggressively once the device no longer
> > have anything mirror in a given range.
> 
> Which patch does this ?

Well it is done in hmm_pt_iter_directory_unref_safe() so there is no particular
patch per say. One optimization i want to do, as part of latter patch is to
delay directory pruning so that we avoid freeing and the reallocating right
away because device or some memory event wrongly induced us into believing it
was done with a range. But i do not want to complexify code before knowing if
it does make sense to do so with hard numbers.


> > As such mapcount is use to keep track of any many valid entry there is per
> > directory.
> >
> > Moreover mapcount is also use to protect from concurrent pruning when
> > you walk through the page table you increment refcount by one along your
> > way. When you done walking you decrement refcount.
> >
> > Because of that last aspect, the mapcount can never reach zero because we
> > unmap page, it can only reach zero once we cleanup the page table walk.
> >
> >> 
> >> > +			}
> >> > +			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pfn);
> >> > +			if (pmd_write(*pmdp))
> >> > +				hmm_pte_set_write(&hmm_pte[i]);
> >> > +		} while (addr += PAGE_SIZE, pfn++, i++, addr != next);
> >> > +		hmm_pt_iter_directory_unlock(iter);
> >> > +		mirror_fault->addr = addr;
> >> > +	}
> >> > +
> >> 
> >> So we don't have huge page mapping in hmm page table ? 
> >
> > No we don't right now. First reason is that i wanted to keep things simple for
> > device driver. Second motivation is to keep first patchset simpler especialy
> > the page migration code.
> >
> > Memory overhead is 2MB per GB of virtual memory mirrored. There is no TLB here.
> > I believe adding huge page can be done as part of a latter patchset if it makes
> > sense.
> >
> 
> One of the thing I am wondering is can we do the patch series in such a
> way that we move the page table mirror to device driver. That is an
> hmm fault will look at cpu page table and call into a device driver callback
> with the pte entry details. It is upto the device driver to maintain a
> mirror table if needed. Similarly for cpu fault we call into hmm
> callback to find per pte dma_addr and do a migrate using
> copy_from_device callback. I haven't fully looked at how easy this would
> be, but I guess lot of the code in this series got to do with mirror
> table and I wondering is there a simpler version we can get upstream
> that hides it within a driver.

This is one possibility but it means that many device driver will duplicate
page table code. It also means that some optimization that i want to do down
the road are not doable. Most notably i want to share IOMMU directory among
several devices (when those devices mirror the same virtual address range)
but this require works in the DMA/IOMMU code.

Another side is related to page reclaimation, with having page use by device
we could get stall because device page table invalidation is way more complex
and takes more time the CPU page table invalidation.

Having mirror in common code makes it easier to have a new lru list for pages
referenced by device. Allowing to hide device page table invalidation latency.
This is also probably doable if we hide the mirror page table into the device
driver but it is harder for common code to know to which device it needs to
ask unmapping. Also this would require either a new page flag or a new pte
flags. Both of which is in short supply and i am not sure people would be
thrill to reserve one just for this feature.

Also i think we want to limit device usage of things like mmu_notifier API.
At least i would.

Another possibility that i did explore is having common code manage mirror
range (instead of a page table) and have the device driver deals on its own
with the down to the page mirroring. I even have patch doing this somewhere.
This might be a middle ground solution. Note by range i means something like:

struct mirror_range {
	struct hmm_device *hdev;
	unsigned long start; /* virtual start address for the range */
	unsigned long end; /* virtual end address for the range */
	/* other field like for an rb_tree and flags. */
};

But it gets quite ugly with range merging/splitting and the obvious worst
case of having one of this struct per page (like mirroring a range every
other page).


> Also does it simply to have interfaces that operates on one pte than an
> array of ptes ? 

I strongly believe we do not want to do that. GPU are like 2048 cores with
16384 threads in flight, if each of the threads page fault over a linear
range you end up having to do 16384 calls and the overhead is gona kill
performances. GPU is about batching things up. So doing things in bulk is
what we want for performances.

Also, i should add that on GPU saving thread context out to memory and
swapping in another is way more expensive. First you can only do so on
large boundary, ie 256 thread at a time or more depends on the GPU.
Seconds for each thread there is way much memory, think few kilo bytes,
so you easily endup moving around MB of thread context data. This is
not lightweight. It is a different paradigm from CPU.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
