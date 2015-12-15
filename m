Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C44126B0255
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 18:28:13 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e66so1642554pfe.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 15:28:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ti16si4715130pac.192.2015.12.15.15.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 15:28:12 -0800 (PST)
Date: Tue, 15 Dec 2015 15:28:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH v2 11/25] x86, mm: introduce vmem_altmap to augment
 vmemmap_populate()
Message-Id: <20151215152811.e6e114f76920a75f084694f3@linux-foundation.org>
In-Reply-To: <20151210023812.30368.84734.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023812.30368.84734.stgit@dwillia2-desk3.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm@ml01.01.org, x86@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, 09 Dec 2015 18:38:12 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> In support of providing struct page for large persistent memory
> capacities, use struct vmem_altmap to change the default policy for
> allocating memory for the memmap array.  The default vmemmap_populate()
> allocates page table storage area from the page allocator.  Given
> persistent memory capacities relative to DRAM it may not be feasible to
> store the memmap in 'System Memory'.  Instead vmem_altmap represents
> pre-allocated "device pages" to satisfy vmemmap_alloc_block_buf()
> requests.
> 
> ...
>
>  include/linux/mm.h              |   92 +++++++++++++++++++++++++++++++++++++--

mm.h is getting ridiculously huge and these additions look to be fairly
standalone.  Perhaps you could take a look at creating a vmem_altmap.h
sometime if feeling bored?

> +
> +/**
> + * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
> + * @altmap - reserved page pool for the allocation
> + * @nr_pfns - size (in pages) of the allocation
> + *
> + * Allocations are aligned to the size of the request
> + */
> +static inline unsigned long vmem_altmap_alloc(struct vmem_altmap *altmap,
> +		unsigned long nr_pfns)
> +{
> +	unsigned long pfn = vmem_altmap_next_pfn(altmap);
> +	unsigned long nr_align;
> +
> +	nr_align = 1UL << find_first_bit(&nr_pfns, BITS_PER_LONG);
> +	nr_align = ALIGN(pfn, nr_align) - pfn;
> +
> +	if (nr_pfns + nr_align > vmem_altmap_nr_free(altmap))
> +		return ULONG_MAX;
> +	altmap->alloc += nr_pfns;
> +	altmap->align += nr_align;
> +	return pfn + nr_align;
> +}

This look pretty large for an inline.  But it has only one callsite so
it doesn't matter.  But if it only has one callsite, why is it in .h?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
