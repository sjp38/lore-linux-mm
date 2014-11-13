Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1006B00D5
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:37:56 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so14631634pdb.9
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:37:55 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id kl11si25675553pbd.55.2014.11.13.05.37.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:37:54 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so15172330pab.22
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:37:54 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH 1/3] mm/zsmalloc: avoid unregister a NOT-registered zsmalloc zpool driver
Date: Thu, 13 Nov 2014 21:37:35 +0800
Message-Id: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, sergey.senozhatsky@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

Now zsmalloc can be registered as a zpool driver into zpool when
CONFIG_ZPOOL is enabled. During the init of zsmalloc, when error happens,
we need to do cleanup. But in current code, it will unregister a not yet
registered zsmalloc zpool driver(*zs_zpool_driver*).

This patch puts the cleanup in zs_init() instead of calling zs_exit()
where it will unregister a not-registered zpool driver.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 839a48c..3d2bb36 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -907,10 +907,8 @@ static int zs_init(void)
 	__register_cpu_notifier(&zs_cpu_nb);
 	for_each_online_cpu(cpu) {
 		ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
-		if (notifier_to_errno(ret)) {
-			cpu_notifier_register_done();
+		if (notifier_to_errno(ret))
 			goto fail;
-		}
 	}
 
 	cpu_notifier_register_done();
@@ -920,8 +918,14 @@ static int zs_init(void)
 #endif
 
 	return 0;
+
 fail:
-	zs_exit();
+	for_each_online_cpu(cpu)
+		zs_cpu_notifier(NULL, CPU_UP_CANCELED, (void *)(long)cpu);
+	__unregister_cpu_notifier(&zs_cpu_nb);
+
+	cpu_notifier_register_done();
+
 	return notifier_to_errno(ret);
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
