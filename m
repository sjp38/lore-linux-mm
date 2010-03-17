Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4471B6B00A7
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:00:48 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o2H10hCS017025
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:00:44 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz9.hot.corp.google.com with ESMTP id o2H10eGD022246
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:00:42 -0700
Received: by pwj10 with SMTP id 10so459082pwj.12
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:00:40 -0700 (PDT)
Date: Tue, 16 Mar 2010 18:00:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/10 -mm v3] oom killer rewrite
In-Reply-To: <20100312163415.ff6fb5c5.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003161747240.7128@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com> <20100312163415.ff6fb5c5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010, KAMEZAWA Hiroyuki wrote:

> BTW, it seems there are still chances for serial-oom-killer.
> 
> Assume I run memory eater (called malloc) on a host.
> ==
> Mar 13 13:05:56 localhost kernel: malloc invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
> Mar 13 13:05:56 localhost kernel: malloc cpuset=/ mems_allowed=0
> Mar 13 13:05:56 localhost kernel: Pid: 2525, comm: malloc Not tainted 2.6.34-rc1-mm1+ #3
> Mar 13 13:05:56 localhost kernel: Call Trace:
> Mar 13 13:05:56 localhost kernel: [<ffffffff8108aebf>] ? cpuset_print_task_mems_allowed+0x91/0x9c
> Mar 13 13:05:56 localhost kernel: [<ffffffff810c90c1>] dump_header+0x74/0x1af
> <snip>
> Mar 13 13:05:56 localhost kernel: [ 2525]   500  2525   434340   433346   0       0             0 malloc
> Mar 13 13:05:56 localhost kernel: Out of memory: Kill process 2525 (malloc) with score 967 or sacrifice child
> Mar 13 13:05:56 localhost kernel: Killed process 2525 (malloc) total-vm:1737360kB, anon-rss:1733364kB, file-rss:20kB
> Mar 13 13:05:56 localhost kernel: rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
> Mar 13 13:05:56 localhost kernel: rsyslogd cpuset=/ mems_allowed=0
> Mar 13 13:05:56 localhost kernel: Pid: 696, comm: rsyslogd Not tainted 2.6.34-rc1-mm1+ #3
> Mar 13 13:05:56 localhost kernel: Call Trace:
> Mar 13 13:05:56 localhost kernel: [<ffffffff8108aebf>] ? cpuset_print_task_mems_allowed+0x91/0x9c
> Mar 13 13:05:56 localhost kernel: [<ffffffff810c90c1>] dump_header+0x74/0x1af
> Mar 13 13:05:56 localhost kernel: [<ffffffff81211a8e>] ? ___ratelimit+0xe6/0x104
> Mar 13 13:05:56 localhost kernel: [<ffffffff810c942a>] oom_kill_process+0x49/0x1ed
> <snip>
> Mar 13 13:05:56 localhost kernel: 480 total pagecache pages
> Mar 13 13:05:56 localhost kernel: 0 pages in swap cache
> Mar 13 13:05:56 localhost kernel: Swap cache stats: add 0, delete 0, find 0/0
> Mar 13 13:05:56 localhost kernel: Free swap  = 0kB
> Mar 13 13:05:56 localhost kernel: Total swap = 0kB
> Mar 13 13:05:56 localhost kernel: 2097151 pages RAM
> Mar 13 13:05:56 localhost kernel: 48776 pages reserved
> Mar 13 13:05:56 localhost kernel: 1356 pages shared
> Mar 13 13:05:56 localhost kernel: 458132 pages non-shared
> <snip>
> Mar 13 13:05:56 localhost kernel: [ 2506]     0  2506     3120       55   0       0             0 anacron
> Mar 13 13:05:56 localhost kernel: Out of memory: Kill process 1267 (gdm-simple-gree) with score 2 or sacrifice child
> Mar 13 13:05:56 localhost kernel: Killed process 1267 (gdm-simple-gree) total-vm:359156kB, anon-rss:4012kB, file-rss:472kB
> ==
> 
> Then, at first, malloc, a bad program is killed. But, another oom-kill happens immediately and 
> gdm-simple-gree is killed.
> 
> I think there is a task as !p->mm but TIF_MEMDIE task in tasklist.
> 

Perhaps, but we should probably handle exit racing conditions with 
PF_EXITING instead of TIF_MEMDIE.  We also need to filter these tasks 
according to memcg and cpusets since oom killed tasks in other cgroups 
shouldn't make the oom killer a no-op for current.

I'll add this:
---
 mm/oom_kill.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -290,12 +290,6 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	for_each_process(p) {
 		unsigned int points;
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
-		if (!p->mm)
-			continue;
 		/* skip the init task */
 		if (is_global_init(p))
 			continue;
@@ -336,6 +330,12 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			*ppoints = 1000;
 		}
 
+		/*
+		 * skip kernel threads and tasks which have already released
+		 * their mm.
+		 */
+		if (!p->mm)
+			continue;
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
