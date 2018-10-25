Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA9606B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 22:13:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c28-v6so5429020pfe.4
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:13:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d11-v6si6309558pgd.342.2018.10.24.19.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 19:13:27 -0700 (PDT)
Date: Wed, 24 Oct 2018 19:13:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 08/17] prmem: struct page: track vmap_area
Message-ID: <20181025021307.GH25444@bombadil.infradead.org>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-9-igor.stoppa@huawei.com>
 <20181024031200.GC25444@bombadil.infradead.org>
 <ffb887e1-2029-42d5-3a97-54546e4d28d8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffb887e1-2029-42d5-3a97-54546e4d28d8@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 25, 2018 at 02:01:02AM +0300, Igor Stoppa wrote:
> > > @@ -1747,6 +1750,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> > >   	if (!addr)
> > >   		return NULL;
> > > +	va = __find_vmap_area((unsigned long)addr);
> > > +	for (i = 0; i < va->vm->nr_pages; i++)
> > > +		va->vm->pages[i]->area = va;
> > 
> > I don't like it that you're calling this for _every_ vmalloc() caller
> > when most of them will never use this.  Perhaps have page->va be initially
> > NULL and then cache the lookup in it when it's accessed for the first time.
> > 
> 
> If __find_vmap_area() was part of the API, this loop could be left out from
> __vmalloc_node_range() and the user of the allocation could initialize the
> field, if needed.
> 
> What is the reason for keeping __find_vmap_area() private?

Well, for one, you're walking the rbtree without holding the spinlock,
so you're going to get crashes.  I don't see why we shouldn't export
find_vmap_area() though.

Another way we could approach this is to embed the vmap_area in the
vm_struct.  It'd require a bit of juggling of the alloc/free paths in
vmalloc, but it might be worthwhile.
