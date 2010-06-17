Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C2E166B01C7
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:56 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1phUs005997
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BE95645DE54
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9598245DE4F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AB3B1DB8061
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 322B01DB8043
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/9] oom: oom_kill_process() doesn't select kthread child
In-Reply-To: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com>
Message-Id: <20100617104517.FB7D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
doesn't. It mean oom_kill_process() may choose wrong task, especially,
when the child are using use_mm().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0aeacb2..dc8589e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -467,6 +467,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (child->mm == p->mm)
 				continue;
+			if (child->flags & PF_KTHREAD)
+				continue;
 			if (mem && !task_in_mem_cgroup(child, mem))
 				continue;
 			if (!has_intersects_mems_allowed(child, nodemask))
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
