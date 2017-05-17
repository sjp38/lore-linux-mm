Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88E4A6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:26:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d127so3284519wmf.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:26:46 -0700 (PDT)
Received: from castle.thefacebook.com ([199.201.66.0])
        by mx.google.com with ESMTP id a35si2617474ede.231.2017.05.17.08.26.44
        for <linux-mm@kvack.org>;
        Wed, 17 May 2017 08:26:44 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm,oom: fix oom invocation issues
Date: Wed, 17 May 2017 16:26:20 +0100
Message-Id: <1495034780-9520-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

During the debugging of some OOM-related stuff, I've noticed
that sometimes OOM kills two processes instead of one.

The problem can be easily reproduced on a vanilla kernel
(allocate is a simple process which calls malloc() and faults
each page in a infinite loop):
[   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   25.725658] allocate cpuset=/ mems_allowed=0
[   25.727033] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
<cut>
[   25.768293] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   25.768860] [  121]     0   121    25672      133      50       3        0             0 systemd-journal
[   25.769530] [  156]     0   156    11157      197      22       3        0         -1000 systemd-udevd
[   25.770206] [  206]     0   206    13896       99      29       3        0         -1000 auditd
[   25.770822] [  227]     0   227    11874      124      27       3        0             0 systemd-logind
[   25.771494] [  229]    81   229    11577      146      28       3        0          -900 dbus-daemon
[   25.772126] [  231]   997   231    27502      102      25       3        0             0 chronyd
[   25.772731] [  233]     0   233    61519     5239      85       3        0             0 firewalld
[   25.773345] [  238]     0   238   123495      529      74       4        0             0 NetworkManager
[   25.773988] [  265]     0   265    25117      231      52       3        0         -1000 sshd
[   25.774569] [  271]     0   271     6092      154      17       3        0             0 crond
[   25.775137] [  277]     0   277    11297       93      26       3        0             0 systemd-hostnam
[   25.775766] [  284]     0   284     1716       29       9       3        0             0 agetty
[   25.776342] [  285]     0   285     2030       34       9       4        0             0 agetty
[   25.776919] [  302]   998   302   133102     2578      58       3        0             0 polkitd
[   25.777505] [  394]     0   394    21785     3076      45       3        0             0 dhclient
[   25.778092] [  444]     0   444    36717      312      74       3        0             0 sshd
[   25.778744] [  446]     0   446    15966      223      36       3        0             0 systemd
[   25.779304] [  447]     0   447    23459      384      47       3        0             0 (sd-pam)
[   25.779877] [  451]     0   451    36717      316      72       3        0             0 sshd
[   25.780450] [  452]     0   452     3611      315      11       3        0             0 bash
[   25.781107] [  492]     0   492   513092   473645     934       5        0             0 allocate
[   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
[   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
<cut>
[   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
[   25.818821] allocate cpuset=/ mems_allowed=0
[   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.820549] Call Trace:
[   25.820733]  dump_stack+0x63/0x82
[   25.820961]  dump_header+0x97/0x21a
[   25.820961]  ? security_capable_noaudit+0x45/0x60
[   25.820961]  oom_kill_process+0x219/0x3e0
[   25.820961]  out_of_memory+0x11d/0x480
[   25.820961]  pagefault_out_of_memory+0x68/0x80
[   25.820961]  mm_fault_error+0x8f/0x190
[   25.820961]  ? handle_mm_fault+0xf3/0x210
[   25.820961]  __do_page_fault+0x4b2/0x4e0
[   25.820961]  trace_do_page_fault+0x37/0xe0
[   25.820961]  do_async_page_fault+0x19/0x70
[   25.820961]  async_page_fault+0x28/0x30
<cut>
[   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
[   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB

After some investigations I've found some issues:

1) Prior to commit 1af8bb432695 ("mm, oom: fortify task_will_free_mem()"),
   if a process with a pending SIGKILL was calling out_of_memory(),
   it was always immediately selected as a victim.
   But now, after some changes, it's not always a case.
   If a process has been reaped at the moment, MMF_SKIP_FLAG is set,
   task_will_free_mem() will return false, and a new
   victim selection logic will be started.

   This actually happens if a userspace pagefault causing an OOM.
   pagefault_out_of_memory() is called in a context of a faulting
   process after it has been selected as OOM victim (assuming, it
   has), and killed. With some probability (there is a race with
   oom_reaper thread) this process will be passed to the oom reaper
   again, or an innocent victim will be selected and killed.

2) We clear up the task->oom_reaper_list before setting
   the MMF_OOM_SKIP flag, so there is a race.

3) We skip the MMF_OOM_SKIP flag check in case of
   an sysrq-triggered OOM.

To address these issues, the following is proposed:
1) If task is already an oom victim, skip out_of_memory() call
   from the pagefault_out_of_memory().

2) Set the MMF_OOM_SKIP bit in wake_oom_reaper() before adding a
   process to the oom_reaper list. If it's already set, do nothing.
   Do not rely on tsk->oom_reaper_list value.

3) Check the MMF_OOM_SKIP even if OOM is triggered by a sysrq.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/oom_kill.c | 33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..c630c76 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -302,10 +302,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * the task has MMF_OOM_SKIP because chances that it would release
 	 * any memory is quite low.
 	 */
-	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
+	if (tsk_is_oom_victim(task)) {
 		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
 			goto next;
-		goto abort;
+		if (!is_sysrq_oom(oc))
+			goto abort;
 	}
 
 	/*
@@ -559,22 +560,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
-
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
-	tsk->oom_reaper_list = NULL;
-
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (attempts > MAX_OOM_REAP_RETRIES) {
+		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+			task_pid_nr(tsk), tsk->comm);
+		debug_show_all_locks();
+	}
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
@@ -590,6 +580,7 @@ static int oom_reaper(void *unused)
 		if (oom_reaper_list != NULL) {
 			tsk = oom_reaper_list;
 			oom_reaper_list = tsk->oom_reaper_list;
+			tsk->oom_reaper_list = NULL;
 		}
 		spin_unlock(&oom_reaper_lock);
 
@@ -605,8 +596,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	if (!oom_reaper_th)
 		return;
 
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	if (test_and_set_bit(MMF_OOM_SKIP, &tsk->signal->oom_mm->flags))
 		return;
 
 	get_task_struct(tsk);
@@ -1068,6 +1058,9 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
+	if (tsk_is_oom_victim(current))
+		return;
+
 	if (!mutex_trylock(&oom_lock))
 		return;
 	out_of_memory(&oc);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
