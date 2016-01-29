Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 43D3C6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:50:40 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id p187so44874115oia.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:50:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f9si14148583oej.97.2016.01.29.02.50.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 02:50:39 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, vmstat: fix wrong WQ sleep when memory reclaim doesn't make any progress
Date: Fri, 29 Jan 2016 19:49:12 +0900
Message-Id: <1454064552-5598-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, jstancek@redhat.com, torvalds@linux-foundation.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, Joonsoo Kim <js1304@gmail.com>, Arkadiusz Miskiewicz <arekm@maven.pl>, stable@vger.kernel.org

Jan Stancek has reported that system occasionally hanging after
"oom01" testcase from LTP triggers OOM. Guessing from a result that
there is a kworker thread doing memory allocation and the values
between "Node 0 Normal free:" and "Node 0 Normal:" differs when
hanging, vmstat is not up-to-date for some reason.

According to commit 373ccbe59270 ("mm, vmstat: allow WQ concurrency to
discover memory reclaim doesn't make any progress"), it meant to force
the kworker thread to take a short sleep, but it by error used
schedule_timeout(1). We missed that schedule_timeout() in state
TASK_RUNNING doesn't do anything.

Fix it by using schedule_timeout_uninterruptible(1) which forces
the kworker thread to take a short sleep in order to make sure
that vmstat is up-to-date.

Fixes: 373ccbe59270 ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make any progress")
Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Cristopher Lameter <clameter@sgi.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Arkadiusz Miskiewicz <arekm@maven.pl>
Cc: <stable@vger.kernel.org>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7340353..cbe6f0b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -989,7 +989,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 		 * here rather than calling cond_resched().
 		 */
 		if (current->flags & PF_WQ_WORKER)
-			schedule_timeout(1);
+			schedule_timeout_uninterruptible(1);
 		else
 			cond_resched();
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
