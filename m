Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DE2926B01BA
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1plj2006041
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F003645DE70
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C5D45DE6E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B18A01DB803B
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F24AD1DB803E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/9] oom: oom_kill_process() need to check p is unkillable
In-Reply-To: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
Message-Id: <20100617104647.FB89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When oom_kill_allocating_task is enabled, an argument task of
oom_kill_process is not selected by select_bad_process(), It's
just out_of_memory() caller task. It mean the task can be
unkillable. check it first.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index afcbf17..541a59b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -687,7 +687,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	check_panic_on_oom(constraint, gfp_mask, order);
 
 	read_lock(&tasklist_lock);
-	if (sysctl_oom_kill_allocating_task) {
+	if (sysctl_oom_kill_allocating_task &&
+	    !oom_unkillable_task(current, NULL, nodemask)) {
 		/*
 		 * oom_kill_process() needs tasklist_lock held.  If it returns
 		 * non-zero, current could not be killed so we must fallback to
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
