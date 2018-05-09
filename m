Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 542C46B02ED
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q8-v6so14480213pgv.22
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x15-v6sor5348870pgq.213.2018.05.08.17.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:40 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 04/13] mm: Use array_size() helpers for kmalloc()
Date: Tue,  8 May 2018 17:42:20 -0700
Message-Id: <20180509004229.36341-5-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Instead of open-coded multiplication, use the new array_size() helper
to detect overflow in kmalloc()-family functions.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 81ebd71f8c03..d03e0726e136 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -13,6 +13,7 @@
 #define	_LINUX_SLAB_H
 
 #include <linux/gfp.h>
+#include <linux/overflow.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
@@ -499,6 +500,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  */
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
+	if (size == SIZE_MAX)
+		return NULL;
 	if (__builtin_constant_p(size)) {
 		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
@@ -539,6 +542,8 @@ static __always_inline unsigned int kmalloc_size(unsigned int n)
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
+	if (size == SIZE_MAX)
+		return NULL;
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
@@ -624,11 +629,13 @@ int memcg_update_all_caches(int num_memcgs);
  */
 static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes = array_size(n, size);
+
+	if (bytes == SIZE_MAX)
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
-		return kmalloc(n * size, flags);
-	return __kmalloc(n * size, flags);
+		return kmalloc(bytes, flags);
+	return __kmalloc(bytes, flags);
 }
 
 /**
@@ -639,7 +646,9 @@ static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
  */
 static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
 {
-	return kmalloc_array(n, size, flags | __GFP_ZERO);
+	size_t bytes = array_size(n, size);
+
+	return kmalloc(bytes, flags | __GFP_ZERO);
 }
 
 /*
@@ -657,16 +666,22 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 static inline void *kmalloc_array_node(size_t n, size_t size, gfp_t flags,
 				       int node)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes = array_size(n, size);
+
+	if (bytes == SIZE_MAX)
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
-		return kmalloc_node(n * size, flags, node);
-	return __kmalloc_node(n * size, flags, node);
+		return kmalloc_node(bytes, flags, node);
+	return __kmalloc_node(bytes, flags, node);
 }
 
 static inline void *kcalloc_node(size_t n, size_t size, gfp_t flags, int node)
 {
-	return kmalloc_array_node(n, size, flags | __GFP_ZERO, node);
+	size_t bytes = array_size(n, size);
+
+	if (bytes == SIZE_MAX)
+		return NULL;
+	return kmalloc_node(bytes, flags | __GFP_ZERO, node);
 }
 
 
-- 
2.17.0
