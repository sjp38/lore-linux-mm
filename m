Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 936046B0005
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 18:25:32 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 5-v6so9094684qke.19
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:25:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y13-v6si3227905qve.161.2018.06.15.15.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 15:25:31 -0700 (PDT)
Date: Fri, 15 Jun 2018 18:25:29 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slub: fix failure when we delete and create a slab cache
Message-ID: <alpine.LRH.2.02.1806151817130.6333@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the kernel 4.17 I removed some code from dm-bufio that did slab cache
merging (21bb13276768) - both slab and slub support merging caches with
identical attributes, so dm-bufio now just calls kmem_cache_create and
relies on implicit merging.

This uncovered a bug in the slub subsystem - if we delete a cache and
immediatelly create another cache with the same attributes, it fails
because of duplicate filename in /sys/kernel/slab/. The slub subsystem
offloads freeing the cache to a workqueue - and if we create the new cache
before the workqueue runs, it complains because of duplicate filename in
sysfs.

This patch fixes the bug by moving the call of kobject_del from 
sysfs_slab_remove_workfn to shutdown_cache. kobject_del must be called 
while we hold slab_mutex - so that the sysfs entry is deleted before a 
cache with the same attributes could be created.


Running device-mapper-test-suite with:
  dmtest run --suite thin-provisioning -n /commit_failure_causes_fallback/

triggers:

[  119.618958] Buffer I/O error on dev dm-0, logical block 1572848, async page read
[  119.686224] device-mapper: thin: 253:1: metadata operation 'dm_pool_alloc_data_block' failed: error = -5
[  119.695821] device-mapper: thin: 253:1: aborting current metadata transaction
[  119.703255] sysfs: cannot create duplicate filename '/kernel/slab/:a-0000144'
[  119.710394] CPU: 2 PID: 1037 Comm: kworker/u48:1 Not tainted 4.17.0.snitm+ #25
[  119.717608] Hardware name: Supermicro SYS-1029P-WTR/X11DDW-L, BIOS 2.0a 12/06/2017
[  119.725177] Workqueue: dm-thin do_worker [dm_thin_pool]
[  119.730401] Call Trace:
[  119.732856]  dump_stack+0x5a/0x73
[  119.736173]  sysfs_warn_dup+0x58/0x70
[  119.739839]  sysfs_create_dir_ns+0x77/0x80
[  119.743939]  kobject_add_internal+0xba/0x2e0
[  119.748210]  kobject_init_and_add+0x70/0xb0
[  119.752399]  ? sysfs_slab_add+0x101/0x250
[  119.756409]  sysfs_slab_add+0xb1/0x250
[  119.760161]  __kmem_cache_create+0x116/0x150
[  119.764436]  ? number+0x2fb/0x340
[  119.767755]  ? _cond_resched+0x15/0x30
[  119.771508]  create_cache+0xd9/0x1f0
[  119.775085]  kmem_cache_create_usercopy+0x1c1/0x250
[  119.779965]  kmem_cache_create+0x18/0x20
[  119.783894]  dm_bufio_client_create+0x1ae/0x410 [dm_bufio]
[  119.789380]  ? dm_block_manager_alloc_callback+0x20/0x20 [dm_persistent_data]
[  119.796509]  ? kmem_cache_alloc_trace+0xae/0x1d0
[  119.801131]  dm_block_manager_create+0x5e/0x90 [dm_persistent_data]
[  119.807397]  __create_persistent_data_objects+0x38/0x940 [dm_thin_pool]
[  119.814008]  dm_pool_abort_metadata+0x64/0x90 [dm_thin_pool]
[  119.819669]  metadata_operation_failed+0x59/0x100 [dm_thin_pool]
[  119.825673]  alloc_data_block.isra.53+0x86/0x180 [dm_thin_pool]
[  119.831592]  process_cell+0x2a3/0x550 [dm_thin_pool]
[  119.836558]  ? mempool_alloc+0x6f/0x180
[  119.840400]  ? u32_swap+0x10/0x10
[  119.843717]  ? sort+0x17b/0x270
[  119.846863]  ? u32_swap+0x10/0x10
[  119.850181]  do_worker+0x28d/0x8f0 [dm_thin_pool]
[  119.854890]  ? move_linked_works+0x6f/0xa0
[  119.858989]  process_one_work+0x171/0x370
[  119.862999]  worker_thread+0x49/0x3f0
[  119.866669]  kthread+0xf8/0x130
[  119.869813]  ? max_active_store+0x80/0x80
[  119.873827]  ? kthread_bind+0x10/0x10
[  119.877493]  ret_from_fork+0x35/0x40
[  119.881076] kobject_add_internal failed for :a-0000144 with -EEXIST, don't try to register things with the same name in the same directory.
[  119.893580] kmem_cache_create(dm_bufio_buffer-16) failed with error -17


Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reported-by: Mike Snitzer <snitzer@redhat.com>
Tested-by: Mike Snitzer <snitzer@redhat.com>
Cc: stable@vger.kernel.org

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -5694,7 +5694,6 @@ static void sysfs_slab_remove_workfn(str
 	kset_unregister(s->memcg_kset);
 #endif
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
-	kobject_del(&s->kobj);
 out:
 	kobject_put(&s->kobj);
 }
@@ -5779,6 +5778,12 @@ static void sysfs_slab_remove(struct kme
 	schedule_work(&s->kobj_remove_work);
 }
 
+void sysfs_slab_unlink(struct kmem_cache *s)
+{
+	if (slab_state >= FULL)
+		kobject_del(&s->kobj);
+}
+
 void sysfs_slab_release(struct kmem_cache *s)
 {
 	if (slab_state >= FULL)
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h
+++ linux-2.6/include/linux/slub_def.h
@@ -156,8 +156,12 @@ struct kmem_cache {
 
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
+void sysfs_slab_unlink(struct kmem_cache *);
 void sysfs_slab_release(struct kmem_cache *);
 #else
+static inline void sysfs_slab_unlink(struct kmem_cache *s)
+{
+}
 static inline void sysfs_slab_release(struct kmem_cache *s)
 {
 }
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c
+++ linux-2.6/mm/slab_common.c
@@ -566,10 +566,14 @@ static int shutdown_cache(struct kmem_ca
 	list_del(&s->list);
 
 	if (s->flags & SLAB_TYPESAFE_BY_RCU) {
+#ifdef SLAB_SUPPORTS_SYSFS
+		sysfs_slab_unlink(s);
+#endif
 		list_add_tail(&s->list, &slab_caches_to_rcu_destroy);
 		schedule_work(&slab_caches_to_rcu_destroy_work);
 	} else {
 #ifdef SLAB_SUPPORTS_SYSFS
+		sysfs_slab_unlink(s);
 		sysfs_slab_release(s);
 #else
 		slab_kmem_cache_release(s);
