Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5765F6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 11:56:23 -0400 (EDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH v2] oom: fix integer overflow of points in oom_badness
Date: Mon, 31 Oct 2011 16:56:09 +0100
Message-Id: <1320076569-23872-1-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1320048865-13175-1-git-send-email-fhrbata@redhat.com>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, minchan.kim@gmail.com, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com

An integer overflow will happen on 64bit archs if task's sum of rss, swapents
and nr_ptes exceeds (2^31)/1000 value. This was introduced by commit

f755a04 oom: use pte pages in OOM score

where the oom score computation was divided into several steps and it's no
longer computed as one expression in unsigned long(rss, swapents, nr_pte are
unsigned long), where the result value assigned to points(int) is in
range(1..1000). So there could be an int overflow while computing

176          points *= 1000;

and points may have negative value. Meaning the oom score for a mem hog task
will be one.

196          if (points <= 0)
197                  return 1;

For example:
[ 3366]     0  3366 35390480 24303939   5       0             0 oom01
Out of memory: Kill process 3366 (oom01) score 1 or sacrifice child

Here the oom1 process consumes more than 24303939(rss)*4096~=92GB physical
memory, but it's oom score is one.

In this situation the mem hog task is skipped and oom killer kills another and
most probably innocent task with oom score greater than one.

The points variable should be of type long instead of int to prevent the int
overflow.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 626303b..e9a1785 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -162,7 +162,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		      const nodemask_t *nodemask, unsigned long totalpages)
 {
-	int points;
+	long points;
 
 	if (oom_unkillable_task(p, mem, nodemask))
 		return 0;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
