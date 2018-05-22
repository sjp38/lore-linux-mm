Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB2786B0277
	for <linux-mm@kvack.org>; Tue, 22 May 2018 19:02:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3-v6so12027871pfe.15
        for <linux-mm@kvack.org>; Tue, 22 May 2018 16:02:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n1-v6si13324657pge.687.2018.05.22.16.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 16:02:35 -0700 (PDT)
Date: Tue, 22 May 2018 16:02:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
Message-Id: <20180522160234.a1fc9de7626de52cfb3a2e7d@linux-foundation.org>
In-Reply-To: <20180522214517.GA30913@bombadil.infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
	<20180518194519.3820-18-willy@infradead.org>
	<74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
	<20180522175836.GB1237@bombadil.infradead.org>
	<e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
	<20180522201958.GC1237@bombadil.infradead.org>
	<20180522134838.fe59b6e4a405fa9af9fc0487@linux-foundation.org>
	<20180522214517.GA30913@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Tue, 22 May 2018 14:45:17 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> On Tue, May 22, 2018 at 01:48:38PM -0700, Andrew Morton wrote:
> > -ENOCOMMENT ;)
> > 
> > --- a/mm/util.c~mm-distinguish-vmalloc-pages-fix-fix
> > +++ a/mm/util.c
> > @@ -512,6 +512,8 @@ struct address_space *page_mapping(struc
> >  	mapping = page->mapping;
> >  	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
> >  		return NULL;
> > +
> > +	/* Don't trip over a vmalloc page's MAPPING_VMalloc cookie */
> >  	if ((unsigned long)mapping < PAGE_SIZE)
> >  		return NULL;
> >  
> > It's a bit sad to put even more stuff into page_mapping() just for
> > page_types diddling.  Is this really justified?  How many people will
> > use it, and get significant benefit from it?
> 
> We could leave page->mapping NULL for vmalloc pages.  We just need to
> find a spot where we can put a unique identifier.  The first word of
> the union looks like a string candidate; bit 0 is already reserved for
> PageTail.  The other users are list_head.prev, a struct page *, and
> struct dev_pagemap *, so that should work out OK.
> 
> If you want to just drop this patch, I'd be OK with that.  I can always
> submit it to you again next merge window.

OK, let's park it for now.
