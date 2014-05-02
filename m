Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 72F176B003D
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:51 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id ar20so4856146iec.5
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:51 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id g20si3313073igf.36.2014.05.02.06.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:50 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 2/6] mm: Introduce kmemleak_update_trace()
Date: Fri,  2 May 2014 14:41:06 +0100
Message-Id: <1399038070-1540-3-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

The memory allocation stack trace is not always useful for debugging
a memory leak (e.g. radix_tree_preload). This function, when called,
updates the stack trace for an already allocated object.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/kmemleak.txt |  1 +
 include/linux/kmemleak.h   |  4 ++++
 mm/kmemleak.c              | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index a7563ec4ea7b..b772418bf064 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -142,6 +142,7 @@ kmemleak_alloc_percpu	 - notify of a percpu memory block allocation
 kmemleak_free		 - notify of a memory block freeing
 kmemleak_free_part	 - notify of a partial memory block freeing
 kmemleak_free_percpu	 - notify of a percpu memory block freeing
+kmemleak_update_trace	 - update object allocation stack trace
 kmemleak_not_leak	 - mark an object as not a leak
 kmemleak_ignore		 - do not scan or report an object as leak
 kmemleak_scan_area	 - add scan areas inside a memory block
diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 5bb424659c04..057e95971014 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -30,6 +30,7 @@ extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size) __ref;
 extern void kmemleak_free(const void *ptr) __ref;
 extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
 extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
+extern void kmemleak_update_trace(const void *ptr) __ref;
 extern void kmemleak_not_leak(const void *ptr) __ref;
 extern void kmemleak_ignore(const void *ptr) __ref;
 extern void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp) __ref;
@@ -83,6 +84,9 @@ static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
 static inline void kmemleak_free_percpu(const void __percpu *ptr)
 {
 }
+static inline void kmemleak_update_trace(const void *ptr)
+{
+}
 static inline void kmemleak_not_leak(const void *ptr)
 {
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 3a36e2b16cba..61a64ed2fbef 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -990,6 +990,40 @@ void __ref kmemleak_free_percpu(const void __percpu *ptr)
 EXPORT_SYMBOL_GPL(kmemleak_free_percpu);
 
 /**
+ * kmemleak_update_trace - update object allocation stack trace
+ * @ptr:	pointer to beginning of the object
+ *
+ * Override the object allocation stack trace for cases where the actual
+ * allocation place is not always useful.
+ */
+void __ref kmemleak_update_trace(const void *ptr)
+{
+	struct kmemleak_object *object;
+	unsigned long flags;
+
+	pr_debug("%s(0x%p)\n", __func__, ptr);
+
+	if (!kmemleak_enabled || IS_ERR_OR_NULL(ptr))
+		return;
+
+	object = find_and_get_object((unsigned long)ptr, 1);
+	if (!object) {
+#ifdef DEBUG
+		kmemleak_warn("Updating stack trace for unknown object at %p\n",
+			      ptr);
+#endif
+		return;
+	}
+
+	spin_lock_irqsave(&object->lock, flags);
+	object->trace_len = __save_stack_trace(object->trace);
+	spin_unlock_irqrestore(&object->lock, flags);
+
+	put_object(object);
+}
+EXPORT_SYMBOL(kmemleak_update_trace);
+
+/**
  * kmemleak_not_leak - mark an allocated object as false positive
  * @ptr:	pointer to beginning of the object
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
