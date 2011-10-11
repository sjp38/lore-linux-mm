Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47E4E6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 00:26:15 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9B4Q6vp020483
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 21:26:11 -0700
Received: from qap1 (qap1.prod.google.com [10.224.4.1])
	by wpaz29.hot.corp.google.com with ESMTP id p9B4M4mi006953
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 21:26:05 -0700
Received: by qap1 with SMTP id 1so11852109qap.0
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 21:26:03 -0700 (PDT)
Date: Mon, 10 Oct 2011 21:26:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly reserved
 on a per-section basis
In-Reply-To: <20111010164152.5485fbaf.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1110102125040.12035@chino.kir.corp.google.com>
References: <20111010071119.GE6418@suse.de> <20111010150038.ac161977.akpm@linux-foundation.org> <20111010232403.GA30513@kroah.com> <20111010162813.7a470ae4.akpm@linux-foundation.org> <20111010233531.GA7234@kroah.com>
 <20111010164152.5485fbaf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Greg KH <greg@kroah.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 10 Oct 2011, Andrew Morton wrote:

> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 2840ed4..ffb69cd 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -224,13 +224,48 @@ int memory_isolate_notify(unsigned long val, void *v)
>  }
>  
>  /*
> + * The probe routines leave the pages reserved, just as the bootmem code does.
> + * Make sure they're still that way.
> + */
> +static bool pages_correctly_reserved(unsigned long start_pfn,
> +					unsigned long nr_pages)
> +{
> +	int i, j;
> +	struct page *page;
> +	unsigned long pfn = start_pfn;
> +
> +	/*
> +	 * memmap between sections is not contiguous except with
> +	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
> +	 * and assume memmap is contiguous within each section
> +	 */
> +	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
> +		if (WARN_ON_ONCE(!pfn_valid(pfn)))
> +			return false;
> +		page = pfn_to_page(pfn);
> +
> +		for (j = 0; j < PAGES_PER_SECTION; j++) {
> +			if (PageReserved(page + i))

page + j

> +				continue;
> +
> +			printk(KERN_WARNING "section number %ld page number %d "
> +				"not reserved, was it already online?\n",
> +				pfn_to_section_nr(pfn), j);
> +
> +			return false;
> +		}
> +	}
> +
> +	return true;
> +}
> +
> +/*
>   * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
>   * OK to have direct references to sparsemem variables in here.
>   */
>  static int
>  memory_block_action(unsigned long phys_index, unsigned long action)
>  {
> -	int i;
>  	unsigned long start_pfn, start_paddr;
>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>  	struct page *first_page;
> @@ -238,26 +273,13 @@ memory_block_action(unsigned long phys_index, unsigned long action)
>  
>  	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
>  
> -	/*
> -	 * The probe routines leave the pages reserved, just
> -	 * as the bootmem code does.  Make sure they're still
> -	 * that way.
> -	 */
> -	if (action == MEM_ONLINE) {
> -		for (i = 0; i < nr_pages; i++) {
> -			if (PageReserved(first_page+i))
> -				continue;
> -
> -			printk(KERN_WARNING "section number %ld page number %d "
> -				"not reserved, was it already online?\n",
> -				phys_index, i);
> -			return -EBUSY;
> -		}
> -	}
> -
>  	switch (action) {
>  		case MEM_ONLINE:
>  			start_pfn = page_to_pfn(first_page);
> +
> +			if (!pages_correctly_reserved(start_pfn, nr_pages))
> +				return -EBUSY;
> +
>  			ret = online_pages(start_pfn, nr_pages);
>  			break;
>  		case MEM_OFFLINE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
