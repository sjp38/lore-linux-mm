Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 132616B025F
	for <linux-mm@kvack.org>; Thu, 26 May 2016 08:40:27 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so38988699lbb.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:27 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gk7si18206391wjb.5.2016.05.26.05.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 05:40:25 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so5036902wme.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no external tasks sharing mm
Date: Thu, 26 May 2016 14:40:10 +0200
Message-Id: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_kill_process makes sure to kill all processes outside of the thread
group which are sharing the mm. This requires to iterate over all tasks.
This is however not a common case so we can optimize it a bit and only
do that path only if we know that there are external users of the mm
struct outside of the thread group.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5bb2f7698ad7..0e33e912f7e4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -820,6 +820,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(victim);
 
 	/*
+	 * skip expensive iterations over all tasks if we know that there
+	 * are no users outside of threads in the same thread group
+	 */
+	if (atomic_read(&mm->mm_users) <= get_nr_threads(victim))
+		goto oom_reap;
+
+	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
 	 * any.  They don't get access to memory reserves, though, to avoid
 	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
@@ -848,6 +855,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
+oom_reap:
 	if (can_oom_reap)
 		wake_oom_reaper(victim);
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
