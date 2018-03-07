Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFFF6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 07:57:55 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 73so1166079pfz.22
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 04:57:55 -0800 (PST)
Received: from alexa-out-tai-02.qualcomm.com (alexa-out-tai-02.qualcomm.com. [103.229.16.227])
        by mx.google.com with ESMTPS id k80si13911177pfh.260.2018.03.07.04.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 04:57:54 -0800 (PST)
From: Gaurav Kohli <gkohli@codeaurora.org>
Subject: [PATCH] mm: oom: Fix race condition between oom_badness and do_exit of task
Date: Wed,  7 Mar 2018 18:27:34 +0530
Message-Id: <1520427454-22813-1-git-send-email-gkohli@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Gaurav Kohli <gkohli@codeaurora.org>

oom_badness access real_cred of task for calculation without increasing
the usage counter of task struct. This may create a race if do_exit of
same task runs and free the real_cred. So using get_task_struct which
blocks the freeing until oom_badness is executing.

el1_da+0x24/0x84
security_capable_noaudit+0x64/0x94
has_capability_noaudit+0x38/0x58
oom_badness.part.21+0x114/0x1c0
oom_badness+0x50/0x5c
proc_oom_score+0x48/0x80
proc_single_show+0x5c/0xb8

Signed-off-by: Gaurav Kohli <gkohli@codeaurora.org>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6fd9773..5f4cc4b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -114,9 +114,11 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
 
 	for_each_thread(p, t) {
 		task_lock(t);
+		get_task_struct(t);
 		if (likely(t->mm))
 			goto found;
 		task_unlock(t);
+		put_task_struct(t);
 	}
 	t = NULL;
 found:
@@ -191,6 +193,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
 			in_vfork(p)) {
 		task_unlock(p);
+		put_task_struct(p);
 		return 0;
 	}
 
@@ -208,7 +211,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
 		points -= (points * 3) / 100;
-
+	put_task_struct(p);
 	/* Normalize to oom_score_adj units */
 	adj *= totalpages / 1000;
 	points += adj;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
