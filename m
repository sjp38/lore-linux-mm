Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6742C6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:23:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so38520514wme.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:23:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id wp4si48895955wjb.173.2016.05.31.00.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:23:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so29631583wmn.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:23:51 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom_reaper: do not use siglock in try_oom_reaper
Date: Tue, 31 May 2016 09:23:43 +0200
Message-Id: <1464679423-30218-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Oleg has noted that siglock usage in try_oom_reaper is both pointless
and dangerous. signal_group_exit can be checked lockless. The problem
is that sighand becomes NULL in __exit_signal so we can crash.

Fixes: 3ef22dfff239 ("oom, oom_reaper: try to reap tasks which skip regular OOM killer path")
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
Oleg has noticed this while reviewing http://lkml.kernel.org/r/20160530173505.GA25287@redhat.com
this should go in 4.7.

 mm/oom_kill.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e01cc3e2e755..25eac62c190c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -625,8 +625,6 @@ void try_oom_reaper(struct task_struct *tsk)
 	if (atomic_read(&mm->mm_users) > 1) {
 		rcu_read_lock();
 		for_each_process(p) {
-			bool exiting;
-
 			if (!process_shares_mm(p, mm))
 				continue;
 			if (fatal_signal_pending(p))
@@ -636,10 +634,7 @@ void try_oom_reaper(struct task_struct *tsk)
 			 * If the task is exiting make sure the whole thread group
 			 * is exiting and cannot acces mm anymore.
 			 */
-			spin_lock_irq(&p->sighand->siglock);
-			exiting = signal_group_exit(p->signal);
-			spin_unlock_irq(&p->sighand->siglock);
-			if (exiting)
+			if (signal_group_exit(p->signal))
 				continue;
 
 			/* Give up */
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
