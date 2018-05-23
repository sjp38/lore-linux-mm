Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF956B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 02:34:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w74-v6so1759807wmw.0
        for <linux-mm@kvack.org>; Tue, 22 May 2018 23:34:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26-v6si2060354eda.47.2018.05.22.23.34.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 23:34:42 -0700 (PDT)
Date: Wed, 23 May 2018 08:34:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-ID: <20180523063439.GD20441@dhcp22.suse.cz>
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
 <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue 22-05-18 22:57:34, Andrey Ryabinin wrote:
> 
> 
> On 05/22/2018 08:58 PM, Matthew Wilcox wrote:
> > On Tue, May 22, 2018 at 07:10:52PM +0300, Andrey Ryabinin wrote:
> >> On 05/18/2018 10:45 PM, Matthew Wilcox wrote:
> >>> From: Matthew Wilcox <mawilcox@microsoft.com>
> >>>
> >>> For diagnosing various performance and memory-leak problems, it is helpful
> >>> to be able to distinguish pages which are in use as VMalloc pages.
> >>> Unfortunately, we cannot use the page_type field in struct page, as
> >>> this is in use for mapcount by some drivers which map vmalloced pages
> >>> to userspace.
> >>>
> >>> Use a special page->mapping value to distinguish VMalloc pages from
> >>> other kinds of pages.  Also record a pointer to the vm_struct and the
> >>> offset within the area in struct page to help reconstruct exactly what
> >>> this page is being used for.
> >>
> >> This seems useless. page->vm_area and page->vm_offset are never used.
> >> There are no follow up patches which use this new information 'For diagnosing various performance and memory-leak problems',
> >> and no explanation how is it can be used in current form.
> > 
> > Right now, it's by-hand.  tools/vm/page-types.c will tell you which pages
> > are allocated to VMalloc.  Many people use kernel debuggers, crashdumps
> > and similar to examine the kernel's memory.  Leaving these breadcrumbs
> > is helpful, and those fields simply weren't in use before.
> > 
> >> Also, this patch breaks code like this:
> >> 	if (mapping = page_mapping(page))
> >> 		// access mapping
> > 
> > Example of broken code, please?  Pages allocated from the page allocator
> > with alloc_page() come with page->mapping == NULL.  This code snippet
> > would not have granted access to vmalloc pages before.
> > 
> 
> Some implementation of the flush_dcache_page(), also set_page_dirty() can be called
> on userspace-mapped vmalloc pages during unmap - zap_pte_range() -> set_page_dirty()

Do you have any specific example? Why would anybody map vmalloc pages to
the userspace? flush_dcache_page on a vmalloc page sounds quite
unexpected to me as well.

-- 
Michal Hocko
SUSE Labs
