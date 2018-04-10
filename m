Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD6A6B002E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:45:40 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t4-v6so9456501plo.9
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:45:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n11-v6si2615431plg.565.2018.04.10.05.45.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 05:45:39 -0700 (PDT)
Subject: Re: [RFC] Group struct page elements
References: <20180408142334.GA29357@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c4b33ef9-26ad-5a55-6c9a-be91180e8838@suse.cz>
Date: Tue, 10 Apr 2018 14:45:31 +0200
MIME-Version: 1.0
In-Reply-To: <20180408142334.GA29357@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On 04/08/2018 04:23 PM, Matthew Wilcox wrote:
> 
> Please let me know if this way of expressing the layout of struct page
> makes more sense to you.  I'm trying to make it easier for other users
> to use some of the space in struct page, and without knowing the VM well,
> it's hard to know what fields you can safely overload.

I like this approach! Tried going all the way and do it for all
doublewords? Or why did you leave the third one unchanged? The _refcount
seems misplaced there in a struct with _mapcount btw, it's not page
cache specific.

> ---
> 
> One of the confusing things about trying to use struct page is knowing
> which fields are already in use by what.  Try and bring some order to
> this by grouping the various fields together into sub-structs.  Verified
> that the layout does not change with pahole.

BTW, I recommend you get/build a version of pahole that has this commit:
https://git.kernel.org/pub/scm/devel/pahole/pahole.git/commit/?id=2dd87be78bb23c071708c93f5180c4b94844759c

Vlastimil

> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 67 ++++++++++++++++++++++--------------------------
>  1 file changed, 31 insertions(+), 36 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1c5dea402501..97ceec1c6e21 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -78,19 +78,18 @@ struct page {
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
>  	union {
> -		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
> -		struct address_space *mapping;
> -
> -		void *s_mem;			/* slab first object */
> +		struct {			/* Page cache */
> +			/* See page-flags.h for PAGE_MAPPING_FLAGS */
> +			struct address_space *mapping;
> +			pgoff_t index;		/* Our offset within mapping. */
> +		};
> +		struct {			/* slab/slob/slub */
> +			void *s_mem;		/* first object */
> +			/* Second dword boundary */
> +			void *freelist;		/* first free object */
> +		};
>  		atomic_t compound_mapcount;	/* first tail page */
> -		/* page_deferred_list().next	 -- second tail page */
> -	};
> -
> -	/* Second double word */
> -	union {
> -		pgoff_t index;		/* Our offset within mapping. */
> -		void *freelist;		/* sl[aou]b first free object */
> -		/* page_deferred_list().prev	-- second tail page */
> +		struct list_head deferred_list;	/* second tail page */
>  	};
>  
>  	union {
> @@ -132,17 +131,27 @@ struct page {
>  	 * avoid collision and false-positive PageTail().
>  	 */
>  	union {
> -		struct list_head lru;	/* Pageout list, eg. active_list
> -					 * protected by zone_lru_lock !
> -					 * Can be used as a generic list
> -					 * by the page owner.
> -					 */
> +		struct {	/* Page cache */
> +			/**
> +			 * @lru: Pageout list, eg. active_list protected by
> +			 * zone_lru_lock.  Can be used as a generic list by
> +			 * the page owner.
> +			 */
> +			struct list_head lru;
> +			/*
> +			 * Mapping-private opaque data:
> +			 * Usually used for buffer_heads if PagePrivate
> +			 * Used for swp_entry_t if PageSwapCache
> +			 * Indicates order in the buddy system if PageBuddy
> +			 */
> +			unsigned long private;
> +		};
>  		struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
>  					    * lru or handled by a slab
>  					    * allocator, this points to the
>  					    * hosting device page map.
>  					    */
> -		struct {		/* slub per cpu partial pages */
> +		struct {			/* slab/slob/slub */
>  			struct page *next;	/* Next partial slab */
>  #ifdef CONFIG_64BIT
>  			int pages;	/* Nr of partial slabs left */
> @@ -151,6 +160,7 @@ struct page {
>  			short int pages;
>  			short int pobjects;
>  #endif
> +			struct kmem_cache *slab_cache;	/* Pointer to slab */
>  		};
>  
>  		struct rcu_head rcu_head;	/* Used by SLAB
> @@ -166,33 +176,18 @@ struct page {
>  			/* two/six bytes available here */
>  		};
>  
> -#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
>  		struct {
>  			unsigned long __pad;	/* do not overlay pmd_huge_pte
>  						 * with compound_head to avoid
>  						 * possible bit 0 collision.
>  						 */
>  			pgtable_t pmd_huge_pte; /* protected by page->ptl */
> -		};
> -#endif
> -	};
> -
> -	union {
> -		/*
> -		 * Mapping-private opaque data:
> -		 * Usually used for buffer_heads if PagePrivate
> -		 * Used for swp_entry_t if PageSwapCache
> -		 * Indicates order in the buddy system if PageBuddy
> -		 */
> -		unsigned long private;
> -#if USE_SPLIT_PTE_PTLOCKS
>  #if ALLOC_SPLIT_PTLOCKS
> -		spinlock_t *ptl;
> +			spinlock_t *ptl;
>  #else
> -		spinlock_t ptl;
> +			spinlock_t ptl;
>  #endif
> -#endif
> -		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> +		};
>  	};
>  
>  #ifdef CONFIG_MEMCG
> 
