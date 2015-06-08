Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 028666B0082
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:29:39 -0400 (EDT)
Received: by qczw4 with SMTP id w4so50940011qcz.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:29:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t19si2647518qge.112.2015.06.08.07.29.36
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 07:29:36 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 3/4] mm: kmemleak: Do not acquire scan_mutex in kmemleak_do_cleanup()
Date: Mon,  8 Jun 2015 15:29:17 +0100
Message-Id: <1433773758-21994-4-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
References: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, vigneshr@codeaurora.org

The kmemleak_do_cleanup() work thread already waits for the
kmemleak_scan thread to finish via kthread_stop(). Waiting in
kthread_stop() while scan_mutex is held may lead to deadlock if
kmemleak_scan_thread() also waits to acquire for scan_mutex.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/kmemleak.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index ecde522ff616..8a57e34625fa 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1762,7 +1762,6 @@ static void __kmemleak_do_cleanup(void)
  */
 static void kmemleak_do_cleanup(struct work_struct *work)
 {
-	mutex_lock(&scan_mutex);
 	stop_scan_thread();
 
 	/*
@@ -1777,7 +1776,6 @@ static void kmemleak_do_cleanup(struct work_struct *work)
 	else
 		pr_info("Kmemleak disabled without freeing internal data. "
 			"Reclaim the memory with \"echo clear > /sys/kernel/debug/kmemleak\"\n");
-	mutex_unlock(&scan_mutex);
 }
 
 static DECLARE_WORK(cleanup_work, kmemleak_do_cleanup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
