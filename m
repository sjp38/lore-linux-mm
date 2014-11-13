Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 143986B00D8
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:38:26 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so15300700pac.2
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:38:25 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id oj8si25535140pbb.207.2014.11.13.05.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:38:24 -0800 (PST)
Received: by mail-pa0-f67.google.com with SMTP id lj1so8853519pab.6
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:38:24 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH 3/3] mm/zsmalloc: adjust zs_init/zs_exit location
Date: Thu, 13 Nov 2014 21:37:37 +0800
Message-Id: <1415885857-5283-3-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
References: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, sergey.senozhatsky@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

In previous code design, the zs_exit() will be called by zs_init().
So function zs_exit() is located before zs_init(). And after patch [1],
the zs_exit() will not be called by zs_init().
So we can move the zs_exit() after zs_init() and put these two module
init/exit functions to the end of the file which is the common style.

  [1] mm/zsmalloc: avoid unregister a NOT-registered zsmalloc zpool driver

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |   96 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 48 insertions(+), 48 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 92af030..4fcb7c9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -881,54 +881,6 @@ static struct notifier_block zs_cpu_nb = {
 	.notifier_call = zs_cpu_notifier
 };
 
-static void __exit zs_exit(void)
-{
-	int cpu;
-
-#ifdef CONFIG_ZPOOL
-	zpool_unregister_driver(&zs_zpool_driver);
-#endif
-
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(cpu)
-		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
-	__unregister_cpu_notifier(&zs_cpu_nb);
-
-	cpu_notifier_register_done();
-}
-
-static int __init zs_init(void)
-{
-	int cpu, ret;
-
-	cpu_notifier_register_begin();
-
-	__register_cpu_notifier(&zs_cpu_nb);
-	for_each_online_cpu(cpu) {
-		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
-		if (notifier_to_errno(ret))
-			goto fail;
-	}
-
-	cpu_notifier_register_done();
-
-#ifdef CONFIG_ZPOOL
-	zpool_register_driver(&zs_zpool_driver);
-#endif
-
-	return 0;
-
-fail:
-	for_each_online_cpu(cpu)
-		zs_cpu_notifier(NULL, CPU_UP_CANCELED, (void *)(long)cpu);
-	__unregister_cpu_notifier(&zs_cpu_nb);
-
-	cpu_notifier_register_done();
-
-	return notifier_to_errno(ret);
-}
-
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -1187,6 +1139,54 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+static int __init zs_init(void)
+{
+	int cpu, ret;
+
+	cpu_notifier_register_begin();
+
+	__register_cpu_notifier(&zs_cpu_nb);
+	for_each_online_cpu(cpu) {
+		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
+		if (notifier_to_errno(ret))
+			goto fail;
+	}
+
+	cpu_notifier_register_done();
+
+#ifdef CONFIG_ZPOOL
+	zpool_register_driver(&zs_zpool_driver);
+#endif
+
+	return 0;
+
+fail:
+	for_each_online_cpu(cpu)
+		zs_cpu_notifier(NULL, CPU_UP_CANCELED, (void *)(long)cpu);
+	__unregister_cpu_notifier(&zs_cpu_nb);
+
+	cpu_notifier_register_done();
+
+	return notifier_to_errno(ret);
+}
+
+static void __exit zs_exit(void)
+{
+	int cpu;
+
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&zs_zpool_driver);
+#endif
+
+	cpu_notifier_register_begin();
+
+	for_each_online_cpu(cpu)
+		zs_cpu_notifier(NULL, CPU_DEAD, (void *)(long)cpu);
+	__unregister_cpu_notifier(&zs_cpu_nb);
+
+	cpu_notifier_register_done();
+}
+
 module_init(zs_init);
 module_exit(zs_exit);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
