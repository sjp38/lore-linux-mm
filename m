Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3764900017
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 13:40:51 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so20052402pab.2
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:40:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x4si10977125pdr.44.2015.03.14.10.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 10:40:50 -0700 (PDT)
Subject: oom: Coredump to pipe can cause TIF_MEMDIE stalls.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201503150240.GII00591.OVSFtQLOFOHJMF@I-love.SAKURA.ne.jp>
Date: Sun, 15 Mar 2015 02:40:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, mhocko@suse.cz

When coredump to pipe is configured, the system stalls under OOM condition.

Steps to reproduce:

(1) Compile a kernel built using linux.git#master with
    https://lkml.org/lkml/2015/3/11/707 and
    http://marc.info/?l=linux-mm&m=141671829611143&w=2 applied.
(2) Configure /proc/sys/kernel/core_pattern to use abrt-addon-ccpp and
    /proc/sys/vm/retry_allocation_attempts to 1 on a system with 4 CPUs /
    2GB RAM / no swap / XFS.
(3) Compile a reproducer program shown below.
(4) Run the program as a local unprivileged user for several times.
    Once per several attempts, the system enters into TIF_MEMDIE stall
    where SysRq-f does not help.

---------- reproducer program start ----------
#define _GNU_SOURCE
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/mman.h>

static int file_mapper(void *unused)
{
	const int fd = open("/proc/self/exe", O_RDONLY);
	void *ptr[10000]; /* Will cause SIGSEGV due to stack overflow */
	int i;
	while (1) {
		for (i = 0; i < 10000; i++)
			ptr[i] = mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd,
				      0);
		for (i = 0; i < 10000; i++)
			munmap(ptr[i], 4096);
	}
	return 0;
}

static void child(void)
{
	const int fd = open("/proc/self/oom_score_adj", O_WRONLY);
	int i;
	write(fd, "999", 3);
	close(fd);
	for (i = 0; i < 10; i++) {
		char *cp = malloc(4 * 1024);
		if (!cp || clone(file_mapper, cp + 4 * 1024,
				 CLONE_SIGHAND | CLONE_VM, NULL) == -1)
			break;
	}
	while (1)
		pause();
}

static void memory_consumer(void)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	while (1)
		read(fd, buf, size); /* Will cause OOM due to overcommit */
}

int main(int argc, char *argv[])
{
	if (fork() == 0)
		child();
	memory_consumer();
	return 0;
}
---------- reproducer program end ----------

Console log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150315.txt.xz
and kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-4.0-rc3 .

[   66.576487] a.out           S ffff88007fc94280     0  2176   2174 0x00000080
[   66.576487]  ffff8800797d08d0 ffff8800363ec100 ffff880035293fd8 ffff880079554f28
[   66.576488]  ffffffffffffffff ffff8800797d08d0 0000000000000000 ffff880079554f00
[   66.576489]  ffffffff815f5ada ffff880079554f00 ffffffff8117bf27 0000000000000000
[   66.576489] Call Trace:
[   66.576490]  [<ffffffff815f5ada>] ? schedule+0x2a/0x80
[   66.576491]  [<ffffffff8117bf27>] ? pipe_wait+0x67/0xb0
[   66.576492]  [<ffffffff8109db00>] ? wait_woken+0x90/0x90
[   66.576493]  [<ffffffff8117c058>] ? pipe_write+0x88/0x450
[   66.576494]  [<ffffffff81173823>] ? new_sync_write+0x83/0xd0
[   66.576496]  [<ffffffff81173997>] ? __kernel_write+0x57/0x140
[   66.576497]  [<ffffffff811c690e>] ? dump_emit+0x8e/0xd0
[   66.576499]  [<ffffffff811c078f>] ? elf_core_dump+0x146f/0x15d0
[   66.576501]  [<ffffffff811c71a1>] ? do_coredump+0x751/0xe10
[   66.576502]  [<ffffffff810164b5>] ? sched_clock+0x5/0x10
[   66.576504]  [<ffffffff810719fe>] ? get_signal+0x18e/0x660
[   66.576505]  [<ffffffff8100d461>] ? do_signal+0x31/0x6d0
[   66.576506]  [<ffffffff81070b42>] ? force_sig_info+0xc2/0xd0
[   66.576507]  [<ffffffff815ef702>] ? __bad_area_nosemaphore+0x19a/0x1e9
[   66.576508]  [<ffffffff8100db62>] ? do_notify_resume+0x62/0x80
[   66.576509]  [<ffffffff815fa092>] ? retint_signal+0x48/0x86
[   66.576625] abrt-hook-ccpp  D 0000000000000000     0  2185    348 0x00000080
[   66.576625] MemAlloc: 0 jiffies on 0x2015a
[   66.576626]  ffff8800794291a0 0000000000000000 ffff880079b5bfd8 ffffffff81a754c0
[   66.576626]  ffffffff81a754c0 00000000fffc6f5e ffff8800794291a0 0000000000000000
[   66.576627]  ffffffff815f5ada ffff880079b5bb68 ffffffff815f81e3 ffff88007fffdb00
[   66.576627] Call Trace:
[   66.576628]  [<ffffffff815f5ada>] ? schedule+0x2a/0x80
[   66.576629]  [<ffffffff815f81e3>] ? schedule_timeout+0x113/0x1b0
[   66.576630]  [<ffffffff810bd0b0>] ? migrate_timer_list+0x60/0x60
[   66.576632]  [<ffffffff81113be0>] ? __alloc_pages_nodemask+0x700/0xa10
[   66.576633]  [<ffffffff81150c57>] ? alloc_pages_current+0x87/0x100
[   66.576634]  [<ffffffff8110d30d>] ? filemap_fault+0x1bd/0x400
[   66.576635]  [<ffffffff8112f85b>] ? __do_fault+0x4b/0xe0
[   66.576636]  [<ffffffff81134465>] ? handle_mm_fault+0xc85/0x1640
[   66.576637]  [<ffffffff81051c9a>] ? __do_page_fault+0x16a/0x430
[   66.576638]  [<ffffffff81051f90>] ? do_page_fault+0x30/0x70
[   66.576638]  [<ffffffff815fae18>] ? page_fault+0x28/0x30

[  251.670022] a.out           S ffff88007fc94280     0  2176   2174 0x00000080
[  251.670023]  ffff8800797d08d0 ffff8800363ec100 ffff880035293fd8 ffff880079554f28
[  251.670024]  ffffffffffffffff ffff8800797d08d0 0000000000000000 ffff880079554f00
[  251.670024]  ffffffff815f5ada ffff880079554f00 ffffffff8117bf27 0000000000000000
[  251.670024] Call Trace:
[  251.670025]  [<ffffffff815f5ada>] ? schedule+0x2a/0x80
[  251.670027]  [<ffffffff8117bf27>] ? pipe_wait+0x67/0xb0
[  251.670028]  [<ffffffff8109db00>] ? wait_woken+0x90/0x90
[  251.670029]  [<ffffffff8117c058>] ? pipe_write+0x88/0x450
[  251.670030]  [<ffffffff81173823>] ? new_sync_write+0x83/0xd0
[  251.670031]  [<ffffffff81173997>] ? __kernel_write+0x57/0x140
[  251.670034]  [<ffffffff811c690e>] ? dump_emit+0x8e/0xd0
[  251.670035]  [<ffffffff811c078f>] ? elf_core_dump+0x146f/0x15d0
[  251.670037]  [<ffffffff811c71a1>] ? do_coredump+0x751/0xe10
[  251.670038]  [<ffffffff810164b5>] ? sched_clock+0x5/0x10
[  251.670040]  [<ffffffff810719fe>] ? get_signal+0x18e/0x660
[  251.670041]  [<ffffffff8100d461>] ? do_signal+0x31/0x6d0
[  251.670042]  [<ffffffff81070b42>] ? force_sig_info+0xc2/0xd0
[  251.670043]  [<ffffffff815ef702>] ? __bad_area_nosemaphore+0x19a/0x1e9
[  251.670044]  [<ffffffff8100db62>] ? do_notify_resume+0x62/0x80
[  251.670045]  [<ffffffff815fa092>] ? retint_signal+0x48/0x86
[  251.670165] abrt-hook-ccpp  D 0000000000000002     0  2185    348 0x00000080
[  251.670165] MemAlloc: 4 jiffies on 0x2015a
[  251.670166]  ffff8800794291a0 0000000000000000 ffff880079b5bfd8 ffff88007ccdc000
[  251.670166]  ffff88007ccdc000 00000000ffff4185 ffff8800794291a0 0000000000000000
[  251.670167]  ffffffff815f5ada ffff880079b5bb68 ffffffff815f81e3 ffff88007fffdb00
[  251.670167] Call Trace:
[  251.670168]  [<ffffffff815f5ada>] ? schedule+0x2a/0x80
[  251.670169]  [<ffffffff815f81e3>] ? schedule_timeout+0x113/0x1b0
[  251.670171]  [<ffffffff810bd0b0>] ? migrate_timer_list+0x60/0x60
[  251.670172]  [<ffffffff81113be0>] ? __alloc_pages_nodemask+0x700/0xa10
[  251.670173]  [<ffffffff81150c57>] ? alloc_pages_current+0x87/0x100
[  251.670174]  [<ffffffff8110d30d>] ? filemap_fault+0x1bd/0x400
[  251.670175]  [<ffffffff812e3dbc>] ? radix_tree_next_chunk+0x5c/0x240
[  251.670176]  [<ffffffff8112f85b>] ? __do_fault+0x4b/0xe0
[  251.670177]  [<ffffffff81134465>] ? handle_mm_fault+0xc85/0x1640
[  251.670178]  [<ffffffff81051c9a>] ? __do_page_fault+0x16a/0x430
[  251.670179]  [<ffffffff81051f90>] ? do_page_fault+0x30/0x70
[  251.670179]  [<ffffffff815fae18>] ? page_fault+0x28/0x30

Commit d003f371b2701635 ("oom: don't assume that a coredumping thread
will exit soon") tried to take SIGNAL_GROUP_COREDUMP into account, but
a case shown above is not handled yet. Oleg explained that

> Note also that SIGNAL_GROUP_COREDUMP is not even set if the process (not a
> sub-thread) shares the memory with the coredumping task. It would be better
> to check mm->core_state != NULL instead, but this needs the locking. Plus
> that process likely sleeps in D state in exit_mm(), so this can't help.

> And that is why we set SIGNAL_GROUP_COREDUMP in zap_threads(), not in
> zap_process(). We probably want to make that "wait for coredump_finish()"
> sleep in exit_mm() killable, but this is not simple.

> On a second thought, perhaps it makes sense to set SIGNAL_GROUP_COREDUMP
> anyway, even if a CLONE_VM process participating in coredump is not killable.
> I'll recheck tomorrow.

and I reposted this mail to see whether he got any idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
