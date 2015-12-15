Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id C72A56B0257
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:37:20 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id 103so21308750qgi.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:37:20 -0800 (PST)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id c92si3501585qgc.107.2015.12.15.15.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 15:37:19 -0800 (PST)
Received: by mail-qk0-x230.google.com with SMTP id k189so39575970qkc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:37:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151215152811.e6e114f76920a75f084694f3@linux-foundation.org>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023812.30368.84734.stgit@dwillia2-desk3.jf.intel.com>
	<20151215152811.e6e114f76920a75f084694f3@linux-foundation.org>
Date: Tue, 15 Dec 2015 15:37:19 -0800
Message-ID: <CAPcyv4g-76NVwdX0dSXySAFLzJM1_0LzDhGaWOs1synquzDyEQ@mail.gmail.com>
Subject: Re: [-mm PATCH v2 11/25] x86, mm: introduce vmem_altmap to augment vmemmap_populate()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Dec 15, 2015 at 3:28 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 09 Dec 2015 18:38:12 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> In support of providing struct page for large persistent memory
>> capacities, use struct vmem_altmap to change the default policy for
>> allocating memory for the memmap array.  The default vmemmap_populate()
>> allocates page table storage area from the page allocator.  Given
>> persistent memory capacities relative to DRAM it may not be feasible to
>> store the memmap in 'System Memory'.  Instead vmem_altmap represents
>> pre-allocated "device pages" to satisfy vmemmap_alloc_block_buf()
>> requests.
>>
>> ...
>>
>>  include/linux/mm.h              |   92 +++++++++++++++++++++++++++++++++++++--
>
> mm.h is getting ridiculously huge and these additions look to be fairly
> standalone.  Perhaps you could take a look at creating a vmem_altmap.h
> sometime if feeling bored?
>

Will do, and the pfn_t inlines can also move out.

>> +
>> +/**
>> + * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
>> + * @altmap - reserved page pool for the allocation
>> + * @nr_pfns - size (in pages) of the allocation
>> + *
>> + * Allocations are aligned to the size of the request
>> + */
>> +static inline unsigned long vmem_altmap_alloc(struct vmem_altmap *altmap,
>> +             unsigned long nr_pfns)
>> +{
>> +     unsigned long pfn = vmem_altmap_next_pfn(altmap);
>> +     unsigned long nr_align;
>> +
>> +     nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
>> +     nr_align = ALIGN(pfn, nr_align) - pfn;
>> +
>> +     if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
>> +             return ULONG_MAX;
>> +     altmap->alloc += nr_pfns;
>> +     altmap->align += nr_align;
>> +     return pfn + nr_align;
>> +}
>
> This look pretty large for an inline.  But it has only one callsite so
> it doesn't matter.  But if it only has one callsite, why is it in .h?

I'll move it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
