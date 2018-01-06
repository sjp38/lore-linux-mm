Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 163026B0368
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 02:37:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p1so4054408pfp.13
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 23:37:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 88si946120plc.76.2018.01.05.23.37.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 23:37:34 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groupssharing victim's memory.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513682774-4416-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171219114012.GK2787@dhcp22.suse.cz>
In-Reply-To: <20171219114012.GK2787@dhcp22.suse.cz>
Message-Id: <201801061637.CCF78186.OOJFFtMVOLSHQF@I-love.SAKURA.ne.jp>
Date: Sat, 6 Jan 2018 16:37:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com

Michal Hocko wrote:
> On Tue 19-12-17 20:26:14, Tetsuo Handa wrote:
> > When the OOM reaper set MMF_OOM_SKIP on the victim's mm before threads
> > sharing that mm get ->signal->oom_mm, the comment "That thread will now
> > get access to memory reserves since it has a pending fatal signal." no
> > longer stands. Also, since we introduced ALLOC_OOM watermark, the comment
> > "They don't get access to memory reserves, though, to avoid depletion of
> > all memory." no longer stands.
> > 
> > This patch treats all thread groups sharing the victim's mm evenly,
> > and updates the outdated comment.
> 
> Nack with a real life example where this matters.

You did not respond to
http://lkml.kernel.org/r/201712232341.FGC64072.VFLOOJOtFSFMHQ@I-love.SAKURA.ne.jp ,
and I observed needless OOM-killing. Therefore, I push this patch again.



(1) One a.out instance was running as PID = 8856, 8857, 8858, 8859, 8860.

----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <sys/mman.h>

#define NUMTHREADS 4
#define MMAPSIZE 1024 * 1048576
#define STACKSIZE 4096
static int pipe_fd[2] = { EOF, EOF };
static int memory_eater(void *unused)
{
        int fd = open("/dev/zero", O_RDONLY);
        char *buf = mmap(NULL, MMAPSIZE, PROT_WRITE | PROT_READ,
                         MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
        read(pipe_fd[0], buf, 1);
        read(fd, buf, MMAPSIZE);
        pause();
        return 0;
}
int main(int argc, char *argv[])
{
        int i;
        char *stack;
        if (fork() || fork() || setsid() == EOF || pipe(pipe_fd))
                _exit(0);
        stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
                     MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
        for (i = 0; i < NUMTHREADS; i++)
                if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
                          CLONE_VM | CLONE_FS | CLONE_FILES, NULL) == -1)
                        break;
        sleep(1);
        close(pipe_fd[1]);
        pause();
        return 0;
}
----------------------------------------

(2) When PID = 8858 invoked the OOM killer, the OOM killer selected PID = 8856
    as the OOM victim.

[  279.228122] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.231253] a.out cpuset=/ mems_allowed=0
[  279.233003] CPU: 3 PID: 8858 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688

[  279.381837] Out of memory: Kill process 8856 (a.out) score 935 or sacrifice child
[  279.384017] Killed process 8856 (a.out) total-vm:4198496kB, anon-rss:88kB, file-rss:0kB, shmem-rss:3520160kB

(3) The OOM reaper failed to reclaim any memory and set MMF_OOM_SKIP.

[  279.387222] oom_reaper: reaped process 8856 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3520176kB

(4) When systemd (running as PID = 1) invoked the OOM killer, the OOM killer
    selected PID = 8848 as the OOM victim.

[  279.391009] systemd invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.393981] systemd cpuset=/ mems_allowed=0
[  279.395588] CPU: 2 PID: 1 Comm: systemd Not tainted 4.15.0-rc6-next-20180105 #688

[  279.502886] Out of memory: Kill process 8848 (rsyslogd) score 0 or sacrifice child
[  279.505135] Killed process 8848 (rsyslogd) total-vm:265556kB, anon-rss:708kB, file-rss:4kB, shmem-rss:2068kB

(5) PID = 8848 released its mm_struct before the OOM reaper starts reaping
    that mm_struct. Thus, no OOM reaper messages but some memory was freed.

(6) When PID = 8859 reached out_of_memory(), task_will_free_mem(current)
    returned false because MMF_OOM_SKIP was already set at (3).

[  279.512711] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.515712] a.out cpuset=/ mems_allowed=0
[  279.517377] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688

(7) PID = 8859 invoked the OOM killer, and the OOM killer selected
    PID = 8846 as the OOM victim.

[  279.633708] Out of memory: Kill process 8846 (systemd-journal) score 0 or sacrifice child
[  279.633727] Killed process 8846 (systemd-journal) total-vm:36844kB, anon-rss:256kB, file-rss:4kB, shmem-rss:784kB
[  279.633873] oom_reaper: reaped process 8846 (systemd-journal), now anon-rss:0kB, file-rss:0kB, shmem-rss:784kB

(8) When PID = 8859 reached out_of_memory(), task_will_free_mem(current)
    again returned false because MMF_OOM_SKIP was already set at (3).

[  279.633953] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.633954] a.out cpuset=/ mems_allowed=0
[  279.633960] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688

(9) PID = 8859 again invoked the OOM killer, and the OOM killer selected
    PID = 8802 as the OOM victim.

[  279.634196] Out of memory: Kill process 8793 (login) score 0 or sacrifice child
[  279.634223] Killed process 8802 (bash) total-vm:115520kB, anon-rss:524kB, file-rss:0kB, shmem-rss:0kB
[  279.634353] oom_reaper: reaped process 8802 (bash), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

(10) When PID = 8859 reached out_of_memory(), task_will_free_mem(current)
     again returned false because MMF_OOM_SKIP was already set at (3).

[  279.634393] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.634394] a.out cpuset=/ mems_allowed=0
[  279.634397] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688

(11) PID = 8859 again invoked the OOM killer, and the OOM killer selected
     PID = 8793 as the OOM victim.

[  279.635209] Out of memory: Kill process 8793 (login) score 0 or sacrifice child
[  279.635213] Killed process 8793 (login) total-vm:94940kB, anon-rss:676kB, file-rss:4kB, shmem-rss:0kB
[  279.635457] oom_reaper: reaped process 8793 (login), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

If PID = 8859 were able to call mark_oom_victim(current), PID = 8846, 8802, 8793
would not have been killed by the OOM victim.



Complete messages are shown below.
----------------------------------------
[  279.228122] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.231253] a.out cpuset=/ mems_allowed=0
[  279.233003] CPU: 3 PID: 8858 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688
[  279.235474] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  279.238506] Call Trace:
[  279.239959]  dump_stack+0x5f/0x86
[  279.241571]  dump_header+0x69/0x431
[  279.243211]  ? trace_hardirqs_on_caller+0xe7/0x180
[  279.245104]  oom_kill_process+0x207/0x210
[  279.246844]  out_of_memory+0x229/0x720
[  279.248530]  __alloc_pages_nodemask+0x1267/0x1400
[  279.250388]  alloc_pages_vma+0x7b/0x1c0
[  279.252116]  shmem_alloc_page+0x70/0xb0
[  279.253946]  ? lock_acquire+0x98/0x1e0
[  279.255553]  ? find_get_entry+0x143/0x210
[  279.257189]  ? find_get_entry+0x160/0x210
[  279.258793]  shmem_alloc_and_acct_page+0x77/0x1d0
[  279.260515]  shmem_getpage_gfp+0x18f/0xd20
[  279.262091]  ? mark_lock+0x590/0x620
[  279.263560]  shmem_fault+0x97/0x1f0
[  279.264987]  ? file_update_time+0x5b/0x120
[  279.266530]  __do_fault+0x15/0xa0
[  279.267873]  __handle_mm_fault+0x932/0x1130
[  279.269391]  handle_mm_fault+0x173/0x330
[  279.270830]  __do_page_fault+0x2a7/0x510
[  279.272248]  do_page_fault+0x2c/0x2b0
[  279.273585]  page_fault+0x2c/0x60
[  279.274825] RIP: 0010:__clear_user+0x38/0x60
[  279.276226] RSP: 0018:ffffc90001ef7da8 EFLAGS: 00010206
[  279.277805] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000200
[  279.279773] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f9de48a6000
[  279.281728] RBP: 00007f9de48a6000 R08: 0000000040000000 R09: 0000000000000000
[  279.283573] R10: ffffc90001ef7e30 R11: ffff88013846ae80 R12: ffffc90001ef7e48
[  279.285349] R13: 0000000000001000 R14: 00007f9daec7e000 R15: ffffc90001ef7e80
[  279.287133]  ? __clear_user+0x19/0x60
[  279.288302]  iov_iter_zero+0x84/0x390
[  279.289475]  read_iter_zero+0x33/0x80
[  279.290646]  __vfs_read+0xe6/0x150
[  279.291773]  vfs_read+0x8c/0x130
[  279.292867]  SyS_read+0x50/0xc0
[  279.293931]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  279.295265]  do_syscall_64+0x5b/0x220
[  279.296412]  entry_SYSCALL64_slow_path+0x25/0x25
[  279.297812] RIP: 0033:0x7f9e2ed677e0
[  279.299017] RSP: 002b:00007f9e2f25efd8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  279.300843] RAX: ffffffffffffffda RBX: 00007f9daec7e000 RCX: 00007f9e2ed677e0
[  279.302578] RDX: 0000000040000000 RSI: 00007f9daec7e000 RDI: 0000000000000006
[  279.304315] RBP: 0000000000000006 R08: ffffffffffffffff R09: 0000000000000000
[  279.306014] R10: 0000000000000021 R11: 0000000000000246 R12: 00000000004007cb
[  279.307666] R13: 00007ffdee065800 R14: 0000000000000000 R15: 0000000000000000
[  279.309520] Mem-Info:
[  279.310629] active_anon:3069 inactive_anon:893121 isolated_anon:0
[  279.310629]  active_file:54 inactive_file:50 isolated_file:0
[  279.310629]  unevictable:0 dirty:5 writeback:1 unstable:0
[  279.310629]  slab_reclaimable:5582 slab_unreclaimable:6202
[  279.310629]  mapped:880632 shmem:894317 pagetables:1991 bounce:0
[  279.310629]  free:21240 free_pcp:10 free_cma:0
[  279.319627] Node 0 active_anon:12276kB inactive_anon:3572616kB active_file:172kB inactive_file:108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3522492kB dirty:20kB writeback:4kB shmem:3577400kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  279.325725] Node 0 DMA free:14820kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:1080kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.332142] lowmem_reserve[]: 0 2684 3642 3642
[  279.333584] Node 0 DMA32 free:53056kB min:49592kB low:61988kB high:74384kB active_anon:380kB inactive_anon:2704684kB active_file:68kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771468kB mlocked:0kB kernel_stack:16kB pagetables:5272kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.340243] lowmem_reserve[]: 0 0 958 958
[  279.341907] Node 0 Normal free:17832kB min:17700kB low:22124kB high:26548kB active_anon:11896kB inactive_anon:866600kB active_file:476kB inactive_file:288kB unevictable:0kB writepending:20kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:3280kB pagetables:2896kB bounce:0kB free_pcp:292kB local_pcp:0kB free_cma:0kB
[  279.349084] lowmem_reserve[]: 0 0 0 0
[  279.350667] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14804kB
[  279.354271] Node 0 DMA32: 12*4kB (UM) 13*8kB (UM) 11*16kB (UM) 2*32kB (UM) 2*64kB (ME) 0*128kB 0*256kB 5*512kB (UME) 1*1024kB (E) 0*2048kB 12*4096kB (M) = 53256kB
[  279.358608] Node 0 Normal: 157*4kB (U) 385*8kB (UME) 308*16kB (UMH) 123*32kB (UM) 35*64kB (UMH) 2*128kB (UM) 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 16860kB
[  279.363383] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  279.366085] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  279.368331] 894630 total pagecache pages
[  279.369841] 0 pages in swap cache
[  279.371442] Swap cache stats: add 0, delete 0, find 0/0
[  279.373180] Free swap  = 0kB
[  279.374717] Total swap = 0kB
[  279.376309] 1048445 pages RAM
[  279.377645] 0 pages HighMem/MovableOnly
[  279.379118] 106318 pages reserved
[  279.380500] 0 pages hwpoisoned
[  279.381837] Out of memory: Kill process 8856 (a.out) score 935 or sacrifice child
[  279.384017] Killed process 8856 (a.out) total-vm:4198496kB, anon-rss:88kB, file-rss:0kB, shmem-rss:3520160kB
[  279.387222] oom_reaper: reaped process 8856 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3520176kB
[  279.391009] systemd invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.393981] systemd cpuset=/ mems_allowed=0
[  279.395588] CPU: 2 PID: 1 Comm: systemd Not tainted 4.15.0-rc6-next-20180105 #688
[  279.397751] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  279.400482] Call Trace:
[  279.401775]  dump_stack+0x5f/0x86
[  279.403214]  dump_header+0x69/0x431
[  279.404700]  ? trace_hardirqs_on_caller+0xe7/0x180
[  279.406395]  oom_kill_process+0x207/0x210
[  279.408389]  out_of_memory+0x229/0x720
[  279.409916]  __alloc_pages_nodemask+0x1267/0x1400
[  279.411630]  filemap_fault+0x470/0x640
[  279.413144]  __xfs_filemap_fault.constprop.0+0x5f/0x1f0
[  279.414919]  __do_fault+0x15/0xa0
[  279.416351]  __handle_mm_fault+0xca6/0x1130
[  279.417961]  handle_mm_fault+0x173/0x330
[  279.419479]  __do_page_fault+0x2a7/0x510
[  279.420974]  do_page_fault+0x2c/0x2b0
[  279.422403]  ? page_fault+0x36/0x60
[  279.423980]  page_fault+0x4c/0x60
[  279.425362] RIP: 0033:0x7fc60f6b0923
[  279.426700] RSP: 002b:00007ffd0515fe00 EFLAGS: 00010293
[  279.426794] Mem-Info:
[  279.429527] active_anon:3047 inactive_anon:893429 isolated_anon:0
[  279.429527]  active_file:2 inactive_file:5 isolated_file:0
[  279.429527]  unevictable:0 dirty:4 writeback:1 unstable:0
[  279.429527]  slab_reclaimable:5634 slab_unreclaimable:6207
[  279.429527]  mapped:880847 shmem:894629 pagetables:2046 bounce:0
[  279.429527]  free:21230 free_pcp:88 free_cma:0
[  279.439247] Node 0 active_anon:12188kB inactive_anon:3573716kB active_file:8kB inactive_file:20kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3523388kB dirty:16kB writeback:4kB shmem:3578516kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  279.445522] Node 0 DMA free:14804kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:1084kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.451679] lowmem_reserve[]: 0 2684 3642 3642
[  279.453132] Node 0 DMA32 free:53256kB min:49592kB low:61988kB high:74384kB active_anon:380kB inactive_anon:2704704kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771468kB mlocked:0kB kernel_stack:16kB pagetables:5276kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.460561] lowmem_reserve[]: 0 0 958 958
[  279.462395] Node 0 Normal free:17092kB min:17700kB low:22124kB high:26548kB active_anon:11808kB inactive_anon:867928kB active_file:4kB inactive_file:20kB unevictable:0kB writepending:20kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:3264kB pagetables:2908kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.469828] lowmem_reserve[]: 0 0 0 0
[  279.471670] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14804kB
[  279.475441] Node 0 DMA32: 12*4kB (UM) 13*8kB (UM) 11*16kB (UM) 2*32kB (UM) 2*64kB (ME) 0*128kB 0*256kB 5*512kB (UME) 1*1024kB (E) 0*2048kB 12*4096kB (M) = 53256kB
[  279.480298] Node 0 Normal: 207*4kB (UM) 404*8kB (UME) 308*16kB (UMH) 123*32kB (UM) 35*64kB (UMH) 2*128kB (UM) 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 17212kB
[  279.484895] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  279.487353] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  279.489765] 894635 total pagecache pages
[  279.491446] 0 pages in swap cache
[  279.492827] Swap cache stats: add 0, delete 0, find 0/0
[  279.494677] Free swap  = 0kB
[  279.495966] Total swap = 0kB
[  279.497340] 1048445 pages RAM
[  279.498640] 0 pages HighMem/MovableOnly
[  279.500091] 106318 pages reserved
[  279.501573] 0 pages hwpoisoned
[  279.502886] Out of memory: Kill process 8848 (rsyslogd) score 0 or sacrifice child
[  279.505135] Killed process 8848 (rsyslogd) total-vm:265556kB, anon-rss:708kB, file-rss:4kB, shmem-rss:2068kB
[  279.512711] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.515712] a.out cpuset=/ mems_allowed=0
[  279.517377] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688
[  279.519496] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  279.522322] Call Trace:
[  279.523565]  dump_stack+0x5f/0x86
[  279.525352]  dump_header+0x69/0x431
[  279.526757]  ? trace_hardirqs_on_caller+0xe7/0x180
[  279.528471]  oom_kill_process+0x207/0x210
[  279.529990]  out_of_memory+0x229/0x720
[  279.531433]  __alloc_pages_nodemask+0x1267/0x1400
[  279.533209]  alloc_pages_vma+0x7b/0x1c0
[  279.534707]  shmem_alloc_page+0x70/0xb0
[  279.536344]  ? lock_acquire+0x98/0x1e0
[  279.537813]  ? find_get_entry+0x143/0x210
[  279.539311]  ? find_get_entry+0x160/0x210
[  279.541474]  shmem_alloc_and_acct_page+0x77/0x1d0
[  279.543066]  shmem_getpage_gfp+0x18f/0xd20
[  279.544727]  ? mark_lock+0x590/0x620
[  279.546192]  shmem_fault+0x97/0x1f0
[  279.547521]  ? file_update_time+0x5b/0x120
[  279.549127]  __do_fault+0x15/0xa0
[  279.550405]  __handle_mm_fault+0x932/0x1130
[  279.551843]  handle_mm_fault+0x173/0x330
[  279.553198]  __do_page_fault+0x2a7/0x510
[  279.554493]  do_page_fault+0x2c/0x2b0
[  279.555818]  page_fault+0x2c/0x60
[  279.557038] RIP: 0010:__clear_user+0x38/0x60
[  279.558351] RSP: 0018:ffffc90001f0fda8 EFLAGS: 00010206
[  279.560008] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000200
[  279.561748] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f9da4a86000
[  279.563577] RBP: 00007f9da4a86000 R08: 0000000040000000 R09: 0000000000000000
[  279.565488] R10: ffffc90001f0fe30 R11: ffff880132d5dd00 R12: ffffc90001f0fe48
[  279.567627] R13: 0000000000001000 R14: 00007f9d6ec7e000 R15: ffffc90001f0fe80
[  279.569317]  ? __clear_user+0x19/0x60
[  279.570397]  iov_iter_zero+0x84/0x390
[  279.571622]  read_iter_zero+0x33/0x80
[  279.572860]  __vfs_read+0xe6/0x150
[  279.573992]  vfs_read+0x8c/0x130
[  279.575058]  SyS_read+0x50/0xc0
[  279.576094]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  279.577359]  do_syscall_64+0x5b/0x220
[  279.578429]  entry_SYSCALL64_slow_path+0x25/0x25
[  279.580097] RIP: 0033:0x7f9e2ed677e0
[  279.581145] RSP: 002b:00007f9e2f25ffd8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  279.582974] RAX: ffffffffffffffda RBX: 00007f9d6ec7e000 RCX: 00007f9e2ed677e0
[  279.584684] RDX: 0000000040000000 RSI: 00007f9d6ec7e000 RDI: 0000000000000007
[  279.586344] RBP: 0000000000000007 R08: ffffffffffffffff R09: 0000000000000000
[  279.588280] R10: 0000000000000021 R11: 0000000000000246 R12: 00000000004007cb
[  279.589940] R13: 00007ffdee065800 R14: 0000000000000000 R15: 0000000000000000
[  279.592024] Mem-Info:
[  279.592974] active_anon:2899 inactive_anon:893434 isolated_anon:0
[  279.592974]  active_file:13 inactive_file:0 isolated_file:0
[  279.592974]  unevictable:0 dirty:4 writeback:1 unstable:0
[  279.592974]  slab_reclaimable:5634 slab_unreclaimable:6207
[  279.592974]  mapped:880403 shmem:894629 pagetables:2046 bounce:0
[  279.592974]  free:21318 free_pcp:176 free_cma:0
[  279.601735] Node 0 active_anon:11596kB inactive_anon:3573736kB active_file:0kB inactive_file:24kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3521612kB dirty:16kB writeback:4kB shmem:3578516kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  279.607968] Node 0 DMA free:14804kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:1084kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.613904] lowmem_reserve[]: 0 2684 3642 3642
[  279.615331] Node 0 DMA32 free:53256kB min:49592kB low:61988kB high:74384kB active_anon:380kB inactive_anon:2704704kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771468kB mlocked:0kB kernel_stack:16kB pagetables:5276kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.622223] lowmem_reserve[]: 0 0 958 958
[  279.623684] Node 0 Normal free:17212kB min:17700kB low:22124kB high:26548kB active_anon:11304kB inactive_anon:867948kB active_file:16kB inactive_file:8kB unevictable:0kB writepending:20kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:3232kB pagetables:2908kB bounce:0kB free_pcp:704kB local_pcp:688kB free_cma:0kB
[  279.631858] lowmem_reserve[]: 0 0 0 0
[  279.633653] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14804kB
[  279.633675] Node 0 DMA32: 12*4kB (UM) 13*8kB (UM) 11*16kB (UM) 2*32kB (UM) 2*64kB (ME) 0*128kB 0*256kB 5*512kB (UME) 1*1024kB (E) 0*2048kB 12*4096kB (M) = 53256kB
[  279.633685] Node 0 Normal: 263*4kB (UM) 407*8kB (UME) 308*16kB (UMH) 123*32kB (UM) 35*64kB (UMH) 2*128kB (UM) 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 17460kB
[  279.633697] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  279.633698] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  279.633699] 894635 total pagecache pages
[  279.633701] 0 pages in swap cache
[  279.633702] Swap cache stats: add 0, delete 0, find 0/0
[  279.633703] Free swap  = 0kB
[  279.633703] Total swap = 0kB
[  279.633705] 1048445 pages RAM
[  279.633705] 0 pages HighMem/MovableOnly
[  279.633706] 106318 pages reserved
[  279.633706] 0 pages hwpoisoned
[  279.633708] Out of memory: Kill process 8846 (systemd-journal) score 0 or sacrifice child
[  279.633727] Killed process 8846 (systemd-journal) total-vm:36844kB, anon-rss:256kB, file-rss:4kB, shmem-rss:784kB
[  279.633873] oom_reaper: reaped process 8846 (systemd-journal), now anon-rss:0kB, file-rss:0kB, shmem-rss:784kB
[  279.633953] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.633954] a.out cpuset=/ mems_allowed=0
[  279.633960] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688
[  279.633961] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  279.633962] Call Trace:
[  279.633971]  dump_stack+0x5f/0x86
[  279.633974]  dump_header+0x69/0x431
[  279.633979]  ? trace_hardirqs_on_caller+0xe7/0x180
[  279.633992]  oom_kill_process+0x207/0x210
[  279.633996]  out_of_memory+0x229/0x720
[  279.634000]  __alloc_pages_nodemask+0x1267/0x1400
[  279.634017]  alloc_pages_vma+0x7b/0x1c0
[  279.634022]  shmem_alloc_page+0x70/0xb0
[  279.634026]  ? lock_acquire+0x98/0x1e0
[  279.634029]  ? find_get_entry+0x143/0x210
[  279.634035]  ? find_get_entry+0x160/0x210
[  279.634037]  shmem_alloc_and_acct_page+0x77/0x1d0
[  279.634041]  shmem_getpage_gfp+0x18f/0xd20
[  279.634046]  ? mark_lock+0x590/0x620
[  279.634050]  shmem_fault+0x97/0x1f0
[  279.634054]  ? file_update_time+0x5b/0x120
[  279.634058]  __do_fault+0x15/0xa0
[  279.634060]  __handle_mm_fault+0x932/0x1130
[  279.634068]  handle_mm_fault+0x173/0x330
[  279.634071]  __do_page_fault+0x2a7/0x510
[  279.634076]  do_page_fault+0x2c/0x2b0
[  279.634080]  page_fault+0x2c/0x60
[  279.634082] RIP: 0010:__clear_user+0x38/0x60
[  279.634083] RSP: 0018:ffffc90001f0fda8 EFLAGS: 00010206
[  279.634093] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000200
[  279.634093] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f9da4a86000
[  279.634094] RBP: 00007f9da4a86000 R08: 0000000040000000 R09: 0000000000000000
[  279.634095] R10: ffffc90001f0fe30 R11: ffff880132d5dd00 R12: ffffc90001f0fe48
[  279.634095] R13: 0000000000001000 R14: 00007f9d6ec7e000 R15: ffffc90001f0fe80
[  279.634102]  ? __clear_user+0x19/0x60
[  279.634105]  iov_iter_zero+0x84/0x390
[  279.634111]  read_iter_zero+0x33/0x80
[  279.634114]  __vfs_read+0xe6/0x150
[  279.634120]  vfs_read+0x8c/0x130
[  279.634122]  SyS_read+0x50/0xc0
[  279.634124]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  279.634126]  do_syscall_64+0x5b/0x220
[  279.634129]  entry_SYSCALL64_slow_path+0x25/0x25
[  279.634130] RIP: 0033:0x7f9e2ed677e0
[  279.634131] RSP: 002b:00007f9e2f25ffd8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  279.634132] RAX: ffffffffffffffda RBX: 00007f9d6ec7e000 RCX: 00007f9e2ed677e0
[  279.634133] RDX: 0000000040000000 RSI: 00007f9d6ec7e000 RDI: 0000000000000007
[  279.634133] RBP: 0000000000000007 R08: ffffffffffffffff R09: 0000000000000000
[  279.634134] R10: 0000000000000021 R11: 0000000000000246 R12: 00000000004007cb
[  279.634134] R13: 00007ffdee065800 R14: 0000000000000000 R15: 0000000000000000
[  279.634140] Mem-Info:
[  279.634143] active_anon:2825 inactive_anon:893434 isolated_anon:0
[  279.634143]  active_file:6 inactive_file:0 isolated_file:0
[  279.634143]  unevictable:0 dirty:4 writeback:1 unstable:0
[  279.634143]  slab_reclaimable:5634 slab_unreclaimable:6207
[  279.634143]  mapped:880403 shmem:894629 pagetables:2046 bounce:0
[  279.634143]  free:21431 free_pcp:178 free_cma:0
[  279.634145] Node 0 active_anon:11300kB inactive_anon:3573736kB active_file:24kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3521612kB dirty:16kB writeback:4kB shmem:3578516kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  279.634145] Node 0 DMA free:14804kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:1084kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.634148] lowmem_reserve[]: 0 2684 3642 3642
[  279.634150] Node 0 DMA32 free:53256kB min:49592kB low:61988kB high:74384kB active_anon:380kB inactive_anon:2704704kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771468kB mlocked:0kB kernel_stack:16kB pagetables:5276kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.634153] lowmem_reserve[]: 0 0 958 958
[  279.634155] Node 0 Normal free:17664kB min:17700kB low:22124kB high:26548kB active_anon:10884kB inactive_anon:867948kB active_file:24kB inactive_file:0kB unevictable:0kB writepending:20kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:3232kB pagetables:2908kB bounce:0kB free_pcp:712kB local_pcp:696kB free_cma:0kB
[  279.634157] lowmem_reserve[]: 0 0 0 0
[  279.634159] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14804kB
[  279.634169] Node 0 DMA32: 12*4kB (UM) 13*8kB (UM) 11*16kB (UM) 2*32kB (UM) 2*64kB (ME) 0*128kB 0*256kB 5*512kB (UME) 1*1024kB (E) 0*2048kB 12*4096kB (M) = 53256kB
[  279.634178] Node 0 Normal: 301*4kB (UM) 419*8kB (UME) 308*16kB (UMH) 123*32kB (UM) 35*64kB (UMH) 2*128kB (UM) 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 17708kB
[  279.634188] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  279.634189] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  279.634190] 894635 total pagecache pages
[  279.634191] 0 pages in swap cache
[  279.634192] Swap cache stats: add 0, delete 0, find 0/0
[  279.634192] Free swap  = 0kB
[  279.634193] Total swap = 0kB
[  279.634194] 1048445 pages RAM
[  279.634194] 0 pages HighMem/MovableOnly
[  279.634194] 106318 pages reserved
[  279.634195] 0 pages hwpoisoned
[  279.634196] Out of memory: Kill process 8793 (login) score 0 or sacrifice child
[  279.634223] Killed process 8802 (bash) total-vm:115520kB, anon-rss:524kB, file-rss:0kB, shmem-rss:0kB
[  279.634353] oom_reaper: reaped process 8802 (bash), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  279.634393] a.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  279.634394] a.out cpuset=/ mems_allowed=0
[  279.634397] CPU: 0 PID: 8859 Comm: a.out Not tainted 4.15.0-rc6-next-20180105 #688
[  279.634398] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  279.634398] Call Trace:
[  279.634402]  dump_stack+0x5f/0x86
[  279.634404]  dump_header+0x69/0x431
[  279.634407]  ? trace_hardirqs_on_caller+0xe7/0x180
[  279.634411]  oom_kill_process+0x207/0x210
[  279.634414]  out_of_memory+0x229/0x720
[  279.634417]  __alloc_pages_nodemask+0x1267/0x1400
[  279.634431]  alloc_pages_vma+0x7b/0x1c0
[  279.634434]  shmem_alloc_page+0x70/0xb0
[  279.634438]  ? lock_acquire+0x98/0x1e0
[  279.634441]  ? find_get_entry+0x143/0x210
[  279.634445]  ? find_get_entry+0x160/0x210
[  279.634447]  shmem_alloc_and_acct_page+0x77/0x1d0
[  279.634450]  shmem_getpage_gfp+0x18f/0xd20
[  279.634456]  ? mark_lock+0x590/0x620
[  279.634460]  shmem_fault+0x97/0x1f0
[  279.634463]  ? file_update_time+0x5b/0x120
[  279.634466]  __do_fault+0x15/0xa0
[  279.634468]  __handle_mm_fault+0x932/0x1130
[  279.634476]  handle_mm_fault+0x173/0x330
[  279.634479]  __do_page_fault+0x2a7/0x510
[  279.634484]  do_page_fault+0x2c/0x2b0
[  279.634500]  page_fault+0x2c/0x60
[  279.634501] RIP: 0010:__clear_user+0x38/0x60
[  279.634502] RSP: 0018:ffffc90001f0fda8 EFLAGS: 00010206
[  279.634503] RAX: 0000000000000000 RBX: 0000000000000200 RCX: 0000000000000200
[  279.634503] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00007f9da4a86000
[  279.634504] RBP: 00007f9da4a86000 R08: 0000000040000000 R09: 0000000000000000
[  279.634505] R10: ffffc90001f0fe30 R11: ffff880132d5dd00 R12: ffffc90001f0fe48
[  279.634505] R13: 0000000000001000 R14: 00007f9d6ec7e000 R15: ffffc90001f0fe80
[  279.634512]  ? __clear_user+0x19/0x60
[  279.634514]  iov_iter_zero+0x84/0x390
[  279.634519]  read_iter_zero+0x33/0x80
[  279.634522]  __vfs_read+0xe6/0x150
[  279.634527]  vfs_read+0x8c/0x130
[  279.634530]  SyS_read+0x50/0xc0
[  279.634531]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  279.634534]  do_syscall_64+0x5b/0x220
[  279.634536]  entry_SYSCALL64_slow_path+0x25/0x25
[  279.634537] RIP: 0033:0x7f9e2ed677e0
[  279.634538] RSP: 002b:00007f9e2f25ffd8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  279.634539] RAX: ffffffffffffffda RBX: 00007f9d6ec7e000 RCX: 00007f9e2ed677e0
[  279.634540] RDX: 0000000040000000 RSI: 00007f9d6ec7e000 RDI: 0000000000000007
[  279.634540] RBP: 0000000000000007 R08: ffffffffffffffff R09: 0000000000000000
[  279.634541] R10: 0000000000000021 R11: 0000000000000246 R12: 00000000004007cb
[  279.634541] R13: 00007ffdee065800 R14: 0000000000000000 R15: 0000000000000000
[  279.635151] Mem-Info:
[  279.635153] active_anon:2677 inactive_anon:893434 isolated_anon:0
[  279.635153]  active_file:6 inactive_file:0 isolated_file:0
[  279.635153]  unevictable:0 dirty:4 writeback:1 unstable:0
[  279.635153]  slab_reclaimable:5634 slab_unreclaimable:6207
[  279.635153]  mapped:880403 shmem:894629 pagetables:2046 bounce:0
[  279.635153]  free:21425 free_pcp:334 free_cma:0
[  279.635155] Node 0 active_anon:10708kB inactive_anon:3573736kB active_file:24kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3521612kB dirty:16kB writeback:4kB shmem:3578516kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  279.635156] Node 0 DMA free:14804kB min:284kB low:352kB high:420kB active_anon:0kB inactive_anon:1084kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.635158] lowmem_reserve[]: 0 2684 3642 3642
[  279.635161] Node 0 DMA32 free:53256kB min:49592kB low:61988kB high:74384kB active_anon:380kB inactive_anon:2704704kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2771468kB mlocked:0kB kernel_stack:16kB pagetables:5276kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  279.635163] lowmem_reserve[]: 0 0 958 958
[  279.635165] Node 0 Normal free:17640kB min:17700kB low:22124kB high:26548kB active_anon:10384kB inactive_anon:867948kB active_file:24kB inactive_file:0kB unevictable:0kB writepending:20kB present:1048576kB managed:981136kB mlocked:0kB kernel_stack:3232kB pagetables:2908kB bounce:0kB free_pcp:1336kB local_pcp:652kB free_cma:0kB
[  279.635168] lowmem_reserve[]: 0 0 0 0
[  279.635170] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (ME) = 14804kB
[  279.635180] Node 0 DMA32: 12*4kB (UM) 13*8kB (UM) 11*16kB (UM) 2*32kB (UM) 2*64kB (ME) 0*128kB 0*256kB 5*512kB (UME) 1*1024kB (E) 0*2048kB 12*4096kB (M) = 53256kB
[  279.635190] Node 0 Normal: 297*4kB (UM) 421*8kB (UME) 308*16kB (UMH) 123*32kB (UM) 35*64kB (UMH) 2*128kB (UM) 1*256kB (H) 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 17708kB
[  279.635201] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  279.635202] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  279.635202] 894635 total pagecache pages
[  279.635204] 0 pages in swap cache
[  279.635205] Swap cache stats: add 0, delete 0, find 0/0
[  279.635205] Free swap  = 0kB
[  279.635206] Total swap = 0kB
[  279.635206] 1048445 pages RAM
[  279.635207] 0 pages HighMem/MovableOnly
[  279.635207] 106318 pages reserved
[  279.635208] 0 pages hwpoisoned
[  279.635209] Out of memory: Kill process 8793 (login) score 0 or sacrifice child
[  279.635213] Killed process 8793 (login) total-vm:94940kB, anon-rss:676kB, file-rss:4kB, shmem-rss:0kB
[  279.635457] oom_reaper: reaped process 8793 (login), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------------------------------------



>From c89dbc3ca71846694886e8972785f71b1dc226b0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 6 Jan 2018 16:23:20 +0900
Subject: [PATCH v2] mm,oom: Set ->signal->oom_mm to all thread groups sharing victim's memory.

When the OOM reaper set MMF_OOM_SKIP on the victim's mm before threads
sharing that mm get ->signal->oom_mm, the comment "That thread will now
get access to memory reserves since it has a pending fatal signal." no
longer stands. It was demonstrated by a test case that the race window
causes the OOM victims to kill more processes than they need.

Also, since we introduced ALLOC_OOM watermark, the comment "They don't
get access to memory reserves, though, to avoid depletion of all memory."
no longer stands.

This patch treats all thread groups sharing the victim's mm evenly,
and updates the outdated comment.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 46 +++++++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 21 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..3ed3f3a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -834,7 +834,7 @@ static bool task_will_free_mem(struct task_struct *task)
 	return ret;
 }
 
-static void __oom_kill_process(struct task_struct *victim)
+static void __oom_kill_process(struct task_struct *victim, const bool silent)
 {
 	struct task_struct *p;
 	struct mm_struct *mm;
@@ -876,24 +876,25 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	if (!silent)
+		pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+		       task_pid_nr(victim), victim->comm, K(mm->total_vm),
+		       K(get_mm_counter(mm, MM_ANONPAGES)),
+		       K(get_mm_counter(mm, MM_FILEPAGES)),
+		       K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
-	 * Kill all user processes sharing victim->mm in other thread groups, if
-	 * any.  They don't get access to memory reserves, though, to avoid
-	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
-	 * oom killed thread cannot exit because it requires the semaphore and
-	 * its contended by another thread trying to allocate memory itself.
-	 * That thread will now get access to memory reserves since it has a
-	 * pending fatal signal.
+	 * Kill (and mark as OOM victim) all user processes sharing this mm.
+	 * This helps the OOM reaper to reclaim memory by interrupting threads
+	 * waiting or holding mm->mmap_sem for write, and also ensures that OOM
+	 * victims can try ALLOC_OOM allocation even if the OOM reaper
+	 * reclaimed before OOM victims calls mark_oom_victim(current).
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
+		struct task_struct *t;
+
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (same_thread_group(p, victim))
@@ -913,6 +914,11 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		t = find_lock_task_mm(p);
+		if (t) {
+			mark_oom_victim(t);
+			task_unlock(t);
+		}
 	}
 	rcu_read_unlock();
 
@@ -942,10 +948,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
 		task_unlock(p);
-		put_task_struct(p);
+		__oom_kill_process(p, true);
 		return;
 	}
 	task_unlock(p);
@@ -984,13 +988,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	read_unlock(&tasklist_lock);
 
-	__oom_kill_process(victim);
+	__oom_kill_process(victim, false);
 }
 
 static int oom_kill_memcg_member(struct task_struct *task, void *unused)
 {
 	get_task_struct(task);
-	__oom_kill_process(task);
+	__oom_kill_process(task, false);
 	return 0;
 }
 
@@ -1018,7 +1022,7 @@ static bool oom_kill_memcg_victim(struct oom_control *oc)
 		    oc->chosen_task == INFLIGHT_VICTIM)
 			goto out;
 
-		__oom_kill_process(oc->chosen_task);
+		__oom_kill_process(oc->chosen_task, false);
 	}
 
 out:
@@ -1096,8 +1100,8 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		get_task_struct(current);
+		__oom_kill_process(current, true);
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
