Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1558A6B023A
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:59:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bx73H014679
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:59:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7964745DE55
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E9645DE50
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 29A91E18002
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C548A1DB804C
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 06/10] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608205829.768C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:59:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now has_intersects_mems_allowed() has own thread iterate logic, but
it should use while_each_thread().

It slightly improve the code readability.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b88172c..8376ad1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -38,16 +38,14 @@ static DEFINE_SPINLOCK(zone_scan_lock);
 /*
  * Is all threads of the target process nodes overlap ours?
  */
-static int has_intersects_mems_allowed(struct task_struct *tsk)
+static int has_intersects_mems_allowed(struct task_struct *p)
 {
-	struct task_struct *t;
+	struct task_struct *t = p;
 
-	t = tsk;
 	do {
 		if (cpuset_mems_allowed_intersects(current, t))
 			return 1;
-		t = next_thread(t);
-	} while (t != tsk);
+	} while_each_thread(p, t);
 
 	return 0;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
