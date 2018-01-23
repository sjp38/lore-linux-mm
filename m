Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1CD7800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:07:21 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u128so114458oib.8
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:07:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 3si846288oil.486.2018.01.23.04.07.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 04:07:20 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1516628782-3524-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180123083806.GF1526@dhcp22.suse.cz>
In-Reply-To: <20180123083806.GF1526@dhcp22.suse.cz>
Message-Id: <201801232107.HJB48975.OHJFFOOLFQMVSt@I-love.SAKURA.ne.jp>
Date: Tue, 23 Jan 2018 21:07:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Mon 22-01-18 22:46:22, Tetsuo Handa wrote:
> > When I was examining a bug which occurs under CPU + memory pressure, I
> > observed that a thread which called out_of_memory() can sleep for minutes
> > at schedule_timeout_killable(1) with oom_lock held when many threads are
> > doing direct reclaim.
> > 
> > --------------------
> > [  163.357628] b.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
> > [  163.360946] CPU: 0 PID: 554 Comm: b.out Not tainted 4.15.0-rc8+ #216
> > (...snipped...)
> > [  163.470193] Out of memory: Kill process 548 (b.out) score 6 or sacrifice child
> > [  163.471813] Killed process 1191 (b.out) total-vm:2108kB, anon-rss:60kB, file-rss:4kB, shmem-rss:0kB
> > (...snipped...)
> > [  248.016033] sysrq: SysRq : Show State
> > (...snipped...)
> > [  249.625720] b.out           R  running task        0   554    538 0x00000004
> > [  249.627778] Call Trace:
> > [  249.628513]  __schedule+0x142/0x4b2
> > [  249.629394]  schedule+0x27/0x70
> > [  249.630114]  schedule_timeout+0xd1/0x160
> > [  249.631029]  ? oom_kill_process+0x396/0x400
> > [  249.632039]  ? __next_timer_interrupt+0xc0/0xc0
> > [  249.633087]  schedule_timeout_killable+0x15/0x20
> > [  249.634097]  out_of_memory+0xea/0x270
> > [  249.634901]  __alloc_pages_nodemask+0x715/0x880
> > [  249.635920]  handle_mm_fault+0x538/0xe40
> > [  249.636888]  ? __enqueue_entity+0x63/0x70
> > [  249.637787]  ? set_next_entity+0x4b/0x80
> > [  249.638687]  __do_page_fault+0x199/0x430
> > [  249.639535]  ? vmalloc_sync_all+0x180/0x180
> > [  249.640452]  do_page_fault+0x1a/0x1e
> > [  249.641283]  common_exception+0x82/0x8a
> > (...snipped...)
> > [  462.676366] oom_reaper: reaped process 1191 (b.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > --------------------
> > 
> > --------------------
> > [  269.985819] b.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
> > [  269.988570] CPU: 0 PID: 9079 Comm: b.out Not tainted 4.15.0-rc8+ #217
> > (...snipped...)
> > [  270.073050] Out of memory: Kill process 914 (b.out) score 9 or sacrifice child
> > [  270.074660] Killed process 2208 (b.out) total-vm:2108kB, anon-rss:64kB, file-rss:4kB, shmem-rss:0kB
> > [  297.562824] sysrq: SysRq : Show State
> > (...snipped...)
> > [  471.716610] b.out           R  running task        0  9079   7400 0x00000000
> > [  471.718203] Call Trace:
> > [  471.718784]  __schedule+0x142/0x4b2
> > [  471.719577]  schedule+0x27/0x70
> > [  471.720294]  schedule_timeout+0xd1/0x160
> > [  471.721207]  ? oom_kill_process+0x396/0x400
> > [  471.722151]  ? __next_timer_interrupt+0xc0/0xc0
> > [  471.723215]  schedule_timeout_killable+0x15/0x20
> > [  471.724350]  out_of_memory+0xea/0x270
> > [  471.725201]  __alloc_pages_nodemask+0x715/0x880
> > [  471.726238]  ? radix_tree_lookup_slot+0x1f/0x50
> > [  471.727253]  filemap_fault+0x346/0x510
> > [  471.728120]  ? filemap_map_pages+0x245/0x2d0
> > [  471.729105]  ? unlock_page+0x30/0x30
> > [  471.729987]  __xfs_filemap_fault.isra.18+0x2d/0xb0
> > [  471.731488]  ? unlock_page+0x30/0x30
> > [  471.732364]  xfs_filemap_fault+0xa/0x10
> > [  471.733260]  __do_fault+0x11/0x30
> > [  471.734033]  handle_mm_fault+0x8e8/0xe40
> > [  471.735200]  __do_page_fault+0x199/0x430
> > [  471.736163]  ? common_exception+0x82/0x8a
> > [  471.737102]  ? vmalloc_sync_all+0x180/0x180
> > [  471.738061]  do_page_fault+0x1a/0x1e
> > [  471.738881]  common_exception+0x82/0x8a
> > (...snipped...)
> > [  566.969400] oom_reaper: reaped process 2208 (b.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > --------------------
> > 
> > Allowing the OOM reaper to start reclaiming memory without waiting for
> > the oom_lock is not sufficient if the OOM reaper did not reclaim enough
> > memory. We need to make sure that the thread which called out_of_memory()
> > will release oom_lock shortly. Thus, this patch brings the short sleep
> > to outside of the OOM killer.
> 
> And why does sleeping outside of the lock make any sense? The whole
> point of the sleep is to give the victim some time to exit and if we
> sleep outside of the lock then contending allocating paths hit the oom
> path early.

Why does subsequent threads call out_of_memory() again without giving
the OOM victim some time to exit matter? MMF_OOM_SKIP test will prevent
subsequent out_of_memory() calls from selecting next OOM victims.

> 
> To be completely host, I am not in love with this
> schedule_timeout_uninterruptible(1). It is an ugly hack. It used to be
> much more important in the past when the oom victim test was too
> fragile. I strongly suspect that it is not needed this days so rather
> than moving the sleep around I would try to remove it altogether.

But this schedule_timeout_uninterruptible(1) serves as a guaranteed
sleep for PF_WQ_WORKER threads
( http://lkml.kernel.org/r/20170830064019.mfihbeu3mm5ygcrb@dhcp22.suse.cz ).

    > If we are under memory pressure, __zone_watermark_ok() can return false.
    > If __zone_watermark_ok() == false, when is schedule_timeout_*() called explicitly?

    If all zones fail with the watermark check then we should hit the oom
    path and sleep there. We do not do so for all cases though.

Thus, you cannot simply remove it.

> 
> Also, your changelog silently skips over some important details. The
> system must be really overloaded when a short sleep can take minutes.

Yes, the system was really overloaded, for I was testing below reproducer
on a x86_32 kernel.

----------------------------------------
#define _FILE_OFFSET_BITS 64
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

static void run(void)
{
	unsigned long long size;
	char *buf = NULL;
	unsigned long long i;
	for (i = 0; i < 24; i++) {
		if (fork() == 0) {
			static char buf[4096];
			const int fd = open("file", O_CREAT | O_WRONLY | O_APPEND, 0600);
			while (write(fd, buf, sizeof(buf)) == sizeof(buf));
			close(fd);
			_exit(0);
		}
	}
	for (size = 1048576; size < 512ULL * (1 << 30); size += 1048576) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size -= 1048576;
			break;
		}
		buf = cp;
	}
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	_exit(0);
} 

int main(int argc, char *argv[])
{
	if (argc != 1)
		run();
	else
		while (1)
			if (fork() == 0)
				execlp(argv[0], argv[0], "", NULL);
	return 0;
}
----------------------------------------

> I would trongly suspect that such an overloaded system doesn't need
> a short sleep to hold the oom lock for too long. All you need is to be
> preempted. So this patch doesn't really solve any _real_ problem.

Preemption makes the OOM situation much worse. The only way to avoid all OOM
lockups caused by lack of CPU resource is to replace mutex_trylock(&oom_lock)
in __alloc_pages_may_oom() with mutex_lock(&oom_lock) (or similar) in order to
guarantee that all threads waiting for the OOM killer/reaper to make forward
progress shall give enough CPU resource.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
