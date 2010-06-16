Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C618E6B01CF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:34:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GBYiw1006361
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 20:34:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A565545DE6E
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8429145DE4D
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 695E81DB803B
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 237B81DB8037
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:34:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 7/9] oom: unify CAP_SYS_RAWIO check into other superuser check
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Message-Id: <20100616203404.72E9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 20:34:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
index e4b1146..4236d39 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -198,19 +198,14 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 
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
