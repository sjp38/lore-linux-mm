Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D78D6B0265
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 05:17:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 132so34912232lfz.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:17:09 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id e124si7002502wme.99.2016.06.03.02.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 02:16:56 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so22112639wme.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:56 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/10] mm, oom: task_will_free_mem should skip oom_reaped tasks
Date: Fri,  3 Jun 2016 11:16:42 +0200
Message-Id: <1464945404-30157-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
 mm/oom_kill.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 64dbffa708fd..70992f0f1b78 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -742,6 +742,16 @@ bool task_will_free_mem(struct task_struct *task)
 		return false;
 
 	mm = p->mm;
+
+	/*
+	 * This task has already been drained by the oom reaper so there are
+	 * only small chances it will free some more
+	 */
+	if (test_bit(MMF_OOM_REAPED, &mm->flags)) {
+		task_unlock(p);
+		return false;
+	}
+
 	if (atomic_read(&mm->mm_users) <= 1) {
 		task_unlock(p);
 		return true;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
