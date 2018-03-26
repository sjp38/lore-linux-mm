Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 437E66B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 07:24:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f19-v6so2717189plr.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:24:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g1-v6si13462692plm.747.2018.03.26.04.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 04:24:15 -0700 (PDT)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: kmemleak: wait for scan completion before disabling free
Date: Mon, 26 Mar 2018 16:53:49 +0530
Message-Id: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
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
kmemleak_scan completion before disabling kmemleak_free.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/kmemleak.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 8b9afc5..aa9c84b 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1931,12 +1931,15 @@ static void kmemleak_do_cleanup(struct work_struct *work)
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
