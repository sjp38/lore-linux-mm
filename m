Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB6916B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:46:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 47-v6so5275740wru.19
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:46:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si1965541eda.386.2018.04.19.06.46.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 06:46:43 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 08/14] mm: Combine first three unions in struct page
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-9-willy@infradead.org>
Message-ID: <72eecf42-202e-0c6f-06bc-9c5c07814e24@suse.cz>
Date: Thu, 19 Apr 2018 15:46:42 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-9-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> By combining these three one-word unions into one three-word union,
> we make it easier for users to add their own multi-word fields to struct
> page, as well as making it obvious that SLUB needs to keep its double-word
> alignment for its freelist & counters.
> 
> No field moves position; verified with pahole.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 65 ++++++++++++++++++++--------------------
>  1 file changed, 32 insertions(+), 33 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 04d9dc442029..39521b8385c1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -70,45 +70,44 @@ struct hmm;
>  #endif
>  
>  struct page {
> -	/* First double word block */
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
> -	union {
> -		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
> -		struct address_space *mapping;
> -
> -		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> +	union {		/* This union is three words (12/24 bytes) in size */
> +		struct {	/* Page cache and anonymous pages */
> +			/* See page-flags.h for PAGE_MAPPING_FLAGS */
> +			struct address_space *mapping;
> +			pgoff_t index;		/* Our offset within mapping. */
> +			/**
> +			 * @private: Mapping-private opaque data.
> +			 * Usually used for buffer_heads if PagePrivate.
> +			 * Used for swp_entry_t if PageSwapCache.
> +			 * Indicates order in the buddy system if PageBuddy.
> +			 */
> +			unsigned long private;
> +		};
> +		struct {	/* slab and slob */
> +			struct kmem_cache *slab_cache;
> +			void *freelist;		/* first free object */
> +			void *s_mem;		/* first object */
> +		};
> +		struct {	/* slub also uses some of the slab fields */
> +			struct kmem_cache *slub_cache;
> +			/* Double-word boundary */
> +			void *slub_freelist;

Is slub going to switch to use those? Or maybe this is an overkill and
we could merge the two sl*b structs and just have an union for s_mem and
the 3 counters?

> +			unsigned inuse:16;
> +			unsigned objects:15;
> +			unsigned frozen:1;
> +		};
