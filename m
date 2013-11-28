Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 40A9E6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 00:09:22 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so11359982pdj.12
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 21:09:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r3si10975568pan.72.2013.11.27.21.09.20
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 21:09:20 -0800 (PST)
From: "Ma, Xindong" <xindong.ma@intel.com>
Subject: [PATCH] Fix race between oom kill and task exit
Date: Thu, 28 Nov 2013 05:09:16 +0000
Message-ID: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "rientjes@google.com" <rientjes@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Peter
 Zijlstra' <peterz@infradead.org>, "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Cc: "Ma, Xindong" <xindong.ma@intel.com>, "Tu, Xiaobing" <xiaobing.tu@intel.com>

From: Leon Ma <xindong.ma@intel.com>
Date: Thu, 28 Nov 2013 12:46:09 +0800
Subject: [PATCH] Fix race between oom kill and task exit

There is a race between oom kill and task exit. Scenario is:
   TASK  A                      TASK  B
TASK B is selected to oom kill
in oom_kill_process()
check PF_EXITING of TASK B
                            task call do_exit()
                            task set PF_EXITING flag
                            write_lock_irq(&tasklist_lock);
                            remove TASK B from thread group in __unhash_pro=
cess()
                            write_unlock_irq(&tasklist_lock);
read_lock(&tasklist_lock);
traverse threads of TASK B
read_unlock(&tasklist_lock);

After that, the following traversal of threads in TASK B will not end becau=
se TASK B is not in the thread group:
do {
....
} while_each_thread(p, t);

Signed-off-by: Leon Ma <xindong.ma@intel.com>
Signed-off-by: xiaobing tu <xiaobing.tu@intel.com>
---
 mm/oom_kill.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e4a600..32ec88d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -412,16 +412,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp=
_mask, int order,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
=20
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	if (p->flags & PF_EXITING) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
-		put_task_struct(p);
-		return;
-	}
-
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
=20
@@ -437,6 +427,16 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp=
_mask, int order,
 	 * still freeing memory.
 	 */
 	read_lock(&tasklist_lock);
+	/*
+	 * If the task is already exiting, don't alarm the sysadmin or kill
+	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 */
+	if (p->flags & PF_EXITING) {
+		set_tsk_thread_flag(p, TIF_MEMDIE);
+		put_task_struct(p);
+		read_unlock(&tasklist_lock);
+		return;
+	}
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
--=20
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
