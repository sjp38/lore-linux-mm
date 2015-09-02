Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7374C6B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 14:04:11 -0400 (EDT)
Received: by oixx17 with SMTP id x17so10741795oix.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 11:04:11 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id z66si26620659qgd.11.2015.09.02.11.04.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 02 Sep 2015 11:04:10 -0700 (PDT)
Date: Wed, 2 Sep 2015 13:04:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Avoid irqoff/on in bulk allocation
In-Reply-To: <20150902110950.4d407c0f@redhat.com>
Message-ID: <alpine.DEB.2.11.1509021300460.14827@east.gentwo.org>
References: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org> <20150902110950.4d407c0f@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, 2 Sep 2015, Jesper Dangaard Brouer wrote:

> > +error:
> > +	__kmem_cache_free_bulk(s, i, p);
>
> Don't we need to update "tid" here, like:
>
>   c->tid = next_tid(c->tid);
>
> Consider a call to the ordinary kmem_cache_alloc/slab_alloc_node was
> in-progress, which get PREEMPT'ed just before it's call to
> this_cpu_cmpxchg_double().
>  Now, this function gets called and we modify c->freelist, but cannot
> get all objects and then fail (goto error).  Although we put-back
> objects (via __kmem_cache_free_bulk) don't we want to update c->tid
> in-order to make sure the call to this_cpu_cmpxchg_double() retry?

Hmm... I thought that __kmem_cache_free_bulk is run with interrupts
disabled and will invoke the __slab_free which will increment tid if any
objects are freed from the local page.

That occurs before interrupts are reenabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
