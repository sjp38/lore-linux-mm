Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C2EA66B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:38:52 -0400 (EDT)
Subject: Re: [RFC PATCH 1/3] kmemleak: Allow partial freeing of memory blocks
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	<20090706105149.16051.99106.stgit@pc1117.cambridge.arm.com>
	<1246950733.24285.10.camel@penberg-laptop>
	<tnxtz1ovq8p.fsf@pc1117.cambridge.arm.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 07 Jul 2009 14:39:20 +0100
In-Reply-To: <tnxtz1ovq8p.fsf@pc1117.cambridge.arm.com> (Catalin Marinas's message of "Tue\, 07 Jul 2009 09\:42\:14 +0100")
Message-ID: <tnxiqi4vchj.fsf@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Catalin Marinas <catalin.marinas@arm.com> wrote:
> Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>> On Mon, 2009-07-06 at 11:51 +0100, Catalin Marinas wrote:
>>> @@ -552,8 +558,29 @@ static void delete_object(unsigned long ptr)
>>>  	 */
>>>  	spin_lock_irqsave(&object->lock, flags);
>>>  	object->flags &= ~OBJECT_ALLOCATED;
>>> +	start = object->pointer;
>>> +	end = object->pointer + object->size;
>>> +	min_count = object->min_count;
>>>  	spin_unlock_irqrestore(&object->lock, flags);
>>>  	put_object(object);
>>> +
>>> +	if (!size)
>>> +		return;
>>> +
>>> +	/*
>>> +	 * Partial freeing. Just create one or two objects that may result
>>> +	 * from the memory block split.
>>> +	 */
>>> +	if (in_atomic())
>>> +		gfp_flags = GFP_ATOMIC;
>>> +	else
>>> +		gfp_flags = GFP_KERNEL;
>>
>> Are you sure we can do this? There's a big fat comment on top of
>> in_atomic() that suggest this is not safe.
[...]
> That's the free_bootmem case where Linux can only partially free a
> block previously allocated with alloc_bootmem (that's why I haven't
> tracked this from the beginning). So if it only frees some part in the
> middle of a block, I would have to create two separate
> kmemleak_objects (well, I can reuse one but I preferred fewer
> modifications as this is not on a fast path anyway).
>
> In the tests I did, free_bootmem is called before the slab allocator
> is initialised and therefore before kmemleak is initialised, which
> means that the requests are just logged and the kmemleak_* functions
> are called later from the kmemleak_init() function. All allocations
> via this function are fine to only use GFP_KERNEL.

Here's an updated patch:


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
 include/linux/kmemleak.h |    4 ++++
 mm/kmemleak.c            |   52 ++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 51 insertions(+), 5 deletions(-)

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
index 5f7d8ae..8614255 100644
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
@@ -522,15 +523,19 @@ out:
 
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
 
 	write_lock_irqsave(&kmemleak_lock, flags);
-	object = lookup_object(ptr, 0);
+	object = lookup_object(ptr, 1);
 	if (!object) {
 #ifdef DEBUG
 		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
@@ -552,8 +557,27 @@ static void delete_object(unsigned long ptr)
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
+	 * from the memory block split. Note that partial freeing is only done
+	 * by free_bootmem() and this happens before kmemleak_init() is
+	 * called. The path below is only executed during early log recording
+	 * in kmemleak_init(), so GFP_KERNEL is enough.
+	 */
+	if (ptr > start)
+		create_object(start, ptr - start, min_count, GFP_KERNEL);
+	if (ptr + size < end)
+		create_object(ptr + size, end - ptr - size, min_count,
+			      GFP_KERNEL);
 }
 
 /*
@@ -720,13 +744,28 @@ void kmemleak_free(const void *ptr)
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
@@ -1345,7 +1384,7 @@ static int kmemleak_cleanup_thread(void *arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(object, &object_list, object_list)
-		delete_object(object->pointer);
+		delete_object(object->pointer, 0);
 	rcu_read_unlock();
 	mutex_unlock(&scan_mutex);
 
@@ -1440,6 +1479,9 @@ void __init kmemleak_init(void)
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
