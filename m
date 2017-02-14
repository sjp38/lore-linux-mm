Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC046B039C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:07:27 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 78so90735237vkj.2
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:07:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k30si724791pgn.247.2017.02.14.07.07.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 07:07:25 -0800 (PST)
From: Aleksa Sarai <asarai@suse.de>
Subject: [PATCH] oom_reaper: switch to struct list_head for reap queue
Date: Wed, 15 Feb 2017 02:07:14 +1100
Message-Id: <20170214150714.6195-1-asarai@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com, Aleksa Sarai <asarai@suse.de>

Rather than implementing an open addressing linked list structure
ourselves, use the standard list_head structure to improve consistency
with the rest of the kernel and reduce confusion.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Aleksa Sarai <asarai@suse.de>
---
 include/linux/sched.h |  6 +++++-
 kernel/fork.c         |  4 ++++
 mm/oom_kill.c         | 24 +++++++++++++-----------
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e93594b88130..d8bcd0f8c5fe 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1960,7 +1960,11 @@ struct task_struct {
 #endif
 	int pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct task_struct *oom_reaper_list;
+	/*
+	 * List of threads that have to be reaped by OOM (rooted at
+	 * &oom_reaper_list in mm/oom_kill.c).
+	 */
+	struct list_head oom_reaper_list;
 #endif
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct *stack_vm_area;
diff --git a/kernel/fork.c b/kernel/fork.c
index 5908f9fba21b..faca59865b1d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1165,6 +1165,10 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	tsk->last_switch_count = tsk->nvcsw + tsk->nivcsw;
 #endif
 
+#ifdef CONFIG_MMU
+	INIT_LIST_HEAD(&tsk->oom_reaper_list);
+#endif
+
 	tsk->mm = NULL;
 	tsk->active_mm = NULL;
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 51c091849dcb..d6b63ef52b88 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1,6 +1,6 @@
 /*
  *  linux/mm/oom_kill.c
- * 
+ *
  *  Copyright (C)  1998,2000  Rik van Riel
  *	Thanks go out to Claus Fischer for some serious inspiration and
  *	for goading me into coding this file...
@@ -460,7 +460,7 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static struct task_struct *oom_reaper_list;
+static LIST_HEAD(oom_reaper_list);
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
@@ -565,7 +565,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	debug_show_all_locks();
 
 done:
-	tsk->oom_reaper_list = NULL;
+	list_del_init(&tsk->oom_reaper_list);
 
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
@@ -582,12 +582,15 @@ static int oom_reaper(void *unused)
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
+		wait_event_freezable(oom_reaper_wait,
+				     !list_empty(&oom_reaper_list));
+
 		spin_lock(&oom_reaper_lock);
-		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
-			oom_reaper_list = tsk->oom_reaper_list;
-		}
+		tsk = list_first_entry_or_null(&oom_reaper_list,
+					       struct task_struct,
+					       oom_reaper_list);
+		if (tsk)
+			list_del_init(&tsk->oom_reaper_list);
 		spin_unlock(&oom_reaper_lock);
 
 		if (tsk)
@@ -603,14 +606,13 @@ static void wake_oom_reaper(struct task_struct *tsk)
 		return;
 
 	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	if (!list_empty(&tsk->oom_reaper_list))
 		return;
 
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	tsk->oom_reaper_list = oom_reaper_list;
-	oom_reaper_list = tsk;
+	list_add_tail(&tsk->oom_reaper_list, &oom_reaper_list);
 	spin_unlock(&oom_reaper_lock);
 	wake_up(&oom_reaper_wait);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
