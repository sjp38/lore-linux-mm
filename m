Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 623966B009C
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 22:34:55 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so101930803pdb.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 19:34:55 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id uv9si19069630pac.126.2015.06.19.19.34.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 19:34:54 -0700 (PDT)
Date: Fri, 19 Jun 2015 19:34:45 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
In-Reply-To: <20150619180713.GA17308@gmail.com>
Message-ID: <alpine.DEB.2.00.1506191928060.19996@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-7-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506171724110.32592@mdh-linux64-2.nvidia.com> <20150619180713.GA17308@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>



On Fri, 19 Jun 2015, Jerome Glisse wrote:

> On Thu, Jun 18, 2015 at 07:06:08PM -0700, Mark Hairgrove wrote:
> > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> 
> [...]
> > > +
> > > +static inline dma_addr_t hmm_pde_from_pfn(dma_addr_t pfn)
> > > +{
> > > +	return (pfn << PAGE_SHIFT) | HMM_PDE_VALID;
> > > +}
> > > +
> > > +static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
> > > +{
> > > +	return (pde & HMM_PDE_VALID) ? pde >> PAGE_SHIFT : 0;
> > > +}
> > > +
> > 
> > Does hmm_pde_pfn return a dma_addr_t pfn or a system memory pfn?
> > 
> > The types between these two functions don't match. According to 
> > hmm_pde_from_pfn, both the pde and the pfn are supposed to be dma_addr_t. 
> > But hmm_pde_pfn returns an unsigned long as a pfn instead of a dma_addr_t. 
> > If hmm_pde_pfn sometimes used to get a dma_addr_t pfn then shouldn't it 
> > also return a dma_addr_t, since as you pointed out in the commit message, 
> > dma_addr_t might be bigger than an unsigned long?
> > 
> 
> Yes internal it use dma_addr_t but for device driver that want to use
> physical system page address aka pfn i want them to use the specialize
> helper hmm_pte_from_pfn() and hmm_pte_pfn() so type casting happen in
> hmm and it make it easier to review device driver as device driver will
> be consistent ie either it wants to use pfn or it want to use dma_addr_t
> but not mix the 2.
> 
> A latter patch add the hmm_pte_from_dma() and hmm_pte_dma_addr() helper
> for the dma case. So this patch only introduce the pfn version.

So the only reason for hmm_pde_from_pfn to take in a dma_addr_t is to 
avoid an (unsigned long) cast at the call sites?


> > > [...]
> > > +/* struct hmm_pt_iter - page table iterator states.
> > > + *
> > > + * @ptd: Array of directory struct page pointer for each levels.
> > > + * @ptdp: Array of pointer to mapped directory levels.
> > > + * @dead_directories: List of directories that died while walking page table.
> > > + * @cur: Current address.
> > > + */
> > > +struct hmm_pt_iter {
> > > +	struct page		*ptd[HMM_PT_MAX_LEVEL - 1];
> > > +	dma_addr_t		*ptdp[HMM_PT_MAX_LEVEL - 1];
> > 
> > These are sized to be HMM_PT_MAX_LEVEL - 1 rather than HMM_PT_MAX_LEVEL 
> > because the iterator doesn't store the top level, correct? This results in 
> > a lot of "level - 1" and "level - 2" logic when dealing with the iterator. 
> > Have you considered keeping the levels consistent to get rid of all the 
> > extra offset-by-1 logic?
> 
> All this should be optimized away by the compiler thought i have not
> check the assembly.

I was talking about code readability and maintainability rather than 
performance. It's conceptually simpler to have consistent definitions of 
"level" across both the iterator and the hmm_pt helpers even though the 
iterator doesn't need to access the top level. This would turn "level-1" 
and "level-2" into "level" and "level-1", which I think are simpler to 
follow.


> [...]
> > > +	/*
> > > +	 * Some iterator may have dereferenced a dead directory entry and looked
> > > +	 * up the struct page but haven't check yet the reference count. As all
> > > +	 * the above happen in rcu read critical section we know that we need
> > > +	 * to wait for grace period before being able to free any of the dead
> > > +	 * directory page.
> > > +	 */
> > > +	synchronize_rcu();
> > > +	list_for_each_entry_safe(ptd, tmp, &iter->dead_directories, lru) {
> > > +		list_del(&ptd->lru);
> > > +		atomic_set(&ptd->_mapcount, -1);
> > > +		__free_page(ptd);
> > > +	}
> > > +}
> > 
> > If I'm following this correctly, a migrate to the device will allocate HMM 
> > page tables and the subsequent migrate from the device will free them. 
> > Assuming that's the case, might thrashing of page allocations be a 
> > problem? What about keeping the HMM page tables around until the actual 
> > munmap() of the corresponding VA range?
> 
> HMM page table is allocate anytime a device mirror a range ie migration to
> device is not a special case. When migrating to and from device, the HMM
> page table is allocated prior to the migration and outlive the migration
> back.
> 
> That said the rational here is that i want to free HMM resources as early as
> possible mostly to support the use GPU on dataset onetime (ie dataset is use
> once and only once by the GPU). I think it will be a common and important use
> case and making sure we free resource early does not prevent other use case
> where dataset are use for longer time to work properly and efficiently.
> 
> In a latter patch i add an helper so that device driver can discard a range
> ie tell HMM that they no longer using a range of address allowing HMM to
> free associated resources.
> 
> However you are correct that currently some MM event will lead to HMM page
> table being free and then reallocated right after once again by the device.
> Which is obviously bad. But because i did not want to make this patch or
> this serie any more complex than it already is i did not include any mecanism
> to delay HMM page table directory reclaim. Such delayed reclaim mecanism is
> on my road map and i think i shared that roadmap with you. I think it is
> something we can optimize latter on. The important part here is that device
> driver knows that HMM page table need to be carefully accessed so that when
> agressive pruning of HMM page table happens it does not disrupt the device
> driver.

Ok, works for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
