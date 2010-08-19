Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F37596B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 06:53:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JArXZf021857
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 19:53:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C1645DE4D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:53:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D70E445DE50
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:53:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7EEA1DB8040
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:53:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 728061DB803C
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:53:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] oom: fix NULL pointer dereference
In-Reply-To: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
Message-Id: <20100819195310.5FC7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 19:53:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

commit b940fd7035 (oom: remove unnecessary code and cleanup) added
unnecessary NULL pointer dereference. remove it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5014e50..17d48a6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -401,10 +401,9 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
 	p = find_lock_task_mm(p);
-	if (!p) {
-		task_unlock(p);
+	if (!p)
 		return 1;
-	}
+
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(p), p->comm, K(p->mm->total_vm),
 		K(get_mm_counter(p->mm, MM_ANONPAGES)),
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
