Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 836356B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:28:16 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2228188pad.28
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 12:28:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zk9si3798712pac.231.2014.01.29.12.28.15
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 12:28:15 -0800 (PST)
Date: Wed, 29 Jan 2014 12:28:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, oom: base root bonus on current usage
Message-Id: <20140129122813.59d32e5c5dad3efc2248bc60@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com>
References: <20140115234308.GB4407@cmpxchg.org>
	<alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
	<20140116070709.GM6963@cmpxchg.org>
	<alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com>
	<20140124040531.GF4407@cmpxchg.org>
	<alpine.DEB.2.02.1401251942510.3140@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 25 Jan 2014 19:48:32 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> A 3% of system memory bonus is sometimes too excessive in comparison to 
> other processes and can yield poor results when all processes on the 
> system are root and none of them use over 3% of memory.
> 
> Replace the 3% of system memory bonus with a 3% of current memory usage 
> bonus.

This changelog has deteriorated :( We should provide sufficient info so
that people will be able to determine whether this patch will fix a
problem they or their customers are observing.  And so that people who
maintain -stable and its derivatives can decide whether to backport it.

I went back and stole some text from the v1 patch.  Please review the
result.  The changelog would be even better if it were to describe the
new behaviour under the problematic workloads.

We don't think -stable needs this?


From: David Rientjes <rientjes@google.com>
Subject: mm, oom: base root bonus on current usage

A 3% of system memory bonus is sometimes too excessive in comparison to
other processes.

With a63d83f427fb ("oom: badness heuristic rewrite"), the OOM killer tries
to avoid killing privileged tasks by subtracting 3% of overall memory
(system or cgroup) from their per-task consumption.  But as a result, all
root tasks that consume less than 3% of overall memory are considered
equal, and so it only takes 33+ privileged tasks pushing the system out of
memory for the OOM killer to do something stupid and kill sshd or
dhclient.  For example, on a 32G machine it can't tell the difference
between the 1M agetty and the 10G fork bomb member.

The changelog describes this 3% boost as the equivalent to the global
overcommit limit being 3% higher for privileged tasks, but this is not the
same as discounting 3% of overall memory from _every privileged task
individually_ during OOM selection.

Replace the 3% of system memory bonus with a 3% of current memory usage
bonus.

Signed-off-by: David Rientjes <rientjes@google.com>
Reported-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/filesystems/proc.txt |    4 ++--
 mm/oom_kill.c                      |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN Documentation/filesystems/proc.txt~mm-oom-base-root-bonus-on-current-usage Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt~mm-oom-base-root-bonus-on-current-usage
+++ a/Documentation/filesystems/proc.txt
@@ -1386,8 +1386,8 @@ may allocate from based on an estimation
 For example, if a task is using all allowed memory, its badness score will be
 1000.  If it is using half of its allowed memory, its score will be 500.
 
-There is an additional factor included in the badness score: root
-processes are given 3% extra memory over other tasks.
+There is an additional factor included in the badness score: the current memory
+and swap usage is discounted by 3% for root processes.
 
 The amount of "allowed" memory depends on the context in which the oom killer
 was called.  If it is due to the memory assigned to the allocating task's cpuset
diff -puN mm/oom_kill.c~mm-oom-base-root-bonus-on-current-usage mm/oom_kill.c
--- a/mm/oom_kill.c~mm-oom-base-root-bonus-on-current-usage
+++ a/mm/oom_kill.c
@@ -178,7 +178,7 @@ unsigned long oom_badness(struct task_st
 	 * implementation used by LSMs.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		adj -= 30;
+		points -= (points * 3) / 100;
 
 	/* Normalize to oom_score_adj units */
 	adj *= totalpages / 1000;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
