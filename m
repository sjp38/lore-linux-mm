Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 11DC06B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 01:51:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o535pTjh027040
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 14:51:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 333F545DE55
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:51:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1151745DE4F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:51:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0CA71DB803E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:51:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A99C2E08002
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:51:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 03/12] oom: the points calculation of child processes must use find_lock_task_mm() too
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603145036.7250.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 14:51:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

child point calclation use find_lock_task_mm() too.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
---
 mm/oom_kill.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ce9c744..0542232 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -87,6 +87,7 @@ static struct task_struct *find_lock_task_mm(struct task_struct *p)
 unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time;
+	struct task_struct *c;
 	struct task_struct *child;
 	int oom_adj = p->signal->oom_adj;
 	struct task_cputime task_time;
@@ -124,11 +125,13 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * child is eating the vast majority of memory, adding only half
 	 * to the parents will make the child our kill candidate of choice.
 	 */
-	list_for_each_entry(child, &p->children, sibling) {
-		task_lock(child);
-		if (child->mm != p->mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
-		task_unlock(child);
+	list_for_each_entry(c, &p->children, sibling) {
+		child = find_lock_task_mm(c);
+		if (child) {
+			if (child->mm != p->mm)
+				points += child->mm->total_vm/2 + 1;
+			task_unlock(child);
+		}
 	}
 
 	/*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
