Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F3FBC6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 04:14:36 -0400 (EDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH] oom: fix integer overflow of points in oom_badness
Date: Mon, 31 Oct 2011 09:14:25 +0100
Message-Id: <1320048865-13175-1-git-send-email-fhrbata@redhat.com>
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

This patch puts the computation of points back in one expression, so the int
overflow will not happen.

My understanding is that we may just change the type of points variable from int
to long and keep the current imho clearer(better readable) computation. There
should not be an overflow on 32bit and there is a plenty of space for 64bit.
If you like this solution better I will post the patch as v2.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 mm/oom_kill.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 626303b..d029e9b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -192,11 +192,9 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
-	points += get_mm_counter(p->mm, MM_SWAPENTS);
+	points = (int)((get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
+					p->mm->nr_ptes) * 1000UL / totalpages);
 
-	points *= 1000;
-	points /= totalpages;
 	task_unlock(p);
 
 	/*
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
