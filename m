Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 515C96B0265
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:31:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so30205967ith.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:31:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t85si2011160oie.129.2016.07.12.06.31.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:31:12 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/8] mm,oom: Close oom_has_pending_mm race.
Date: Tue, 12 Jul 2016 22:29:19 +0900
Message-Id: <1468330163-4405-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Previous patch ignored a situation where oom_has_pending_mm() returns
false due to all threads which mm->oom_mm.victim belongs to have reached
TASK_DEAD state, for there might be other thread groups sharing that mm.

This patch handles such situation by always updating mm->oom_mm.victim.
By applying this patch, the comm/pid pair printed at oom_kill_process()
and oom_reap_task() might differ. But that will not be a critical
problem.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 07e8c1a..0b78133 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -688,6 +688,7 @@ subsys_initcall(oom_init)
 void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
+	struct task_struct *old_tsk;
 
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -705,15 +706,26 @@ void mark_oom_victim(struct task_struct *tsk)
 	/*
 	 * Since mark_oom_victim() is called from multiple threads,
 	 * connect this mm to oom_mm_list only if not yet connected.
+	 *
+	 * But task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask) in
+	 * oom_has_pending_mm() might return false after all threads in one
+	 * thread group (which mm->oom_mm.victim belongs to) reached TASK_DEAD
+	 * state. In that case, the same mm will be selected by another thread
+	 * group (which mm->oom_mm.victim does not belongs to). Therefore,
+	 * we need to replace the old task with the new task (at least when
+	 * task_in_oom_domain() returned false).
 	 */
-	if (!mm->oom_mm.victim) {
+	get_task_struct(tsk);
+	spin_lock(&oom_mm_lock);
+	old_tsk = mm->oom_mm.victim;
+	mm->oom_mm.victim = tsk;
+	if (!old_tsk) {
 		atomic_inc(&mm->mm_count);
-		get_task_struct(tsk);
-		mm->oom_mm.victim = tsk;
-		spin_lock(&oom_mm_lock);
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
-		spin_unlock(&oom_mm_lock);
 	}
+	spin_unlock(&oom_mm_lock);
+	if (old_tsk)
+		put_task_struct(old_tsk);
 }
 
 /**
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
