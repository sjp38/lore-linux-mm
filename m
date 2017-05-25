Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A02D6B02FA
	for <linux-mm@kvack.org>; Thu, 25 May 2017 11:42:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m5so233666827pfc.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 08:42:32 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x23si28475395pff.102.2017.05.25.08.42.30
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 08:42:31 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 3/3] mm: kmemleak: Treat vm_struct as alternative reference to vmalloc'ed objects
Date: Thu, 25 May 2017 16:42:17 +0100
Message-Id: <1495726937-23557-4-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
References: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

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

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 Documentation/dev-tools/kmemleak.rst |  1 +
 include/linux/kmemleak.h             |  7 +++
 mm/kmemleak.c                        | 93 ++++++++++++++++++++++++++++++++++--
 mm/vmalloc.c                         |  7 +--
 4 files changed, 98 insertions(+), 10 deletions(-)

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
index 266482f460c2..7780cd83a495 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
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
@@ -264,7 +267,10 @@ struct early_log {
 	int op_type;			/* kmemleak operation type */
 	int min_count;			/* minimum reference count */
 	const void *ptr;		/* allocated/freed memory block */
-	size_t size;			/* memory block size */
+	union {
+		size_t size;		/* memory block size */
+		unsigned long excess_ref; /* surplus reference passing */
+	};
 	unsigned long trace[MAX_TRACE];	/* stack trace */
 	unsigned int trace_len;		/* stack trace length */
 };
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
@@ -1248,6 +1309,7 @@ static void scan_block(void *_start, void *_end,
 	for (ptr = start; ptr < end; ptr++) {
 		struct kmemleak_object *object;
 		unsigned long pointer;
+		unsigned long excess_ref;
 
 		if (scan_should_stop())
 			break;
@@ -1283,8 +1345,27 @@ static void scan_block(void *_start, void *_end,
 		 * enclosed by scan_mutex.
 		 */
 		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
-		update_refs(object);
+		/* only pass surplus references (object already gray) */
+		if (color_gray(object)) {
+			excess_ref = object->excess_ref;
+			/* no need for update_refs() if object already gray */
+		} else {
+			excess_ref = 0;
+			update_refs(object);
+		}
 		spin_unlock(&object->lock);
+
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
+		}
 	}
 	read_unlock_irqrestore(&kmemleak_lock, flags);
 }
@@ -1987,6 +2068,10 @@ void __init kmemleak_init(void)
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
