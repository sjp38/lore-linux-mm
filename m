Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6328E6B01CC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:34:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GBY3sh006022
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 20:34:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4A945DE55
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B02445DE51
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C1AAE08003
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DFE81DB803E
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/9] oom: use same_thread_group instead comparing ->mm
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Message-Id: <20100616203319.72E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 20:34:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

Now, oom are using "child->mm != p->mm" check to distinguish subthread.
But It's incorrect. vfork() child also have the same ->mm.

This patch change to use same_thread_group() instead.

Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 12204c7..e4b1146 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -161,7 +161,7 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 		list_for_each_entry(c, &t->children, sibling) {
 			child = find_lock_task_mm(c);
 			if (child) {
-				if (child->mm != p->mm)
+				if (same_thread_group(p, child))
 					points += child->mm->total_vm/2 + 1;
 				task_unlock(child);
 			}
@@ -486,7 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned long child_points;
 
-			if (child->mm == p->mm)
+			if (same_thread_group(p, child))
 				continue;
 			if (oom_unkillable_task(child, mem, nodemask))
 				continue;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
