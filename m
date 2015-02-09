Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 162446B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 07:22:51 -0500 (EST)
Received: by ierx19 with SMTP id x19so9479800ier.3
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 04:22:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mg3si421878igb.55.2015.02.09.04.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Feb 2015 04:22:49 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141220223504.GI15665@dastard>
	<201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
In-Reply-To: <20141230112158.GA15546@dhcp22.suse.cz>
Message-Id: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
Date: Mon, 9 Feb 2015 20:44:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

Hello.

Today I tested Linux 3.19 and noticed unexpected behavior (A) (B)
shown below.

(A) The order-0 __GFP_WAIT allocation fails immediately upon OOM condition
    despite we didn't remove the

        /*
         * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
         * means __GFP_NOFAIL, but that may not be true in other
         * implementations.
         */
        if (order <= PAGE_ALLOC_COSTLY_ORDER)
                return 1;

    check in should_alloc_retry(). Is this what you expected?

(B) When coredump to pipe is configured, the system stalls under OOM
    condition due to memory allocation by coredump's reader side.
    How should we handle this "expected to terminate shortly but unable
    to terminate due to invisible dependency" case? What approaches
    other than applying timeout on coredump's writer side are possible?
    (Running inside memory cgroup is not an answer which I want.)

Console log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150209.txt.xz
and kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-3.19 .

To reproduce these behavior, you can run reproducer program shown below
on a system with 4 CPUs / 2GB RAM / no swap. (Too small stack is passed
to clone() because I by error did so when trying to reproduce OOM-stall
situations caused by memory allocations inside unkillable
down_write("struct mm_struct"->mmap_sem) calls.)

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

Logs for (A)

[   98.933472] kworker/1:2: page allocation failure: order:0, mode:0x10
[   98.935374] CPU: 1 PID: 363 Comm: kworker/1:2 Not tainted 3.19.0 #329
[   98.937271] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   98.940026] Workqueue: events_freezable_power_ disk_events_workfn
[   98.942084]  0000000000000000 00000000f967a090 0000000000000000 ffffffff81576f4e
[   98.944511]  0000000000000010 ffffffff8110d26e ffff88007fffdb00 0000000000000000
[   98.946873]  0000000236945e30 0000000000000002 0000000000000000 00000000f967a090
[   98.949121] Call Trace:
[   98.950318]  [<ffffffff81576f4e>] ? dump_stack+0x40/0x50
[   98.952054]  [<ffffffff8110d26e>] ? warn_alloc_failed+0xee/0x150
[   98.953935]  [<ffffffff811108e2>] ? __alloc_pages_nodemask+0x6a2/0xa70
[   98.955912]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[   98.957812]  [<ffffffff812467c6>] ? bio_copy_user_iov+0x1c6/0x380
[   98.959709]  [<ffffffff81246a1a>] ? bio_copy_kern+0x4a/0xf0
[   98.961518]  [<ffffffff8125053a>] ? blk_rq_map_kern+0x6a/0x150
[   98.963346]  [<ffffffff8124a856>] ? blk_get_request+0x76/0x120
[   98.965208]  [<ffffffff8139d39c>] ? scsi_execute+0x12c/0x160
[   98.967093]  [<ffffffff8139d4ab>] ? scsi_execute_req_flags+0x8b/0x100
[   98.969088]  [<ffffffffa01fca20>] ? sr_check_events+0xc0/0x300 [sr_mod]
[   98.971076]  [<ffffffff81579152>] ? __schedule+0x272/0x760
[   98.972838]  [<ffffffffa01f017f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[   98.974856]  [<ffffffff8125a5ba>] ? disk_check_events+0x5a/0x1e0
[   98.976753]  [<ffffffff8107b0b1>] ? process_one_work+0x131/0x360
[   98.978650]  [<ffffffff8107b863>] ? worker_thread+0x113/0x590
[   98.980489]  [<ffffffff8107b750>] ? rescuer_thread+0x470/0x470
[   98.982330]  [<ffffffff810804d1>] ? kthread+0xd1/0xf0
[   98.984068]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190
[   98.986049]  [<ffffffff8157d27c>] ? ret_from_fork+0x7c/0xb0
[   98.987845]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190

[  101.495212] kworker/1:2: page allocation failure: order:0, mode:0x10
[  101.497410] CPU: 1 PID: 363 Comm: kworker/1:2 Not tainted 3.19.0 #329
[  101.499581] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  101.502603] Workqueue: events_freezable_power_ disk_events_workfn
[  101.504775]  0000000000000000 00000000f967a090 0000000000000000 ffffffff81576f4e
[  101.507283]  0000000000000010 ffffffff8110d26e ffff88007fffdb00 0000000000000000
[  101.509800]  0000000236945e30 0000000000000002 0000000000000000 00000000f967a090
[  101.512324] Call Trace:
[  101.513767]  [<ffffffff81576f4e>] ? dump_stack+0x40/0x50
[  101.515748]  [<ffffffff8110d26e>] ? warn_alloc_failed+0xee/0x150
[  101.517897]  [<ffffffff811108e2>] ? __alloc_pages_nodemask+0x6a2/0xa70
[  101.520140]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  101.522352]  [<ffffffff812467c6>] ? bio_copy_user_iov+0x1c6/0x380
[  101.524534]  [<ffffffff81246a1a>] ? bio_copy_kern+0x4a/0xf0
[  101.526619]  [<ffffffff8125053a>] ? blk_rq_map_kern+0x6a/0x150
[  101.528743]  [<ffffffff8124a856>] ? blk_get_request+0x76/0x120
[  101.530870]  [<ffffffff8139d39c>] ? scsi_execute+0x12c/0x160
[  101.532971]  [<ffffffff8139d4ab>] ? scsi_execute_req_flags+0x8b/0x100
[  101.535250]  [<ffffffffa01fca20>] ? sr_check_events+0xc0/0x300 [sr_mod]
[  101.537641]  [<ffffffff81579152>] ? __schedule+0x272/0x760
[  101.539713]  [<ffffffffa01f017f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[  101.542015]  [<ffffffff8125a5ba>] ? disk_check_events+0x5a/0x1e0
[  101.544189]  [<ffffffff8107b0b1>] ? process_one_work+0x131/0x360
[  101.546370]  [<ffffffff8107b863>] ? worker_thread+0x113/0x590
[  101.548488]  [<ffffffff8107b750>] ? rescuer_thread+0x470/0x470
[  101.550575]  [<ffffffff810804d1>] ? kthread+0xd1/0xf0
[  101.552492]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190
[  101.554657]  [<ffffffff8157d27c>] ? ret_from_fork+0x7c/0xb0
[  101.556628]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190

[  104.052500] kworker/1:2: page allocation failure: order:0, mode:0x10
[  104.054694] CPU: 1 PID: 363 Comm: kworker/1:2 Not tainted 3.19.0 #329
[  104.056897] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  104.059887] Workqueue: events_freezable_power_ disk_events_workfn
[  104.062061]  0000000000000000 00000000f967a090 0000000000000000 ffffffff81576f4e
[  104.064611]  0000000000000010 ffffffff8110d26e ffff88007fffdb00 0000000000000000
[  104.067119]  0000000236945e30 0000000000000002 0000000000000000 00000000f967a090
[  104.069657] Call Trace:
[  104.071074]  [<ffffffff81576f4e>] ? dump_stack+0x40/0x50
[  104.073080]  [<ffffffff8110d26e>] ? warn_alloc_failed+0xee/0x150
[  104.075194]  [<ffffffff811108e2>] ? __alloc_pages_nodemask+0x6a2/0xa70
[  104.077424]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  104.079626]  [<ffffffff812467c6>] ? bio_copy_user_iov+0x1c6/0x380
[  104.081800]  [<ffffffff81246a1a>] ? bio_copy_kern+0x4a/0xf0
[  104.083868]  [<ffffffff8125053a>] ? blk_rq_map_kern+0x6a/0x150
[  104.085988]  [<ffffffff8124a856>] ? blk_get_request+0x76/0x120
[  104.088119]  [<ffffffff8139d39c>] ? scsi_execute+0x12c/0x160
[  104.090206]  [<ffffffff8139d4ab>] ? scsi_execute_req_flags+0x8b/0x100
[  104.092497]  [<ffffffffa01fca20>] ? sr_check_events+0xc0/0x300 [sr_mod]
[  104.094781]  [<ffffffff81579152>] ? __schedule+0x272/0x760
[  104.096843]  [<ffffffffa01f017f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[  104.099147]  [<ffffffff8125a5ba>] ? disk_check_events+0x5a/0x1e0
[  104.101306]  [<ffffffff8107b0b1>] ? process_one_work+0x131/0x360
[  104.103470]  [<ffffffff8107b863>] ? worker_thread+0x113/0x590
[  104.105600]  [<ffffffff8107b750>] ? rescuer_thread+0x470/0x470
[  104.107710]  [<ffffffff810804d1>] ? kthread+0xd1/0xf0
[  104.109607]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190
[  104.111781]  [<ffffffff8157d27c>] ? ret_from_fork+0x7c/0xb0
[  104.113733]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190

[  106.608783] kworker/1:2: page allocation failure: order:0, mode:0x10
[  106.610960] CPU: 1 PID: 363 Comm: kworker/1:2 Not tainted 3.19.0 #329
[  106.613123] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  106.616159] Workqueue: events_freezable_power_ disk_events_workfn
[  106.618337]  0000000000000000 00000000f967a090 0000000000000000 ffffffff81576f4e
[  106.621153]  0000000000000010 ffffffff8110d26e ffff88007fffdb00 0000000000000000
[  106.623823]  0000000236945e30 0000000000000002 0000000000000000 00000000f967a090
[  106.626386] Call Trace:
[  106.627810]  [<ffffffff81576f4e>] ? dump_stack+0x40/0x50
[  106.629800]  [<ffffffff8110d26e>] ? warn_alloc_failed+0xee/0x150
[  106.632128]  [<ffffffff811108e2>] ? __alloc_pages_nodemask+0x6a2/0xa70
[  106.634460]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  106.636638]  [<ffffffff812467c6>] ? bio_copy_user_iov+0x1c6/0x380
[  106.638856]  [<ffffffff81246a1a>] ? bio_copy_kern+0x4a/0xf0
[  106.640929]  [<ffffffff8125053a>] ? blk_rq_map_kern+0x6a/0x150
[  106.643053]  [<ffffffff8124a856>] ? blk_get_request+0x76/0x120
[  106.645209]  [<ffffffff8139d39c>] ? scsi_execute+0x12c/0x160
[  106.647293]  [<ffffffff8139d4ab>] ? scsi_execute_req_flags+0x8b/0x100
[  106.649573]  [<ffffffffa01fca20>] ? sr_check_events+0xc0/0x300 [sr_mod]
[  106.651921]  [<ffffffff81579152>] ? __schedule+0x272/0x760
[  106.654008]  [<ffffffffa01f017f>] ? cdrom_check_events+0xf/0x30 [cdrom]
[  106.656297]  [<ffffffff8125a5ba>] ? disk_check_events+0x5a/0x1e0
[  106.658466]  [<ffffffff8107b0b1>] ? process_one_work+0x131/0x360
[  106.660610]  [<ffffffff8107b863>] ? worker_thread+0x113/0x590
[  106.662744]  [<ffffffff8107b750>] ? rescuer_thread+0x470/0x470
[  106.664849]  [<ffffffff810804d1>] ? kthread+0xd1/0xf0
[  106.666759]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190
[  106.668930]  [<ffffffff8157d27c>] ? ret_from_fork+0x7c/0xb0
[  106.670889]  [<ffffffff81080400>] ? kthread_create_on_node+0x190/0x190

Logs for (B)

[  145.078502] a.out           S ffff88007fc92d00     0  2643   2641 0x00000080
[  145.078503]  ffff88003681c480 0000000000012d00 ffff88007a51bfd8 0000000000012d00
[  145.078504]  ffff88003681c480 ffff88003681c480 000200d20000000f 0000000000000001
[  145.078504]  ffff88003681c480 ffff88003681c480 00007fb700000001 ffff88007adcc508
[  145.078505] Call Trace:
[  145.078506]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  145.078507]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  145.078508]  [<ffffffff8117ba17>] ? pipe_wait+0x67/0xb0
[  145.078509]  [<ffffffff8109ced0>] ? wait_woken+0x90/0x90
[  145.078510]  [<ffffffff8117bb48>] ? pipe_write+0x88/0x450
[  145.078511]  [<ffffffff811732a3>] ? new_sync_write+0x83/0xd0
[  145.078512]  [<ffffffff81173417>] ? __kernel_write+0x57/0x140
[  145.078513]  [<ffffffff811c615e>] ? dump_emit+0x8e/0xd0
[  145.078515]  [<ffffffff811c002f>] ? elf_core_dump+0x146f/0x15d0
[  145.078516]  [<ffffffff811c6a09>] ? do_coredump+0x769/0xe80
[  145.078517]  [<ffffffff8101634d>] ? native_sched_clock+0x2d/0x80
[  145.078518]  [<ffffffff8106fd2b>] ? __send_signal+0x16b/0x3a0
[  145.078520]  [<ffffffff810717f2>] ? get_signal+0x192/0x770
[  145.078521]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[  145.078522]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[  145.078523]  [<ffffffff8157e022>] ? retint_signal+0x48/0x86

[  145.078625] abrt-hook-ccpp  D 0000000000000002     0  2650    347 0x00000080
[  145.078626]  ffff88007b364d10 0000000000012d00 ffff88007ae3ffd8 0000000000012d00
[  145.078627]  ffff88007b364d10 ffff88007fffc000 ffffffff8111a6a5 0000000000000000
[  145.078628]  0000000000000000 000088007ae3f9e8 ffff88007b364d10 ffffffff81015df5
[  145.078628] Call Trace:
[  145.078629]  [<ffffffff8111a6a5>] ? shrink_zone+0x105/0x2a0
[  145.078630]  [<ffffffff81015df5>] ? read_tsc+0x5/0x10
[  145.078631]  [<ffffffff810c0270>] ? ktime_get+0x30/0x90
[  145.078632]  [<ffffffff810f73b9>] ? delayacct_end+0x39/0x70
[  145.078633]  [<ffffffff8111ae45>] ? do_try_to_free_pages+0x3e5/0x480
[  145.078634]  [<ffffffff8157c013>] ? schedule_timeout+0x113/0x1b0
[  145.078635]  [<ffffffff810b9800>] ? migrate_timer_list+0x60/0x60
[  145.078636]  [<ffffffff811109ee>] ? __alloc_pages_nodemask+0x7ae/0xa70
[  145.078638]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  145.078640]  [<ffffffff8110a240>] ? filemap_fault+0x1c0/0x400
[  145.078641]  [<ffffffff8112e7c6>] ? __do_fault+0x46/0xd0
[  145.078642]  [<ffffffff81131128>] ? do_read_fault.isra.62+0x228/0x310
[  145.078643]  [<ffffffff8113380e>] ? handle_mm_fault+0x7ae/0x10e0
[  145.078644]  [<ffffffff81138145>] ? vma_set_page_prot+0x35/0x60
[  145.078645]  [<ffffffff8105194e>] ? __do_page_fault+0x17e/0x540
[  145.078646]  [<ffffffff811399ac>] ? do_mmap_pgoff+0x33c/0x3f0
[  145.078647]  [<ffffffff8112180b>] ? vm_mmap_pgoff+0xbb/0xf0
[  145.078648]  [<ffffffff81051d40>] ? do_page_fault+0x30/0x70
[  145.078649]  [<ffffffff8157ed38>] ? page_fault+0x28/0x30

[  232.113394] a.out           S ffff88007fc92d00     0  2643   2641 0x00000080
[  232.115926]  ffff88003681c480 0000000000012d00 ffff88007a51bfd8 0000000000012d00
[  232.118630]  ffff88003681c480 ffff88003681c480 000200d20000000f 0000000000000001
[  232.121312]  ffff88003681c480 ffff88003681c480 00007fb700000001 ffff88007adcc508
[  232.124004] Call Trace:
[  232.125242]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  232.127506]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  232.129972]  [<ffffffff8117ba17>] ? pipe_wait+0x67/0xb0
[  232.131960]  [<ffffffff8109ced0>] ? wait_woken+0x90/0x90
[  232.133928]  [<ffffffff8117bb48>] ? pipe_write+0x88/0x450
[  232.135901]  [<ffffffff811732a3>] ? new_sync_write+0x83/0xd0
[  232.137956]  [<ffffffff81173417>] ? __kernel_write+0x57/0x140
[  232.140033]  [<ffffffff811c615e>] ? dump_emit+0x8e/0xd0
[  232.141958]  [<ffffffff811c002f>] ? elf_core_dump+0x146f/0x15d0
[  232.144161]  [<ffffffff811c6a09>] ? do_coredump+0x769/0xe80
[  232.146178]  [<ffffffff8101634d>] ? native_sched_clock+0x2d/0x80
[  232.148343]  [<ffffffff8106fd2b>] ? __send_signal+0x16b/0x3a0
[  232.150441]  [<ffffffff810717f2>] ? get_signal+0x192/0x770
[  232.152468]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[  232.154441]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[  232.156552]  [<ffffffff8157e022>] ? retint_signal+0x48/0x86

[  232.340460] abrt-hook-ccpp  D 0000000000000002     0  2650    347 0x00000080
[  232.343038]  ffff88007b364d10 0000000000012d00 ffff88007ae3ffd8 0000000000012d00
[  232.345779]  ffff88007b364d10 ffff88007fffc000 ffffffff8111a6a5 0000000000000000
[  232.348626]  0000000000000000 000088007ae3f9e8 ffff88007b364d10 ffffffff81015df5
[  232.351400] Call Trace:
[  232.352798]  [<ffffffff8111a6a5>] ? shrink_zone+0x105/0x2a0
[  232.355177]  [<ffffffff81015df5>] ? read_tsc+0x5/0x10
[  232.357260]  [<ffffffff810c0270>] ? ktime_get+0x30/0x90
[  232.359321]  [<ffffffff810f73b9>] ? delayacct_end+0x39/0x70
[  232.361597]  [<ffffffff8111ae45>] ? do_try_to_free_pages+0x3e5/0x480
[  232.364151]  [<ffffffff81089ac1>] ? try_to_wake_up+0x221/0x2b0
[  232.366364]  [<ffffffff8110af07>] ? oom_badness+0x17/0x130
[  232.368410]  [<ffffffff8109ced9>] ? autoremove_wake_function+0x9/0x30
[  232.370694]  [<ffffffff8157992f>] ? _cond_resched+0x1f/0x40
[  232.372765]  [<ffffffff811106d0>] ? __alloc_pages_nodemask+0x490/0xa70
[  232.375082]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  232.377416]  [<ffffffff8110a240>] ? filemap_fault+0x1c0/0x400
[  232.379542]  [<ffffffff8112e7c6>] ? __do_fault+0x46/0xd0
[  232.381624]  [<ffffffff81131128>] ? do_read_fault.isra.62+0x228/0x310
[  232.383984]  [<ffffffff8113380e>] ? handle_mm_fault+0x7ae/0x10e0
[  232.386198]  [<ffffffff81138145>] ? vma_set_page_prot+0x35/0x60
[  232.388386]  [<ffffffff8105194e>] ? __do_page_fault+0x17e/0x540
[  232.390592]  [<ffffffff811399ac>] ? do_mmap_pgoff+0x33c/0x3f0
[  232.392762]  [<ffffffff8112180b>] ? vm_mmap_pgoff+0xbb/0xf0
[  232.395259]  [<ffffffff81051d40>] ? do_page_fault+0x30/0x70
[  232.397472]  [<ffffffff8157ed38>] ? page_fault+0x28/0x30

[  328.225954] a.out           S ffff88007fc92d00     0  2643   2641 0x00000080
[  328.228262]  ffff88003681c480 0000000000012d00 ffff88007a51bfd8 0000000000012d00
[  328.230731]  ffff88003681c480 ffff88003681c480 000200d20000000f 0000000000000001
[  328.233188]  ffff88003681c480 ffff88003681c480 00007fb700000001 ffff88007adcc508
[  328.235701] Call Trace:
[  328.236851]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  328.238826]  [<ffffffff8112af4e>] ? copy_from_iter+0x10e/0x2d0
[  328.240792]  [<ffffffff8117ba17>] ? pipe_wait+0x67/0xb0
[  328.242598]  [<ffffffff8109ced0>] ? wait_woken+0x90/0x90
[  328.244426]  [<ffffffff8117bb48>] ? pipe_write+0x88/0x450
[  328.246284]  [<ffffffff811732a3>] ? new_sync_write+0x83/0xd0
[  328.248208]  [<ffffffff81173417>] ? __kernel_write+0x57/0x140
[  328.250159]  [<ffffffff811c615e>] ? dump_emit+0x8e/0xd0
[  328.251967]  [<ffffffff811c002f>] ? elf_core_dump+0x146f/0x15d0
[  328.253930]  [<ffffffff811c6a09>] ? do_coredump+0x769/0xe80
[  328.255811]  [<ffffffff8101634d>] ? native_sched_clock+0x2d/0x80
[  328.257806]  [<ffffffff8106fd2b>] ? __send_signal+0x16b/0x3a0
[  328.259714]  [<ffffffff810717f2>] ? get_signal+0x192/0x770
[  328.261552]  [<ffffffff8100d451>] ? do_signal+0x31/0x6d0
[  328.263369]  [<ffffffff8100db5c>] ? do_notify_resume+0x6c/0x90
[  328.265292]  [<ffffffff8157e022>] ? retint_signal+0x48/0x86

[  328.444215] abrt-hook-ccpp  D 0000000000000002     0  2650    347 0x00000080
[  328.446549]  ffff88007b364d10 0000000000012d00 ffff88007ae3ffd8 0000000000012d00
[  328.449029]  ffff88007b364d10 ffff88007fffc000 ffffffff8111a6a5 0000000000000000
[  328.451689]  0000000000000000 000088007ae3f9e8 ffff88007b364d10 ffffffff81015df5
[  328.454187] Call Trace:
[  328.455408]  [<ffffffff8111a6a5>] ? shrink_zone+0x105/0x2a0
[  328.457406]  [<ffffffff81015df5>] ? read_tsc+0x5/0x10
[  328.459289]  [<ffffffff810c0270>] ? ktime_get+0x30/0x90
[  328.461368]  [<ffffffff810f73b9>] ? delayacct_end+0x39/0x70
[  328.464191]  [<ffffffff8111ae45>] ? do_try_to_free_pages+0x3e5/0x480
[  328.466419]  [<ffffffff8157c013>] ? schedule_timeout+0x113/0x1b0
[  328.468506]  [<ffffffff810b9800>] ? migrate_timer_list+0x60/0x60
[  328.470672]  [<ffffffff811109ee>] ? __alloc_pages_nodemask+0x7ae/0xa70
[  328.472883]  [<ffffffff811501d7>] ? alloc_pages_current+0x87/0x100
[  328.475087]  [<ffffffff8110a240>] ? filemap_fault+0x1c0/0x400
[  328.477089]  [<ffffffff8112e7c6>] ? __do_fault+0x46/0xd0
[  328.478960]  [<ffffffff81131128>] ? do_read_fault.isra.62+0x228/0x310
[  328.481116]  [<ffffffff8113380e>] ? handle_mm_fault+0x7ae/0x10e0
[  328.483454]  [<ffffffff81138145>] ? vma_set_page_prot+0x35/0x60
[  328.485613]  [<ffffffff8105194e>] ? __do_page_fault+0x17e/0x540
[  328.487634]  [<ffffffff811399ac>] ? do_mmap_pgoff+0x33c/0x3f0
[  328.489611]  [<ffffffff8112180b>] ? vm_mmap_pgoff+0xbb/0xf0
[  328.491539]  [<ffffffff81051d40>] ? do_page_fault+0x30/0x70
[  328.493441]  [<ffffffff8157ed38>] ? page_fault+0x28/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
