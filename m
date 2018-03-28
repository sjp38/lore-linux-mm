Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 900DC6B0029
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 02:53:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b9so361439pgs.10
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 23:53:14 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f125si2029460pgc.736.2018.03.27.23.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 23:53:13 -0700 (PDT)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v2] mm: kmemleak: wait for scan completion before disabling free
Date: Wed, 28 Mar 2018 12:22:52 +0530
Message-Id: <1522219972-22809-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Vinayak Menon <vinmenon@codeaurora.org>

A crash is observed when kmemleak_scan accesses the
object->pointer, likely due to the following race.

TASK A             TASK B                     TASK C
kmemleak_write
 (with "scan" and
 NOT "scan=on")
kmemleak_scan()
                   create_object
                   kmem_cache_alloc fails
                   kmemleak_disable
                   kmemleak_do_cleanup
                   kmemleak_free_enabled = 0
                                              kfree
                                              kmemleak_free bails out
                                               (kmemleak_free_enabled is 0)
                                              slub frees object->pointer
update_checksum
crash - object->pointer
 freed (DEBUG_PAGEALLOC)

kmemleak_do_cleanup waits for the scan thread to complete, but not for
direct call to kmemleak_scan via kmemleak_write. So add a wait for
kmemleak_scan completion before disabling kmemleak_free, and while at
it fix the comment on stop_scan_thread.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---

v2: Fix stop_scan_thread comment

 mm/kmemleak.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 8b9afc5..9a085d5 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1667,8 +1667,7 @@ static void start_scan_thread(void)
 }
 
 /*
- * Stop the automatic memory scanning thread. This function must be called
- * with the scan_mutex held.
+ * Stop the automatic memory scanning thread.
  */
 static void stop_scan_thread(void)
 {
@@ -1931,12 +1930,15 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 {
 	stop_scan_thread();
 
+	mutex_lock(&scan_mutex);
 	/*
-	 * Once the scan thread has stopped, it is safe to no longer track
-	 * object freeing. Ordering of the scan thread stopping and the memory
-	 * accesses below is guaranteed by the kthread_stop() function.
+	 * Once it is made sure that kmemleak_scan has stopped, it is safe to no
+	 * longer track object freeing. Ordering of the scan thread stopping and
+	 * the memory accesses below is guaranteed by the kthread_stop()
+	 * function.
 	 */
 	kmemleak_free_enabled = 0;
+	mutex_unlock(&scan_mutex);
 
 	if (!kmemleak_found_leaks)
 		__kmemleak_do_cleanup();
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation
