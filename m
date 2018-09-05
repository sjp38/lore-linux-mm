Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAA66B735D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:53:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 185-v6so7850855itl.2
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:53:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h16-v6si1302236oih.3.2018.09.05.06.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:53:51 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1808231544001.150774@chino.kir.corp.google.com>
 <201808240031.w7O0V5hT019529@www262.sakura.ne.jp>
 <195a512f-aecc-f8cf-f409-6c42ee924a8c@i-love.sakura.ne.jp>
 <20180905134038.GE14951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <81cc1f29-e42e-7813-dc70-5d6d9e999dd1@i-love.sakura.ne.jp>
Date: Wed, 5 Sep 2018 22:53:33 +0900
MIME-Version: 1.0
In-Reply-To: <20180905134038.GE14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/09/05 22:40, Michal Hocko wrote:
> Changelog said 
> 
> "Although this is possible in principle let's wait for it to actually
> happen in real life before we make the locking more complex again."
> 
> So what is the real life workload that hits it? The log you have pasted
> below doesn't tell much.

Nothing special. I just ran a multi-threaded memory eater on a CONFIG_PREEMPT=y kernel.
The OOM reaper succeeded to reclaim all memory but the OOM killer still triggered
just because somebody was inside that race window.

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
	static cpu_set_t set = { { 1 } };
	sched_setaffinity(0, sizeof(set), &set);
	srand(getpid());
	while (1) {
		int size = rand() % 1048576;
		void *ptr = mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
		munmap(ptr, size);
	}
	return 0;
}

static int child(void *unused)
{
	static char *stack[256] = { };
	char buf[32] = { };
	int i;
	sleep(1);
	snprintf(buf, sizeof(buf), "tgid=%u", getpid());
	prctl(PR_SET_NAME, (unsigned long) buf, 0, 0, 0);
	for (i = 0; i < 256; i++)
		stack[i] = malloc(4096 * 2);
	for (i = 1; i < 128; i++)
		if (clone(memory_eater, stack[i] + 8192, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL) == -1)
			_exit(1);
	for (; i < 254; i++)
		if (clone(memory_eater, stack[i] + 8192, CLONE_VM, NULL) == -1)
			_exit(1);
	return 0;
}

int main(int argc, char *argv[])
{
	char *stack = malloc(1048576);
	char *buf = NULL;
	unsigned long size;
	unsigned long i;
	if (clone(child, stack + 1048576, CLONE_VM, NULL) == -1)
		_exit(1);
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
	return 0;
}

> 
>> [  278.147280] Out of memory: Kill process 9943 (a.out) score 919 or sacrifice child
>> [  278.148927] Killed process 9943 (a.out) total-vm:4267252kB, anon-rss:3430056kB, file-rss:0kB, shmem-rss:0kB
>> [  278.151586] vmtoolsd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
> [...]
>> [  278.331527] Out of memory: Kill process 8790 (firewalld) score 5 or sacrifice child
>> [  278.333267] Killed process 8790 (firewalld) total-vm:358012kB, anon-rss:21928kB, file-rss:0kB, shmem-rss:0kB
>> [  278.336430] oom_reaper: reaped process 8790 (firewalld), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 

Another example from a different machine.

[  765.523676] a.out invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  765.528172] a.out cpuset=/ mems_allowed=0
[  765.530603] CPU: 5 PID: 4540 Comm: a.out Tainted: G                T 4.19.0-rc2+ #689
[  765.534307] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  765.538975] Call Trace:
[  765.540920]  dump_stack+0x85/0xcb
[  765.543088]  dump_header+0x69/0x2fe
[  765.545375]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  765.547983]  oom_kill_process+0x307/0x390
[  765.550394]  out_of_memory+0x2f5/0x5b0
[  765.552818]  __alloc_pages_slowpath+0xc01/0x1030
[  765.555442]  __alloc_pages_nodemask+0x333/0x390
[  765.557966]  alloc_pages_vma+0x77/0x1f0
[  765.560292]  __handle_mm_fault+0x81c/0xf40
[  765.562736]  handle_mm_fault+0x1b7/0x3c0
[  765.565038]  __do_page_fault+0x2a6/0x580
[  765.567420]  do_page_fault+0x32/0x270
[  765.569670]  ? page_fault+0x8/0x30
[  765.571833]  page_fault+0x1e/0x30
[  765.573934] RIP: 0033:0x4008d8
[  765.575924] Code: Bad RIP value.
[  765.577842] RSP: 002b:00007ffec6f7d420 EFLAGS: 00010206
[  765.580221] RAX: 00007f6a201f4010 RBX: 0000000100000000 RCX: 0000000000000000
[  765.583253] RDX: 00000000bde23000 RSI: 0000000000020000 RDI: 0000000200000050
[  765.586207] RBP: 00007f6a201f4010 R08: 0000000200001000 R09: 0000000000021000
[  765.589047] R10: 0000000000000022 R11: 0000000000001000 R12: 0000000000000006
[  765.591996] R13: 00007ffec6f7d510 R14: 0000000000000000 R15: 0000000000000000
[  765.595732] Mem-Info:
[  765.597580] active_anon:794622 inactive_anon:2126 isolated_anon:0
[  765.597580]  active_file:7 inactive_file:11 isolated_file:0
[  765.597580]  unevictable:0 dirty:0 writeback:0 unstable:0
[  765.597580]  slab_reclaimable:7612 slab_unreclaimable:22840
[  765.597580]  mapped:1432 shmem:2280 pagetables:3230 bounce:0
[  765.597580]  free:20847 free_pcp:0 free_cma:0
[  765.611408] Node 0 active_anon:3178488kB inactive_anon:8504kB active_file:28kB inactive_file:44kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:5728kB dirty:0kB writeback:0kB shmem:9120kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3004416kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  765.620811] Node 0 DMA free:13792kB min:308kB low:384kB high:460kB active_anon:2016kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  765.630835] lowmem_reserve[]: 0 2674 3378 3378
[  765.633372] Node 0 DMA32 free:55732kB min:53260kB low:66572kB high:79884kB active_anon:2680196kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2738556kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  765.643494] lowmem_reserve[]: 0 0 703 703
[  765.645712] Node 0 Normal free:13912kB min:14012kB low:17512kB high:21012kB active_anon:495920kB inactive_anon:8504kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:720644kB mlocked:0kB kernel_stack:6144kB pagetables:12924kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  765.656802] lowmem_reserve[]: 0 0 0 0
[  765.658884] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 0*2048kB 3*4096kB (M) = 13792kB
[  765.663518] Node 0 DMA32: 22*4kB (U) 26*8kB (UM) 50*16kB (U) 55*32kB (U) 46*64kB (U) 34*128kB (UM) 33*256kB (UM) 21*512kB (UM) 12*1024kB (UM) 3*2048kB (UM) 2*4096kB (M) = 55976kB
[  765.671041] Node 0 Normal: 74*4kB (UM) 22*8kB (UM) 22*16kB (UM) 147*32kB (UE) 31*64kB (UME) 8*128kB (UME) 3*256kB (UME) 1*512kB (M) 4*1024kB (UM) 0*2048kB 0*4096kB = 13912kB
[  765.677850] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  765.681352] 2295 total pagecache pages
[  765.683550] 0 pages in swap cache
[  765.685731] Swap cache stats: add 0, delete 0, find 0/0
[  765.688430] Free swap  = 0kB
[  765.690419] Total swap = 0kB
[  765.692375] 1048422 pages RAM
[  765.694388] 0 pages HighMem/MovableOnly
[  765.696637] 179653 pages reserved
[  765.698618] 0 pages cma reserved
[  765.700601] 0 pages hwpoisoned
[  765.702651] Out of memory: Kill process 4540 (a.out) score 897 or sacrifice child
[  765.706876] Killed process 4540 (a.out) total-vm:4267252kB, anon-rss:3111084kB, file-rss:0kB, shmem-rss:0kB
[  765.711735] in:imjournal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  765.719957] in:imjournal cpuset=/ mems_allowed=0
[  765.723302] CPU: 6 PID: 1012 Comm: in:imjournal Tainted: G                T 4.19.0-rc2+ #689
[  765.731014] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  765.747405] Call Trace:
[  765.749579]  dump_stack+0x85/0xcb
[  765.752179]  dump_header+0x69/0x2fe
[  765.754475]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  765.757307]  oom_kill_process+0x307/0x390
[  765.759873]  out_of_memory+0x2f5/0x5b0
[  765.762464]  __alloc_pages_slowpath+0xc01/0x1030
[  765.765176]  __alloc_pages_nodemask+0x333/0x390
[  765.767832]  filemap_fault+0x465/0x910
[  765.770399]  ? xfs_ilock+0xbf/0x2b0 [xfs]
[  765.770514] oom_reaper: reaped process 4540 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  765.773047]  ? __xfs_filemap_fault+0x7d/0x2c0 [xfs]
[  765.773054]  ? down_read_nested+0x66/0xa0
[  765.783474]  __xfs_filemap_fault+0x8e/0x2c0 [xfs]
[  765.786436]  __do_fault+0x11/0x133
[  765.788649]  __handle_mm_fault+0xa57/0xf40
[  765.791022]  handle_mm_fault+0x1b7/0x3c0
[  765.793307]  __do_page_fault+0x2a6/0x580
[  765.795566]  do_page_fault+0x32/0x270
[  765.797708]  ? page_fault+0x8/0x30
[  765.799735]  page_fault+0x1e/0x30
[  765.801707] RIP: 0033:0x7f9a91e00fcf
[  765.803724] Code: Bad RIP value.
[  765.805569] RSP: 002b:00007f9a8ebe6c60 EFLAGS: 00010293
[  765.808021] RAX: 0000000000000000 RBX: 0000562b41445bb0 RCX: 00007f9a91e00fcf
[  765.810969] RDX: 00007f9a8ebe6c80 RSI: 0000000000000001 RDI: 00007f9a8ebe6ca0
[  765.813911] RBP: 00000000000dbba0 R08: 0000000000000008 R09: 0000000000000000
[  765.816861] R10: 0000000000000000 R11: 0000000000000293 R12: 00007f9a8ebe6d90
[  765.819762] R13: 00007f9a80029af0 R14: 00007f9a8002fdf0 R15: 00007f9a8001ea60
[  765.823619] Mem-Info:
[  765.825340] active_anon:16863 inactive_anon:2126 isolated_anon:0
[  765.825340]  active_file:35 inactive_file:3002 isolated_file:0
[  765.825340]  unevictable:0 dirty:0 writeback:0 unstable:0
[  765.825340]  slab_reclaimable:7612 slab_unreclaimable:22764
[  765.825340]  mapped:2597 shmem:2280 pagetables:1686 bounce:0
[  765.825340]  free:796988 free_pcp:423 free_cma:0
[  765.839674] Node 0 active_anon:67452kB inactive_anon:8504kB active_file:140kB inactive_file:12008kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:10388kB dirty:0kB writeback:0kB shmem:9120kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 24576kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  765.848867] Node 0 DMA free:15840kB min:308kB low:384kB high:460kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  765.859189] lowmem_reserve[]: 0 2674 3378 3378
[  765.861638] Node 0 DMA32 free:2735512kB min:53260kB low:66572kB high:79884kB active_anon:12kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2738556kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:1276kB local_pcp:0kB free_cma:0kB
[  765.871163] lowmem_reserve[]: 0 0 703 703
[  765.873345] Node 0 Normal free:436320kB min:14012kB low:17512kB high:21012kB active_anon:67460kB inactive_anon:8504kB active_file:140kB inactive_file:12112kB unevictable:0kB writepending:0kB present:1048576kB managed:720644kB mlocked:0kB kernel_stack:6128kB pagetables:6844kB bounce:0kB free_pcp:416kB local_pcp:0kB free_cma:0kB
[  765.884108] lowmem_reserve[]: 0 0 0 0
[  765.886080] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15844kB
[  765.891129] Node 0 DMA32: 28*4kB (UM) 33*8kB (UM) 58*16kB (UM) 60*32kB (UM) 48*64kB (UM) 34*128kB (UM) 34*256kB (UM) 21*512kB (UM) 12*1024kB (UM) 9*2048kB (UM) 653*4096kB (M) = 2735512kB
[  765.898614] Node 0 Normal: 3528*4kB (UM) 1178*8kB (UM) 1371*16kB (UM) 898*32kB (UME) 362*64kB (UME) 108*128kB (UME) 46*256kB (UME) 22*512kB (M) 7*1024kB (UM) 10*2048kB (M) 67*4096kB (M) = 436320kB
[  765.906220] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  765.909852] 5357 total pagecache pages
[  765.912036] 0 pages in swap cache
[  765.914092] Swap cache stats: add 0, delete 0, find 0/0
[  765.916680] Free swap  = 0kB
[  765.918560] Total swap = 0kB
[  765.920583] 1048422 pages RAM
[  765.922676] 0 pages HighMem/MovableOnly
[  765.924973] 179653 pages reserved
[  765.927004] 0 pages cma reserved
[  765.928919] 0 pages hwpoisoned
[  765.930821] Unreclaimable slab info:
[  765.932934] Name                      Used          Total
[  765.936489] nf_conntrack               0KB         31KB
[  765.939582] xfs_buf                   22KB        127KB
[  765.942322] xfs_ili                   20KB        127KB
[  765.944942] xfs_efi_item               0KB         31KB
[  765.947427] xfs_efd_item               0KB         31KB
[  765.949957] xfs_buf_item               0KB         62KB
[  765.952490] xfs_trans                  0KB         63KB
[  765.955268] xfs_ifork                 27KB        158KB
[  765.957913] xfs_da_state               0KB         31KB
[  765.960483] xfs_btree_cur              0KB         63KB
[  765.962943] xfs_bmap_free_item          0KB         15KB
[  765.965415] xfs_log_ticket             0KB         63KB
[  765.967880] bio-2                     24KB         63KB
[  765.970409] sd_ext_cdb                 0KB         15KB
[  765.973778] scsi_sense_cache           7KB        128KB
[  765.976603] fib6_nodes                11KB         32KB
[  765.979072] ip6_dst_cache              4KB         31KB
[  765.981504] RAWv6                    266KB        384KB
[  765.983897] UDPv6                      0KB         31KB
[  765.986243] TCPv6                     10KB         30KB
[  765.988850] sgpool-128                 8KB         62KB
[  765.991320] sgpool-64                  4KB         31KB
[  765.993554] sgpool-32                  2KB         31KB
[  765.995733] sgpool-16                  1KB         31KB
[  765.997852] sgpool-8                   1KB         63KB
[  766.000043] mqueue_inode_cache          1KB         31KB
[  766.002313] bio-1                      2KB         31KB
[  766.004549] fasync_cache               0KB         15KB
[  766.006757] posix_timers_cache          0KB         31KB
[  766.009787] UNIX                     187KB        240KB
[  766.012175] tcp_bind_bucket            1KB         32KB
[  766.014163] ip_fib_trie                2KB         15KB
[  766.016080] ip_fib_alias               3KB         15KB
[  766.017988] ip_dst_cache               6KB         31KB
[  766.019808] RAW                      464KB        585KB
[  766.021751] UDP                        8KB         30KB
[  766.023730] request_sock_TCP           0KB         31KB
[  766.025684] TCP                       12KB         31KB
[  766.027458] hugetlbfs_inode_cache          2KB         30KB
[  766.029314] eventpoll_pwq             37KB         63KB
[  766.031131] eventpoll_epi             53KB         94KB
[  766.032938] inotify_inode_mark         27KB         31KB
[  766.034774] request_queue             16KB         56KB
[  766.036598] blkdev_ioc                31KB        126KB
[  766.038508] bio-0                      6KB        127KB
[  766.040390] biovec-max               405KB        506KB
[  766.042199] biovec-128                 0KB         31KB
[  766.044857] biovec-64                  0KB         94KB
[  766.047009] biovec-16                  0KB         63KB
[  766.048856] bio_integrity_payload          1KB         31KB
[  766.050745] khugepaged_mm_slot          1KB         15KB
[  766.052602] uid_cache                  2KB         31KB
[  766.054537] dmaengine-unmap-2          0KB         15KB
[  766.056523] audit_buffer               0KB         15KB
[  766.058506] skbuff_fclone_cache          0KB         31KB
[  766.060521] skbuff_head_cache          0KB        127KB
[  766.062391] configfs_dir_cache          1KB         15KB
[  766.064226] file_lock_cache           13KB         31KB
[  766.066061] file_lock_ctx             15KB         31KB
[  766.067883] fsnotify_mark_connector         18KB         31KB
[  766.069874] net_namespace              0KB         32KB
[  766.071801] shmem_inode_cache       1546KB       1595KB
[  766.073838] task_delay_info          177KB        318KB
[  766.075820] taskstats                  2KB         63KB
[  766.077664] proc_dir_entry           498KB        540KB
[  766.080418] pde_opener                 0KB         31KB
[  766.082620] seq_file                   1KB        127KB
[  766.084526] sigqueue                   0KB         63KB
[  766.086374] kernfs_node_cache      29487KB      29536KB
[  766.088403] mnt_cache                 90KB        126KB
[  766.090442] filp                    1195KB       1466KB
[  766.092412] names_cache                0KB        155KB
[  766.094412] key_jar                    4KB         31KB
[  766.096428] nsproxy                    1KB         15KB
[  766.098448] vm_area_struct          3312KB       3480KB
[  766.100378] mm_struct                 68KB        128KB
[  766.102292] fs_cache                  90KB        189KB
[  766.104179] files_cache              200KB        281KB
[  766.106192] signal_cache             690KB        892KB
[  766.108158] sighand_cache            943KB       1137KB
[  766.110116] task_struct             3590KB       3825KB
[  766.112005] cred_jar                 249KB        378KB
[  766.113912] anon_vma_chain          1634KB       1742KB
[  766.116711] anon_vma                1214KB       1309KB
[  766.119046] pid                      129KB        256KB
[  766.121108] Acpi-Operand            3713KB       3761KB
[  766.123251] Acpi-ParseExt              0KB         15KB
[  766.125261] Acpi-Parse                 0KB         31KB
[  766.127259] Acpi-State                 0KB         47KB
[  766.129256] Acpi-Namespace          2913KB       2936KB
[  766.131118] numa_policy               74KB         94KB
[  766.132954] trace_event_file         455KB        456KB
[  766.134815] ftrace_event_field        777KB        787KB
[  766.136762] pool_workqueue            72KB         94KB
[  766.138859] task_group                35KB         63KB
[  766.140890] page->ptl                725KB        828KB
[  766.142857] dma-kmalloc-512            0KB         31KB
[  766.144751] kmalloc-8192             441KB        499KB
[  766.146793] kmalloc-4096             965KB       1090KB
[  766.148619] kmalloc-2048            4570KB       4691KB
[  766.150479] kmalloc-1024             881KB        988KB
[  766.153265] kmalloc-512             3343KB       3430KB
[  766.155491] kmalloc-256             3368KB       3434KB
[  766.157383] kmalloc-192              276KB        447KB
[  766.159287] kmalloc-128              981KB       1078KB
[  766.161152] kmalloc-96              2288KB       2294KB
[  766.163011] kmalloc-64              1675KB       1921KB
[  766.164862] kmalloc-32              1395KB       1533KB
[  766.166635] kmalloc-16              3359KB       3795KB
[  766.168413] kmalloc-8               2344KB       2384KB
[  766.170249] kmem_cache_node          102KB        126KB
[  766.172232] kmem_cache               147KB        158KB
[  766.174204] Out of memory: Kill process 679 (firewalld) score 6 or sacrifice child
[  766.176757] Killed process 679 (firewalld) total-vm:357864kB, anon-rss:21920kB, file-rss:0kB, shmem-rss:0kB
[  766.183011] oom_reaper: reaped process 679 (firewalld), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
