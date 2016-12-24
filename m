Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD0F280257
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 01:25:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c20so111611968itb.5
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 22:25:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g74si26246248iod.161.2016.12.23.22.25.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 22:25:51 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161219122738.GB427@tigerII.localdomain>
	<20161220153948.GA575@tigerII.localdomain>
	<201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
	<201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
	<20161222192406.GB19898@dhcp22.suse.cz>
In-Reply-To: <20161222192406.GB19898@dhcp22.suse.cz>
Message-Id: <201612241525.EDB52697.OQSFOLJFFOHVMt@I-love.SAKURA.ne.jp>
Date: Sat, 24 Dec 2016 15:25:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, torvalds@linux-foundation.org, akpm@linux-foundation.org
Cc: sergey.senozhatsky@gmail.com, linux-mm@kvack.org, pmladek@suse.cz

Linus and Andrew, may I have your attitude about Linux kernel's memory management
subsystem? Currently, the kernel can OOM lockup if more stress than Michal Hocko
thinks "sane" is given. Should we just throw our hands up if stress like
sleep-with-oom_lock2.c shown below is given?

---------- sleep-with-oom_lock2.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>
#include <poll.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { 0 };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	int fd;
	signal(SIGCLD, SIG_IGN);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	for (size = 512; size <= 1024 * 256; size <<= 1) 
		buf = realloc(buf, size);
	if (!buf)
		exit(1);
	pipe(pipe_fd);
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			char c;
			close(pipe_fd[1]);
			read(pipe_fd[0], &c, 1);
			/*
			 * Wait for a bit after idle-priority started
			 * invoking the OOM killer.
			 */
			poll(NULL, 0, 1000);
			/* Try to consume as much CPU time as possible. */
			for (i = 0; i < 1024 * 256; i += 4096)
				buf[i] = 0;
			_exit(0);
		}
	fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	close(pipe_fd[1]);
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
---------- sleep-with-oom_lock2.c end ----------



Michal Hocko wrote:
> On Thu 22-12-16 22:33:40, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > Now, what options are left other than replacing !mutex_trylock(&oom_lock)
> > > with mutex_lock_killable(&oom_lock) which also stops wasting CPU time?
> > > Are we waiting for offloading sending to consoles?
> > 
> >  From http://lkml.kernel.org/r/20161222115057.GH6048@dhcp22.suse.cz :
> > > > Although I don't know whether we agree with mutex_lock_killable(&oom_lock)
> > > > change, I think this patch alone can go as a cleanup.
> > > 
> > > No, we don't agree on that part. As this is a printk issue I do not want
> > > to workaround it in the oom related code. That is just ridiculous. The
> > > very same issue would be possible due to other continous source of log
> > > messages.
> > 
> > I don't think so. Lockup caused by printk() is printk's problem. But printk
> > is not the only source of lockup. If CONFIG_PREEMPT=y, it is possible that
> > a thread which held oom_lock can sleep for unbounded period depending on
> > scheduling priority.
> 
> Unless there is some runaway realtime process then the holder of the oom
> lock shouldn't be preempted for the _unbounded_ amount of time. It might
> take quite some time, though. But that is not reduced to the OOM killer.
> Any important part of the system (IO flushers and what not) would suffer
> from the same issue.

I fail to understand why you assume "realtime process".
This lockup is still triggerable using "normal process" and "idle process".

Below are results where "printk() lockup with oom_lock held" was solved by
applying http://lkml.kernel.org/r/20161222140930.GF413@tigerII.localdomain .



sleep-with-oom_lock1.c shown below is a reproducer which did not recover
within acceptable period.

---------- sleep-with-oom_lock1.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { 0 };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	char *buf = NULL;
	unsigned long size = 0;
	unsigned int i;
	int fd;
	pipe(pipe_fd);
	signal(SIGCLD, SIG_IGN);
	if (fork() == 0) {
		prctl(PR_SET_NAME, (unsigned long) "first-victim", 0, 0, 0);
		while (1)
			pause();
	}
	close(pipe_fd[1]);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	for (i = 0; i < 1024; i++)
		if (fork() == 0) {
			char c;
			/* Wait until the first-victim is OOM-killed. */
			read(pipe_fd[0], &c, 1);
			/* Try to consume as much CPU time as possible. */
			while(1);
			_exit(0);
		}
	close(pipe_fd[0]);
	fd = open("/dev/zero", O_RDONLY);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sched_setscheduler(0, SCHED_IDLE, &sp);
	prctl(PR_SET_NAME, (unsigned long) "idle-priority", 0, 0, 0);
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
---------- sleep-with-oom_lock1.c end ----------

Complete log is http://I-love.SAKURA.ne.jp/tmp/serial-20161224-1.txt.xz
----------
[  426.927853] idle-priority invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
[  426.927855] idle-priority cpuset=/ mems_allowed=0
(...snipped...)
[  426.928017] Out of memory: Kill process 4360 (idle-priority) score 660 or sacrifice child
[  426.929886] Killed process 4362 (normal-priority) total-vm:4164kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  436.962756] normal-priority: page allocation stalls for 10015ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  436.962762] CPU: 0 PID: 5203 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[  447.123293] normal-priority: page allocation stalls for 20134ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[  447.123299] CPU: 0 PID: 5176 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 1037.019523] normal-priority: page allocation stalls for 610074ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1037.019529] CPU: 0 PID: 5203 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 1050.710795] normal-priority: page allocation stalls for 623723ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1050.710801] CPU: 0 PID: 5176 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 1051.133604] systemd-logind: page allocation stalls for 510002ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[ 1051.133611] CPU: 0 PID: 668 Comm: systemd-logind Not tainted 4.9.0-next-20161222+ #480
[ 1051.133612] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1051.133613] Call Trace:
[ 1051.133618]  dump_stack+0x85/0xc9
[ 1051.133621]  warn_alloc+0xf8/0x190
[ 1051.133624]  __alloc_pages_slowpath+0x4a8/0x8a0
[ 1051.133625]  __alloc_pages_nodemask+0x456/0x4e0
[ 1051.133627]  alloc_pages_current+0x97/0x1b0
[ 1051.133630]  ? find_get_entry+0x5/0x300
[ 1051.133631]  __page_cache_alloc+0x15d/0x1a0
[ 1051.133633]  ? pagecache_get_page+0x2c/0x2b0
[ 1051.133634]  filemap_fault+0x48e/0x6d0
[ 1051.133636]  ? filemap_fault+0x339/0x6d0
----------

The last OOM killer invocation was uptime = 426 and
I gave up waiting and pressed SysRq-b at uptime = 1051.

You might complain that it is not fair to use 'wasting CPU time by "while(1);"
in userspace' as a reason to push this patch. I agree that we can't cope with it
if CPU time is wasted in userspace.

But sleep-with-oom_lock2.c shown above is a similar reproducer which did not
recover within acceptable period. This time, nobody is wasting CPU time in userspace.

Complete log is http://I-love.SAKURA.ne.jp/tmp/serial-20161224-2.txt.xz
----------
[ 1061.428002] idle-priority invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
[ 1061.428004] idle-priority cpuset=/ mems_allowed=0
(...snipped...)
[ 1061.428147] Out of memory: Kill process 10553 (idle-priority) score 640 or sacrifice child
[ 1061.429857] Killed process 11527 (normal-priority) total-vm:4556kB, anon-rss:304kB, file-rss:4kB, shmem-rss:0kB
[ 1062.300349] warn_alloc: 117 callbacks suppressed
[ 1062.300351] normal-priority: page allocation stalls for 190508ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[ 1062.300355] CPU: 0 PID: 10858 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 1080.345125] normal-priority: page allocation stalls for 20165ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[ 1080.345131] CPU: 0 PID: 11564 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 2202.150829] normal-priority: page allocation stalls for 1330359ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[ 2202.150835] CPU: 0 PID: 10858 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
(...snipped...)
[ 2300.897797] normal-priority: page allocation stalls for 1240719ms, order:0, mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[ 2300.897804] CPU: 0 PID: 11564 Comm: normal-priority Not tainted 4.9.0-next-20161222+ #480
[ 2300.897804] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 2300.897805] Call Trace:
[ 2300.897811]  dump_stack+0x85/0xc9
[ 2300.897814]  warn_alloc+0xf8/0x190
[ 2300.897817]  __alloc_pages_slowpath+0x4a8/0x8a0
[ 2300.897819]  __alloc_pages_nodemask+0x456/0x4e0
[ 2300.897820]  ? lock_page_memcg+0x5/0xf0
[ 2300.897823]  alloc_pages_vma+0xbe/0x2d0
[ 2300.897826]  ? sched_clock_cpu+0x84/0xb0
[ 2300.897829]  wp_page_copy+0x83/0x6f0
[ 2300.897830]  do_wp_page+0xa0/0x5c0
[ 2300.897831]  handle_mm_fault+0x929/0x1180
[ 2300.897832]  ? handle_mm_fault+0x5e/0x1180
[ 2300.897835]  __do_page_fault+0x24a/0x530
[ 2300.897837]  do_page_fault+0x30/0x80
[ 2300.897840]  page_fault+0x28/0x30
[ 2300.897841] RIP: 0033:0x4009c0
[ 2300.897842] RSP: 002b:00007fff48aade40 EFLAGS: 00010287
[ 2300.897843] RAX: 0000000000001000 RBX: 000000000000000e RCX: 00007fc7e74bcde0
[ 2300.897844] RDX: 00000000000003e8 RSI: 0000000000000000 RDI: 0000000000000000
[ 2300.897844] RBP: 00007fc7e795f010 R08: 00007fc7e79a0740 R09: 0000000000000000
[ 2300.897845] R10: 00007fff48aadbc0 R11: 0000000000000246 R12: 0000000000080000
[ 2300.897846] R13: 00007fff48aadfe0 R14: 0000000000000000 R15: 0000000000000000
----------

The last OOM killer invocation was uptime = 1061 and
I gave up waiting and pressed SysRq-b at uptime = 2300.

See? The runaway is occurring inside kernel space due to almost-busy looping
direct reclaim against a thread with idle priority with oom_lock held.

My assertion is that we need to make sure that the OOM killer/reaper are given
enough CPU time so that they can perform memory reclaim operation and release
oom_lock. We can't solve CPU time consumption by sleep-with-oom_lock1.c case
but we can solve CPU time consumption by sleep-with-oom_lock2.c case.

I think it is waste of CPU time to let all threads try direct reclaim
which also bothers them with consistent __GFP_NOFS/__GFP_NOIO usage which
might involve dependency to other threads. But changing it is not easy.

Thus, I'm proposing to save CPU time if waiting for the OOM killer/reaper
when direct reclaim did not help.

> 
> > Then, you call such latency as scheduler's problem?
> > mutex_lock_killable(&oom_lock) change helps coping with whatever delays
> > OOM killer/reaper might encounter.
> 
> It helps _your_ particular insane workload. I believe you can construct
> many others which which would cause a similar problem and the above
> suggestion wouldn't help a bit. Until I can see this is easily
> triggerable on a reasonably configured system then I am not convinced
> we should add more non trivial changes to the oom killer path.

I'm not using root privileges nor realtime priority nor CONFIG_PREEMPT=y.
Why you don't care about the worst situation / corner cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
