Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC59831F5
	for <linux-mm@kvack.org>; Mon, 22 May 2017 13:35:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e131so135534884pfh.7
        for <linux-mm@kvack.org>; Mon, 22 May 2017 10:35:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z20si17479526pfi.56.2017.05.22.10.35.25
        for <linux-mm@kvack.org>;
        Mon, 22 May 2017 10:35:25 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: kmemleak: Treat vm_struct as alternative reference to vmalloc'ed objects
Date: Mon, 22 May 2017 18:35:14 +0100
Message-Id: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>

Kmemleak requires that vmalloc'ed objects have a minimum reference count
of 2: one in the corresponding vm_struct object and the other owned by
the vmalloc() caller. There are cases, however, where the original
vmalloc() returned pointer is lost and, instead, a pointer to vm_struct
is stored (see free_thread_stack()). Kmemleak currently reports such
objects as leaks.

This patch adds support for treating any surplus references to an object
as additional references to a specified object. It introduces the
kmemleak_vmalloc() API function which takes a vm_struct pointer and sets
its surplus reference passing to the actual vmalloc() returned pointer.
The __vmalloc_node_range() calling site has been modified accordingly.

An unrelated minor change is included in this patch to change the type
of kmemleak_object.flags to unsigned int (previously unsigned long).

Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

Hi,

As per [1], I added support to use pointers to vm_struct as an
alternative way to avoid false positives when the original vmalloc()
pointer has been lost. This is slightly harder to reason about but it
seems to work for this use-case. I'm not aware of other cases (than
free_thread_stack()) where the original vmalloc() pointer is removed in
favour of a vm_struct one.

An alternative implementation (simpler to understand), if preferred, is
to annotate alloc_thread_stack_node() and free_thread_stack() with
kmemleak_unignore()/kmemleak_ignore() calls and proper comments.

Feedback welcome, I'm fine with either option.

Thanks.

[1] http://lkml.kernel.org/r/20170517110922.GA18716@e104818-lin.cambridge.arm.com

 Documentation/dev-tools/kmemleak.rst |   1 +
 include/linux/kmemleak.h             |   7 ++
 mm/kmemleak.c                        | 136 +++++++++++++++++++++++++++++------
 mm/vmalloc.c                         |   7 +-
 4 files changed, 122 insertions(+), 29 deletions(-)

diff --git a/Documentation/dev-tools/kmemleak.rst b/Documentation/dev-tools/kmemleak.rst
index b2391b829169..cb8862659178 100644
--- a/Documentation/dev-tools/kmemleak.rst
+++ b/Documentation/dev-tools/kmemleak.rst
@@ -150,6 +150,7 @@ See the include/linux/kmemleak.h header for the functions prototype.
 - ``kmemleak_init``		 - initialize kmemleak
 - ``kmemleak_alloc``		 - notify of a memory block allocation
 - ``kmemleak_alloc_percpu``	 - notify of a percpu memory block allocation
+- ``kmemleak_vmalloc``		 - notify of a vmalloc() memory allocation
 - ``kmemleak_free``		 - notify of a memory block freeing
 - ``kmemleak_free_part``	 - notify of a partial memory block freeing
 - ``kmemleak_free_percpu``	 - notify of a percpu memory block freeing
diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 1c2a32829620..590343f6c1b1 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -22,6 +22,7 @@
 #define __KMEMLEAK_H
 
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 #ifdef CONFIG_DEBUG_KMEMLEAK
 
@@ -30,6 +31,8 @@ extern void kmemleak_alloc(const void *ptr, size_t size, int min_count,
 			   gfp_t gfp) __ref;
 extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
 				  gfp_t gfp) __ref;
+extern void kmemleak_vmalloc(const struct vm_struct *area, size_t size,
+			     gfp_t gfp) __ref;
 extern void kmemleak_free(const void *ptr) __ref;
 extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
 extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
@@ -81,6 +84,10 @@ static inline void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
 					 gfp_t gfp)
 {
 }
+static inline void kmemleak_vmalloc(const struct vm_struct *area, size_t size,
+				    gfp_t gfp)
+{
+}
 static inline void kmemleak_free(const void *ptr)
 {
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 20036d4f9f13..11ab654502fd 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -150,7 +150,7 @@ struct kmemleak_scan_area {
  */
 struct kmemleak_object {
 	spinlock_t lock;
-	unsigned long flags;		/* object status flags */
+	unsigned int flags;		/* object status flags */
 	struct list_head object_list;
 	struct list_head gray_list;
 	struct rb_node rb_node;
@@ -159,6 +159,8 @@ struct kmemleak_object {
 	atomic_t use_count;
 	unsigned long pointer;
 	size_t size;
+	/* pass surplus references to this pointer */
+	unsigned long excess_ref;
 	/* minimum number of a pointers found before it is considered leak */
 	int min_count;
 	/* the total number of pointers found pointing to this object */
@@ -253,7 +255,8 @@ enum {
 	KMEMLEAK_NOT_LEAK,
 	KMEMLEAK_IGNORE,
 	KMEMLEAK_SCAN_AREA,
-	KMEMLEAK_NO_SCAN
+	KMEMLEAK_NO_SCAN,
+	KMEMLEAK_SET_EXCESS_REF
 };
 
 /*
@@ -262,9 +265,12 @@ enum {
  */
 struct early_log {
 	int op_type;			/* kmemleak operation type */
-	const void *ptr;		/* allocated/freed memory block */
-	size_t size;			/* memory block size */
 	int min_count;			/* minimum reference count */
+	const void *ptr;		/* allocated/freed memory block */
+	union {
+		size_t size;		/* memory block size */
+		unsigned long excess_ref; /* surplus reference passing */
+	};
 	unsigned long trace[MAX_TRACE];	/* stack trace */
 	unsigned int trace_len;		/* stack trace length */
 };
@@ -393,7 +399,7 @@ static void dump_object_info(struct kmemleak_object *object)
 		  object->comm, object->pid, object->jiffies);
 	pr_notice("  min_count = %d\n", object->min_count);
 	pr_notice("  count = %d\n", object->count);
-	pr_notice("  flags = 0x%lx\n", object->flags);
+	pr_notice("  flags = 0x%x\n", object->flags);
 	pr_notice("  checksum = %u\n", object->checksum);
 	pr_notice("  backtrace:\n");
 	print_stack_trace(&trace, 4);
@@ -562,6 +568,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	object->flags = OBJECT_ALLOCATED;
 	object->pointer = ptr;
 	object->size = size;
+	object->excess_ref = 0;
 	object->min_count = min_count;
 	object->count = 0;			/* white color initially */
 	object->jiffies = jiffies;
@@ -795,6 +802,30 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 }
 
 /*
+ * Any surplus references (object already gray) to 'ptr' are passed to
+ * 'excess_ref'. This is used in the vmalloc() case where a pointer to
+ * vm_struct may be used as an alternative reference to the vmalloc'ed object
+ * (see free_thread_stack()).
+ */
+static void object_set_excess_ref(unsigned long ptr, unsigned long excess_ref)
+{
+	unsigned long flags;
+	struct kmemleak_object *object;
+
+	object = find_and_get_object(ptr, 0);
+	if (!object) {
+		kmemleak_warn("Setting excess_ref on unknown object at 0x%08lx\n",
+			      ptr);
+		return;
+	}
+
+	spin_lock_irqsave(&object->lock, flags);
+	object->excess_ref = excess_ref;
+	spin_unlock_irqrestore(&object->lock, flags);
+	put_object(object);
+}
+
+/*
  * Set the OBJECT_NO_SCAN flag for the object corresponding to the give
  * pointer. Such object will not be scanned by kmemleak but references to it
  * are searched.
@@ -908,7 +939,7 @@ static void early_alloc_percpu(struct early_log *log)
  * @gfp:	kmalloc() flags used for kmemleak internal memory allocations
  *
  * This function is called from the kernel allocators when a new object
- * (memory block) is allocated (kmem_cache_alloc, kmalloc, vmalloc etc.).
+ * (memory block) is allocated (kmem_cache_alloc, kmalloc etc.).
  */
 void __ref kmemleak_alloc(const void *ptr, size_t size, int min_count,
 			  gfp_t gfp)
@@ -952,6 +983,36 @@ void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
 EXPORT_SYMBOL_GPL(kmemleak_alloc_percpu);
 
 /**
+ * kmemleak_vmalloc - register a newly vmalloc'ed object
+ * @area:	pointer to vm_struct
+ * @size:	size of the object
+ * @gfp:	__vmalloc() flags used for kmemleak internal memory allocations
+ *
+ * This function is called from the vmalloc() kernel allocator when a new
+ * object (memory block) is allocated.
+ */
+void __ref kmemleak_vmalloc(const struct vm_struct *area, size_t size, gfp_t gfp)
+{
+	pr_debug("%s(0x%p, %zu)\n", __func__, area, size);
+
+	/*
+	 * A min_count = 2 is needed because vm_struct contains a reference to
+	 * the virtual address of the vmalloc'ed block.
+	 */
+	if (kmemleak_enabled) {
+		create_object((unsigned long)area->addr, size, 2, gfp);
+		object_set_excess_ref((unsigned long)area,
+				      (unsigned long)area->addr);
+	} else if (kmemleak_early_log) {
+		log_early(KMEMLEAK_ALLOC, area->addr, size, 2);
+		/* reusing early_log.size for storing area->addr */
+		log_early(KMEMLEAK_SET_EXCESS_REF,
+			  area, (unsigned long)area->addr, 0);
+	}
+}
+EXPORT_SYMBOL_GPL(kmemleak_vmalloc);
+
+/**
  * kmemleak_free - unregister a previously registered object
  * @ptr:	pointer to beginning of the object
  *
@@ -1188,6 +1249,30 @@ static bool update_checksum(struct kmemleak_object *object)
 }
 
 /*
+ * Update an object's references. object->lock must be held by the caller.
+ */
+static void update_refs(struct kmemleak_object *object)
+{
+	if (!color_white(object)) {
+		/* non-orphan, ignored or new */
+		return;
+	}
+
+	/*
+	 * Increase the object's reference count (number of pointers to the
+	 * memory block). If this count reaches the required minimum, the
+	 * object's color will become gray and it will be added to the
+	 * gray_list.
+	 */
+	object->count++;
+	if (color_gray(object)) {
+		/* put_object() called when removing from gray_list */
+		WARN_ON(!get_object(object));
+		list_add_tail(&object->gray_list, &gray_list);
+	}
+}
+
+/*
  * Memory scanning is a long process and it needs to be interruptable. This
  * function checks whether such interrupt condition occurred.
  */
@@ -1224,6 +1309,7 @@ static void scan_block(void *_start, void *_end,
 	for (ptr = start; ptr < end; ptr++) {
 		struct kmemleak_object *object;
 		unsigned long pointer;
+		unsigned long excess_ref;
 
 		if (scan_should_stop())
 			break;
@@ -1259,25 +1345,25 @@ static void scan_block(void *_start, void *_end,
 		 * enclosed by scan_mutex.
 		 */
 		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
-		if (!color_white(object)) {
-			/* non-orphan, ignored or new */
-			spin_unlock(&object->lock);
-			continue;
-		}
+		/* only pass surplus references (object already gray) */
+		if (color_gray(object))
+			excess_ref = object->excess_ref;
+		else
+			excess_ref = 0;
+		update_refs(object);
+		spin_unlock(&object->lock);
 
-		/*
-		 * Increase the object's reference count (number of pointers
-		 * to the memory block). If this count reaches the required
-		 * minimum, the object's color will become gray and it will be
-		 * added to the gray_list.
-		 */
-		object->count++;
-		if (color_gray(object)) {
-			/* put_object() called when removing from gray_list */
-			WARN_ON(!get_object(object));
-			list_add_tail(&object->gray_list, &gray_list);
+		if (excess_ref) {
+			object = lookup_object(excess_ref, 0);
+			if (!object)
+				continue;
+			if (object == scanned)
+				/* circular reference, ignore */
+				continue;
+			spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
+			update_refs(object);
+			spin_unlock(&object->lock);
 		}
-		spin_unlock(&object->lock);
 	}
 	read_unlock_irqrestore(&kmemleak_lock, flags);
 }
@@ -1980,6 +2066,10 @@ void __init kmemleak_init(void)
 		case KMEMLEAK_NO_SCAN:
 			kmemleak_no_scan(log->ptr);
 			break;
+		case KMEMLEAK_SET_EXCESS_REF:
+			object_set_excess_ref((unsigned long)log->ptr,
+					      log->excess_ref);
+			break;
 		default:
 			kmemleak_warn("Unknown early log operation: %d\n",
 				      log->op_type);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e46ed7..b805cc5ecca0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1759,12 +1759,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	 */
 	clear_vm_uninitialized_flag(area);
 
-	/*
-	 * A ref_count = 2 is needed because vm_struct allocated in
-	 * __get_vm_area_node() contains a reference to the virtual address of
-	 * the vmalloc'ed block.
-	 */
-	kmemleak_alloc(addr, real_size, 2, gfp_mask);
+	kmemleak_vmalloc(area, size, gfp_mask);
 
 	return addr;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
