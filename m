Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 09F046B01EB
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 12:25:17 -0400 (EDT)
Received: by ewy5 with SMTP id 5so1504823ewy.10
        for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:25:15 -0700 (PDT)
From: Anfei Zhou <anfei.zhou@gmail.com>
Subject: [PATCH] oom killer: break from infinite loop
Date: Thu, 25 Mar 2010 00:25:05 +0800
Message-Id: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In multi-threading environment, if the current task(A) have got
the mm->mmap_sem semaphore, and the thread(B) in the same process
is selected to be oom killed, because they shares the same semaphore,
thread B can not really be killed.  So __alloc_pages_slowpath turns
to be a infinite loop.  Here set all the threads in the group to
TIF_MEMDIE, it gets a chance to break and exit.

Signed-off-by: Anfei Zhou <anfei.zhou@gmail.com>
---
 mm/oom_kill.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9b223af..aab9892 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -381,6 +381,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  */
 static void __oom_kill_task(struct task_struct *p, int verbose)
 {
+	struct task_struct *t;
+
 	if (is_global_init(p)) {
 		WARN_ON(1);
 		printk(KERN_WARNING "tried to kill init!\n");
@@ -412,6 +414,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
+	for (t = next_thread(p); t != p; t = next_thread(t))
+		set_tsk_thread_flag(t, TIF_MEMDIE);
 
 	force_sig(SIGKILL, p);
 }
-- 
1.6.4.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
