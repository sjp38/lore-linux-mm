Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A36606B5365
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 11:01:55 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so2146399qtk.6
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 08:01:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x2si1588895qta.285.2018.11.29.08.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 08:01:54 -0800 (PST)
Subject: Re: [PATCH v3 2/2] mm, sparse: pass nid instead of pgdat to
 sparse_add_one_section()
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181129155316.8174-2-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7acfdb10-9e4e-a766-fb6f-08c575887167@redhat.com>
Date: Thu, 29 Nov 2018 17:01:51 +0100
MIME-Version: 1.0
In-Reply-To: <20181129155316.8174-2-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On 29.11.18 16:53, Wei Yang wrote:
> Since the information needed in sparse_add_one_section() is node id to
> allocate proper memory, it is not necessary to pass its pgdat.
> 
> This patch changes the prototype of sparse_add_one_section() to pass
> node id directly. This is intended to reduce misleading that
> sparse_add_one_section() would touch pgdat.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/memory_hotplug.h | 2 +-
>  mm/memory_hotplug.c            | 2 +-
>  mm/sparse.c                    | 6 +++---
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 45a5affcab8a..3787d4e913e6 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -333,7 +333,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int sparse_add_one_section(struct pglist_data *pgdat,
> +extern int sparse_add_one_section(int nid,
>  		unsigned long start_pfn, struct vmem_altmap *altmap);

While you touch that, can you fixup the alignment of the other parameters?

Apart from that

Reviewed-by: David Hildenbrand <david@redhat.com>

>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f626e7e5f57b..5b3a3d7b4466 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -253,7 +253,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  	if (pfn_valid(phys_start_pfn))
>  		return -EEXIST;
>  
> -	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
> +	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
>  	if (ret < 0)
>  		return ret;
>  
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 5825f276485f..2472bf23278a 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -662,7 +662,7 @@ static void free_map_bootmem(struct page *memmap)
>   * set.  If this is <=0, then that means that the passed-in
>   * map was not consumed and must be freed.
>   */
> -int __meminit sparse_add_one_section(struct pglist_data *pgdat,
> +int __meminit sparse_add_one_section(int nid,
>  		unsigned long start_pfn, struct vmem_altmap *altmap)
>  {
>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> @@ -675,11 +675,11 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  	 * no locking for this, because it does its own
>  	 * plus, it does a kmalloc
>  	 */
> -	ret = sparse_index_init(section_nr, pgdat->node_id);
> +	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;
>  	ret = 0;
> -	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
>  	if (!memmap)
>  		return -ENOMEM;
>  	usemap = __kmalloc_section_usemap();
> 


-- 

Thanks,

David / dhildenb
