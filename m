Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D349A6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:34:59 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so6951411pde.24
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:34:59 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id ic8si8816436pad.13.2014.04.07.12.34.58
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 12:34:59 -0700 (PDT)
Date: Mon, 7 Apr 2014 14:34:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <53401F56.5090507@oracle.com>
Message-ID: <alpine.DEB.2.10.1404071429530.4447@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc> <53321CB6.5050706@oracle.com>
 <alpine.DEB.2.10.1403261042360.2057@nuc> <53401F56.5090507@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 5 Apr 2014, Sasha Levin wrote:

> [ 1035.193166] Call Trace:
> [ 1035.193166] ? init_object (mm/slub.c:679)
> [ 1035.193166] setup_object.isra.34 (mm/slub.c:1071 mm/slub.c:1399)
> [ 1035.193166] new_slab (mm/slub.c:286 mm/slub.c:1439)
> [ 1035.193166] __slab_alloc (mm/slub.c:2203 mm/slub.c:2363)
> [ 1035.193166] ? kmem_cache_alloc (mm/slub.c:2469 mm/slub.c:2480 mm/slub.c:2485)


Ok so the story here is that slub decided it needed a new slab and
requested memory from the page allocator.

setup_object() tries to write to the page which fails.

Could the page allocator have delivered a reference to a page struct that
creates an invalid address?

The code that fails is:

 page = allocate_slab(s,
                flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
        if (!page)
                goto out;

--- So we got a page from teh page allocator

        order = compound_order(page);
        inc_slabs_node(s, page_to_nid(page), page->objects);
        memcg_bind_pages(s, order);
        page->slab_cache = s;
        __SetPageSlab(page);

-- Writing to the page struct works.

        if (page->pfmemalloc)
                SetPageSlabPfmemalloc(page);

        start = page_address(page);

        if (unlikely(s->flags & SLAB_POISON))
                memset(start, POISON_INUSE, PAGE_SIZE << order);


--- This should have triggered since we write to the page but maybe this
	slab has a ctor set and therefore no poisining is possible.

        last = start;
        for_each_object(p, s, start, page->objects) {
                setup_object(s, page, last);

*** This is where the write access to the page fails.

                set_freepointer(s, last, p);
                last = p;
        }
        setup_object(s, page, last);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
