Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 51B526B0081
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:29:36 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so78640755qkh.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:29:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u2si2659175qhd.75.2015.06.08.07.29.34
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 07:29:35 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 2/4] mm: kmemleak: Fix delete_object_*() race when called on the same memory block
Date: Mon,  8 Jun 2015 15:29:16 +0100
Message-Id: <1433773758-21994-3-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
References: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, vigneshr@codeaurora.org

Calling delete_object_*() on the same pointer is not a standard use case
(unless there is a bug in the code calling kmemleak_free()). However,
during kmemleak disabling (error or user triggered via /sys), there is a
potential race between kmemleak_free() calls on a CPU and
__kmemleak_do_cleanup() on a different CPU. The current
delete_object_*() implementation first performs a look-up holding
kmemleak_lock, increments the object->use_count and then re-acquires
kmemleak_lock to remove the object from object_tree_root and
object_list.

This patch simplifies the delete_object_*() mechanism to both look up
and remove an object from the object_tree_root and object_list
atomically (guarded by kmemleak_lock). This allows safe concurrent calls
to delete_object_*() on the same pointer without additional locking for
synchronising the kmemleak_free_enabled flag.

A side effect is a slight improvement in the delete_object_*()
performance by avoiding acquiring kmemleak_lock twice and
incrementing/decrementing object->use_count.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/kmemleak.c | 39 ++++++++++++++++++++++++++-------------
 1 file changed, 26 insertions(+), 13 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 41df5b8efd25..ecde522ff616 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -498,6 +498,27 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
 }
 
 /*
+ * Look up an object in the object search tree and remove it from both
+ * object_tree_root and object_list. The returned object's use_count should be
+ * at least 1, as initially set by create_object().
+ */
+static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int alias)
+{
+	unsigned long flags;
+	struct kmemleak_object *object;
+
+	write_lock_irqsave(&kmemleak_lock, flags);
+	object = lookup_object(ptr, alias);
+	if (object) {
+		rb_erase(&object->rb_node, &object_tree_root);
+		list_del_rcu(&object->object_list);
+	}
+	write_unlock_irqrestore(&kmemleak_lock, flags);
+
+	return object;
+}
+
+/*
  * Save stack trace to the given array of MAX_TRACE size.
  */
 static int __save_stack_trace(unsigned long *trace)
@@ -600,20 +621,14 @@ out:
 }
 
 /*
- * Remove the metadata (struct kmemleak_object) for a memory block from the
- * object_list and object_tree_root and decrement its use_count.
+ * Mark the object as not allocated and schedule RCU freeing via put_object().
  */
 static void __delete_object(struct kmemleak_object *object)
 {
 	unsigned long flags;
 
-	write_lock_irqsave(&kmemleak_lock, flags);
-	rb_erase(&object->rb_node, &object_tree_root);
-	list_del_rcu(&object->object_list);
-	write_unlock_irqrestore(&kmemleak_lock, flags);
-
 	WARN_ON(!(object->flags & OBJECT_ALLOCATED));
-	WARN_ON(atomic_read(&object->use_count) < 2);
+	WARN_ON(atomic_read(&object->use_count) < 1);
 
 	/*
 	 * Locking here also ensures that the corresponding memory block
@@ -633,7 +648,7 @@ static void delete_object_full(unsigned long ptr)
 {
 	struct kmemleak_object *object;
 
-	object = find_and_get_object(ptr, 0);
+	object = find_and_remove_object(ptr, 0);
 	if (!object) {
 #ifdef DEBUG
 		kmemleak_warn("Freeing unknown object at 0x%08lx\n",
@@ -642,7 +657,6 @@ static void delete_object_full(unsigned long ptr)
 		return;
 	}
 	__delete_object(object);
-	put_object(object);
 }
 
 /*
@@ -655,7 +669,7 @@ static void delete_object_part(unsigned long ptr, size_t size)
 	struct kmemleak_object *object;
 	unsigned long start, end;
 
-	object = find_and_get_object(ptr, 1);
+	object = find_and_remove_object(ptr, 1);
 	if (!object) {
 #ifdef DEBUG
 		kmemleak_warn("Partially freeing unknown object at 0x%08lx "
@@ -663,7 +677,6 @@ static void delete_object_part(unsigned long ptr, size_t size)
 #endif
 		return;
 	}
-	__delete_object(object);
 
 	/*
 	 * Create one or two objects that may result from the memory block
@@ -681,7 +694,7 @@ static void delete_object_part(unsigned long ptr, size_t size)
 		create_object(ptr + size, end - ptr - size, object->min_count,
 			      GFP_KERNEL);
 
-	put_object(object);
+	__delete_object(object);
 }
 
 static void __paint_it(struct kmemleak_object *object, int color)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
