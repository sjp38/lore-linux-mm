Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 042D56B0010
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:25:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f13-v6so6314643qtg.15
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:25:17 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id e72si5220235qkj.235.2018.04.20.08.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 08:25:16 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:25:14 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 05/14] mm: Move 'private' union within struct page
In-Reply-To: <20180418184912.2851-6-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1804201024090.18006@nuc-kabylake>
References: <20180418184912.2851-1-willy@infradead.org> <20180418184912.2851-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 18 Apr 2018, Matthew Wilcox wrote:

> @@ -95,6 +89,30 @@ struct page {
>  		/* page_deferred_list().prev	-- second tail page */
>  	};
>
> +	union {
> +		/*
> +		 * Mapping-private opaque data:
> +		 * Usually used for buffer_heads if PagePrivate
> +		 * Used for swp_entry_t if PageSwapCache
> +		 * Indicates order in the buddy system if PageBuddy
> +		 */
> +		unsigned long private;
> +#if USE_SPLIT_PTE_PTLOCKS
> +#if ALLOC_SPLIT_PTLOCKS
> +		spinlock_t *ptl;
> +#else
> +		spinlock_t ptl;

^^^^ This used to be defined at the end of the struct so that you could
have larger structs for spinlocks here (debugging and some such thing).

Could this not misalign the rest?


> +#endif
> +#endif
> +		void *s_mem;			/* slab first object */
> +		unsigned long counters;		/* SLUB */
> +		struct {			/* SLUB */
> +			unsigned inuse:16;
> +			unsigned objects:15;
> +			unsigned frozen:1;
> +		};
> +	};
> +
>  	union {
