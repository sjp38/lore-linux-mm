Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 647CD6B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 08:23:18 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 62so5989056wrg.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 05:23:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si14149630wml.166.2018.02.19.05.23.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 05:23:16 -0800 (PST)
Date: Mon, 19 Feb 2018 14:23:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 4/6] mm/memory_hotplug: optimize probe routine
Message-ID: <20180219132313.GK21134@dhcp22.suse.cz>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-5-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-5-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Thu 15-02-18 11:59:18, Pavel Tatashin wrote:
> When memory is hotplugged pages_correctly_reserved() is called to verify
> that the added memory is present, this routine traverses through every
> struct page and verifies that PageReserved() is set. This is a slow
> operation especially if a large amount of memory is added.
> 
> Instead of checking every page, it is enough to simply check that the
> section is present, has mapping (struct page array is allocated), and the
> mapping is online.
> 
> In addition, we should not excpect that probe routine sets flags in struct
> page, as the struct pages have not yet been initialized. The initialization
> should be done in __init_single_page(), the same as during boot.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  drivers/base/memory.c | 36 ++++++++++++++++++++----------------
>  1 file changed, 20 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index fe4b24f05f6a..deb3f029b451 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -187,13 +187,14 @@ int memory_isolate_notify(unsigned long val, void *v)
>  }
>  
>  /*
> - * The probe routines leave the pages reserved, just as the bootmem code does.
> - * Make sure they're still that way.
> + * The probe routines leave the pages uninitialized, just as the bootmem code
> + * does. Make sure we do not access them, but instead use only information from
> + * within sections.
>   */
> -static bool pages_correctly_reserved(unsigned long start_pfn)
> +static bool pages_correctly_probed(unsigned long start_pfn)
>  {
> -	int i, j;
> -	struct page *page;
> +	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +	unsigned long section_nr_end = section_nr + sections_per_block;
>  	unsigned long pfn = start_pfn;
>  
>  	/*
> @@ -201,21 +202,24 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
>  	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
>  	 * and assume memmap is contiguous within each section
>  	 */
> -	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
> +	for (; section_nr < section_nr_end; section_nr++) {
>  		if (WARN_ON_ONCE(!pfn_valid(pfn)))
>  			return false;
> -		page = pfn_to_page(pfn);
> -
> -		for (j = 0; j < PAGES_PER_SECTION; j++) {
> -			if (PageReserved(page + j))
> -				continue;
> -
> -			printk(KERN_WARNING "section number %ld page number %d "
> -				"not reserved, was it already online?\n",
> -				pfn_to_section_nr(pfn), j);
>  
> +		if (!present_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) not present",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
> +			return false;
> +		} else if (!valid_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
> +			return false;
> +		} else if (online_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) is already online",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
>  			return false;
>  		}
> +		pfn += PAGES_PER_SECTION;
>  	}
>  
>  	return true;
> @@ -237,7 +241,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>  
>  	switch (action) {
>  	case MEM_ONLINE:
> -		if (!pages_correctly_reserved(start_pfn))
> +		if (!pages_correctly_probed(start_pfn))
>  			return -EBUSY;
>  
>  		ret = online_pages(start_pfn, nr_pages, online_type);
> -- 
> 2.16.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
