Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 06C6A6B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 04:53:29 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so4581301pde.29
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 01:53:29 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id dj5si3267764pad.0.2014.03.28.01.53.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 01:53:29 -0700 (PDT)
Message-ID: <5335384A.2000000@huawei.com>
Date: Fri, 28 Mar 2014 16:52:26 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v3 1/4] kmemleak: free internal objects only if there're no
 leaks to be reported
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Currently if you disabling kmemleak after stopping kmemleak thread,
kmemleak objects will be freed and so you won't be able to check
previously reported leaks.

With this patch, kmemleak objects won't be freed if there're leaks
that can be reported.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/kmemleak.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 31f01c5..be7ecc0 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -218,7 +218,8 @@ static int kmemleak_stack_scan = 1;
 static DEFINE_MUTEX(scan_mutex);
 /* setting kmemleak=on, will set this var, skipping the disable */
 static int kmemleak_skip_disable;
-
+/* If there're leaks that can be reported */
+static bool kmemleak_has_leaks;
 
 /*
  * Early object allocation/freeing logging. Kmemleak is initialized after the
@@ -1382,9 +1383,12 @@ static void kmemleak_scan(void)
 	}
 	rcu_read_unlock();
 
-	if (new_leaks)
+	if (new_leaks) {
+		kmemleak_has_leaks = true;
+
 		pr_info("%d new suspected memory leaks (see "
 			"/sys/kernel/debug/kmemleak)\n", new_leaks);
+	}
 
 }
 
@@ -1592,6 +1596,8 @@ static void kmemleak_clear(void)
 		spin_unlock_irqrestore(&object->lock, flags);
 	}
 	rcu_read_unlock();
+
+	kmemleak_has_leaks = false;
 }
 
 /*
@@ -1685,12 +1691,11 @@ static const struct file_operations kmemleak_fops = {
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
 	struct kmemleak_object *object;
-	bool cleanup = scan_thread == NULL;
 
 	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
-	if (cleanup) {
+	if (!kmemleak_has_leaks) {
 		rcu_read_lock();
 		list_for_each_entry_rcu(object, &object_list, object_list)
 			delete_object_full(object->pointer);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
