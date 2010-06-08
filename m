Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AB6A66B0216
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:54:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BsuMh013012
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:54:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF9C445DE4D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:54:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F0B545DE4F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:54:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 898661DB803F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:54:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 492DEE18003
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:54:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 01/10] oom: don't try to kill oom_unkillable child
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608205343.767D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:54:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, badness() doesn't care neigher CPUSET nor mempolicy. Then
if the victim child process is oom_unkillable()==1, __out_of_memory()
can makes kernel hang eventually.

This patch fixes it.


[remark: this is needed to fold "oom: sacrifice child with highest
badness score for parent"]
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d49d542..0d7397b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -387,9 +387,6 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
 			      int verbose)
 {
-	if (oom_unkillable(p, mem))
-		return 1;
-
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 1;
@@ -440,6 +437,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (c->mm == p->mm)
 				continue;
+			if (oom_unkillable(c, mem, nodemask))
+				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
 			cpoints = badness(c, uptime.tv_sec);
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
