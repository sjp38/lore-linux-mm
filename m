Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B809828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 02:51:47 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cx13so116736958pac.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:47 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id h6si2636686pfa.280.2016.07.03.23.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 23:51:46 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id lm4so3894561pab.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:46 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Date: Mon,  4 Jul 2016 14:49:58 +0800
Message-Id: <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

Add __init,__exit attribute for function that only called in
module init/exit to save memory.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v2:
    add __init/__exit for zs_register_cpu_notifier/zs_unregister_cpu_notifier
---
 mm/zsmalloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index df804b8..756f839 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1314,7 +1314,7 @@ static struct notifier_block zs_cpu_nb = {
 	.notifier_call = zs_cpu_notifier
 };
 
-static int zs_register_cpu_notifier(void)
+static int __init zs_register_cpu_notifier(void)
 {
 	int cpu, uninitialized_var(ret);
 
@@ -1331,7 +1331,7 @@ static int zs_register_cpu_notifier(void)
 	return notifier_to_errno(ret);
 }
 
-static void zs_unregister_cpu_notifier(void)
+static void __exit zs_unregister_cpu_notifier(void)
 {
 	int cpu;
 
@@ -1344,7 +1344,7 @@ static void zs_unregister_cpu_notifier(void)
 	cpu_notifier_register_done();
 }
 
-static void init_zs_size_classes(void)
+static void __init init_zs_size_classes(void)
 {
 	int nr;
 
@@ -1887,7 +1887,7 @@ static struct file_system_type zsmalloc_fs = {
 	.kill_sb	= kill_anon_super,
 };
 
-static int zsmalloc_mount(void)
+static int __init zsmalloc_mount(void)
 {
 	int ret = 0;
 
@@ -1898,7 +1898,7 @@ static int zsmalloc_mount(void)
 	return ret;
 }
 
-static void zsmalloc_unmount(void)
+static void __exit zsmalloc_unmount(void)
 {
 	kern_unmount(zsmalloc_mnt);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
