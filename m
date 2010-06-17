Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B365A6B01B7
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1piMe029706
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DF34745DE55
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCB6F45DE53
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BCB91DB8043
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 54EE41DB805E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
Message-Id: <20100617104719.FB8C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now has_intersects_mems_allowed() has own thread iterate logic, but
it should use while_each_thread().

It slightly improve the code readability.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 541a59b..b27db90 100644
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
