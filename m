Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD236B0417
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 07:57:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v84so436553135oie.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:57:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t127si14970594oib.306.2016.12.22.04.57.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 04:57:37 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom_reaper: Update rationale comment for holding oom_lock.
Date: Thu, 22 Dec 2016 21:57:30 +0900
Message-Id: <1482411450-8097-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since commit 862e3073b3eed13f
("mm, oom: get rid of signal_struct::oom_victims")
changed to wait until MMF_OOM_SKIP is set rather than wait while
TIF_MEMDIE is set, rationale comment for commit e2fe14564d3316d1
("oom_reaper: close race with exiting task") needs to be updated.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d..6fd076b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -470,18 +470,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	bool ret = true;
 
 	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
+	 * Make sure that other threads waiting for oom_lock at
+	 * __alloc_pages_may_oom() are given a chance to call
+	 * get_page_from_freelist() after MMF_OOM_SKIP is set.
 	 */
 	mutex_lock(&oom_lock);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
