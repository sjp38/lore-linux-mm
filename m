Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 42F6F6B01D1
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:35:22 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GBZJOm025085
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 20:35:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C78445DE4F
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:35:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32C9545DD70
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:35:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A14E1DB8012
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:35:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D0EF31DB8015
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:35:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 8/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Message-Id: <20100616203445.72EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 20:35:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now has_intersects_mems_allowed() has own thread iterate logic, but
it should use while_each_thread().

It slightly improve the code readability.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4236d39..7e9942d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -46,10 +46,10 @@ static DEFINE_SPINLOCK(zone_scan_lock);
  * shares the same mempolicy nodes as current if it is bound by such a policy
  * and whether or not it has the same set of allowed cpuset nodes.
  */
-static bool has_intersects_mems_allowed(struct task_struct *tsk,
+static bool has_intersects_mems_allowed(struct task_struct *p,
 					const nodemask_t *mask)
 {
-	struct task_struct *start = tsk;
+	struct task_struct *tsk = p;
 
 	do {
 		if (mask) {
@@ -69,8 +69,8 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 			if (cpuset_mems_allowed_intersects(current, tsk))
 				return true;
 		}
-		tsk = next_thread(tsk);
-	} while (tsk != start);
+	} while_each_thread(p, tsk);
+
 	return false;
 }
 #else
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
