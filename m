Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FEE96B0125
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 02:37:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C7bqOk006668
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 16:37:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9221C45DE54
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:37:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D0E445DE4D
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:37:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D0881DB803C
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:37:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A41041DB803E
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:37:51 +0900 (JST)
Date: Fri, 12 Mar 2010 16:34:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 00/10 -mm v3] oom killer rewrite
Message-Id: <20100312163415.ff6fb5c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2010 02:41:08 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> This patchset is a rewrite of the out of memory killer to address several
> issues that have been raised recently.  The most notable change is a
> complete rewrite of the badness heuristic that determines which task is
> killed; the goal was to make it as simple and predictable as possible
> while still addressing issues that plague the VM.
> 
> Changes from version 2:
> 
>  - updated to mmotm-2010-03-09-19-15
> 
>  - schedule a timeout for current if it was not selected for oom kill
>    when it has returned VM_FAULT_OOM so memory can freed to prevent
>    needlessly recalling the oom killer and looping.
> 

To me, this seems to work nicer than current oom-killer, memory eater dies 1st. 
thanks.

BTW, it seems there are still chances for serial-oom-killer.

Assume I run memory eater (called malloc) on a host.
==
Mar 13 13:05:56 localhost kernel: malloc invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
Mar 13 13:05:56 localhost kernel: malloc cpuset=/ mems_allowed=0
Mar 13 13:05:56 localhost kernel: Pid: 2525, comm: malloc Not tainted 2.6.34-rc1-mm1+ #3
Mar 13 13:05:56 localhost kernel: Call Trace:
Mar 13 13:05:56 localhost kernel: [<ffffffff8108aebf>] ? cpuset_print_task_mems_allowed+0x91/0x9c
Mar 13 13:05:56 localhost kernel: [<ffffffff810c90c1>] dump_header+0x74/0x1af
<snip>
Mar 13 13:05:56 localhost kernel: [ 2525]   500  2525   434340   433346   0       0             0 malloc
Mar 13 13:05:56 localhost kernel: Out of memory: Kill process 2525 (malloc) with score 967 or sacrifice child
Mar 13 13:05:56 localhost kernel: Killed process 2525 (malloc) total-vm:1737360kB, anon-rss:1733364kB, file-rss:20kB
Mar 13 13:05:56 localhost kernel: rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
Mar 13 13:05:56 localhost kernel: rsyslogd cpuset=/ mems_allowed=0
Mar 13 13:05:56 localhost kernel: Pid: 696, comm: rsyslogd Not tainted 2.6.34-rc1-mm1+ #3
Mar 13 13:05:56 localhost kernel: Call Trace:
Mar 13 13:05:56 localhost kernel: [<ffffffff8108aebf>] ? cpuset_print_task_mems_allowed+0x91/0x9c
Mar 13 13:05:56 localhost kernel: [<ffffffff810c90c1>] dump_header+0x74/0x1af
Mar 13 13:05:56 localhost kernel: [<ffffffff81211a8e>] ? ___ratelimit+0xe6/0x104
Mar 13 13:05:56 localhost kernel: [<ffffffff810c942a>] oom_kill_process+0x49/0x1ed
<snip>
Mar 13 13:05:56 localhost kernel: 480 total pagecache pages
Mar 13 13:05:56 localhost kernel: 0 pages in swap cache
Mar 13 13:05:56 localhost kernel: Swap cache stats: add 0, delete 0, find 0/0
Mar 13 13:05:56 localhost kernel: Free swap  = 0kB
Mar 13 13:05:56 localhost kernel: Total swap = 0kB
Mar 13 13:05:56 localhost kernel: 2097151 pages RAM
Mar 13 13:05:56 localhost kernel: 48776 pages reserved
Mar 13 13:05:56 localhost kernel: 1356 pages shared
Mar 13 13:05:56 localhost kernel: 458132 pages non-shared
<snip>
Mar 13 13:05:56 localhost kernel: [ 2506]     0  2506     3120       55   0       0             0 anacron
Mar 13 13:05:56 localhost kernel: Out of memory: Kill process 1267 (gdm-simple-gree) with score 2 or sacrifice child
Mar 13 13:05:56 localhost kernel: Killed process 1267 (gdm-simple-gree) total-vm:359156kB, anon-rss:4012kB, file-rss:472kB
==

Then, at first, malloc, a bad program is killed. But, another oom-kill happens immediately and 
gdm-simple-gree is killed.

I think there is a task as !p->mm but TIF_MEMDIE task in tasklist.

Because exit_mm()'s logic is as following.
	mm = task->mm
	task->mm = NULL;
	mmput(mm)
		-> free pages under this mm.

This patch make the result better on my box, no serial killer, at least.

-Kame
==

---
 mm/oom_kill.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

Index: mmotm-2.6.34-Mar11/mm/oom_kill.c
===================================================================
--- mmotm-2.6.34-Mar11.orig/mm/oom_kill.c
+++ mmotm-2.6.34-Mar11/mm/oom_kill.c
@@ -290,6 +290,17 @@ static struct task_struct *select_bad_pr
 	for_each_process(p) {
 		unsigned int points;
 		/*
+		 * This task already has access to memory reserves and is
+		 * being killed. Don't allow any other task access to the
+		 * memory reserve.
+		 *
+		 * Note: this may have a chance of deadlock if it gets
+		 * blocked waiting for another task which itself is waiting
+		 * for memory. Is there a better alternative?
+		 */
+		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+			return ERR_PTR(-1UL);
+		/*
 		 * skip kernel threads and tasks which have already released
 		 * their mm.
 		 */
@@ -305,17 +316,6 @@ static struct task_struct *select_bad_pr
 									 NULL))
 			continue;
 
-		/*
-		 * This task already has access to memory reserves and is
-		 * being killed. Don't allow any other task access to the
-		 * memory reserve.
-		 *
-		 * Note: this may have a chance of deadlock if it gets
-		 * blocked waiting for another task which itself is waiting
-		 * for memory. Is there a better alternative?
-		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
-			return ERR_PTR(-1UL);
 
 		/*
 		 * This is in the process of releasing memory so wait for it


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
