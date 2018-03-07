Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 468F76B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 18:52:18 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m70so3864972ioi.8
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 15:52:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 84sor8611905ita.76.2018.03.07.15.52.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 15:52:17 -0800 (PST)
Date: Wed, 7 Mar 2018 15:52:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: remove 3% bonus for CAP_SYS_ADMIN processes
Message-ID: <alpine.DEB.2.20.1803071548510.6996@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gaurav Kohli <gkohli@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

Since the 2.6 kernel, the oom killer has slightly biased away from 
CAP_SYS_ADMIN processes by discounting some of its memory usage in 
comparison to other processes.

This has always been implicit and nothing exactly relies on the behavior.

Gaurav notices that __task_cred() can dereference a potentially freed 
pointer if the task under consideration is exiting because a reference to 
the task_struct is not held.

Remove the CAP_SYS_ADMIN bias so that all processes are treated equally.

If any CAP_SYS_ADMIN process would like to be biased against, it is always 
allowed to adjust /proc/pid/oom_score_adj.

Reported-by: Gaurav Kohli <gkohli@codeaurora.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -224,13 +224,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
 	task_unlock(p);
 
-	/*
-	 * Root processes get 3% bonus, just like the __vm_enough_memory()
-	 * implementation used by LSMs.
-	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		points -= (points * 3) / 100;
-
 	/* Normalize to oom_score_adj units */
 	adj *= totalpages / 1000;
 	points += adj;
