Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE4276B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 20:39:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so234211888pfb.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 17:39:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o8si27475106pad.129.2016.05.13.17.39.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 17:39:57 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
	<20160425095508.GE23933@dhcp22.suse.cz>
	<20160426135402.GB20813@dhcp22.suse.cz>
	<201604271943.GAC60432.FFJHtFVSOQOOLM@I-love.SAKURA.ne.jp>
	<20160427111147.GI2179@dhcp22.suse.cz>
In-Reply-To: <20160427111147.GI2179@dhcp22.suse.cz>
Message-Id: <201605140939.BFG05745.FJOOOSVQtLFMHF@I-love.SAKURA.ne.jp>
Date: Sat, 14 May 2016 09:39:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Wed 27-04-16 19:43:08, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 25-04-16 11:55:08, Michal Hocko wrote:
> > > > On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > I have seen that patch. I didn't get to review it properly yet as I am
> > > > > > still travelling. From a quick view I think it is conflating two things
> > > > > > together. I could see arguments for the panic part but I do not consider
> > > > > > the move-to-kill-another timeout as justified. I would have to see a
> > > > > > clear indication this is actually useful for real life usecases.
> > > > > 
> > > > > You admit that it is possible that the TIF_MEMDIE thread is blocked at
> > > > > unkillable wait (due to memory allocation requests by somebody else) but
> > > > > the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> > > > > for write), don't you?
> > > > 
> > > > I have never said this to be impossible.
> > > 
> > > And just to clarify. I consider unkillable sleep while holding mmap_sem
> > > for write to be a _bug_ which should be fixed rather than worked around
> > > by some timeout based heuristics.
> > 
> > Excuse me, but I think that it is difficult to fix.
> > Since currently it is legal to block kswapd from memory reclaim paths
> > ( http://lkml.kernel.org/r/20160211225929.GU14668@dastard ) and there
> > are allocation requests with mmap_sem held for write, you will need to
> > make memory reclaim paths killable. (I wish memory reclaim paths being
> > completely killable because fatal_signal_pending(current) check done in
> > throttle_direct_reclaim() is racy.)
> 
> Be it difficult or not it is something that should be fixed.
> 
I hit "allowing the OOM killer to select the same thread again" problem
using reproducer shown below on linux-next-20160513 + kmallocwd v5.

---------- Reproducer start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <poll.h>
#include <sched.h>
#include <sys/prctl.h>
#include <sys/wait.h>
#include <sys/mman.h>

static int memory_eater(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	srand(getpid());
	while (1) {
		int size = rand() % 1048576;
		void *ptr = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
		munmap(ptr, size);
	}
	return 0;
}

static int self_killer(void *unused)
{
	srand(getpid());
	poll(NULL, 0, rand() % 1000);
	kill(getpid(), SIGKILL);
	return 0;
}

static void child(void)
{
	static char *stack[256] = { };
	char buf[32] = { };
	int i;
	int fd = open("/proc/self/oom_score_adj", O_WRONLY);
	write(fd, "1000", 4);
	close(fd);
	snprintf(buf, sizeof(buf), "tgid=%u", getpid());
	prctl(PR_SET_NAME, (unsigned long) buf, 0, 0, 0);
	for (i = 0; i < 256; i++)
		stack[i] = malloc(4096 * 2);
	for (i = 1; i < 256 - 2; i++)
		if (clone(memory_eater, stack[i] + 8192, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
			_exit(1);
	if (clone(memory_eater, stack[i++] + 8192, CLONE_VM, NULL) == -1)
		_exit(1);
	if (clone(self_killer, stack[i] + 8192, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
		_exit(1);
	_exit(0);
}

int main(int argc, char *argv[])
{
	static cpu_set_t set = { { 1 } };
	sched_setaffinity(0, sizeof(set), &set);
	if (fork() > 0) {
		char *buf = NULL;
		unsigned long size;
		unsigned long i;
		sleep(1);
		for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
			char *cp = realloc(buf, size);
			if (!cp) {
				size >>= 1;
				break;
			}
			buf = cp;
		}
		/* Will cause OOM due to overcommit */
		for (i = 0; i < size; i += 4096)
			buf[i] = 0;
		while (1)
			pause();
	}
	while (1)
		if (fork() == 0)
			child();
		else
			wait(NULL);
	return 0;
}
---------- Reproducer end ----------

This reproducer tried to attack the shortcuts

        /*
         * If the task is already exiting, don't alarm the sysadmin or kill
         * its children or threads, just set TIF_MEMDIE so it can die quickly
         */
        task_lock(p);
        if (p->mm && task_will_free_mem(p)) {
                mark_oom_victim(p);
                try_oom_reaper(p);
                task_unlock(p);
                put_task_struct(p);
                return;
        }
        task_unlock(p);

in out_of_memory() and/or

        /*
         * If the task is already exiting, don't alarm the sysadmin or kill
         * its children or threads, just set TIF_MEMDIE so it can die quickly
         */
        task_lock(p);
        if (p->mm && task_will_free_mem(p)) {
                mark_oom_victim(p);
                try_oom_reaper(p);
                task_unlock(p);
                put_task_struct(p);
                return;
        }
        task_unlock(p);

in oom_kill_process(), by making try_oom_reaper() not to wake up the OOM
reaper by reproducing a situation where one thread group receives SIGKILL
(and hence blocked at down_read() after reaching do_exit()) and the other
thread group does not receive SIGKILL (and hence continue blocked at
down_write_killable()), in order to demonstrate how optimistic it is
to wait for TIF_MEMDIE thread unconditionally forever.

What I got is that the OOM victim is blocked at
down_write(vma->file->f_mapping) in i_mmap_lock_write() called from
link_file_vma(vma) etc.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160514.txt.xz .
----------
[  156.182149] oom_reaper: reaped process 13333 (tgid=13079), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  157.113150] oom_reaper: reaped process 4372 (tgid=4118), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  157.995910] oom_reaper: reaped process 11029 (tgid=10775), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  158.181043] oom_reaper: reaped process 11285 (tgid=11031), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  169.049766] oom_reaper: reaped process 11541 (tgid=11287), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  169.323695] oom_reaper: reaped process 11797 (tgid=11543), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  176.294340] oom_reaper: reaped process 12309 (tgid=12055), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  240.458346] MemAlloc-Info: stalling=16 dying=1 exiting=1 victim=0 oom_count=729
[  241.950461] MemAlloc-Info: stalling=16 dying=1 exiting=1 victim=0 oom_count=729
[  301.956044] MemAlloc-Info: stalling=19 dying=1 exiting=1 victim=0 oom_count=729
[  303.654382] MemAlloc-Info: stalling=19 dying=1 exiting=1 victim=0 oom_count=729
[  349.771068] oom_reaper: reaped process 13589 (tgid=13335), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  349.996636] oom_reaper: reaped process 13845 (tgid=13591), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  350.704767] oom_reaper: reaped process 14357 (tgid=14103), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  351.656833] Out of memory: Kill process 5652 (tgid=5398) score 999 or sacrifice child
[  351.659127] Killed process 5652 (tgid=5398) total-vm:6348kB, anon-rss:1116kB, file-rss:12kB, shmem-rss:0kB
[  352.664419] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  357.238418] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  358.621747] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  359.970605] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  361.423518] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  362.704023] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  363.832115] MemAlloc-Info: stalling=1 dying=3 exiting=1 victim=1 oom_count=25279
[  364.148948] MemAlloc: tgid=5398(5652) flags=0x400040 switches=266 dying victim
[  364.150851] tgid=5398       R  running task    12920  5652      1 0x00100084
[  364.152773]  ffff88000637fbe8 ffffffff8172b257 000091fa78a0caf8 ffff8800389de440
[  364.154843]  ffff880006376440 ffff880006380000 ffff880078a0caf8 ffff880078a0caf8
[  364.156898]  ffff880078a0cb10 ffff880078a0cb00 ffff88000637fc00 ffffffff81725e1a
[  364.158972] Call Trace:
[  364.159979]  [<ffffffff8172b257>] ? _raw_spin_unlock_irq+0x27/0x50
[  364.161691]  [<ffffffff81725e1a>] schedule+0x3a/0x90
[  364.163170]  [<ffffffff8172a366>] rwsem_down_write_failed+0x106/0x220
[  364.164925]  [<ffffffff813bd2c7>] call_rwsem_down_write_failed+0x17/0x30
[  364.166737]  [<ffffffff81729877>] down_write+0x47/0x60
[  364.168258]  [<ffffffff811c3284>] ? vma_link+0x44/0xc0
[  364.169773]  [<ffffffff811c3284>] vma_link+0x44/0xc0
[  364.171255]  [<ffffffff811c5c05>] mmap_region+0x3a5/0x5b0
[  364.172822]  [<ffffffff811c6204>] do_mmap+0x3f4/0x4c0
[  364.174324]  [<ffffffff811a64dc>] vm_mmap_pgoff+0xbc/0x100
[  364.175894]  [<ffffffff811c4060>] SyS_mmap_pgoff+0x1c0/0x290
[  364.177499]  [<ffffffff81002c91>] ? do_syscall_64+0x21/0x170
[  364.179118]  [<ffffffff81022b7d>] SyS_mmap+0x1d/0x20
[  364.180592]  [<ffffffff81002ccc>] do_syscall_64+0x5c/0x170
[  364.182140]  [<ffffffff8172b9da>] entry_SYSCALL64_slow_path+0x25/0x25
[  364.183855] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  365.199023] MemAlloc-Info: stalling=1 dying=3 exiting=1 victim=1 oom_count=28254
[  366.283955] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  368.158264] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  369.568325] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  371.416533] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  373.159185] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  374.835808] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  376.386226] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  378.223962] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  379.601584] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  381.067290] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  382.394818] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  383.918460] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  385.540088] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  386.915094] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  388.297575] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  391.598638] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  393.580423] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  395.744709] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  397.377497] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  399.614030] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  401.103803] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  402.484887] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  404.503755] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  406.433219] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  407.958772] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  410.094990] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  413.509253] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  416.820991] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  420.485121] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  422.302336] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  424.623738] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  425.204811] MemAlloc-Info: stalling=13 dying=3 exiting=1 victim=0 oom_count=161064
[  425.592191] MemAlloc-Info: stalling=13 dying=3 exiting=1 victim=0 oom_count=161064
[  430.507619] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  432.487807] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  436.810127] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  439.310553] oom_reaper: unable to reap pid:5652 (tgid=5398)
[  441.404857] oom_reaper: unable to reap pid:5652 (tgid=5398)
----------

static inline void i_mmap_lock_write(struct address_space *mapping)
{
        down_write(&mapping->i_mmap_rwsem);
}

static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
                        struct vm_area_struct *prev, struct rb_node **rb_link,
                        struct rb_node *rb_parent)
{
        struct address_space *mapping = NULL;

        if (vma->vm_file) {
                mapping = vma->vm_file->f_mapping;
                i_mmap_lock_write(mapping);
        }

        __vma_link(mm, vma, prev, rb_link, rb_parent); /* [<ffffffff811c3284>] vma_link+0x44/0xc0 */
        __vma_link_file(vma);

        if (mapping)
                i_mmap_unlock_write(mapping);

        mm->map_count++;
        validate_mm(mm);
}

As you said that "I consider unkillable sleep while holding mmap_sem
for write to be a _bug_ which should be fixed rather than worked around
by some timeout based heuristics.", you of course have a plan to rewrite
functions to return "int" which are currently "void" in order to use
killable waits, don't you?

I think that clearing TIF_MEMDIE even if the OOM reaper failed to reap the
OOM vitctim's memory is confusing for panic_on_oom_timeout timer (which stops
itself when TIF_MEMDIE is cleared) and kmallocwd (which prints victim=0 in
MemAlloc-Info: line). Until you complete rewriting all functions which could
be called with mmap_sem held for write, we should allow the OOM killer to
select next OOM victim upon timeout; otherwise calling panic() is premature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
