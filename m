Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D81836B0055
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 06:16:05 -0400 (EDT)
Subject: [RFC PATCH 1/3] kmemleak: Allow partial freeing of memory blocks
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 06 Jul 2009 11:51:49 +0100
Message-ID: <20090706105149.16051.99106.stgit@pc1117.cambridge.arm.com>
In-Reply-To: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Functions like free_bootmem() are allowed to free only part of a memory
block. This patch adds support for this via the kmemleak_free_part()
callback which removes the original object and creates one or two
additional objects as a result of the memory block split.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/kmemleak.h |    4 +++
 mm/kmemleak.c            |   55 ++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 7796aed..6a63807 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -27,6 +27,7 @@ extern void kmemleak_init(void);
 extern void kmemleak_alloc(const void *ptr, size_t size, int min_count,
 			   gfp_t gfp);
 extern void kmemleak_free(const void *ptr);
+extern void kmemleak_free_part(const void *ptr, size_t size);
 extern void kmemleak_padding(const void *ptr, unsigned long offset,
 			     size_t size);
 extern void kmemleak_not_leak(const void *ptr);
@@ -71,6 +72,9 @@ static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
 static inline void kmemleak_free(const void *ptr)
 {
 }
+static inline void kmemleak_free_part(const void *ptr, size_t size)
+{
+}
 static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
 {
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5f7d8ae..57f8081 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -210,6 +210,7 @@ static DEFINE_MUTEX(scan_mutex);
 enum {
 	KMEMLEAK_ALLOC,
 	KMEMLEAK_FREE,
+	KMEMLEAK_FREE_PART,
 	KMEMLEAK_NOT_LEAK,
 	KMEMLEAK_IGNORE,
 	KMEMLEAK_SCAN_AREA,
@@ -522,15 +523,20 @@ out:
 
 /*
  * Remove the metadata (struct kmemleak_object) for a memory block from the
- * object_list and object_tree_root and decrement its use_count.
+ * object_list and object_tree_root and decrement its use_count. If the memory
+ * block is partially freed (size > 0), the function may create additional
+ * metadata for the remaining parts of the block.
  */
-static void delete_object(unsigned long ptr)
+static void delete_object(unsigned long ptr, size_t size)
 {
 	unsigned long flags;
 	struct kmemleak_object *object;
+	unsigned long start, end;
+	unsigned int min_count;
+	gfp_t gfp_flags;
 
 	write_lock_irqsave(&kmemleak_lock, flags);
-	object = lookup_object(ptr, 0);
+	object = lookup_object(ptr, 1);
 	if (!object) {
 #ifdef DEBUG
 		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
@@ -552,8 +558,29 @@ static void delete_object(unsigned long ptr)
 	 */
 	spin_lock_irqsave(&object->lock, flags);
 	object->flags &= ~OBJECT_ALLOCATED;
+	start = object->pointer;
+	end = object->pointer + object->size;
+	min_count = object->min_count;
 	spin_unlock_irqrestore(&object->lock, flags);
 	put_object(object);
+
+	if (!size)
+		return;
+
+	/*
+	 * Partial freeing. Just create one or two objects that may result
+	 * from the memory block split.
+	 */
+	if (in_atomic())
+		gfp_flags = GFP_ATOMIC;
+	else
+		gfp_flags = GFP_KERNEL;
+
+	if (ptr > start)
+		create_object(start, ptr - start, min_count, gfp_flags);
+	if (ptr + size < end)
+		create_object(ptr + size, end - ptr - size, min_count,
+			      gfp_flags);
 }
 
 /*
@@ -720,13 +747,28 @@ void kmemleak_free(const void *ptr)
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
 	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
-		delete_object((unsigned long)ptr);
+		delete_object((unsigned long)ptr, 0);
 	else if (atomic_read(&kmemleak_early_log))
 		log_early(KMEMLEAK_FREE, ptr, 0, 0, 0, 0);
 }
 EXPORT_SYMBOL_GPL(kmemleak_free);
 
 /*
+ * Partial memory freeing function callback. This function is usually called
+ * from bootmem allocator when (part of) a memory block is freed.
+ */
+void kmemleak_free_part(const void *ptr, size_t size)
+{
+	pr_debug("%s(0x%p)\n", __func__, ptr);
+
+	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
+		delete_object((unsigned long)ptr, size);
+	else if (atomic_read(&kmemleak_early_log))
+		log_early(KMEMLEAK_FREE_PART, ptr, size, 0, 0, 0);
+}
+EXPORT_SYMBOL_GPL(kmemleak_free_part);
+
+/*
  * Mark an already allocated memory block as a false positive. This will cause
  * the block to no longer be reported as leak and always be scanned.
  */
@@ -1345,7 +1387,7 @@ static int kmemleak_cleanup_thread(void *arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(object, &object_list, object_list)
-		delete_object(object->pointer);
+		delete_object(object->pointer, 0);
 	rcu_read_unlock();
 	mutex_unlock(&scan_mutex);
 
@@ -1440,6 +1482,9 @@ void __init kmemleak_init(void)
 		case KMEMLEAK_FREE:
 			kmemleak_free(log->ptr);
 			break;
+		case KMEMLEAK_FREE_PART:
+			kmemleak_free_part(log->ptr, log->size);
+			break;
 		case KMEMLEAK_NOT_LEAK:
 			kmemleak_not_leak(log->ptr);
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
