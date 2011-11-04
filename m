Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 94C8B6B006E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 10:31:47 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Date: Fri, 4 Nov 2011 12:59:44 +0100
Subject: [PATCH] oom: do not kill tasks with oom_score_adj OOM_SCORE_ADJ_MIN
Message-Id: <20111104143145.0F93B8B45E@mx2.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

c9f01245 (oom: remove oom_disable_count) has removed oom_disable_count
counter which has been used for early break out from oom_badness so we
could never select a task with oom_score_adj set to OOM_SCORE_ADJ_MIN
(oom disabled).

Now that the counter is gone we are always going through heuristics
calculation and we always return a non zero positive value.  This
means that we can end up killing a task with OOM disabled because it is
indistinguishable from regular tasks with 1% resp. CAP_SYS_ADMIN tasks
with 3% usage of memory or tasks with oom_score_adj set but OOM enabled.

Let's break out early if the task should have OOM disabled.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e916168..4883514 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -185,6 +185,9 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	if (!p)
 		return 0;
 
+	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		return 0;
+
 	/*
 	 * The memory controller may have a limit of 0 bytes, so avoid a divide
 	 * by zero, if necessary.
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
