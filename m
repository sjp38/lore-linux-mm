Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B5D2C6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:07:40 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so1234479ggn.14
        for <linux-mm@kvack.org>; Wed, 08 Aug 2012 10:07:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344324343-3817-4-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
	<1344324343-3817-4-git-send-email-walken@google.com>
Date: Wed, 8 Aug 2012 10:07:39 -0700
Message-ID: <CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
Subject: Re: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Forgot to add Catalin on this review...

---------- Forwarded message ----------
From: Michel Lespinasse <walken@google.com>
Date: Tue, Aug 7, 2012 at 12:25 AM
Subject: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
To: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu,
daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org,
akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
torvalds@linux-foundation.org


kmemleak uses a tree where each node represents an allocated memory object
in order to quickly find out what object a given address is part of.
However, the objects don't overlap, so rbtrees are a better choice than
prio tree for this use. They are both faster and have lower memory overhead.

Tested by booting a kernel with kmemleak enabled, loading the kmemleak_test
module, and looking for the expected messages.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/kmemleak.c |   98 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 45eb621..8de1b09 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -29,7 +29,7 @@
  * - kmemleak_lock (rwlock): protects the object_list modifications and
  *   accesses to the object_tree_root. The object_list is the main list
  *   holding the metadata (struct kmemleak_object) for the allocated memory
- *   blocks. The object_tree_root is a priority search tree used to look-up
+ *   blocks. The object_tree_root is a red black tree used to look-up
  *   metadata based on a pointer to the corresponding memory block.  The
  *   kmemleak_object structures are added to the object_list and
  *   object_tree_root in the create_object() function called from the
@@ -71,7 +71,7 @@
 #include <linux/delay.h>
 #include <linux/export.h>
 #include <linux/kthread.h>
-#include <linux/prio_tree.h>
+#include <linux/rbtree.h>
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
@@ -132,7 +132,7 @@ struct kmemleak_scan_area {
  * Structure holding the metadata for each allocated memory block.
  * Modifications to such objects should be made while holding the
  * object->lock. Insertions or deletions from object_list, gray_list or
- * tree_node are already protected by the corresponding locks or mutex (see
+ * rb_node are already protected by the corresponding locks or mutex (see
  * the notes on locking above). These objects are reference-counted
  * (use_count) and freed using the RCU mechanism.
  */
@@ -141,7 +141,7 @@ struct kmemleak_object {
        unsigned long flags;            /* object status flags */
        struct list_head object_list;
        struct list_head gray_list;
-       struct prio_tree_node tree_node;
+       struct rb_node rb_node;
        struct rcu_head rcu;            /* object_list lockless traversal */
        /* object usage count; object freed when use_count == 0 */
        atomic_t use_count;
@@ -182,9 +182,9 @@ struct kmemleak_object {
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
 static LIST_HEAD(gray_list);
-/* prio search tree for object boundaries */
-static struct prio_tree_root object_tree_root;
-/* rw_lock protecting the access to object_list and prio_tree_root */
+/* search tree for object boundaries */
+static struct rb_root object_tree_root = RB_ROOT;
+/* rw_lock protecting the access to object_list and object_tree_root */
 static DEFINE_RWLOCK(kmemleak_lock);

 /* allocation caches for kmemleak internal data */
@@ -380,7 +380,7 @@ static void dump_object_info(struct kmemleak_object *object)
        trace.entries = object->trace;

        pr_notice("Object 0x%08lx (size %zu):\n",
-                 object->tree_node.start, object->size);
+                 object->pointer, object->size);
        pr_notice("  comm \"%s\", pid %d, jiffies %lu\n",
                  object->comm, object->pid, object->jiffies);
        pr_notice("  min_count = %d\n", object->min_count);
@@ -392,32 +392,32 @@ static void dump_object_info(struct
kmemleak_object *object)
 }

 /*
- * Look-up a memory block metadata (kmemleak_object) in the priority search
+ * Look-up a memory block metadata (kmemleak_object) in the object search
  * tree based on a pointer value. If alias is 0, only values pointing to the
  * beginning of the memory block are allowed. The kmemleak_lock must be held
  * when calling this function.
  */
 static struct kmemleak_object *lookup_object(unsigned long ptr, int alias)
 {
-       struct prio_tree_node *node;
-       struct prio_tree_iter iter;
-       struct kmemleak_object *object;
-
-       prio_tree_iter_init(&iter, &object_tree_root, ptr, ptr);
-       node = prio_tree_next(&iter);
-       if (node) {
-               object = prio_tree_entry(node, struct kmemleak_object,
-                                        tree_node);
-               if (!alias && object->pointer != ptr) {
+       struct rb_node *rb = object_tree_root.rb_node;
+
+       while (rb) {
+               struct kmemleak_object *object =
+                       rb_entry(rb, struct kmemleak_object, rb_node);
+               if (ptr < object->pointer)
+                       rb = object->rb_node.rb_left;
+               else if (object->pointer + object->size <= ptr)
+                       rb = object->rb_node.rb_right;
+               else if (object->pointer == ptr || alias)
+                       return object;
+               else {
                        kmemleak_warn("Found object by alias at 0x%08lx\n",
                                      ptr);
                        dump_object_info(object);
-                       object = NULL;
+                       break;
                }
-       } else
-               object = NULL;
-
-       return object;
+       }
+       return NULL;
 }

 /*
@@ -471,7 +471,7 @@ static void put_object(struct kmemleak_object *object)
 }

 /*
- * Look up an object in the prio search tree and increase its use_count.
+ * Look up an object in the object search tree and increase its use_count.
  */
 static struct kmemleak_object *find_and_get_object(unsigned long ptr,
int alias)
 {
@@ -516,8 +516,8 @@ static struct kmemleak_object
*create_object(unsigned long ptr, size_t size,
                                             int min_count, gfp_t gfp)
 {
        unsigned long flags;
-       struct kmemleak_object *object;
-       struct prio_tree_node *node;
+       struct kmemleak_object *object, *parent;
+       struct rb_node **link, *rb_parent;

        object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
        if (!object) {
@@ -560,31 +560,34 @@ static struct kmemleak_object
*create_object(unsigned long ptr, size_t size,
        /* kernel backtrace */
        object->trace_len = __save_stack_trace(object->trace);

-       INIT_PRIO_TREE_NODE(&object->tree_node);
-       object->tree_node.start = ptr;
-       object->tree_node.last = ptr + size - 1;
-
        write_lock_irqsave(&kmemleak_lock, flags);

        min_addr = min(min_addr, ptr);
        max_addr = max(max_addr, ptr + size);
-       node = prio_tree_insert(&object_tree_root, &object->tree_node);
-       /*
-        * The code calling the kernel does not yet have the pointer to the
-        * memory block to be able to free it.  However, we still hold the
-        * kmemleak_lock here in case parts of the kernel started freeing
-        * random memory blocks.
-        */
-       if (node != &object->tree_node) {
-               kmemleak_stop("Cannot insert 0x%lx into the object search tree "
-                             "(already existing)\n", ptr);
-               object = lookup_object(ptr, 1);
-               spin_lock(&object->lock);
-               dump_object_info(object);
-               spin_unlock(&object->lock);

-               goto out;
+       link = &object_tree_root.rb_node;
+       rb_parent = NULL;
+       while (*link) {
+               rb_parent = *link;
+               parent = rb_entry(rb_parent, struct kmemleak_object, rb_node);
+               if (ptr + size <= parent->pointer)
+                       link = &parent->rb_node.rb_left;
+               else if (parent->pointer + parent->size <= ptr)
+                       link = &parent->rb_node.rb_right;
+               else {
+                       kmemleak_stop("Cannot insert 0x%lx into the object "
+                                     "search tree (overlaps existing)\n",
+                                     ptr);
+                       object = parent;
+                       spin_lock(&object->lock);
+                       dump_object_info(object);
+                       spin_unlock(&object->lock);
+                       goto out;
+               }
        }
+       rb_link_node(&object->rb_node, rb_parent, link);
+       rb_insert_color(&object->rb_node, &object_tree_root);
+
        list_add_tail_rcu(&object->object_list, &object_list);
 out:
        write_unlock_irqrestore(&kmemleak_lock, flags);
@@ -600,7 +603,7 @@ static void __delete_object(struct kmemleak_object *object)
        unsigned long flags;

        write_lock_irqsave(&kmemleak_lock, flags);
-       prio_tree_remove(&object_tree_root, &object->tree_node);
+       rb_erase(&object->rb_node, &object_tree_root);
        list_del_rcu(&object->object_list);
        write_unlock_irqrestore(&kmemleak_lock, flags);

@@ -1768,7 +1771,6 @@ void __init kmemleak_init(void)

        object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
        scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
-       INIT_PRIO_TREE_ROOT(&object_tree_root);

        if (crt_early_log >= ARRAY_SIZE(early_log))
                pr_warning("Early log buffer exceeded (%d), please increase "
--
1.7.7.3


-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
