Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B6416B01C7
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:32:58 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GBWtfh023970
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 20:32:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CAFB545DE4F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:32:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A461F45DE52
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:32:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 45B421DB805B
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:32:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 11B091DB8043
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:32:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/9] oom: oom_kill_process() need to check p is unkillable
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Message-Id: <20100616203212.72E0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 20:32:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When oom_kill_allocating_task is enabled, an argument of
oom_kill_process is not selected by select_bad_process(), but
just out_of_memory() caller task. It mean the task can be
unkillable. check it first.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6ca6cb8..3e48023 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -436,6 +436,17 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	unsigned long victim_points = 0;
 	struct timespec uptime;
 
+	/*
+	 * When oom_kill_allocating_task is enabled, p can be
+	 * unkillable. check it first.
+	 */
+	if (is_global_init(p) || (p->flags & PF_KTHREAD))
+		return 1;
+	if (mem && !task_in_mem_cgroup(p, mem))
+		return 1;
+	if (!has_intersects_mems_allowed(p, nodemask))
+		return 1;
+
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
