Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 702886B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 05:35:03 -0400 (EDT)
Subject: Re: [RFC PATCH 1/3] kmemleak: Allow partial freeing of memory
	blocks
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1247035243.15919.28.camel@penberg-laptop>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	 <20090706105149.16051.99106.stgit@pc1117.cambridge.arm.com>
	 <1246950733.24285.10.camel@penberg-laptop>
	 <tnxtz1ovq8p.fsf@pc1117.cambridge.arm.com>
	 <tnxiqi4vchj.fsf@pc1117.cambridge.arm.com>
	 <1247035243.15919.28.camel@penberg-laptop>
Content-Type: text/plain
Date: Wed, 08 Jul 2009 10:42:21 +0100
Message-Id: <1247046141.6595.12.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-08 at 09:40 +0300, Pekka Enberg wrote:
> Looks good to me. I think it would be better to have
> delete_object_full() and delete_object_part(), and extract the common
> code to __delete_object() or something instead of passing the magic zero
> from kmemleak_free().

Yes, it make sense:


kmemleak: Allow partial freeing of memory blocks

From: Catalin Marinas <catalin.marinas@arm.com>

Functions like free_bootmem() are allowed to free only part of a memory
block. This patch adds support for this via the kmemleak_free_part()
callback which removes the original object and creates one or two
additional objects as a result of the memory block split.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/kmemleak.h |    4 ++
 mm/kmemleak.c            |   95 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 85 insertions(+), 14 deletions(-)

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
index 5f7d8ae..7b4647d 100644
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
@@ -524,27 +525,17 @@ out:
  * Remove the metadata (struct kmemleak_object) for a memory block from the
  * object_list and object_tree_root and decrement its use_count.
  */
-static void delete_object(unsigned long ptr)
+static void __delete_object(struct kmemleak_object *object)
 {
 	unsigned long flags;
-	struct kmemleak_object *object;
 
 	write_lock_irqsave(&kmemleak_lock, flags);
-	object = lookup_object(ptr, 0);
-	if (!object) {
-#ifdef DEBUG
-		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
-			      ptr);
-#endif
-		write_unlock_irqrestore(&kmemleak_lock, flags);
-		return;
-	}
 	prio_tree_remove(&object_tree_root, &object->tree_node);
 	list_del_rcu(&object->object_list);
 	write_unlock_irqrestore(&kmemleak_lock, flags);
 
 	WARN_ON(!(object->flags & OBJECT_ALLOCATED));
-	WARN_ON(atomic_read(&object->use_count) < 1);
+	WARN_ON(atomic_read(&object->use_count) < 2);
 
 	/*
 	 * Locking here also ensures that the corresponding memory block
@@ -557,6 +548,64 @@ static void delete_object(unsigned long ptr)
 }
 
 /*
+ * Look up the metadata (struct kmemleak_object) corresponding to ptr and
+ * delete it.
+ */
+static void delete_object_full(unsigned long ptr)
+{
+	struct kmemleak_object *object;
+
+	object = find_and_get_object(ptr, 0);
+	if (!object) {
+#ifdef DEBUG
+		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
+			      ptr);
+#endif
+		return;
+	}
+	__delete_object(object);
+	put_object(object);
+}
+
+/*
+ * Look up the metadata (struct kmemleak_object) corresponding to ptr and
+ * delete it. If the memory block is partially freed, the function may create
+ * additional metadata for the remaining parts of the block.
+ */
+static void delete_object_part(unsigned long ptr, size_t size)
+{
+	struct kmemleak_object *object;
+	unsigned long start, end;
+
+	object = find_and_get_object(ptr, 1);
+	if (!object) {
+#ifdef DEBUG
+		kmemleak_warn("Partially freeing unknown object at 0x%08lx "
+			      "(size %zu)\n", ptr, size);
+#endif
+		return;
+	}
+	__delete_object(object);
+
+	/*
+	 * Create one or two objects that may result from the memory block
+	 * split. Note that partial freeing is only done by free_bootmem() and
+	 * this happens before kmemleak_init() is called. The path below is
+	 * only executed during early log recording in kmemleak_init(), so
+	 * GFP_KERNEL is enough.
+	 */
+	start = object->pointer;
+	end = object->pointer + object->size;
+	if (ptr > start)
+		create_object(start, ptr - start, object->min_count,
+			      GFP_KERNEL);
+	if (ptr + size < end)
+		create_object(ptr + size, end - ptr - size, object->min_count,
+			      GFP_KERNEL);
+
+	put_object(object);
+}
+/*
  * Make a object permanently as gray-colored so that it can no longer be
  * reported as a leak. This is used in general to mark a false positive.
  */
@@ -720,13 +769,28 @@ void kmemleak_free(const void *ptr)
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
 	if (atomic_read(&kmemleak_enabled) && ptr && !IS_ERR(ptr))
-		delete_object((unsigned long)ptr);
+		delete_object_full((unsigned long)ptr);
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
+		delete_object_part((unsigned long)ptr, size);
+	else if (atomic_read(&kmemleak_early_log))
+		log_early(KMEMLEAK_FREE_PART, ptr, size, 0, 0, 0);
+}
+EXPORT_SYMBOL_GPL(kmemleak_free_part);
+
+/*
  * Mark an already allocated memory block as a false positive. This will cause
  * the block to no longer be reported as leak and always be scanned.
  */
@@ -1345,7 +1409,7 @@ static int kmemleak_cleanup_thread(void *arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(object, &object_list, object_list)
-		delete_object(object->pointer);
+		delete_object_full(object->pointer);
 	rcu_read_unlock();
 	mutex_unlock(&scan_mutex);
 
@@ -1440,6 +1504,9 @@ void __init kmemleak_init(void)
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
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
