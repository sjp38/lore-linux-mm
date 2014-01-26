Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9FC6B0035
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 22:48:38 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so2126507bkg.19
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 19:48:38 -0800 (PST)
Received: from mail-bk0-x231.google.com (mail-bk0-x231.google.com [2a00:1450:4008:c01::231])
        by mx.google.com with ESMTPS id kw2si8963906bkb.351.2014.01.25.19.48.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Jan 2014 19:48:37 -0800 (PST)
Received: by mail-bk0-f49.google.com with SMTP id v15so2114159bkz.22
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 19:48:37 -0800 (PST)
Date: Sat, 25 Jan 2014 19:48:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: base root bonus on current usage
In-Reply-To: <20140124040531.GF4407@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com>
References: <20140115234308.GB4407@cmpxchg.org> <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com> <20140116070709.GM6963@cmpxchg.org> <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com> <20140124040531.GF4407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A 3% of system memory bonus is sometimes too excessive in comparison to 
other processes and can yield poor results when all processes on the 
system are root and none of them use over 3% of memory.

Replace the 3% of system memory bonus with a 3% of current memory usage 
bonus.

Reported-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/filesystems/proc.txt | 4 ++--
 mm/oom_kill.c                      | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1386,8 +1386,8 @@ may allocate from based on an estimation of its current memory and swap use.
 For example, if a task is using all allowed memory, its badness score will be
 1000.  If it is using half of its allowed memory, its score will be 500.
 
-There is an additional factor included in the badness score: root
-processes are given 3% extra memory over other tasks.
+There is an additional factor included in the badness score: the current memory
+and swap usage is discounted by 3% for root processes.
 
 The amount of "allowed" memory depends on the context in which the oom killer
 was called.  If it is due to the memory assigned to the allocating task's cpuset
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -178,7 +178,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * implementation used by LSMs.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		adj -= 30;
+		points -= (points * 3) / 100;
 
 	/* Normalize to oom_score_adj units */
 	adj *= totalpages / 1000;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
