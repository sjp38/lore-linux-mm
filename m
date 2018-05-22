Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DED66B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 16:48:41 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q16-v6so12844775pls.15
        for <linux-mm@kvack.org>; Tue, 22 May 2018 13:48:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d15-v6si18233767pln.533.2018.05.22.13.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 13:48:40 -0700 (PDT)
Date: Tue, 22 May 2018 13:48:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-Id: <20180522134838.fe59b6e4a405fa9af9fc0487@linux-foundation.org>
In-Reply-To: <20180522201958.GC1237@bombadil.infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
	<20180518194519.3820-18-willy@infradead.org>
	<74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
	<20180522175836.GB1237@bombadil.infradead.org>
	<e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
	<20180522201958.GC1237@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Tue, 22 May 2018 13:19:58 -0700 Matthew Wilcox <willy@infradead.org> wrote:

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

I give the -fix patches a single-line summary in the final rollup.

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

-ENOCOMMENT ;)

--- a/mm/util.c~mm-distinguish-vmalloc-pages-fix-fix
+++ a/mm/util.c
@@ -512,6 +512,8 @@ struct address_space *page_mapping(struc
 	mapping = page->mapping;
 	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;
+
+	/* Don't trip over a vmalloc page's MAPPING_VMalloc cookie */
 	if ((unsigned long)mapping < PAGE_SIZE)
 		return NULL;
 
It's a bit sad to put even more stuff into page_mapping() just for
page_types diddling.  Is this really justified?  How many people will
use it, and get significant benefit from it?
