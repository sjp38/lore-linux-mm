Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 614656B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:12:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j9-v6so1813973plt.3
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 20:12:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 11-v6si3359923plc.224.2018.10.23.20.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 20:12:23 -0700 (PDT)
Date: Tue, 23 Oct 2018 20:12:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 08/17] prmem: struct page: track vmap_area
Message-ID: <20181024031200.GC25444@bombadil.infradead.org>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-9-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023213504.28905-9-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 24, 2018 at 12:34:55AM +0300, Igor Stoppa wrote:
> The connection between each page and its vmap_area avoids more expensive
> searches through the btree of vmap_areas.

Typo -- it's an rbtree.

> +++ b/include/linux/mm_types.h
> @@ -87,13 +87,24 @@ struct page {
>  			/* See page-flags.h for PAGE_MAPPING_FLAGS */
>  			struct address_space *mapping;
>  			pgoff_t index;		/* Our offset within mapping. */
> -			/**
> -			 * @private: Mapping-private opaque data.
> -			 * Usually used for buffer_heads if PagePrivate.
> -			 * Used for swp_entry_t if PageSwapCache.
> -			 * Indicates order in the buddy system if PageBuddy.
> -			 */
> -			unsigned long private;
> +			union {
> +				/**
> +				 * @private: Mapping-private opaque data.
> +				 * Usually used for buffer_heads if
> +				 * PagePrivate.
> +				 * Used for swp_entry_t if PageSwapCache.
> +				 * Indicates order in the buddy system if
> +				 * PageBuddy.
> +				 */
> +				unsigned long private;
> +				/**
> +				 * @area: reference to the containing area
> +				 * For pages that are mapped into a virtually
> +				 * contiguous area, avoids performing a more
> +				 * expensive lookup.
> +				 */
> +				struct vmap_area *area;
> +			};

Not like this.  Make it part of a different struct in the existing union,
not a part of the pagecache struct.  And there's no need to use ->private
explicitly.

> @@ -1747,6 +1750,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  	if (!addr)
>  		return NULL;
>  
> +	va = __find_vmap_area((unsigned long)addr);
> +	for (i = 0; i < va->vm->nr_pages; i++)
> +		va->vm->pages[i]->area = va;

I don't like it that you're calling this for _every_ vmalloc() caller
when most of them will never use this.  Perhaps have page->va be initially
NULL and then cache the lookup in it when it's accessed for the first time.
