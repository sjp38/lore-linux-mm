Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9CE6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 09:49:41 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so5134032pab.30
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 06:49:41 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m2si11950513pdj.77.2014.11.27.06.49.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 06:49:39 -0800 (PST)
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141125103820.GA4607@dhcp22.suse.cz>
	<201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
	<20141125134558.GA4415@dhcp22.suse.cz>
	<201411262058.GAJ81735.OHFMOLQOSFtVJF@I-love.SAKURA.ne.jp>
	<20141126184316.GA31930@dhcp22.suse.cz>
In-Reply-To: <20141126184316.GA31930@dhcp22.suse.cz>
Message-Id: <201411272349.JJF21899.OHOFtSQJOFMVFL@I-love.SAKURA.ne.jp>
Date: Thu, 27 Nov 2014 23:49:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, rientjes@google.com
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 26-11-14 20:58:52, Tetsuo Handa wrote:
> > Here is an example trace of 3.10.0-121.el7-test. Two of OOM-killed processes
> > are inside task_work_run() from do_exit() and got stuck at memory allocation.
> > Processes past exit_mm() in do_exit() contribute OOM deadlock.
> 
> If the OOM victim passed exit_mm then it is usually not interesting for
> the OOM killer as it has already unmapped and freed its memory (assuming
> that mm_users is not elevated). It also doesn't have TIF_MEMDIE anymore
> so it doesn't block OOM killer from killing other tasks.

Then, why did the stall last for many minutes without making any progress?
I think that some lock held by a process past exit_mm() can prevent another
process chosen by the OOM killer from holding the lock (and therefore make
it impossible for another process to terminate).

> Without OOM report these traces are not useful very much. They are both
> somewhere in exit_files and deferred fput. I am not sure how much memory
> the process might hold at that time. I would be quite surprised if this
> was the majority of the OOM victim's memory.

I don't mean to attach any OOM reports here because attaching the OOM report
is equivalent with posting the reproducer program to LKML because the trace
of a.out will tell how to trigger the OOM deadlock/livelock. You already have
the source code of a.out and you are free to compile it and run a.out in
your environment.

> > > The OOM report was not complete so it is hard to say why the OOM
> > > condition wasn't resolved by the OOM killer but other OOM report you
> > > have posted (26 Apr) in that thread suggested that the system doesn't
> > > have any swap and the page cache is full of shmem. The process list
> > > didn't contain any large memory consumer so killing somebody wouldn't
> > > help much. But the OOM victim died normally in that case:
> > 
> > The problem is that a.out invoked by a local unprivileged user is the only
> > and the biggest memory consumer which the OOM killer thinks the least memory
> > consumer.
> 
> Yes, because a.out doesn't consume to much of per-process accounted
> memory. It's rss, ptes and swapped out memory is negligible to
> the memory allocated on behalf of processes for in-kernel data
> structures. This is quite unfortunate but this is basically "an
> untrusted user on your computer has to be contained" scenario.

Why do you think about only containing untrusted user? I'm using a.out as
a memory stressing tester for finding bugs under extreme memory pressure.
This is quite unfortunate but this is basically "any unreasonably lasting
stalls under extreme memory pressure have to be fixed" scenario.

>                                                                Ulimits
> should help to a certain degree and kmem accounting from memory cgroup
> controller should help for dentries, inodes and fork bombs but there
> might be other resources that might be unrestricted. If this is the case
> then the OOM killer should be taught to consider them or added a
> restriction for them. Later is preferable IMO.

Ulimits does not help at all because a.out consumes kernel memory where only
kmem accounting can account. But the kmem accounting helps little for me
because what I want is kmem accounting based on UID rather than memory cgroup.

I agree that teaching the OOM killer to consider them is preferable.
This vulnerability resembles "CVE-2010-4243 kernel: mm: mem allocated invisible
to oom_kill() when not attached to any threads", but much harder to fix and
backport. No patches are ever proposed due to performance hit and complexity.

>                                                But adding a timeout to
> OOM killer and hope that the next attempt will be more successful is
> definitely not the right approach.

I saw a case where an innocent administrator unexpectedly hit
"CVE-2012-4398 kernel: request_module() OOM local DoS" and his system
stalled for many hours until he manually issued SysRq-c.
I fixed request_module() and kthread_create(), but there are dozens of
memory allocation with locks held which may cause unexpected OOM stalls.
If below one is available, I will no longer see similar cases even if
the cause of OOM stall is out-of-tree kernel modules.

 	/* p may not be terminated within reasonale duration */
-	if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+	if (sysctl_memdie_timeout_jiffies &&
+	    test_tsk_thread_flag(p, TIF_MEMDIE)) {
 		smp_rmb(); /* set_memdie_flag() uses smp_wmb(). */
-		if (time_after(jiffies, p->memdie_start + 5 * HZ)) {
-			static unsigned char warn = 255;
-			char comm[sizeof(p->comm)];
-
-			if (warn && warn--)
-				pr_err("Process %d (%s) was not killed within 5 seconds.\n",
-				       task_pid_nr(p), get_task_comm(comm, p));
-			return true;
-		}
+		if (time_after(jiffies, p->memdie_start + sysctl_memdie_timeout_jiffies))
+			panic("Process %d (%s) did not die within %lu jiffies.\n",
+			      task_pid_nr(p), get_task_comm(comm, p),
+			      sysctl_memdie_timeout_jiffies);
 	}

If timeout for next OOM-kill is not acceptable, what about timeout for
kernel panic (followed by kdump and automatic reboot) like above one?
If still NACK, what alternatives can you propose for distributions using
2.6.18 / 2.6.32 / 3.2 kernels which do not have the kmem accounting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
