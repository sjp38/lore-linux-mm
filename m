Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5B86B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 16:47:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e200so14012470oig.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:47:15 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id b189si6483447itg.101.2016.10.26.13.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 13:47:14 -0700 (PDT)
Date: Wed, 26 Oct 2016 15:47:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <CAJcbSZHZdiMpd4Nhr+UjBk5=5EmUb7xT-8VvCch2NHkm95415g@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1610261541560.3235@east.gentwo.org>
References: <1477503688-69191-1-git-send-email-thgarnie@google.com> <alpine.DEB.2.20.1610261400270.31096@east.gentwo.org> <CAJcbSZHZdiMpd4Nhr+UjBk5=5EmUb7xT-8VvCch2NHkm95415g@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

On Wed, 26 Oct 2016, Thomas Garnier wrote:

> Okay, I think for SLAB we can allow everything except the two flags
> mentioned here.

No no no. Just allow the flags already defined in include/linux/slab.h
that can be specd by subsystems when they call into the slab allocators.

> Should I deny certain flags for SLUB? I can allow everything for now.

All allocator should just allow flags defined in include/linux/slab.h be
passed to kmem_cache_create(). That is the API that all allocators need to support.
If someone wants to add new flags then we need to make sure that all
allocators can handle it.


The flags are (from include/linux/slab.h)
/*
 * Flags to pass to kmem_cache_create().
 */
#define SLAB_CONSISTENCY_CHECKS 0x00000100UL    /* DEBUG: Perform (expensive) checks on alloc/free */
#define SLAB_RED_ZONE           0x00000400UL    /* DEBUG: Red zone objs in a cache */
#define SLAB_POISON             0x00000800UL    /* DEBUG: Poison objects */
#define SLAB_HWCACHE_ALIGN      0x00002000UL    /* Align objs on cache lines */
#define SLAB_CACHE_DMA          0x00004000UL    /* Use GFP_DMA memory */
#define SLAB_STORE_USER         0x00010000UL    /* DEBUG: Store the last owner for bug hunting */
#define SLAB_PANIC              0x00040000UL    /* Panic if kmem_cache_create() fails */
#define SLAB_DESTROY_BY_RCU     0x00080000UL    /* Defer freeing slabs to RCU */
#define SLAB_MEM_SPREAD         0x00100000UL    /* Spread some memory over cpuset */
#define SLAB_TRACE              0x00200000UL    /* Trace allocations and frees */
#define SLAB_DEBUG_OBJECTS	0x00400000UL
#define SLAB_NOLEAKTRACE 	0x00800000UL    /* Avoid kmemleak tracing
#define SLAB_NOTRACK      	0x01000000UL
#define SLAB_FAILSLAB          	0x02000000UL    /* Fault injection mark */
#define SLAB_ACCOUNT          	0x04000000UL    /* Account to memcg */
#define SLAB_KASAN              0x08000000UL
#define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
