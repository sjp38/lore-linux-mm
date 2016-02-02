Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 535146B0254
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 10:57:45 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id o185so102396981pfb.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 07:57:45 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id db2si2576454pad.210.2016.02.02.07.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 07:57:44 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2] mm/slab: fix race with dereferencing NULL ptr in alloc_calls_show
Date: Tue, 2 Feb 2016 18:57:10 +0300
Message-ID: <1454428630-22930-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

memcg_destroy_kmem_caches shutdowns in the first place kmem_caches under
slab_mutex which involves freeing NUMA node structures for kmem_cache
and only then under release_caches removes corresponding sysfs files for
these caches. Which may lead to dereferencing NULL ptr on read.
Lets remove sysfs files right there.

Fixes the following panic:
[43963.463055] BUG: unable to handle kernel
[43963.463090] NULL pointer dereference at 0000000000000020
[43963.463146] IP: [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.463185] PGD 257304067 PUD 438456067 PMD 0
[43963.463220] Oops: 0000 [#1] SMP
[43963.463850] CPU: 3 PID: 973074 Comm: cat ve: 0 Not tainted 3.10.0-229.7.2.ovz.9.30-00007-japdoll-dirty #2 9.30
[43963.463913] Hardware name: DEPO Computers To Be Filled By O.E.M./H67DE3, BIOS L1.60c 07/14/2011
[43963.463976] task: ffff88042a5dc5b0 ti: ffff88037f8d8000 task.ti: ffff88037f8d8000
[43963.464036] RIP: 0010:[<ffffffff811c6959>]  [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.464725] Call Trace:
[43963.464756]  [<ffffffff811c6d1d>] alloc_calls_show+0x1d/0x30
[43963.464793]  [<ffffffff811c15ab>] slab_attr_show+0x1b/0x30
[43963.464829]  [<ffffffff8125d27a>] sysfs_read_file+0x9a/0x1a0
[43963.464865]  [<ffffffff811e3c6c>] vfs_read+0x9c/0x170
[43963.464900]  [<ffffffff811e4798>] SyS_read+0x58/0xb0
[43963.464936]  [<ffffffff81612d49>] system_call_fastpath+0x16/0x1b
[43963.464970] Code: 5e 07 12 00 b9 00 04 00 00 3d 00 04 00 00 0f 4f c1 3d 00 04 00 00 89 45 b0 0f 84 c3 00 00 00 48 63 45 b0 49 8b 9c c4 f8 00 00 00 <48> 8b 43 20 48 85 c0 74 b6 48 89 df e8 46 37 44 00 48 8b 53 10
[43963.465119] RIP  [<ffffffff811c6959>] list_locations+0x169/0x4e0
[43963.465155]  RSP <ffff88037f8dbe28>
[43963.465185] CR2: 0000000000000020

Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
v2: Down with SLAB_SUPPORTS_SYSFS thing.

 include/linux/slub_def.h | 10 ----------
 mm/slab.h                |  8 ++++++++
 mm/slab_common.c         | 10 ++++------
 mm/slub.c                |  6 ------
 4 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index b7e57927..43634cd 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -101,16 +101,6 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-#ifdef CONFIG_SYSFS
-#define SLAB_SUPPORTS_SYSFS
-void sysfs_slab_remove(struct kmem_cache *);
-#else
-static inline void sysfs_slab_remove(struct kmem_cache *s)
-{
-}
-#endif
-
-
 /**
  * virt_to_obj - returns address of the beginning of object.
  * @s: object's kmem_cache
diff --git a/mm/slab.h b/mm/slab.h
index 834ad24..2983ab2 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -367,6 +367,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 
 #endif
 
+#if defined(CONFIG_SLUB) && defined(CONFIG_SYSFS)
+void sysfs_slab_remove(struct kmem_cache *);
+#else
+static inline void sysfs_slab_remove(struct kmem_cache *s)
+{
+}
+#endif
+
 void *slab_start(struct seq_file *m, loff_t *pos);
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b50aef0..6725eb3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -468,13 +468,8 @@ static void release_caches(struct list_head *release, bool need_rcu_barrier)
 	if (need_rcu_barrier)
 		rcu_barrier();
 
-	list_for_each_entry_safe(s, s2, release, list) {
-#ifdef SLAB_SUPPORTS_SYSFS
-		sysfs_slab_remove(s);
-#else
+	list_for_each_entry_safe(s, s2, release, list)
 		slab_kmem_cache_release(s);
-#endif
-	}
 }
 
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
@@ -614,6 +609,9 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 	list_for_each_entry_safe(s, s2, &slab_caches, list) {
 		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
 			continue;
+
+		sysfs_slab_remove(s);
+
 		/*
 		 * The cgroup is about to be freed and therefore has no charges
 		 * left. Hence, all its caches must be empty by now.
diff --git a/mm/slub.c b/mm/slub.c
index 2e1355a..b6a68b7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5296,11 +5296,6 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 #endif
 }
 
-static void kmem_cache_release(struct kobject *k)
-{
-	slab_kmem_cache_release(to_slab(k));
-}
-
 static const struct sysfs_ops slab_sysfs_ops = {
 	.show = slab_attr_show,
 	.store = slab_attr_store,
@@ -5308,7 +5303,6 @@ static const struct sysfs_ops slab_sysfs_ops = {
 
 static struct kobj_type slab_ktype = {
 	.sysfs_ops = &slab_sysfs_ops,
-	.release = kmem_cache_release,
 };
 
 static int uevent_filter(struct kset *kset, struct kobject *kobj)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
