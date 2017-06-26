Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1326B6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 03:50:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u36so107660931pgn.5
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:50:17 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id m6si8547600pga.243.2017.06.26.00.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 00:50:16 -0700 (PDT)
Subject: Re: [RFC PATCH 3/4] mm/hotplug: make __add_pages() iterate on
 memory_block and split __add_section()
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-4-richard.weiyang@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <559864c6-6ad6-297a-3094-8abecbd251b9@nvidia.com>
Date: Mon, 26 Jun 2017 00:50:14 -0700
MIME-Version: 1.0
In-Reply-To: <20170625025227.45665-4-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

On 06/24/2017 07:52 PM, Wei Yang wrote:
> Memory hotplug unit is memory_block which contains one or several
> mem_section. The current logic is iterating on each mem_section and add or
> adjust the memory_block every time.
> 
> This patch makes the __add_pages() iterate on memory_block and split
> __add_section() to two functions: __add_section() and __add_memory_block().
> 
> The first one would take care of each section data and the second one would
> register the memory_block at once, which makes the function more clear and
> natural.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  drivers/base/memory.c | 17 +++++------------
>  mm/memory_hotplug.c   | 27 +++++++++++++++++----------
>  2 files changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index b54cfe9cd98b..468e5ad1bc87 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -705,19 +705,12 @@ int register_new_memory(int nid, struct mem_section *section)
>  
>  	mutex_lock(&mem_sysfs_mutex);
>  
> -	mem = find_memory_block(section);
> -	if (mem) {
> -		mem->section_count++;
> -		put_device(&mem->dev);
> -	} else {
> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
> -		if (ret)
> -			goto out;
> -		mem->section_count++;
> -	}
> +	ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +	if (ret)
> +		goto out;
> +	mem->section_count = sections_per_block;

Hi Wei,

Things have changed...the register_new_memory() routine is accepting a single section,
but instead of registering just that section, it is registering a containing block.
(That works, because apparently the approach is to make sections_per_block == 1,
and eventually kill sections, if I am reading all this correctly.)

So, how about this: let's add a line to the function comment: 

* Register an entire memory_block.

That makes it clearer that we're dealing in blocks, even though the memsection*
argument is passed in.

>  
> -	if (mem->section_count == sections_per_block)
> -		ret = register_mem_sect_under_node(mem, nid);
> +	ret = register_mem_sect_under_node(mem, nid);
>  out:
>  	mutex_unlock(&mem_sysfs_mutex);
>  	return ret;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a79a83ec965f..14a08b980b59 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -302,8 +302,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>  }
>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>  
> -static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> -		bool want_memblock)
> +static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
>  {
>  	int ret;
>  	int i;
> @@ -332,6 +331,18 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  		SetPageReserved(page);
>  	}
>  
> +	return 0;
> +}
> +
> +static int __meminit __add_memory_block(int nid, unsigned long phys_start_pfn,
> +		bool want_memblock)
> +{
> +	int ret;
> +
> +	ret = __add_section(nid, phys_start_pfn);
> +	if (ret)
> +		return ret;
> +
>  	if (!want_memblock)
>  		return 0;
>  
> @@ -347,15 +358,10 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  			unsigned long nr_pages, bool want_memblock)
>  {
> -	unsigned long i;
> +	unsigned long pfn;
>  	int err = 0;
> -	int start_sec, end_sec;
>  	struct vmem_altmap *altmap;
>  
> -	/* during initialize mem_map, align hot-added range to section */
> -	start_sec = pfn_to_section_nr(phys_start_pfn);
> -	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> -
>  	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
>  	if (altmap) {
>  		/*
> @@ -370,8 +376,9 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  		altmap->alloc = 0;
>  	}
>  
> -	for (i = start_sec; i <= end_sec; i++) {
> -		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
> +	for (pfn; pfn < phys_start_pfn + nr_pages;
> +			pfn += sections_per_block * PAGES_PER_SECTION) {

A pages_per_block variable would be nice here, too.

thanks,
john h

> +		err = __add_memory_block(nid, pfn, want_memblock);
>  
>  		/*
>  		 * EEXIST is finally dealt with by ioresource collision
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
