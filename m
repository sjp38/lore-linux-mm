Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD3CE6B0033
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 11:06:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w204so30860661iow.16
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 08:06:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 65si10731572itc.73.2017.11.25.08.06.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Nov 2017 08:06:14 -0800 (PST)
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is
 illogical
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
Date: Sun, 26 Nov 2017 01:05:58 +0900
MIME-Version: 1.0
In-Reply-To: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org
Cc: jack@suse.cz, mhocko@suse.com, linux-mm@kvack.org

On 2017/09/28 18:54, Yafang Shao wrote:
> The vm direct limit setting must be set greater than vm background
> limit setting.
> Otherwise we will print a warning to help the operator to figure
> out that the vm dirtiness settings is in illogical state.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

I got this warning by simple OOM killer flooding. Is this what you meant?

----------
[  621.747994] vmtoolsd invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  621.751357] vmtoolsd cpuset=/ mems_allowed=0
[  621.753124] CPU: 1 PID: 684 Comm: vmtoolsd Not tainted 4.14.0-next-20171124+ #681
[  621.755392] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  621.758535] Call Trace:
[  621.760324]  dump_stack+0x5f/0x86
[  621.761981]  dump_header+0x69/0x431
[  621.763459]  ? trace_hardirqs_on_caller+0xe7/0x180
[  621.765200]  oom_kill_process+0x294/0x670
[  621.766800]  out_of_memory+0x423/0x5c0
[  621.768432]  __alloc_pages_nodemask+0x11e2/0x1450
[  621.770135]  filemap_fault+0x4b7/0x710
[  621.771656]  __xfs_filemap_fault.constprop.0+0x68/0x210
[  621.773463]  __do_fault+0x15/0xc0
[  621.775252]  __handle_mm_fault+0xd7c/0x1390
[  621.777204]  ? __audit_syscall_exit+0x195/0x290
[  621.779318]  handle_mm_fault+0x173/0x330
[  621.781047]  __do_page_fault+0x2a7/0x510
[  621.784331]  do_page_fault+0x2c/0x2f0
[  621.786126]  page_fault+0x22/0x30
[  621.787581] RIP: 0033:0x7f397f268dd0
[  621.789102] RSP: 002b:00007fffa8b225f8 EFLAGS: 00010202
[  621.790842] RAX: 00005635d5c715b0 RBX: 0000000000000001 RCX: 0000000000000001
[  621.793421] RDX: 0000000000000001 RSI: 00007f3981f16350 RDI: 00005635d5c715b0
[  621.795610] RBP: 00005635d5c715b0 R08: 0000000000000000 R09: 0000000000000004
[  621.797732] R10: 0000000000000005 R11: 0000000000000246 R12: 0000000000000000
[  621.800252] R13: 00007f3981f16350 R14: 0000000000000000 R15: 0000000000000000
[  621.802406] Mem-Info:
[  621.803682] active_anon:881485 inactive_anon:2093 isolated_anon:0
 active_file:54 inactive_file:468 isolated_file:0
 unevictable:0 dirty:13 writeback:0 unstable:0
 slab_reclaimable:6684 slab_unreclaimable:16061
 mapped:626 shmem:2165 pagetables:3418 bounce:0
 free:21384 free_pcp:74 free_cma:0
[  621.814512] Node 0 active_anon:3525940kB inactive_anon:8372kB active_file:216kB inactive_file:1872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2504kB dirty:52kB writeback:0kB shmem:8660kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 636928kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  621.821534] Node 0 DMA free:14848kB min:284kB low:352kB high:420kB active_anon:992kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  621.829035] lowmem_reserve[]: 0 2687 3645 3645
[  621.831655] Node 0 DMA32 free:53004kB min:49608kB low:62008kB high:74408kB active_anon:2712648kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2773132kB mlocked:0kB kernel_stack:96kB pagetables:5096kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  621.839945] lowmem_reserve[]: 0 0 958 958
[  621.842811] Node 0 Normal free:17140kB min:17684kB low:22104kB high:26524kB active_anon:812300kB inactive_anon:8372kB active_file:1228kB inactive_file:1868kB unevictable:0kB writepending:52kB present:1048576kB managed:981224kB mlocked:0kB kernel_stack:3520kB pagetables:8552kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
[  621.852473] lowmem_reserve[]: 0 0 0 0
[  621.854094] Node 0 DMA: 2*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 0*2048kB 3*4096kB (ME) = 14848kB
[  621.857755] Node 0 DMA32: 65*4kB (UM) 5*8kB (UME) 118*16kB (UME) 66*32kB (UME) 25*64kB (UME) 12*128kB (UE) 8*256kB (UE) 3*512kB (ME) 5*1024kB (E) 10*2048kB (E) 4*4096kB (ME) = 53004kB
[  621.864205] Node 0 Normal: 619*4kB (UME) 506*8kB (UME) 207*16kB (UME) 121*32kB (UME) 33*64kB (UME) 7*128kB (ME) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16972kB
[  621.869661] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  621.872283] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  621.875600] 2823 total pagecache pages
[  621.878108] 0 pages in swap cache
[  621.879818] Swap cache stats: add 0, delete 0, find 0/0
[  621.864205] Node 0 Normal: 619*4kB (UME) 506*8kB (UME) 207*16kB (UME) 121*32kB (UME) 33*64kB (UME) 7*128kB (ME) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16972kB
[  621.869661] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  621.872283] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  621.875600] 2823 total pagecache pages
[  621.878108] 0 pages in swap cache
[  621.879818] Swap cache stats: add 0, delete 0, find 0/0
[  621.881796] Free swap  = 0kB
[  621.883389] Total swap = 0kB
[  621.884940] 1048445 pages RAM
[  621.886442] 0 pages HighMem/MovableOnly
[  621.888197] 105880 pages reserved
[  621.889964] 0 pages hwpoisoned
[  621.891477] Out of memory: Kill process 8459 (a.out) score 999 or sacrifice child
[  621.894363] Killed process 8459 (a.out) total-vm:4180kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  621.897172] oom_reaper: reaped process 8459 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  622.424664] vm direct limit must be set greater than background limit.
[  622.427810] vm direct limit must be set greater than background limit.
[  622.631937] vm direct limit must be set greater than background limit.
[  622.634316] vm direct limit must be set greater than background limit.
[  622.789310] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  622.792603] a.out cpuset=/ mems_allowed=0
[  622.794797] CPU: 2 PID: 8455 Comm: a.out Not tainted 4.14.0-next-20171124+ #681
[  622.797307] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  622.800901] Call Trace:
[  622.802264]  dump_stack+0x5f/0x86
[  622.803733]  dump_header+0x69/0x431
[  622.805198]  ? trace_hardirqs_on_caller+0xe7/0x180
[  622.807001]  oom_kill_process+0x294/0x670
[  622.808655]  out_of_memory+0x423/0x5c0
[  622.810771]  __alloc_pages_nodemask+0x11e2/0x1450
[  622.812632]  ? __lock_acquire+0x306/0x1420
[  622.814315]  alloc_pages_vma+0x7b/0x1e0
[  622.816091]  __handle_mm_fault+0x1001/0x1390
[  622.817754]  ? retint_kernel+0x2d/0x2d
[  622.819785]  handle_mm_fault+0x173/0x330
[  622.821331]  __do_page_fault+0x2a7/0x510
[  622.822886]  do_page_fault+0x2c/0x2f0
[  622.824307]  page_fault+0x22/0x30
[  622.828293] RIP: 0033:0x4006f0
[  622.829930] RSP: 002b:00007fffa638c440 EFLAGS: 00010206
[  622.831701] RAX: 00000000d380e000 RBX: 0000000100000000 RCX: 00007f9ed5110190
[  622.834199] RDX: 0000000000000000 RSI: 00007fffa638c260 RDI: 00007fffa638c260
[  622.836253] RBP: 00007f9cd5245010 R08: 00007fffa638c370 R09: 00007fffa638c1b0
[  622.838271] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000006
[  622.840430] R13: 00007f9cd5245010 R14: 0000000000000000 R15: 0000000000000000
[  622.854308] Mem-Info:
[  622.855493] active_anon:881658 inactive_anon:2093 isolated_anon:0
 active_file:1 inactive_file:120 isolated_file:0
 unevictable:0 dirty:3 writeback:0 unstable:0
 slab_reclaimable:6676 slab_unreclaimable:16057
 mapped:585 shmem:2165 pagetables:3412 bounce:0
 free:21273 free_pcp:124 free_cma:0
[  622.867896] Node 0 active_anon:3526676kB inactive_anon:8372kB active_file:8kB inactive_file:828kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2344kB dirty:20kB writeback:0kB shmem:8660kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 636928kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  622.875151] Node 0 DMA free:14848kB min:284kB low:352kB high:420kB active_anon:992kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  622.882244] lowmem_reserve[]: 0 2687 3645 3645
[  622.883861] Node 0 DMA32 free:53004kB min:49608kB low:62008kB high:74408kB active_anon:2712648kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2773132kB mlocked:0kB kernel_stack:96kB pagetables:5096kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  622.891029] lowmem_reserve[]: 0 0 958 958
[  622.892814] Node 0 Normal free:18000kB min:17684kB low:22104kB high:26524kB active_anon:813036kB inactive_anon:8372kB active_file:8kB inactive_file:1300kB unevictable:0kB writepending:20kB present:1048576kB managed:981224kB mlocked:0kB kernel_stack:3488kB pagetables:8532kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB
[  622.901963] lowmem_reserve[]: 0 0 0 0
[  622.903501] Node 0 DMA: 2*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 0*2048kB 3*4096kB (ME) = 14848kB
[  622.907115] Node 0 DMA32: 65*4kB (UM) 5*8kB (UME) 118*16kB (UME) 66*32kB (UME) 25*64kB (UME) 12*128kB (UE) 8*256kB (UE) 3*512kB (ME) 5*1024kB (E) 10*2048kB (E) 4*4096kB (ME) = 53004kB
[  622.912651] Node 0 Normal: 823*4kB (UME) 505*8kB (UME) 214*16kB (UME) 127*32kB (UME) 33*64kB (UME) 7*128kB (ME) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18084kB
[  622.917512] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  622.920171] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  622.922742] 2503 total pagecache pages
[  622.924417] 0 pages in swap cache
[  622.928889] Swap cache stats: add 0, delete 0, find 0/0
[  622.931040] Free swap  = 0kB
[  622.932560] Total swap = 0kB
[  622.934031] 1048445 pages RAM
[  622.935503] 0 pages HighMem/MovableOnly
[  622.937440] 105880 pages reserved
[  622.939066] 0 pages hwpoisoned
[  622.940578] Out of memory: Kill process 8460 (a.out) score 999 or sacrifice child
[  622.943093] Killed process 8460 (a.out) total-vm:4180kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  622.946331] oom_reaper: reaped process 8460 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
        static char buffer[4096] = { };
        char *buf = NULL;
        unsigned long size;
        unsigned long i;
        for (i = 0; i < 16; i++) {
                if (fork() == 0) {
                        int fd = open("/proc/self/oom_score_adj", O_WRONLY);
                        write(fd, "1000", 4);
                        close(fd);
                        snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
                        fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
                        sleep(1);
                        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
                        _exit(0);
                }
        }
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        sleep(2);
        /* Will cause OOM due to overcommit */
        for (i = 0; i < size; i += 4096)
                buf[i] = 0;
        return 0;
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
