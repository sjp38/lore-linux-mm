Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2DC6B0009
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:10:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i64-v6so2090351ita.8
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:10:29 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id y203-v6si6917499itc.51.2018.03.23.08.10.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 08:10:28 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:10:26 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803211613010.28365@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803230956420.4108@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake> <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake> <alpine.LRH.2.02.1803211613010.28365@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Mikulas Patocka wrote:

> > +	s->allocflags = allocflags;
>
> I'd also use "WRITE_ONCE(s->allocflags, allocflags)" here and when writing
> s->oo and s->min to avoid some possible compiler misoptimizations.

It only matters that 0 etc is never written.

> Another problem is that it updates s->oo and later it updates s->max:
>         s->oo = oo_make(order, size, s->reserved);
>         s->min = oo_make(get_order(size), size, s->reserved);
>         if (oo_objects(s->oo) > oo_objects(s->max))
>                 s->max = s->oo;
> --- so, the concurrently running code could see s->oo > s->max, which
> could trigger some memory corruption.

Well s->max is only relevant for code that analyses the details of slab
structures for diagnostics.

> s->max is only used in memory allocations -
> kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long)), so
> perhaps we could fix the bug by removing s->max at all and always
> allocating enough memory for the maximum possible number of objects?
>
> - kmalloc(BITS_TO_LONGS(oo_objects(s->max)) * sizeof(unsigned long), GFP_KERNEL);
> + kmalloc(BITS_TO_LONGS(MAX_OBJS_PER_PAGE) * sizeof(unsigned long), GFP_KERNEL);

MAX_OBJS_PER_PAGE is 32k. So you are looking at contiguous allocations of
256kbyte. Not good.

The simplest measure would be to disallow the changing of the order while
the slab contains objects.


Subject: slub: Disallow order changes when objects exist in a slab

There seems to be a couple of races that would have to be
addressed if the slab order would be changed during active use.

Lets disallow this in the same way as we also do not allow
other changes of slab characteristics when objects are active.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -4919,6 +4919,9 @@ static ssize_t order_store(struct kmem_c
 	unsigned long order;
 	int err;

+	if (any_slab_objects(s))
+		return -EBUSY;
+
 	err = kstrtoul(buf, 10, &order);
 	if (err)
 		return err;
