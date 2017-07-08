Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD25440843
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 09:31:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 125so63318579pgi.2
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 06:31:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p14si4719609pli.440.2017.07.08.06.31.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 08 Jul 2017 06:31:03 -0700 (PDT)
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM memory allocations?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
	<20170707023601.GA7478@jagdpanzerIV.localdomain>
In-Reply-To: <20170707023601.GA7478@jagdpanzerIV.localdomain>
Message-Id: <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
Date: Sat, 8 Jul 2017 22:30:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky.work@gmail.com
Cc: sergey.senozhatsky@gmail.com, pmladek@suse.com, mhocko@kernel.org, pavel@ucw.cz, rostedt@goodmis.org, andi@lisas.de, jack@suse.cz, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, daniel.vetter@ffwll.ch

Sergey Senozhatsky wrote:
> On (07/06/17 19:28), Tetsuo Handa wrote:
> > Pressing SysRq-c caused all locks to be released (doesn't it ?), and console
> 
> hm, I think what happened is a bit different thing. sysrq-c didn't
> unlock any of the locks. I suspect that ->bo_mutex is never taken
> on the direct path vprintk_emit()->console_unlock()->call_console_drivers(),
> otherwise it would have made vprintk_emit() from atomic context impossible.
> so ->bo_mutex does not directly affect printk. it affects it indirectly.
> the root cause, however, I think, is actually console semaphore and
> console_lock() in change_console(). printk() depends on it a lot, so do
> drm/tty/etc. as long as the console semaphore is locked, printk can only
> add new messages to the logbuf. and this is what happened here, under
> console_sem we scheduled on ->bo_mutex, which was locked because of memory
> allocation on another CPU, yes. you see lost messages in your report
> because part of printk that is responsible for storing new messages was
> working just fine; it's the output to consoles that was blocked by
> console_sem -> bo_mutex chain.
> 
> the reason why sysrq-c helped was because, sysrq-c did
> 
> 	panic_on_oops = 1
> 	panic()
> 
> and panic() called console_flush_on_panic(), which completely ignored the
> state of console semaphore and just flushed all the pending logbuf
> messages.
> 
> 	console_trylock();
> 	console_unlock();
> 
> so, I believe, console_semaphore remained locked just like it was before
> sysrq-c, and ->bo_mutex most likely remained locked as well. it's just we
> ignored the state of console_sem and this let us to print the messages
> (which also proves that ->bo_mutex is not taken by
> console_unlock()->call_console_drivers()).

Indeed, you are right. No need to unlock all locks, and should not change
the state of locks for capturing vmcore for analysis.

Today I was testing below OOM program in order to demonstrate how wasting
CPU time via direct reclaim / compaction negatively affects when oom_lock is
already held by somebody else, I again hit this problem when the system is
under OOM situation (i.e. oom_lock is already held).

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <signal.h>
#include <sys/prctl.h>

int main(int argc, char *argv[])
{
	struct sched_param sp = { };
	cpu_set_t cpu = { { 1 } };
	static int pipe_fd[2] = { EOF, EOF };
	unsigned long size = 65536;
	char *buf = malloc(size);
	unsigned long i = 0;
	signal(SIGCLD, SIG_IGN);
	sched_setaffinity(0, sizeof(cpu), &cpu);
	prctl(PR_SET_NAME, (unsigned long) "normal-priority", 0, 0, 0);
	pipe(pipe_fd);
	for (i = 0; i < 10; i++)
		if (fork() == 0) {
			if (i)
				close(pipe_fd[1]);
			/* Wait until first child gets SIGKILL. */
			read(pipe_fd[0], &i, 1);
			/* Join the direct reclaim storm. */
			for (i = 0; i < size; i += 4096)
				buf[i] = 0;
			_exit(0);
		}
	for (size = 512; size < 512UL * (1 << 30); size <<= 1) {
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
	for (i = 0; i < size; i += 4096)
		buf[i] = 0; /* Will cause OOM due to overcommit */
	kill(-1, SIGKILL);
	return 0; /* Not reached. */
}
----------

The only difference against linux-next-20170707 is that I temporarily disabled
stall warning (using below change), for warn_alloc() trivially causes printk()
lockup inside the OOM killer with oom_lock held.

----------
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3899,7 +3899,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
+	if (0 && time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
----------

Excuse me, I forgot to save bootup messages into serial.log file.
----------
[  324.038782] Out of memory: Kill process 2786 (idle-priority) score 942 or sacrifice child
[  324.041336] Killed process 2786 (idle-priority) total-vm:4264140kB, anon-rss:3508120kB, file-rss:4kB, shmem-rss:0kB
[  324.571323] oom_reaper: reaped process 2786 (idle-priority), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  350.140740] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[  350.144370] idle-priority cpuset=/ mems_allowed=0
[  350.146357] CPU: 0 PID: 2798 Comm: idle-priority Not tainted 4.12.0-next-20170707+ #620
[  350.147344] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  350.147344] Call Trace:
[  350.147344]  dump_stack+0x67/0x9e
[  350.147344]  dump_header+0x9d/0x3fa
[  350.147344]  ? trace_hardirqs_on+0xd/0x10
[  350.147344]  oom_kill_process+0x226/0x650
[  350.147344]  out_of_memory+0x136/0x560
[  350.147344]  ? out_of_memory+0x206/0x560
[  350.147344]  __alloc_pages_nodemask+0xcd2/0xe50
[  350.147344]  alloc_pages_vma+0x76/0x1a0
[  350.147344]  __handle_mm_fault+0xdff/0x1180
[  350.147344]  handle_mm_fault+0x186/0x360
[  350.147344]  ? handle_mm_fault+0x44/0x360
[  350.147344]  __do_page_fault+0x1da/0x510
[  350.147344]  do_page_fault+0x21/0x70
[  350.147344]  page_fault+0x22/0x30
[  350.147344] RIP: 0033:0x4008b8
[  350.147344] RSP: 002b:00007ffe9feca070 EFLAGS: 00010206
[  350.147344] RAX: 00000000d61d9000 RBX: 0000000100000000 RCX: 00007fb31dca3bd0
[  350.147344] RDX: 0000000000000000 RSI: 0000000000400ae0 RDI: 0000000000000004
[  350.147344] RBP: 00007fb11ddaf010 R08: 0000000000000000 R09: 0000000000021000
[  350.147344] R10: 00007ffe9fec9df0 R11: 0000000000000246 R12: 0000000000000006
[  350.147344] R13: 00007fb11ddaf010 R14: 0000000000000000 R15: 0000000000000000
[  350.199327] Mem-Info:
[  350.201499] active_anon:878748 inactive_anon:1643 isolated_anon:0
[  350.201499]  active_file:0 inactive_file:0 isolated_file:0
[  350.201499]  unevictable:0 dirty:0 writeback:0 unstable:0
[  350.201499]  slab_reclaimable:0 slab_unreclaimable:0
[  350.201499]  mapped:1124 shmem:2152 pagetables:1990 bounce:0
[  350.201499]  free:21375 free_pcp:0 free_cma:0
[  350.212232] Node 0 active_anon:3514992kB inactive_anon:6572kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:4496kB dirty:0kB writeback:0kB shmem:8608kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3328000kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  350.219383] Node 0 DMA free:14780kB min:288kB low:360kB high:432kB active_anon:1092kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  350.226577] lowmem_reserve[]: 0 2688 3624 3624
[  350.228274] Node 0 DMA32 free:53428kB min:49908kB low:62384kB high:74860kB active_anon:2698464kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752964kB mlocked:0kB kernel_stack:0kB pagetables:8kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  350.236222] lowmem_reserve[]: 0 0 936 936
[  350.238267] Node 0 Normal free:17292kB min:17384kB low:21728kB high:26072kB active_anon:815436kB inactive_anon:6572kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2752kB pagetables:7952kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  350.246639] lowmem_reserve[]: 0 0 0 0
[  350.248437] Node 0 DMA: 1*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (M) 2*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14780kB
[  350.253174] Node 0 DMA32: 1*4kB (M) 4*8kB (U) 5*16kB (U) 6*32kB (UM) 2*64kB (UM) 4*128kB (UM) 7*256kB (M) 5*512kB (UM) 3*1024kB (M) 2*2048kB (UM) 10*4096kB (UM) = 53428kB
[  350.258555] Node 0 Normal: 47*4kB (UMH) 70*8kB (UMH) 100*16kB (UMEH) 107*32kB (EH) 68*64kB (UMEH) 24*128kB (UEH) 6*256kB (EH) 1*512kB (U) 2*1024kB (M) 0*2048kB 0*4096kB = 17292kB
[  350.263669] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  350.266375] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  350.268956] 2152 total pagecache pages
[  350.273000] 0 pages in swap cache
[  350.274823] Swap cache stats: add 0, delete 0, find 0/0
[  350.276871] Free swap  = 0kB
[  350.278372] Total swap = 0kB
[  350.279833] 1048445 pages RAM
[  350.281552] 0 pages HighMem/MovableOnly
[  350.284522] 116511 pages reserved
[  350.286255] 0 pages hwpoisoned
[  350.288789] Out of memory: Kill process 2798 (idle-priority) score 942 or sacrifice child
[  350.291615] Killed process 2799 (normal-priority) total-vm:4360kB, anon-rss:92kB, file-rss:0kB, shmem-rss:0kB
[  360.523274] idle-priority invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[  378.871399] idle-priority cpuset=/ mems_allowed=0
[  378.873536] CPU: 0 PID: 2798 Comm: idle-priority Not tainted 4.12.0-next-20170707+ #620
[  378.874519] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  378.874519] Call Trace:
[  378.874519]  dump_stack+0x67/0x9e
[  378.874519]  dump_header+0x9d/0x3fa
[  378.874519]  ? trace_hardirqs_on+0xd/0x10
[  378.874519]  oom_kill_process+0x226/0x650
[  378.874519]  out_of_memory+0x136/0x560
[  378.874519]  ? out_of_memory+0x206/0x560
[  378.874519]  __alloc_pages_nodemask+0xcd2/0xe50
[  378.874519]  alloc_pages_vma+0x76/0x1a0
[  378.874519]  __handle_mm_fault+0xdff/0x1180
[  378.874519]  handle_mm_fault+0x186/0x360
[  378.874519]  ? handle_mm_fault+0x44/0x360
[  378.874519]  __do_page_fault+0x1da/0x510
[  378.874519]  do_page_fault+0x21/0x70
[  378.874519]  page_fault+0x22/0x30
[  378.874519] RIP: 0033:0x4008b8
[  378.874519] RSP: 002b:00007ffe9feca070 EFLAGS: 00010206
[  378.874519] RAX: 00000000d61d9000 RBX: 0000000100000000 RCX: 00007fb31dca3bd0
[  378.874519] RDX: 0000000000000000 RSI: 0000000000400ae0 RDI: 0000000000000004
[  378.874519] RBP: 00007fb11ddaf010 R08: 0000000000000000 R09: 0000000000021000
[  378.874519] R10: 00007ffe9fec9df0 R11: 0000000000000246 R12: 0000000000000006
[  378.874519] R13: 00007fb11ddaf010 R14: 0000000000000000 R15: 0000000000000000
[  378.923708] Mem-Info:
[  454.043526] sysrq: SysRq : Show Memory
[  454.043529] Mem-Info:
[  454.043533] active_anon:878741 inactive_anon:1643 isolated_anon:0
[  454.043533]  active_file:0 inactive_file:0 isolated_file:0
[  454.043533]  unevictable:0 dirty:0 writeback:0 unstable:0
[  454.043533]  slab_reclaimable:0 slab_unreclaimable:0
[  454.043533]  mapped:1124 shmem:2152 pagetables:1982 bounce:0
[  454.043533]  free:21348 free_pcp:53 free_cma:0
[  454.043535] Node 0 active_anon:3514964kB inactive_anon:6572kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:4496kB dirty:0kB writeback:0kB shmem:8608kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3328000kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  454.043536] Node 0 DMA free:14780kB min:288kB low:360kB high:432kB active_anon:1092kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  454.043539] lowmem_reserve[]: 0 2688 3624 3624
[  454.043543] Node 0 DMA32 free:53428kB min:49908kB low:62384kB high:74860kB active_anon:2698464kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2752964kB mlocked:0kB kernel_stack:0kB pagetables:8kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  454.043546] lowmem_reserve[]: 0 0 936 936
[  454.043550] Node 0 Normal free:17184kB min:17384kB low:21728kB high:26072kB active_anon:815408kB inactive_anon:6572kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:958868kB mlocked:0kB kernel_stack:2736kB pagetables:7920kB bounce:0kB free_pcp:212kB local_pcp:0kB free_cma:0kB
[  454.043553] lowmem_reserve[]: 0 0 0 0
[  454.043556] Node 0 DMA: 1*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (M) 2*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14780kB
[  454.043591] Node 0 DMA32: 1*4kB (M) 4*8kB (U) 5*16kB (U) 6*32kB (UM) 2*64kB (UM) 4*128kB (UM) 7*256kB (M) 5*512kB (UM) 3*1024kB (M) 2*2048kB (UM) 10*4096kB (UM) = 53428kB
[  454.043610] Node 0 Normal: 18*4kB (MH) 69*8kB (UMH) 101*16kB (UMEH) 107*32kB (EH) 68*64kB (UMEH) 24*128kB (UEH) 6*256kB (EH) 1*512kB (U) 2*1024kB (M) 0*2048kB 0*4096kB = 17184kB
[  454.043638] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  454.043639] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  454.043640] 2152 total pagecache pages
[  454.043651] 0 pages in swap cache
[  454.043652] Swap cache stats: add 0, delete 0, find 0/0
[  454.043653] Free swap  = 0kB
[  454.043654] Total swap = 0kB
[  454.043658] 1048445 pages RAM
[  454.043659] 0 pages HighMem/MovableOnly
[  454.043660] 116511 pages reserved
[  454.043661] 0 pages hwpoisoned
[  462.683506] sysrq: SysRq : HELP : loglevel(0-9) reboot(b) crash(c) show-all-locks(d) terminate-all-tasks(e) memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k) show-backtrace-all-active-cpus(l) show-memory-usage(m) nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q) unraw(r) sync(s) show-task-states(t) unmount(u) show-blocked-tasks(w) 
[  469.931550] sysrq: SysRq : Trigger a crash
[  469.931556] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  469.931563] IP: sysrq_handle_crash+0x42/0x80
[  469.931564] PGD 1377d1067 
[  469.931565] P4D 1377d1067 
[  469.931565] PUD 0 
[  469.931566] 
[  469.931567] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[  469.931569] Modules linked in: pcspkr coretemp sg shpchp i2c_piix4 vmw_vmci sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea mptspi scsi_transport_spi sysfillrect mptscsih sysimgblt fb_sys_fops ttm ahci e1000 libahci drm ata_piix mptbase i2c_core libata ipv6
[  469.931591] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.12.0-next-20170707+ #620
[  469.931592] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  469.931593] task: ffff880138ef8040 task.stack: ffff880138ef4000
[  469.931595] RIP: 0010:sysrq_handle_crash+0x42/0x80
[  469.931596] RSP: 0000:ffff88013a203b50 EFLAGS: 00010086
[  469.931597] RAX: 0000000000000000 RBX: ffffffff81c793c0 RCX: 000000002e837f6c
[  469.931598] RDX: 0000000000000003 RSI: 00000000b36b48a8 RDI: ffff880138ef8040
[  469.931598] RBP: ffff88013a203b50 R08: ffff880138ef8930 R09: ffff880138ef88f8
[  469.931599] R10: 0000000000000000 R11: 00000000e8aa6fec R12: 0000000000000063
[  469.931599] R13: 0000000000000001 R14: 000000000000000a R15: ffff880138af2530
[  469.931600] FS:  0000000000000000(0000) GS:ffff88013a200000(0000) knlGS:0000000000000000
[  469.931601] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  469.931651] CR2: 0000000000000000 CR3: 0000000136f3c000 CR4: 00000000001406e0
[  469.931672] Call Trace:
[  469.931674]  <IRQ>
[  469.931677]  __handle_sysrq+0x138/0x220
[  469.931679]  ? __sysrq_get_key_op+0x30/0x30
[  469.931682]  sysrq_filter+0x372/0x3b0
[  469.931686]  input_to_handler+0x52/0x100
[  469.931689]  input_pass_values.part.5+0x1bb/0x260
[  469.931691]  ? input_devices_seq_next+0x20/0x20
[  469.931693]  input_handle_event+0xcb/0x590
[  469.931696]  input_event+0x4f/0x70
[  469.931699]  atkbd_interrupt+0x5c0/0x6a0
[  469.931702]  serio_interrupt+0x41/0x80
[  469.931705]  i8042_interrupt+0x1da/0x3a0
[  469.931710]  __handle_irq_event_percpu+0x31/0xe0
[  469.931713]  handle_irq_event_percpu+0x2d/0x70
[  469.931715]  handle_irq_event+0x34/0x60
[  469.931718]  handle_edge_irq+0x99/0x120
[  469.931721]  handle_irq+0x5d/0x120
[  469.931724]  do_IRQ+0x59/0x110
[  469.931727]  common_interrupt+0x9a/0x9a
[  469.931730] RIP: 0010:__do_softirq+0x9b/0x220
[  469.931731] RSP: 0000:ffff88013a203f70 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff8b
[  469.931732] RAX: ffff880138ef8040 RBX: ffff880138ef8040 RCX: 0000000000000000
[  469.931733] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880138ef8040
[  469.931734] RBP: ffff88013a203fb8 R08: 0000000000000000 R09: 0000000000000000
[  469.931734] R10: 0000000000000001 R11: 00000000ffffffff R12: ffff880138ef8040
[  469.931735] R13: 0000000000000002 R14: 0000000000000002 R15: ffff880138ef8040
[  469.931744]  irq_exit+0xcf/0xf0
[  469.931747]  smp_apic_timer_interrupt+0x38/0x50
[  469.931749]  apic_timer_interrupt+0x9a/0xa0
[  469.931750] RIP: 0010:default_idle+0xb/0x10
[  469.931751] RSP: 0000:ffff880138ef7ea0 EFLAGS: 00000212 ORIG_RAX: ffffffffffffff10
[  469.931752] RAX: ffff880138ef8040 RBX: ffff880138ef8040 RCX: 0000000000000001
[  469.931753] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff880138ef8040
[  469.931754] RBP: ffff880138ef7ea0 R08: 0000000000000000 R09: 0000000000000000
[  469.931755] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880138ef8040
[  469.931755] R13: ffff880138ef8040 R14: 0000000000000000 R15: 0000000000000000
[  469.931756]  </IRQ>
[  469.931764]  arch_cpu_idle+0xa/0x10
[  469.931766]  default_idle_call+0x1e/0x30
[  469.931768]  do_idle+0x158/0x1e0
[  469.931771]  cpu_startup_entry+0x6e/0x80
[  469.931773]  start_secondary+0x15f/0x190
[  469.931777]  secondary_startup_64+0x9f/0x9f
[  469.931782] Code: c7 c2 76 55 41 81 be 01 00 00 00 48 c7 c7 a0 0b c5 81 65 ff 0d 08 70 bf 7e e8 6b 60 ca ff c7 05 f1 37 ba 00 01 00 00 00 0f ae f8 <c6> 04 25 00 00 00 00 01 5d c3 e8 3f 4b cc ff 84 c0 75 c1 48 c7 
[  469.931818] RIP: sysrq_handle_crash+0x42/0x80 RSP: ffff88013a203b50
[  469.931819] CR2: 0000000000000000
[  469.931831] ---[ end trace 3f8fe8ab749c5fb1 ]---
[  469.931832] Kernel panic - not syncing: Fatal exception in interrupt
[  469.931892] Kernel Offset: disabled
----------

I noticed that console output stopped at uptime = 379. At first, I thought
that it is just a random delay caused by priority problem. But I pressed
SysRq-m at uptime = 454 because nothing was printed to console for more than
one minute. I started to suspect that I hit this problem rather than a random
delay. Thus, I pressed SysRq-h at uptime = 462 in order to confirm it, and
pressed SysRq-c at uptime = 469 in order to flush console output.

We can find that the OOM killer was invoked for the last time at uptime = 360,
and "Node 0 Normal free:" was still below min: watermark at uptime = 454. This
means that the OOM killer was not able to send SIGKILL for at least 94 seconds
on a CONFIG_PREEMPT_VOLUNTARY=y kernel. But that is not what I want to mention here.

What I want to mention here is that messages which were sent to printk()
were not printed to not only /dev/tty0 but also /dev/ttyS0 (I'm passing
"console=ttyS0,115200n8 console=tty0" to kernel command line.) I don't care
if output to /dev/tty0 is delayed, but I expect that output to /dev/ttyS0
is not delayed, for I'm anayzing things using printk() output sent to serial
console (serial.log in my VMware configuration). Hitting this problem when we
cannot allocate memory results in failing to save printk() output. Oops, it
is sad.

> 
> [..]
> > Since vmw_fb_dirty_flush was stalling for 130989 jiffies,
> > vmw_fb_dirty_flush started stalling at uptime = 782. And
> > drm_modeset_lock_all() from vmw_fb_dirty_flush work started
> > GFP_KERNEL memory allocation
> > 
> > ----------
> > void drm_modeset_lock_all(struct drm_device *dev)
> > {
> >         struct drm_mode_config *config = &dev->mode_config;
> >         struct drm_modeset_acquire_ctx *ctx;
> >         int ret;
> > 
> >         ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
> >         if (WARN_ON(!ctx))
> >                 return;
> 
> hm, this allocation, per se, looks ok to me. can't really blame it.
> what you had is a combination of factors
> 
> 	CPU0			CPU1				CPU2
> 								console_callback()
> 								 console_lock()
> 								 ^^^^^^^^^^^^^
> 	vprintk_emit()		mutex_lock(&par->bo_mutex)
> 				 kzalloc(GFP_KERNEL)
> 	 console_trylock()	  kmem_cache_alloc()		  mutex_lock(&par->bo_mutex)
> 	 ^^^^^^^^^^^^^^^^	   io_schedule_timeout
> 
> // but I haven't seen the logs that you have provided, yet.
> 
> [..]
> > As a result, console was not able to print SysRq-t output.
> > 
> > So, how should we avoid this problem?
> 
> from the top of my head -- console_sem must be replaced with something
> better. but that's a task for years.
> 
> hm...
> 
> > But should fbcon, drm, tty and so on stop using __GFP_DIRECT_RECLAIM
> > memory allocations because consoles should be as responsive as printk() ?
> 
> may be, may be not. like I said, the allocation in question does not
> participate in console output. it's rather hard to imagine how we would
> enforce a !__GFP_DIRECT_RECLAIM requirement here. it's console semaphore
> to blame, I think.
> 
> if we could unlock console for some of operations done under ->bo_mutex,
> then may be we could make some printing progress, at least. but I have
> zero knowledge of that part of the kernel.
> 
> 	-ss
> 

I thought that we can use GFP_ATOMIC | __GFP_NOWARN (or static allocation;
wasting 16 pages or so for things like "struct drm_modeset_acquire_ctx" won't
become a problem, will it?) for short term, and fix console_sem dependency for
long term. But according to Daniel's reply, GFP_ATOMIC | __GFP_NOWARN is not
acceptable? Hmm... should we consider addressing console_sem problem before
introducing printing kernel thread and offloading to that kernel thread?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
