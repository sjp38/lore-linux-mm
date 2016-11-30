Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 267956B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:15:30 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so49349834pgd.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:15:30 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id 8si65873368pge.77.2016.11.30.13.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 13:15:29 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id c4so41115826pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:15:29 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2] zswap: only use CPU notifier when HOTPLUG_CPU=y
Date: Wed, 30 Nov 2016 13:15:16 -0800
Message-Id: <1480540516-6458-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

__unregister_cpu_notifier() only removes registered notifier from its
linked list when CPU hotplug is configured. If we free registered CPU
notifier when HOTPLUG_CPU=n, we corrupt the linked list.

To fix the problem, we can either use a static CPU notifier that walks
through each pool or just simply disable CPU notifier when CPU hotplug
is not configured (which is perfectly safe because the code in question
is called after all possible CPUs are online and will remain online
until power off).

v2: #ifdef for cpu_notifier_register_done during cleanup.

Signe-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/zswap.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index 275b22c..2915f44 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -118,7 +118,9 @@ struct zswap_pool {
 	struct kref kref;
 	struct list_head list;
 	struct work_struct work;
+#ifdef CONFIG_HOTPLUG_CPU
 	struct notifier_block notifier;
+#endif
 	char tfm_name[CRYPTO_MAX_ALG_NAME];
 };
 
@@ -448,6 +450,7 @@ static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
 	return NOTIFY_OK;
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
 static int zswap_cpu_comp_notifier(struct notifier_block *nb,
 				   unsigned long action, void *pcpu)
 {
@@ -456,27 +459,34 @@ static int zswap_cpu_comp_notifier(struct notifier_block *nb,
 
 	return __zswap_cpu_comp_notifier(pool, action, cpu);
 }
+#endif
 
 static int zswap_cpu_comp_init(struct zswap_pool *pool)
 {
 	unsigned long cpu;
 
+#ifdef CONFIG_HOTPLUG_CPU
 	memset(&pool->notifier, 0, sizeof(pool->notifier));
 	pool->notifier.notifier_call = zswap_cpu_comp_notifier;
 
 	cpu_notifier_register_begin();
+#endif
 	for_each_online_cpu(cpu)
 		if (__zswap_cpu_comp_notifier(pool, CPU_UP_PREPARE, cpu) ==
 		    NOTIFY_BAD)
 			goto cleanup;
+#ifdef CONFIG_HOTPLUG_CPU
 	__register_cpu_notifier(&pool->notifier);
 	cpu_notifier_register_done();
+#endif
 	return 0;
 
 cleanup:
 	for_each_online_cpu(cpu)
 		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
+#ifdef CONFIG_HOTPLUG_CPU
 	cpu_notifier_register_done();
+#endif
 	return -ENOMEM;
 }
 
@@ -484,11 +494,15 @@ static void zswap_cpu_comp_destroy(struct zswap_pool *pool)
 {
 	unsigned long cpu;
 
+#ifdef CONFIG_HOTPLUG_CPU
 	cpu_notifier_register_begin();
+#endif
 	for_each_online_cpu(cpu)
 		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
+#ifdef CONFIG_HOTPLUG_CPU
 	__unregister_cpu_notifier(&pool->notifier);
 	cpu_notifier_register_done();
+#endif
 }
 
 /*********************************
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
