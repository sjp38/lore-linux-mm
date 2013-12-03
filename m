Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0827E6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 15:25:23 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so12896536qeb.28
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 12:25:22 -0800 (PST)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTP id k3si37175669qao.154.2013.12.03.12.25.19
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 12:25:21 -0800 (PST)
Date: Tue, 3 Dec 2013 20:25:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <alpine.DEB.2.02.1312030930450.4115@gentwo.org>
Message-ID: <00000142ba22e43b-99d8d7cb-9ecd-4f18-9609-8805270843d4-000000@email.amazonses.com>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1312030930450.4115@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Tue, 3 Dec 2013, Christoph Lameter wrote:

> Subject: slab: Do not use off slab metadata for CONFIG_DEBUG_PAGEALLOC
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

The patch fails here at the largest slab which requires off slab
management because otherwise the order becomes too high.

The fundamental problem is that debugging increases the size of the slab
significantly so that even small slabs require slab management. But
the kmalloc slabs used for the sizes required for management objects have not
been created yet.

Slab bootstrap relies on smaller slabs not requiring slab management
slabs. Once it gets to larger sizes then smaller slab management objects
may be allocated.

However, in this case the slab sizes are required for management at early
boot after slab_early_init has been set to 0 are not available.

If the slab management sizes required match other slab caches sizes that
were already created at boot then bootstrap will succeed regardless.

I have another patch here (that I cannot test since I cannot run sparc
code) that simply changes the determination for switching slab management
to base the decision not on the final size of the slab (which is always
large in the debugging cases here) but on the initial object size. For
small objects < PAGESIZE/8 this should avoid the use of slab management
even in the debugging case.

Subject: slab: Do not use slab management for slabs with smaller objects

Use the object size to make the off slab decision instead of the final
size of the slab objects (which is large in case of
CONFIG_PAGEALLOC_DEBUG).

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2013-12-03 10:48:42.625823157 -0600
+++ linux/mm/slab.c	2013-12-03 10:49:06.755152653 -0600
@@ -2243,8 +2243,8 @@ __kmem_cache_create (struct kmem_cache *
 	 * it too early on. Always use on-slab management when
 	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
 	 */
-	if ((size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
-	    !(flags & SLAB_NOLEAKTRACE))
+	if ((cachep->size >= (PAGE_SIZE >> 3)) && !slab_early_init &&
+	    !(flags & SLAB_NOLEAKTRACE) )
 		/*
 		 * Size is large, assume best to place the slab management obj
 		 * off-slab (should allow better packing of objs).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
