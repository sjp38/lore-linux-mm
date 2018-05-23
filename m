Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4756B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 02:36:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w74-v6so1762890wmw.0
        for <linux-mm@kvack.org>; Tue, 22 May 2018 23:36:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k26-v6si5880281edk.67.2018.05.22.23.36.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 23:36:35 -0700 (PDT)
Date: Wed, 23 May 2018 08:36:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-ID: <20180523063634.GE20441@dhcp22.suse.cz>
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
 <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
 <20180522201958.GC1237@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522201958.GC1237@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue 22-05-18 13:19:58, Matthew Wilcox wrote:
> On Tue, May 22, 2018 at 10:57:34PM +0300, Andrey Ryabinin wrote:
> > On 05/22/2018 08:58 PM, Matthew Wilcox wrote:
> > > On Tue, May 22, 2018 at 07:10:52PM +0300, Andrey Ryabinin wrote:
> > >> On 05/18/2018 10:45 PM, Matthew Wilcox wrote:
> > >>> From: Matthew Wilcox <mawilcox@microsoft.com>
> > >>>
> > >>> For diagnosing various performance and memory-leak problems, it is helpful
> > >>> to be able to distinguish pages which are in use as VMalloc pages.
> > >>> Unfortunately, we cannot use the page_type field in struct page, as
> > >>> this is in use for mapcount by some drivers which map vmalloced pages
> > >>> to userspace.
> > >>>
> > >>> Use a special page->mapping value to distinguish VMalloc pages from
> > >>> other kinds of pages.  Also record a pointer to the vm_struct and the
> > >>> offset within the area in struct page to help reconstruct exactly what
> > >>> this page is being used for.
> > >>
> > >> This seems useless. page->vm_area and page->vm_offset are never used.
> > >> There are no follow up patches which use this new information 'For diagnosing various performance and memory-leak problems',
> > >> and no explanation how is it can be used in current form.
> > > 
> > > Right now, it's by-hand.  tools/vm/page-types.c will tell you which pages
> > > are allocated to VMalloc.  Many people use kernel debuggers, crashdumps
> > > and similar to examine the kernel's memory.  Leaving these breadcrumbs
> > > is helpful, and those fields simply weren't in use before.
> > > 
> > >> Also, this patch breaks code like this:
> > >> 	if (mapping = page_mapping(page))
> > >> 		// access mapping
> > > 
> > > Example of broken code, please?  Pages allocated from the page allocator
> > > with alloc_page() come with page->mapping == NULL.  This code snippet
> > > would not have granted access to vmalloc pages before.
> > > 
> > 
> > Some implementation of the flush_dcache_page(), also set_page_dirty() can be called
> > on userspace-mapped vmalloc pages during unmap - zap_pte_range() -> set_page_dirty()
> 
> Ah, good catch!  I'm anticipating we'll have other special values for
> page->mapping in the future. so how about this?
> 
> (no changelog because I assume Andrew will add this as a -fix patch)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 10ca6f1d5c75..be81c9052ef7 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -561,6 +561,8 @@ struct address_space *page_mapping(struct page *page)
>  	mapping = page->mapping;
>  	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>  		return NULL;
> +	if ((unsigned long)mapping < PAGE_SIZE)
> +		return NULL;
>  
>  	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
>  }

Well, this would be quite unfortunate. We do not want to pay a branch
price for something that doesn't have a _real_ user. Which is kinda sad
because I found the explicit vmalloc page "flag" nice to have (if it was
for free basically).

-- 
Michal Hocko
SUSE Labs
