Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE456B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:00:08 -0400 (EDT)
Received: by qgev79 with SMTP id v79so19367470qge.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:00:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g77si3752599qhc.64.2015.09.17.11.00.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:00:07 -0700 (PDT)
From: Kyle Walker <kwalker@redhat.com>
Subject: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Date: Thu, 17 Sep 2015 13:59:43 -0400
Message-Id: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyle Walker <kwalker@redhat.com>

Currently, the oom killer will attempt to kill a process that is in
TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
period of time, such as processes writing to a frozen filesystem during
a lengthy backup operation, this can result in a deadlock condition as
related processes memory access will stall within the page fault
handler.

Within oom_unkillable_task(), check for processes in
TASK_UNINTERRUPTIBLE (TASK_KILLABLE omitted). The oom killer will
move on to another task.

Signed-off-by: Kyle Walker <kwalker@redhat.com>
---
 mm/oom_kill.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..66f03f8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -131,6 +131,10 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (memcg && !task_in_mem_cgroup(p, memcg))
 		return true;
 
+	/* Uninterruptible tasks should not be killed unless in TASK_WAKEKILL */
+	if (p->state == TASK_UNINTERRUPTIBLE)
+		return true;
+
 	/* p may not have freeable memory in nodemask */
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
