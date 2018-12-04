Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 497856B6DF7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:24:35 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id h68so16214890qke.3
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:24:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si2428622qtq.248.2018.12.04.01.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:24:34 -0800 (PST)
Subject: Re: [PATCH v4 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
References: <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181204085657.20472-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <3be585a2-7d01-82e8-3c4c-a746077298fe@redhat.com>
Date: Tue, 4 Dec 2018 10:24:31 +0100
MIME-Version: 1.0
In-Reply-To: <20181204085657.20472-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On 04.12.18 09:56, Wei Yang wrote:
> pgdat_resize_lock is used to protect pgdat's memory region information
> like: node_start_pfn, node_present_pages, etc. While in function
> sparse_add/remove_one_section(), pgdat_resize_lock is used to protect
> initialization/release of one mem_section. This looks not proper.
> 
> These code paths are currently protected by mem_hotplug_lock currently
> but should there ever be any reason for locking at the sparse layer a
> dedicated lock should be introduced.
> 
> Following is the current call trace of sparse_add/remove_one_section()
> 
>     mem_hotplug_begin()
>     arch_add_memory()
>        add_pages()
>            __add_pages()
>                __add_section()
>                    sparse_add_one_section()
>     mem_hotplug_done()
> 
>     mem_hotplug_begin()
>     arch_remove_memory()
>         __remove_pages()
>             __remove_section()
>                 sparse_remove_one_section()
>     mem_hotplug_done()
> 
> The comment above the pgdat_resize_lock also mentions "Holding this will
> also guarantee that any pfn_valid() stays that way.", which is true with
> the current implementation and false after this patch. But current
> implementation doesn't meet this comment. There isn't any pfn walkers
> to take the lock so this looks like a relict from the past. This patch
> also removes this comment.
> 
> [Michal: changelog suggestion]
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> ---
> v4:
>    * fix typo in changelog
>    * adjust second paragraph of changelog
> v3:
>    * adjust the changelog with the reason for this change
>    * remove a comment for pgdat_resize_lock
>    * separate the prototype change of sparse_add_one_section() to
>      another one
> v2:
>    * adjust changelog to show this procedure is serialized by global
>      mem_hotplug_lock
> ---
>  include/linux/mmzone.h | 2 --
>  mm/sparse.c            | 9 +--------
>  2 files changed, 1 insertion(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d76177cb8436..be126113b499 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -639,8 +639,6 @@ typedef struct pglist_data {
>  	/*
>  	 * Must be held any time you expect node_start_pfn,
>  	 * node_present_pages, node_spanned_pages or nr_zones stay constant.
> -	 * Holding this will also guarantee that any pfn_valid() stays that
> -	 * way.
>  	 *
>  	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
>  	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 33307fc05c4d..5825f276485f 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -669,7 +669,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  	struct mem_section *ms;
>  	struct page *memmap;
>  	unsigned long *usemap;
> -	unsigned long flags;
>  	int ret;
>  
>  	/*
> @@ -689,8 +688,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  		return -ENOMEM;
>  	}
>  
> -	pgdat_resize_lock(pgdat, &flags);
> -
>  	ms = __pfn_to_section(start_pfn);
>  	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
>  		ret = -EEXIST;
> @@ -707,7 +704,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
>  out:
> -	pgdat_resize_unlock(pgdat, &flags);
>  	if (ret < 0) {
>  		kfree(usemap);
>  		__kfree_section_memmap(memmap, altmap);
> @@ -769,10 +765,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap)
>  {
>  	struct page *memmap = NULL;
> -	unsigned long *usemap = NULL, flags;
> -	struct pglist_data *pgdat = zone->zone_pgdat;
> +	unsigned long *usemap = NULL;
>  
> -	pgdat_resize_lock(pgdat, &flags);
>  	if (ms->section_mem_map) {
>  		usemap = ms->pageblock_flags;
>  		memmap = sparse_decode_mem_map(ms->section_mem_map,
> @@ -780,7 +774,6 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		ms->section_mem_map = 0;
>  		ms->pageblock_flags = NULL;
>  	}
> -	pgdat_resize_unlock(pgdat, &flags);
>  
>  	clear_hwpoisoned_pages(memmap + map_offset,
>  			PAGES_PER_SECTION - map_offset);
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
