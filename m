Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 926CB6B01C3
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1plKZ029733
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78E0E45DE50
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F94C45DE4F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B3F61DB803C
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6441DB8050
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/9] oom: unify CAP_SYS_RAWIO check into other superuser check
In-Reply-To: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
Message-Id: <20100617104756.FB8F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now, CAP_SYS_RAWIO check is very strange. if the user have both
CAP_SYS_ADMIN and CAP_SYS_RAWIO, points will makes 1/16.

Superuser's 1/4 bonus worthness is quite a bit dubious, but
considerable. However 1/16 is obviously insane.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b27db90..7f91151 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -199,19 +199,14 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 
 	/*
 	 * Superuser processes are usually more important, so we make it
-	 * less likely that we kill those.
+	 * less likely that we kill those. And we don't want to kill a
+	 * process with direct hardware access. Not only could that mess
+	 * up the hardware, but usually users tend to only have this
+	 * flag set on applications they think of as important.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
-	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
-		points /= 4;
-
-	/*
-	 * We don't want to kill a process with direct hardware access.
-	 * Not only could that mess up the hardware, but usually users
-	 * tend to only have this flag set on applications they think
-	 * of as important.
-	 */
-	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
+	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
+	    has_capability_noaudit(p, CAP_SYS_RAWIO))
 		points /= 4;
 
 	/*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
