Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B5E666B0062
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so8932541pde.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:43 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id nl15si7235902pdb.246.2014.07.09.04.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:39 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G004YR08TTW50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:29 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 12/21] mm: util: move krealloc/kzfree to
 slab_common.c
Date: Wed, 09 Jul 2014 15:30:06 +0400
Message-id: <1404905415-9046-13-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

To avoid false positive reports in kernel address sanitizer krealloc/kzfree
functions shouldn't be instrumented. Since we want to instrument other
functions in mm/util.c, krealloc/kzfree moved to slab_common.c which is not
instrumented.

Unfortunately we can't completely disable instrumentation for one function.
We could disable compiler's instrumentation for one function by using
__atribute__((no_sanitize_address)).
But the problem here is that memset call will be replaced by instumented
version kasan_memset since currently it's implemented as define:

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slab_common.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/util.c        | 91 --------------------------------------------------------
 2 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index d31c4ba..8df59b09 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -787,3 +787,94 @@ static int __init slab_proc_init(void)
 }
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
+
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
+/**
+ * __krealloc - like krealloc() but don't free @p.
+ * @p: object to reallocate memory for.
+ * @new_size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * This function is like krealloc() except it never frees the originally
+ * allocated buffer. Use this if you don't want to free the buffer immediately
+ * like, for example, with RCU.
+ */
+void *__krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	if (unlikely(!new_size))
+		return ZERO_SIZE_PTR;
+
+	return __do_krealloc(p, new_size, flags);
+
+}
+EXPORT_SYMBOL(__krealloc);
+
+/**
+ * krealloc - reallocate memory. The contents will remain unchanged.
+ * @p: object to reallocate memory for.
+ * @new_size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * The contents of the object pointed to are preserved up to the
+ * lesser of the new and old sizes.  If @p is %NULL, krealloc()
+ * behaves exactly like kmalloc().  If @new_size is 0 and @p is not a
+ * %NULL pointer, the object pointed to is freed.
+ */
+void *krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	void *ret;
+
+	if (unlikely(!new_size)) {
+		kfree(p);
+		return ZERO_SIZE_PTR;
+	}
+
+	ret = __do_krealloc(p, new_size, flags);
+	if (ret && p != ret)
+		kfree(p);
+
+	return ret;
+}
+EXPORT_SYMBOL(krealloc);
+
+/**
+ * kzfree - like kfree but zero memory
+ * @p: object to free memory of
+ *
+ * The memory of the object @p points to is zeroed before freed.
+ * If @p is %NULL, kzfree() does nothing.
+ *
+ * Note: this function zeroes the whole allocated buffer which can be a good
+ * deal bigger than the requested buffer size passed to kmalloc(). So be
+ * careful when using this function in performance sensitive code.
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
diff --git a/mm/util.c b/mm/util.c
index 8f326ed..2992e16 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -142,97 +142,6 @@ void *memdup_user(const void __user *src, size_t len)
 }
 EXPORT_SYMBOL(memdup_user);
 
-static __always_inline void *__do_krealloc(const void *p, size_t new_size,
-					   gfp_t flags)
-{
-	void *ret;
-	size_t ks = 0;
-
-	if (p)
-		ks = ksize(p);
-
-	if (ks >= new_size)
-		return (void *)p;
-
-	ret = kmalloc_track_caller(new_size, flags);
-	if (ret && p)
-		memcpy(ret, p, ks);
-
-	return ret;
-}
-
-/**
- * __krealloc - like krealloc() but don't free @p.
- * @p: object to reallocate memory for.
- * @new_size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * This function is like krealloc() except it never frees the originally
- * allocated buffer. Use this if you don't want to free the buffer immediately
- * like, for example, with RCU.
- */
-void *__krealloc(const void *p, size_t new_size, gfp_t flags)
-{
-	if (unlikely(!new_size))
-		return ZERO_SIZE_PTR;
-
-	return __do_krealloc(p, new_size, flags);
-
-}
-EXPORT_SYMBOL(__krealloc);
-
-/**
- * krealloc - reallocate memory. The contents will remain unchanged.
- * @p: object to reallocate memory for.
- * @new_size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The contents of the object pointed to are preserved up to the
- * lesser of the new and old sizes.  If @p is %NULL, krealloc()
- * behaves exactly like kmalloc().  If @new_size is 0 and @p is not a
- * %NULL pointer, the object pointed to is freed.
- */
-void *krealloc(const void *p, size_t new_size, gfp_t flags)
-{
-	void *ret;
-
-	if (unlikely(!new_size)) {
-		kfree(p);
-		return ZERO_SIZE_PTR;
-	}
-
-	ret = __do_krealloc(p, new_size, flags);
-	if (ret && p != ret)
-		kfree(p);
-
-	return ret;
-}
-EXPORT_SYMBOL(krealloc);
-
-/**
- * kzfree - like kfree but zero memory
- * @p: object to free memory of
- *
- * The memory of the object @p points to is zeroed before freed.
- * If @p is %NULL, kzfree() does nothing.
- *
- * Note: this function zeroes the whole allocated buffer which can be a good
- * deal bigger than the requested buffer size passed to kmalloc(). So be
- * careful when using this function in performance sensitive code.
- */
-void kzfree(const void *p)
-{
-	size_t ks;
-	void *mem = (void *)p;
-
-	if (unlikely(ZERO_OR_NULL_PTR(mem)))
-		return;
-	ks = ksize(mem);
-	memset(mem, 0, ks);
-	kfree(mem);
-}
-EXPORT_SYMBOL(kzfree);
-
 /*
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
