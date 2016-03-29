Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 699A36B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:03:03 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id tt10so23878675pab.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:03:03 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id dd5si1150396pad.117.2016.03.29.15.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 15:03:02 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id tt10so23878466pab.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:03:02 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] zsmalloc: use workqueue to destroy pool in zpool callback
Date: Tue, 29 Mar 2016 15:02:57 -0700
Message-Id: <1459288977-25562-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Yu Zhao <yuzhao@google.com>

zs_destroy_pool() might sleep so it shouldn't be used in zpool
destroy callback which can be invoked in softirq context when
zsmalloc is configured to work with zswap.

  BUG: scheduling while atomic: swapper/6/0/0x00000100
  ...
  Call Trace:
   <IRQ>  [<ffffffffaf09e31e>] dump_stack+0x4d/0x63
   [<ffffffffaf09aae2>] __schedule_bug+0x46/0x54
   [<ffffffffaea00704>] __schedule+0x334/0x3d3
   [<ffffffffaea00897>] schedule+0x37/0x80
   [<ffffffffaea00a5e>] schedule_preempt_disabled+0xe/0x10
   [<ffffffffaeafced5>] mutex_optimistic_spin+0x185/0x1c0
   [<ffffffffaea0215b>] __mutex_lock_slowpath+0x2b/0x100
   [<ffffffffaebf90ce>] ? __drain_alien_cache+0x9e/0xf0
   [<ffffffffaea0224b>] mutex_lock+0x1b/0x2f
   [<ffffffffaebca4f0>] kmem_cache_destroy+0x50/0x130
   [<ffffffffaec10405>] zs_destroy_pool+0x85/0xe0
   [<ffffffffaec1046e>] zs_zpool_destroy+0xe/0x10
   [<ffffffffaec101a4>] zpool_destroy_pool+0x54/0x70
   [<ffffffffaebedac2>] __zswap_pool_release+0x62/0x90
   [<ffffffffaeb1037e>] rcu_process_callbacks+0x22e/0x640
   [<ffffffffaeb15a3e>] ? run_timer_softirq+0x3e/0x280
   [<ffffffffaeabe13b>] __do_softirq+0xcb/0x250
   [<ffffffffaeabe4dc>] irq_exit+0x9c/0xb0
   [<ffffffffaea03e7a>] smp_apic_timer_interrupt+0x6a/0x80
   [<ffffffffaf0a394f>] apic_timer_interrupt+0x7f/0x90
   <EOI>  [<ffffffffaef609a2>] ? cpuidle_enter_state+0xb2/0x200
   [<ffffffffaef60985>] ? cpuidle_enter_state+0x95/0x200
   [<ffffffffaef60b27>] cpuidle_enter+0x17/0x20
   [<ffffffffaeaf79c5>] cpu_startup_entry+0x235/0x320
   [<ffffffffaea9a9db>] start_secondary+0xeb/0x100[  218.606157]

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/zsmalloc.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e72efb1..fca5366 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -262,6 +262,9 @@ struct zs_pool {
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
+#ifdef CONFIG_ZPOOL
+	struct work_struct zpool_destroy_work;
+#endif
 };
 
 /*
@@ -327,9 +330,17 @@ static void *zs_zpool_create(const char *name, gfp_t gfp,
 	return zs_create_pool(name, gfp);
 }
 
+static void zs_zpool_destroy_work(struct work_struct *work)
+{
+	zs_destroy_pool(container_of(work, struct zs_pool, zpool_destroy_work));
+}
+
 static void zs_zpool_destroy(void *pool)
 {
-	zs_destroy_pool(pool);
+	struct zs_pool *zs_pool = pool;
+
+	INIT_WORK(&zs_pool->zpool_destroy_work, zs_zpool_destroy_work);
+	schedule_work(&zs_pool->zpool_destroy_work);
 }
 
 static int zs_zpool_malloc(void *pool, size_t size, gfp_t gfp,
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
