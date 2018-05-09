Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459506B0580
	for <linux-mm@kvack.org>; Wed,  9 May 2018 16:02:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x21so10009603pfn.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 13:02:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15-v6sor4280225plk.105.2018.05.09.13.02.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 13:02:37 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 4/6] mm: Use overflow helpers in kmalloc_array*()
Date: Wed,  9 May 2018 13:02:21 -0700
Message-Id: <20180509200223.22451-5-keescook@chromium.org>
In-Reply-To: <20180509200223.22451-1-keescook@chromium.org>
References: <20180509200223.22451-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Instead of open-coded multiplication and bounds checking, use the new
overflow helper.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 81ebd71f8c03..4d759e1ddc33 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -13,6 +13,7 @@
 #define	_LINUX_SLAB_H
 
 #include <linux/gfp.h>
+#include <linux/overflow.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
@@ -624,11 +625,13 @@ int memcg_update_all_caches(int num_memcgs);
  */
 static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes;
+
+	if (unlikely(check_mul_overflow(n, size, &bytes)))
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
-		return kmalloc(n * size, flags);
-	return __kmalloc(n * size, flags);
+		return kmalloc(bytes, flags);
+	return __kmalloc(bytes, flags);
 }
 
 /**
@@ -657,11 +660,13 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 static inline void *kmalloc_array_node(size_t n, size_t size, gfp_t flags,
 				       int node)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes;
+
+	if (unlikely(check_mul_overflow(n, size, &bytes)))
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
-		return kmalloc_node(n * size, flags, node);
-	return __kmalloc_node(n * size, flags, node);
+		return kmalloc_node(bytes, flags, node);
+	return __kmalloc_node(bytes, flags, node);
 }
 
 static inline void *kcalloc_node(size_t n, size_t size, gfp_t flags, int node)
-- 
2.17.0
