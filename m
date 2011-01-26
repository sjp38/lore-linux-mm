Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 464366B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:29:38 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
Date: Wed, 26 Jan 2011 00:29:15 -0800
Message-Id: <1296030555-3594-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

mem_cgroup_get_limit() returns a byte limit as a unsigned 64 bit value,
which is converted to a page count by mem_cgroup_out_of_memory().  Prior
to this patch the conversion could overflow on 32 bit platforms
yielding a limit of zero.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7dcca55..3fcac51 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -538,7 +538,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	struct task_struct *p;
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
-	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
+	limit = min(mem_cgroup_get_limit(mem) >> PAGE_SHIFT, (u64)ULONG_MAX);
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, limit, mem, NULL);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
