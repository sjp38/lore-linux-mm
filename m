Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6528D6B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 08:10:53 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id x190so91413209qkb.5
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 05:10:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e70si29804927qkh.139.2016.11.27.05.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 05:10:52 -0800 (PST)
Date: Sun, 27 Nov 2016 08:10:44 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 08/18] mm/hmm: heterogeneous memory management (HMM for
 short)
Message-ID: <20161127131043.GA3710@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-9-git-send-email-jglisse@redhat.com>
 <58351517.2060405@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <58351517.2060405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed, Nov 23, 2016 at 09:33:35AM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:

[...]

> > + *
> > + *      hmm_vma_migrate(vma, start, end, ops);
> > + *
> > + * With ops struct providing 2 callback alloc_and_copy() which allocated the
> > + * destination memory and initialize it using source memory. Migration can fail
> > + * after this step and thus last callback finalize_and_map() allow the device
> > + * driver to know which page were successfully migrated and which were not.
> 
> So we have page->pgmap->free_devpage() to release the individual page back
> into the device driver management during migration and also we have this ops
> based finalize_and_mmap() to check on the failed instances inside a single
> migration context which can contain set of pages at a time.
> 
> > + *
> > + * This can easily be use outside of HMM intended use case.
> 
> Where you think this can be used outside of HMM ?

Well on the radar is new memory hierarchy that seems to be on every CPU designer
roadmap. Where you have a fast small HBM like memory package with the CPU and then
you have the regular memory.

In the embedded world they want to migrate active process to fast CPU memory and
shutdown the regular memory to save power.

In the HPC world they want to migrate hot data of hot process to this fast memory.

In both case we are talking about process base memory migration and in case of
embedded they also have DMA engine they can use to offload the copy operation
itself.

This are the useful case i have in mind but other people might see that code and
realise they could also use it for their own specific corner case.

[...]

> > +/*
> > + * hmm_pfn_t - HMM use its own pfn type to keep several flags per page
> > + *
> > + * Flags:
> > + * HMM_PFN_VALID: pfn is valid
> > + * HMM_PFN_WRITE: CPU page table have the write permission set
> > + */
> > +typedef unsigned long hmm_pfn_t;
> > +
> > +#define HMM_PFN_VALID (1 << 0)
> > +#define HMM_PFN_WRITE (1 << 1)
> > +#define HMM_PFN_SHIFT 2
> > +
> > +static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
> > +{
> > +	if (!(pfn & HMM_PFN_VALID))
> > +		return NULL;
> > +	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
> > +}
> > +
> > +static inline unsigned long hmm_pfn_to_pfn(hmm_pfn_t pfn)
> > +{
> > +	if (!(pfn & HMM_PFN_VALID))
> > +		return -1UL;
> > +	return (pfn >> HMM_PFN_SHIFT);
> > +}
> > +
> > +static inline hmm_pfn_t hmm_pfn_from_page(struct page *page)
> > +{
> > +	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> > +}
> > +
> > +static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
> > +{
> > +	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> > +}
> 
> Hmm, so if we use last two bits on PFN as flags, it does reduce the number of
> bits available for the actual PFN range. But given that we support maximum of
> 64TB on POWER (not sure about X86) we can live with this two bits going away
> from the unsigned long. But what is the purpose of tracking validity and write
> flag inside the PFN ?

So 2^46 so with 12bits PAGE_SHIFT we only need 34 bits for pfns value hence i
should have enough place for my flag or is unsigned long not 64bits on powerpc ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
