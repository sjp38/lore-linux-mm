Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 314316B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 10:03:12 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so24640961lbn.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:03:12 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id go9si870087wjb.213.2016.06.02.07.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 07:03:10 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id e3so16074380wme.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:03:10 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/6] mm, oom: task_will_free_mem should skip oom_reaped tasks
Date: Thu,  2 Jun 2016 16:03:03 +0200
Message-Id: <1464876183-15559-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

0-day robot has encountered the following:
[   82.694232] Out of memory: Kill process 3914 (trinity-c0) score 167 or sacrifice child
[   82.695110] Killed process 3914 (trinity-c0) total-vm:55864kB, anon-rss:1512kB, file-rss:1088kB, shmem-rss:25616kB
[   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
[   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
[   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB

oom_reaper is trying to reap the same task again and again. This
is possible only when the oom killer is bypassed because of
task_will_free_mem because we skip over tasks with MMF_OOM_REAPED
already set during select_bad_process. Teach task_will_free_mem to skip
over MMF_OOM_REAPED tasks as well because they will be unlikely to free
anything more.

Analyzed-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dacfb6ab7b04..d6e121decb1a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -766,6 +766,15 @@ bool task_will_free_mem(struct task_struct *task)
 		return true;
 	}
 
+	/*
+	 * This task has already been drained by the oom reaper so there are
+	 * only small chances it will free some more
+	 */
+	if (test_bit(MMF_OOM_REAPED, &mm->flags)) {
+		task_unlock(p);
+		return false;
+	}
+
 	/* pin the mm to not get freed and reused */
 	atomic_inc(&mm->mm_count);
 	task_unlock(p);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
