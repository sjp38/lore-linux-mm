Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82E6D6B005C
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:09:38 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i64-v6so5543868ita.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:09:38 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 126si3716900iov.154.2018.03.21.13.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 13:09:37 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:09:35 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake>
 <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Mikulas Patocka wrote:

> For example, if someone creates a slab cache with the flag SLAB_CACHE_DMA,
> and he allocates an object from this cache and this allocation races with
> the user writing to /sys/kernel/slab/cache/order - then the allocator can
> for a small period of time see "s->allocflags == 0" and allocate a non-DMA
> page. That is a bug.

True we need to fix that:

Subject: Avoid potentially visible allocflags without all flags set

During slab size recalculation s->allocflags may be temporarily set
to 0 and thus the flags may not be set which may result in the wrong
flags being passed. Slab size calculation happens in two cases:

1. When a slab is created (which is safe since we cannot have
   concurrent allocations)

2. When the slab order is changed via /sysfs.

Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3457,6 +3457,7 @@ static void set_cpu_partial(struct kmem_
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	slab_flags_t flags = s->flags;
+	gfp_t allocflags;
 	size_t size = s->object_size;
 	int order;

@@ -3551,16 +3552,17 @@ static int calculate_sizes(struct kmem_c
 	if (order < 0)
 		return 0;

-	s->allocflags = 0;
+	allocflags = 0;
 	if (order)
-		s->allocflags |= __GFP_COMP;
+		allocflags |= __GFP_COMP;

 	if (s->flags & SLAB_CACHE_DMA)
-		s->allocflags |= GFP_DMA;
+		allocflags |= GFP_DMA;

 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
-		s->allocflags |= __GFP_RECLAIMABLE;
+		allocflags |= __GFP_RECLAIMABLE;

+	s->allocflags = allocflags;
 	/*
 	 * Determine the number of objects per slab
 	 */
