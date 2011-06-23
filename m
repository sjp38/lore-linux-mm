Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7BED0900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:36:16 -0400 (EDT)
Date: Thu, 23 Jun 2011 09:36:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
In-Reply-To: <alpine.DEB.2.00.1106221641120.14635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1106230934250.19668@router.home>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc> <alpine.DEB.2.00.1106141614480.10017@router.home> <alpine.DEB.2.00.1106221641120.14635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 22 Jun 2011, David Rientjes wrote:

> >   * struct kmem_cache
> >   *
> >   * manages a cache.
>
> Looks like we lost some valuable information in the comments when this got
> moved to slab.h :(

Ok. If we want a description for these defines then lets use this.


Subject: slab allocators: Provide generic description of alignment defines

Provide description for alignment defines.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2011-06-23 09:26:55.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2011-06-23 09:33:46.000000000 -0500
@@ -133,12 +133,22 @@ unsigned int kmem_cache_size(struct kmem
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
 #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)

+/*
+ * Some archs want to perform DMA into kmalloc caches and need a guaranteed
+ * alignment larger than the alignment of a 64-bit integer.
+ * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
+ */
 #ifdef ARCH_DMA_MINALIGN
 #define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
 #else
 #define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
 #endif

+/*
+ * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
+ * Intended for arches that get misalignment faults even for 64 bit integer
+ * aligned buffers.
+ */
 #ifndef ARCH_SLAB_MINALIGN
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
