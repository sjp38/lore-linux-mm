Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A137F6B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 21:59:01 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so194582071pfg.0
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 18:59:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q8si53260997pgf.282.2016.11.27.18.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 18:59:00 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAS2wirQ145115
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 21:58:59 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2707u48mu3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 21:58:59 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 28 Nov 2016 12:58:57 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 11BF02CE8054
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:58:52 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAS2wqdP59768884
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:58:52 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAS2wphm002328
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:58:51 +1100
Subject: Re: [HMM v13 08/18] mm/hmm: heterogeneous memory management (HMM for
 short)
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-9-git-send-email-jglisse@redhat.com>
 <58351517.2060405@linux.vnet.ibm.com> <20161127131043.GA3710@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 28 Nov 2016 08:28:44 +0530
MIME-Version: 1.0
In-Reply-To: <20161127131043.GA3710@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <583B9D64.7020005@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 11/27/2016 06:40 PM, Jerome Glisse wrote:
> On Wed, Nov 23, 2016 at 09:33:35AM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> 
> [...]
> 
>>> + *
>>> + *      hmm_vma_migrate(vma, start, end, ops);
>>> + *
>>> + * With ops struct providing 2 callback alloc_and_copy() which allocated the
>>> + * destination memory and initialize it using source memory. Migration can fail
>>> + * after this step and thus last callback finalize_and_map() allow the device
>>> + * driver to know which page were successfully migrated and which were not.
>>
>> So we have page->pgmap->free_devpage() to release the individual page back
>> into the device driver management during migration and also we have this ops
>> based finalize_and_mmap() to check on the failed instances inside a single
>> migration context which can contain set of pages at a time.
>>
>>> + *
>>> + * This can easily be use outside of HMM intended use case.
>>
>> Where you think this can be used outside of HMM ?
> 
> Well on the radar is new memory hierarchy that seems to be on every CPU designer
> roadmap. Where you have a fast small HBM like memory package with the CPU and then
> you have the regular memory.
> 
> In the embedded world they want to migrate active process to fast CPU memory and
> shutdown the regular memory to save power.
> 
> In the HPC world they want to migrate hot data of hot process to this fast memory.
> 
> In both case we are talking about process base memory migration and in case of
> embedded they also have DMA engine they can use to offload the copy operation
> itself.
> 
> This are the useful case i have in mind but other people might see that code and
> realise they could also use it for their own specific corner case.

If there are plans for HBM or specialized type of memory which will be
packaged inside the CPU (without any other device accessing it like in
the case of GPU or Network Card), then I think in that case using HMM
is not ideal. CPU will be the only thing accessing this memory and
there is never going to be any other device or context which can access
this outside of CPU. Hence role of a device driver is redundant, it
should be initialized and used as a basic platform component.

In that case what we need is a core VM managed memory with certain kind
of restrictions around the allocation and a way of explicit allocation
into it if required. Representing these memory like a cpu less restrictive
coherent device memory node is a better solution IMHO. These RFCs what I
have posted regarding CDM representation are efforts in this direction.

[RFC Specialized Zonelists]    https://lkml.org/lkml/2016/10/24/19
[RFC Restrictive mems_allowed] https://lkml.org/lkml/2016/11/22/339

I believe both HMM and CDM have their own use cases and will complement
each other.

> 
> [...]
> 
>>> +/*
>>> + * hmm_pfn_t - HMM use its own pfn type to keep several flags per page
>>> + *
>>> + * Flags:
>>> + * HMM_PFN_VALID: pfn is valid
>>> + * HMM_PFN_WRITE: CPU page table have the write permission set
>>> + */
>>> +typedef unsigned long hmm_pfn_t;
>>> +
>>> +#define HMM_PFN_VALID (1 << 0)
>>> +#define HMM_PFN_WRITE (1 << 1)
>>> +#define HMM_PFN_SHIFT 2
>>> +
>>> +static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
>>> +{
>>> +	if (!(pfn & HMM_PFN_VALID))
>>> +		return NULL;
>>> +	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
>>> +}
>>> +
>>> +static inline unsigned long hmm_pfn_to_pfn(hmm_pfn_t pfn)
>>> +{
>>> +	if (!(pfn & HMM_PFN_VALID))
>>> +		return -1UL;
>>> +	return (pfn >> HMM_PFN_SHIFT);
>>> +}
>>> +
>>> +static inline hmm_pfn_t hmm_pfn_from_page(struct page *page)
>>> +{
>>> +	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
>>> +}
>>> +
>>> +static inline hmm_pfn_t hmm_pfn_from_pfn(unsigned long pfn)
>>> +{
>>> +	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
>>> +}
>>
>> Hmm, so if we use last two bits on PFN as flags, it does reduce the number of
>> bits available for the actual PFN range. But given that we support maximum of
>> 64TB on POWER (not sure about X86) we can live with this two bits going away
>> from the unsigned long. But what is the purpose of tracking validity and write
>> flag inside the PFN ?
> 
> So 2^46 so with 12bits PAGE_SHIFT we only need 34 bits for pfns value hence i
> should have enough place for my flag or is unsigned long not 64bits on powerpc ?

Yeah it is 64 bits on POWER, we use 12 bits of PAGE_SHIFT for 4K
pages and 16 bits of PAGE_SHIFT for 64K pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
