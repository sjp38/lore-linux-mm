Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 310096B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 02:48:58 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id go11so214792lbb.36
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 23:48:56 -0800 (PST)
Subject: [PATCH for 3.9] memcg: initialize kmem-cache destroying work earlier
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 07 Mar 2013 11:48:53 +0400
Message-ID: <20130307074853.26272.83618.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>

This patch fixes warning from lockdep caused by calling cancel_work_sync()
for uninitialized struct work. This path has been triggered by destructon
kmem-cache hierarchy via destroying its root kmem-cache.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

---

[  250.781400] cache ffff88003c072d80
[  250.783706] obj ffff88003b410000 cache ffff88003c072d80
[  250.786312] obj ffff88003b924000 cache ffff88003c20bd40
[  250.787233] INFO: trying to register non-static key.
[  250.788046] the code is fine but needs lockdep annotation.
[  250.788184] turning off the locking correctness validator.
[  250.788184] Pid: 2825, comm: insmod Tainted: G           O 3.9.0-rc1-next-20130307+ #611
[  250.788184] Call Trace:
[  250.788184]  [<ffffffff81092ea2>] __lock_acquire+0x16a2/0x1cb0
[  250.788184]  [<ffffffff81093a6a>] lock_acquire+0x8a/0x120
[  250.788184]  [<ffffffff81058ae0>] ? cancel_delayed_work+0xb0/0xb0
[  250.788184]  [<ffffffff81058b18>] flush_work+0x38/0x2a0
[  250.788184]  [<ffffffff81058ae0>] ? cancel_delayed_work+0xb0/0xb0
[  250.788184]  [<ffffffff8109438e>] ? mark_held_locks+0xae/0x120
[  250.788184]  [<ffffffff81058dfd>] ? __cancel_work_timer+0x7d/0xf0
[  250.788184]  [<ffffffff81094505>] ? trace_hardirqs_on_caller+0x105/0x1d0
[  250.788184]  [<ffffffff81058e09>] __cancel_work_timer+0x89/0xf0
[  250.788184]  [<ffffffff81058e8b>] cancel_work_sync+0xb/0x10
[  250.788184]  [<ffffffff8114a401>] kmem_cache_destroy_memcg_children+0x81/0xb0
[  250.788184]  [<ffffffff81114a6f>] kmem_cache_destroy+0xf/0xe0
[  250.788184]  [<ffffffffa000a0cb>] init_module+0xcb/0x1000 [kmem_test]
[  250.788184]  [<ffffffffa000a000>] ? 0xffffffffa0009fff
[  250.788184]  [<ffffffff810002fa>] do_one_initcall+0x11a/0x170
[  250.788184]  [<ffffffff8109fdb0>] load_module+0x19b0/0x2320
[  250.788184]  [<ffffffff8109bfa0>] ? __unlink_module+0x30/0x30
[  250.788184]  [<ffffffff817f365c>] ? retint_restore_args+0xe/0xe
[  250.788184]  [<ffffffff817f365c>] ? retint_restore_args+0xe/0xe
[  250.788184]  [<ffffffff810a07e6>] SyS_init_module+0xc6/0xf0
[  250.788184]  [<ffffffff817fb1d2>] system_call_fastpath+0x16/0x1b

---

#include <linux/module.h>
#include <linux/slab.h>
#include <linux/mm.h>
#include <linux/workqueue.h>

int __init mod_init(void)
{
	int size = 256;
	struct kmem_cache *cache;
	void *obj;
	struct page *page;

	cache = kmem_cache_create("kmem_cache_test", size, size, 0, NULL);
	if (!cache)
		return -ENOMEM;

	printk("cache %p\n", cache);

	obj = kmem_cache_alloc(cache, GFP_KERNEL);
	if (obj) {
		page = virt_to_head_page(obj);
		printk("obj %p cache %p\n", obj, page->slab_cache);
		kmem_cache_free(cache, obj);
	}

	flush_scheduled_work();

	obj = kmem_cache_alloc(cache, GFP_KERNEL);
	if (obj) {
		page = virt_to_head_page(obj);
		printk("obj %p cache %p\n", obj, page->slab_cache);
		kmem_cache_free(cache, obj);
	}

	kmem_cache_destroy(cache);

	return -EBUSY;
}

module_init(mod_init);
MODULE_LICENSE("GPL");
---
 mm/memcontrol.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 669d16a..690fa8c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3078,6 +3078,8 @@ void memcg_update_array_size(int num)
 		memcg_limited_groups_array_size = memcg_caches_array_size(num);
 }
 
+static void kmem_cache_destroy_work_func(struct work_struct *w);
+
 int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 {
 	struct memcg_cache_params *cur_params = s->memcg_params;
@@ -3097,6 +3099,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 			return -ENOMEM;
 		}
 
+		INIT_WORK(&s->memcg_params->destroy,
+				kmem_cache_destroy_work_func);
 		s->memcg_params->is_root_cache = true;
 
 		/*
@@ -3144,6 +3148,8 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
 	if (!s->memcg_params)
 		return -ENOMEM;
 
+	INIT_WORK(&s->memcg_params->destroy,
+			kmem_cache_destroy_work_func);
 	if (memcg) {
 		s->memcg_params->memcg = memcg;
 		s->memcg_params->root_cache = root_cache;
@@ -3424,8 +3430,6 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
 		cachep = memcg_params_to_cache(params);
 		cachep->memcg_params->dead = true;
-		INIT_WORK(&cachep->memcg_params->destroy,
-				  kmem_cache_destroy_work_func);
 		schedule_work(&cachep->memcg_params->destroy);
 	}
 	mutex_unlock(&memcg->slab_caches_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
