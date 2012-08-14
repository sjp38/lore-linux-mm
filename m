Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 4B8E66B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 08:55:37 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so518297ggn.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 05:55:36 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH] mm: Use __do_krealloc to do the krealloc job
Date: Tue, 14 Aug 2012 09:55:21 -0300
Message-Id: <1344948921-17633-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

Without this patch we can get (many) kmem trace events
with call site at krealloc().

This happens because krealloc is calling __krealloc,
which performs the allocation through kmalloc_track_caller.

Since neither krealloc nor __krealloc are marked inline explicitly,
the caller can be traced as being krealloc, which clearly is not
the intended behavior.

This patch allows to get the real caller of krealloc, by creating
an always inlined function __do_krealloc, thus tracing the
call site accurately.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/util.c |   35 +++++++++++++++++++++--------------
 1 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 8c7265a..dc3036c 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -105,6 +105,25 @@ void *memdup_user(const void __user *src, size_t len)
 }
 EXPORT_SYMBOL(memdup_user);
 
+static __always_inline void *__do_krealloc(const void *p, size_t new_size,
+					   gfp_t flags)
+{
+	void *ret;
+	size_t ks = 0;
+
+	if (p)
+		ks = ksize(p);
+
+	if (ks >= new_size)
+		return (void *)p;
+
+	ret = kmalloc_track_caller(new_size, flags);
+	if (ret && p)
+		memcpy(ret, p, ks);
+
+	return ret;
+}
+
 /**
  * __krealloc - like krealloc() but don't free @p.
  * @p: object to reallocate memory for.
@@ -117,23 +136,11 @@ EXPORT_SYMBOL(memdup_user);
  */
 void *__krealloc(const void *p, size_t new_size, gfp_t flags)
 {
-	void *ret;
-	size_t ks = 0;
-
 	if (unlikely(!new_size))
 		return ZERO_SIZE_PTR;
 
-	if (p)
-		ks = ksize(p);
+	return __do_krealloc(p, new_size, flags);
 
-	if (ks >= new_size)
-		return (void *)p;
-
-	ret = kmalloc_track_caller(new_size, flags);
-	if (ret && p)
-		memcpy(ret, p, ks);
-
-	return ret;
 }
 EXPORT_SYMBOL(__krealloc);
 
@@ -157,7 +164,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
 		return ZERO_SIZE_PTR;
 	}
 
-	ret = __krealloc(p, new_size, flags);
+	ret = __do_krealloc(p, new_size, flags);
 	if (ret && p != ret)
 		kfree(p);
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
