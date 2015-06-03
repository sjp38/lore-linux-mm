Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6469B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 11:43:06 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so7674946qko.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:43:06 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 19si964528qkt.64.2015.06.03.08.43.05
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 08:43:05 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: kmemleak: Fix crashing during kmemleak disabling
Date: Wed,  3 Jun 2015 16:42:56 +0100
Message-Id: <1433346176-912-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vignesh Radhakrishnan <vigneshr@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>

With the current implementation, if kmemleak is disabled because of an
error condition (e.g. fails to allocate metadata), alloc/free calls are
no longer tracked. Usually this is not a problem since the kmemleak
metadata is being removed via kmemleak_do_cleanup(). However, if the
scanning thread is running at the time of disabling, kmemleak would no
longer notice a potential vfree() call and the freed/unmapped object may
still be accessed, causing a fault.

This patch separates the kmemleak_free() enabling/disabling from the
overall kmemleak_enabled nob so that we can defer the disabling of the
object freeing tracking until the scanning thread completed. The
kmemleak_free_part() is deliberately ignored by this patch since this is
only called during boot before the scanning thread started.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Reported-by: Vignesh Radhakrishnan <vigneshr@codeaurora.org>
Tested-by: Vignesh Radhakrishnan <vigneshr@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
---
 mm/kmemleak.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f0fe4f2c1fa7..11d6f8015896 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -195,6 +195,8 @@ static struct kmem_cache *scan_area_cache;
 
 /* set if tracing memory operations is enabled */
 static int kmemleak_enabled;
+/* same as above but only for the kmemleak_free() callback */
+static int kmemleak_free_enabled;
 /* set in the late_initcall if there were no errors */
 static int kmemleak_initialized;
 /* enables or disables early logging of the memory operations */
@@ -942,7 +944,7 @@ void __ref kmemleak_free(const void *ptr)
 {
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
+	if (kmemleak_free_enabled && ptr && !IS_ERR(ptr))
 		delete_object_full((unsigned long)ptr);
 	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_FREE, ptr, 0, 0);
@@ -982,7 +984,7 @@ void __ref kmemleak_free_percpu(const void __percpu *ptr)
 
 	pr_debug("%s(0x%p)\n", __func__, ptr);
 
-	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
+	if (kmemleak_free_enabled && ptr && !IS_ERR(ptr))
 		for_each_possible_cpu(cpu)
 			delete_object_full((unsigned long)per_cpu_ptr(ptr,
 								      cpu));
@@ -1750,6 +1752,12 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
+	/*
+	 * Once the scan thread has stopped, it is safe to no longer track
+	 * object freeing.
+	 */
+	kmemleak_free_enabled = 0;
+
 	if (!kmemleak_found_leaks)
 		__kmemleak_do_cleanup();
 	else
@@ -1776,6 +1784,8 @@ static void kmemleak_disable(void)
 	/* check whether it is too early for a kernel thread */
 	if (kmemleak_initialized)
 		schedule_work(&cleanup_work);
+	else
+		kmemleak_free_enabled = 0;
 
 	pr_info("Kernel memory leak detector disabled\n");
 }
@@ -1840,8 +1850,10 @@ void __init kmemleak_init(void)
 	if (kmemleak_error) {
 		local_irq_restore(flags);
 		return;
-	} else
+	} else {
 		kmemleak_enabled = 1;
+		kmemleak_free_enabled = 1;
+	}
 	local_irq_restore(flags);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
