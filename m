Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6656B0270
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:45:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j14-v6so11830421pfn.11
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:45:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33-v6si17906398plg.260.2018.05.22.14.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 14:45:20 -0700 (PDT)
Date: Tue, 22 May 2018 14:45:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-ID: <20180522214517.GA30913@bombadil.infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
 <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
 <20180522201958.GC1237@bombadil.infradead.org>
 <20180522134838.fe59b6e4a405fa9af9fc0487@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522134838.fe59b6e4a405fa9af9fc0487@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue, May 22, 2018 at 01:48:38PM -0700, Andrew Morton wrote:
> -ENOCOMMENT ;)
> 
> --- a/mm/util.c~mm-distinguish-vmalloc-pages-fix-fix
> +++ a/mm/util.c
> @@ -512,6 +512,8 @@ struct address_space *page_mapping(struc
>  	mapping = page->mapping;
>  	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>  		return NULL;
> +
> +	/* Don't trip over a vmalloc page's MAPPING_VMalloc cookie */
>  	if ((unsigned long)mapping < PAGE_SIZE)
>  		return NULL;
>  
> It's a bit sad to put even more stuff into page_mapping() just for
> page_types diddling.  Is this really justified?  How many people will
> use it, and get significant benefit from it?

We could leave page->mapping NULL for vmalloc pages.  We just need to
find a spot where we can put a unique identifier.  The first word of
the union looks like a string candidate; bit 0 is already reserved for
PageTail.  The other users are list_head.prev, a struct page *, and
struct dev_pagemap *, so that should work out OK.

If you want to just drop this patch, I'd be OK with that.  I can always
submit it to you again next merge window.
