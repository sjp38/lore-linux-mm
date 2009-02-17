Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A93BB6B00AE
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:43:55 -0500 (EST)
Message-Id: <20090217184135.747921027@cmpxchg.org>
Date: Tue, 17 Feb 2009 19:26:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/7] slab: introduce kzfree()
References: <20090217182615.897042724@cmpxchg.org>
Content-Disposition: inline; filename=slab-introduce-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

kzfree() is a wrapper for kfree() that additionally zeroes the
underlying memory before releasing it to the slab allocator.

Currently there is code which memset()s the memory region of an object
before releasing it back to the slab allocator to make sure
security-sensitive data are really zeroed out after use.

These callsites can then just use kzfree() which saves some code,
makes users greppable and allows for a stupid destructor that isn't
necessarily aware of the actual object size.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>
---
 include/linux/slab.h |    1 +
 mm/util.c            |   20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

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
@@ -129,6 +129,26 @@ void *krealloc(const void *p, size_t new
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
+EXPORT_SYMBOL(kzfree);
+
 /*
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
