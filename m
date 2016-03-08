Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id DB6DA6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:02:57 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id vs8so45428550igb.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:02:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z19si18695055igq.93.2016.03.08.03.02.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 03:02:57 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Reduce needless dereference.
Date: Tue,  8 Mar 2016 20:02:31 +0900
Message-Id: <1457434951-12691-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since we assigned mm = victim->mm before pr_err(),
we don't need to dereference victim->mm again at pr_err().
This saves a few instructions.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c84e784..1808db32 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -756,10 +756,10 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	       task_pid_nr(victim), victim->comm, K(mm->total_vm),
+	       K(get_mm_counter(mm, MM_ANONPAGES)),
+	       K(get_mm_counter(mm, MM_FILEPAGES)),
+	       K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
