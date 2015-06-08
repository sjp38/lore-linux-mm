Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6426B0080
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:29:35 -0400 (EDT)
Received: by qkx62 with SMTP id 62so78578886qkx.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:29:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p76si2668300qkp.60.2015.06.08.07.29.34
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 07:29:34 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 1/4] mm: kmemleak: Allow safe memory scanning during kmemleak disabling
Date: Mon,  8 Jun 2015 15:29:15 +0100
Message-Id: <1433773758-21994-2-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
References: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, vigneshr@codeaurora.org

The kmemleak scanning thread can run for minutes. Callbacks like
kmemleak_free() are allowed during this time, the race being taken care
of by the object->lock spinlock. Such lock also prevents a memory block
from being freed or unmapped while it is being scanned by blocking the
kmemleak_free() -> ... -> __delete_object() function until the lock is
released in scan_object().

When a kmemleak error occurs (e.g. it fails to allocate its metadata),
kmemleak_enabled is set and __delete_object() is no longer called on
freed objects. If kmemleak_scan is running at the same time,
kmemleak_free() no longer waits for the object scanning to complete,
allowing the corresponding memory block to be freed or unmapped (in the
case of vfree()). This leads to kmemleak_scan potentially triggering a
page fault.

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
 mm/kmemleak.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f0fe4f2c1fa7..41df5b8efd25 100644
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
@@ -1750,6 +1752,13 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
+	/*
+	 * Once the scan thread has stopped, it is safe to no longer track
+	 * object freeing. Ordering of the scan thread stopping and the memory
+	 * accesses below is guaranteed by the kthread_stop() function.
+	 */
+	kmemleak_free_enabled = 0;
+
 	if (!kmemleak_found_leaks)
 		__kmemleak_do_cleanup();
 	else
@@ -1776,6 +1785,8 @@ static void kmemleak_disable(void)
 	/* check whether it is too early for a kernel thread */
 	if (kmemleak_initialized)
 		schedule_work(&cleanup_work);
+	else
+		kmemleak_free_enabled = 0;
 
 	pr_info("Kernel memory leak detector disabled\n");
 }
@@ -1840,8 +1851,10 @@ void __init kmemleak_init(void)
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
