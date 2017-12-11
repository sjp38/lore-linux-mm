Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5506B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 07:05:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so12866120pgs.9
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 04:05:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b92si9963726plb.305.2017.12.11.04.05.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 04:05:52 -0800 (PST)
Subject: [PATCH] mm, oom: task_will_free_mem() should ignore MMF_OOM_SKIP unless __GFP_NOFAIL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1512646940-3388-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171207115127.GH20234@dhcp22.suse.cz>
	<201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
	<20171207122249.GI20234@dhcp22.suse.cz>
	<201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
In-Reply-To: <201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
Message-Id: <201712112015.BGH95360.HtMSJOOQVFLFOF@I-love.SAKURA.ne.jp>
Date: Mon, 11 Dec 2017 20:15:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com, penguin-kernel@I-love.SAKURA.ne.jp

>From 6f45864753ce820adede5b318b9cb341ffd3e740 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 11 Dec 2017 19:52:07 +0900
Subject: [PATCH] mm, oom: task_will_free_mem() should ignore MMF_OOM_SKIP
 unless __GFP_NOFAIL.

Manish Jaggi noticed that running LTP oom01/oom02 tests with high core
count causes random kernel panics when an OOM victim which consumed memory
in a way the OOM reaper does not help was selected by the OOM killer [1].

Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
victim's mm were not able to try allocation from memory reserves after the
OOM reaper gave up reclaiming memory.

Since __alloc_pages_slowpath() will bail out after ALLOC_OOM allocation
failed (unless __GFP_NOFAIL is specified), this patch forces OOM victims
to try ALLOC_OOM allocation and then bail out rather than selecting next
OOM victim (unless __GFP_NOFAIL is specified which is necessary for
avoiding potential OOM lockup).

[1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com

Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7f54d9f..f71fe4c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -784,7 +784,7 @@ static inline bool __task_will_free_mem(struct task_struct *task)
  * Caller has to make sure that task->mm is stable (hold task_lock or
  * it operates on the current).
  */
-static bool task_will_free_mem(struct task_struct *task)
+static bool task_will_free_mem(struct task_struct *task, gfp_t gfp_mask)
 {
 	struct mm_struct *mm = task->mm;
 	struct task_struct *p;
@@ -802,10 +802,10 @@ static bool task_will_free_mem(struct task_struct *task)
 		return false;
 
 	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
+	 * Select next OOM victim only if existing OOM victims can not satisfy
+	 * __GFP_NOFAIL allocation even after the OOM reaper reclaimed memory.
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if ((gfp_mask & __GFP_NOFAIL) && test_bit(MMF_OOM_SKIP, &mm->flags))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
@@ -938,7 +938,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * so it can die quickly
 	 */
 	task_lock(p);
-	if (task_will_free_mem(p)) {
+	if (task_will_free_mem(p, oc->gfp_mask)) {
 		mark_oom_victim(p);
 		wake_oom_reaper(p);
 		task_unlock(p);
@@ -1092,7 +1092,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (task_will_free_mem(current)) {
+	if (task_will_free_mem(current, oc->gfp_mask)) {
 		mark_oom_victim(current);
 		wake_oom_reaper(current);
 		return true;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
