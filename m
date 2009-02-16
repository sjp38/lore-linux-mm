Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 24F656B0095
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:04:48 -0500 (EST)
Message-Id: <20090216144725.572446535@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/8] slab: introduce kzfree()
References: <20090216142926.440561506@cmpxchg.org>
Content-Disposition: inline; filename=slab-introduce-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

kzfree() is a wrapper for kfree() that additionally zeroes the
underlying memory before releasing it to the slab allocator.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>
---
 include/linux/slab.h |    1 +
 mm/util.c            |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -127,6 +127,7 @@ int kmem_ptr_validate(struct kmem_cache 
 void * __must_check __krealloc(const void *, size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
+void kzfree(const void *);
 size_t ksize(const void *);
 
 /*
--- a/mm/util.c
+++ b/mm/util.c
@@ -129,6 +129,25 @@ void *krealloc(const void *p, size_t new
 }
 EXPORT_SYMBOL(krealloc);
 
+/**
+ * kzfree - like kfree but zero memory
+ * @p: object to free memory of
+ *
+ * The memory of the object @p points to is zeroed before freed.
+ * If @p is %NULL, kzfree() does nothing.
+ */
+void kzfree(const void *p)
+{
+	size_t ks;
+	void *mem = (void *)p;
+
+	if (unlikely(ZERO_OR_NULL_PTR(mem)))
+		return;
+	ks = ksize(mem);
+	memset(mem, 0, ks);
+	kfree(mem);
+}
+
 /*
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
