Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 501C36B01D9
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:57:55 -0400 (EDT)
From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH V2] slab: fix caller tracking on !CONFIG_DEBUG_SLAB && CONFIG_TRACING
Date: Wed, 30 Jun 2010 17:57:22 +0800
Message-Id: <1277891842-18898-1-git-send-email-dfeng@redhat.com>
In-Reply-To: <alpine.DEB.2.00.1004090947030.10992@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004090947030.10992@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Monakhov <dmonakhov@openvz.org>, Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

In slab, all __xxx_track_caller is defined on CONFIG_DEBUG_SLAB || CONFIG_TRACING,
thus caller tracking function should be worked for CONFIG_TRACING. But if
CONFIG_DEBUG_SLAB is not set, include/linux/slab.h will define xxx_track_caller to
__xxx() without consideration of CONFIG_TRACING. This will break the caller tracking
behaviour then.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Dmitry Monakhov <dmonakhov@openvz.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/slab.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 49d1247..59260e2 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -268,7 +268,8 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
  * allocator where we care about the real place the memory allocation
  * request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
+	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, _RET_IP_)
@@ -286,7 +287,8 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
  * standard allocator where we care about the real place the memory
  * allocation request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
+	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
