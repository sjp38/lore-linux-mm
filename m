Received: from wip-ec-wd.wipro.com (localhost.wipro.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id 7F57B205F6
	for <linux-mm@kvack.org>; Mon, 19 Jun 2006 18:14:13 +0530 (IST)
Received: from blr-ec-bh01.wipro.com (blr-ec-bh01.wipro.com [10.201.50.91])
	by wip-ec-wd.wipro.com (Postfix) with ESMTP id 69BF0205F1
	for <linux-mm@kvack.org>; Mon, 19 Jun 2006 18:14:13 +0530 (IST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: Patch required for memory leak detection for 2.6.15.4
Date: Mon, 19 Jun 2006 18:16:22 +0530
Message-ID: <C1BBF34889A04C4C8ACEE5C7CC753FDFCCA6A5@PNE-HJN-MBX01.wipro.com>
From: <bhuvan.kumarmital@wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 


 
I am trying to enable memory leak detection for kernel 2.6.15.4 on
fedora core 4. I guess i need to do some modification to mm/slab.c and
lib/Kconfig.debug. 
I am not sure about what to do exactly. Can someone help me? Does any
other file require to be modified (patched)? Would the following patch
work for me :
 
---
lib/Kconfig.debug |   12 ++++++++++++
mm/slab.c         |   49
+++++++++++++++++++++++++++++++++++++++++++++++++
2 files changed, 61 insertions(+)
Index: 2.6-git/mm/slab.c
===================================================================
--- 2.6-git.orig/mm/slab.c
+++ 2.6-git/mm/slab.c
@@ -3669,6 +3669,54 @@ struct seq_operations slabinfo_op = {
.show = s_show,
};

+#ifdef CONFIG_DEBUG_SLAB_LEAK
+
+static void print_slab_last_users(struct kmem_cache *cache, struct slab
*slab)
+{
+ int i;
+
+ for (i = 0; i < cache->num; i++) {
+ void *obj = slab->s_mem + cache->buffer_size * i;
+ unsigned long sym = (unsigned long) *dbg_userword(cache, obj);
+
+ printk("obj %p/%d: %p", slab, i, (void *)sym);
+ print_symbol(" <%s>", sym);
+ printk("\n");
+ }
+}
+
+static void print_cache_last_users(struct kmem_cache *cache)
+{
+ int node;
+
+ if (!(cache->flags & SLAB_STORE_USER))
+ return;
+
+ check_irq_on();
+ spin_lock_irq(&cache->spinlock);
+ for_each_online_node(node) {
+ struct kmem_list3 *lists = cache->nodelists[node];
+ struct list_head *q;
+
+ spin_lock(&lists->list_lock);
+
+ list_for_each(q, &lists->slabs_full) {
+ struct slab *slab = list_entry(q, struct slab, list);
+ print_slab_last_users(cache, slab);
+ }
+ spin_unlock(&lists->list_lock);
+ }
+ spin_unlock_irq(&cache->spinlock);
+}
+
+#else
+
+static void print_cache_last_users(struct kmem_cache *cache)
+{
+}
+
+#endif
+
#define MAX_SLABINFO_WRITE 128
/**
  * slabinfo_write - Tuning for the slab allocator
@@ -3709,6 +3757,7 @@ ssize_t slabinfo_write(struct file *file
if (limit < 1 ||
    batchcount < 1 ||
    batchcount > limit || shared < 0) {
+ print_cache_last_users(cachep);
res = 0;
} else {
res = do_tune_cpucache(cachep, limit,
Index: 2.6-git/lib/Kconfig.debug
===================================================================
--- 2.6-git.orig/lib/Kconfig.debug
+++ 2.6-git/lib/Kconfig.debug
@@ -85,6 +85,18 @@ config DEBUG_SLAB
  allocation as well as poisoning memory on free to catch use of freed
  memory. This can make kmalloc/kfree-intensive workloads much slower.

+config DEBUG_SLAB_LEAK
+ bool "Debug memory leaks"
+ depends on DEBUG_SLAB
+ help
+   Say Y here to have the kernel track last user of a slab object which
+   can be used to detect memory leaks. With this config option enabled,
+
+       echo "size-32 0 0 0" > /proc/slabinfo
+
+   walks the objects in the size-32 slab, printing out the calling
+   address of whoever allocated that object.
+
config DEBUG_PREEMPT
bool "Debug preemptible kernel"
depends on DEBUG_KERNEL && PREEMPT
-

 
Bhuvan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
