Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 74C636B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:06:55 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so122323899pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:06:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id tg10si32638201pbc.171.2015.08.25.05.06.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 05:06:54 -0700 (PDT)
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
	<20150824094718.GF17078@dhcp22.suse.cz>
In-Reply-To: <20150824094718.GF17078@dhcp22.suse.cz>
Message-Id: <201508252106.JIE81718.FHOOFSJFMQLtOV@I-love.SAKURA.ne.jp>
Date: Tue, 25 Aug 2015 21:06:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5249e7e..c0a5a69 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -555,12 +555,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	/* Get a reference to safely compare mm after task_unlock(victim) */
> >  	mm = victim->mm;
> >  	atomic_inc(&mm->mm_users);
> > -	mark_oom_victim(victim);
> >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> >  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> >  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> >  		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> >  	task_unlock(victim);
> > +	/* Send SIGKILL before setting TIF_MEMDIE. */
> > +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> > +	task_lock(victim);
> > +	if (victim->mm)
> > +		mark_oom_victim(victim);
> > +	task_unlock(victim);
> 
> Why cannot you simply move do_send_sig_info without touching
> mark_oom_victim? Are you still able to trigger the issue if you just
> kill before crawling through all the tasks sharing the mm?

If you meant

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..ea578fb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -560,6 +560,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
                K(get_mm_counter(victim->mm, MM_ANONPAGES)),
                K(get_mm_counter(victim->mm, MM_FILEPAGES)));
        task_unlock(victim);
+       do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);

        /*
         * Kill all user processes sharing victim->mm in other thread groups, if
@@ -585,7 +586,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
                }
        rcu_read_unlock();

-       do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
        put_task_struct(victim);
 }
 #undef K

then yes I still can trigger the issue under very limited condition (i.e.
ran as root user for polling kernel messages with realtime priority, after
killing all processes using SysRq-i).

---------- oom-depleter2.c start ----------
#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <sys/klog.h>

static int zero_fd = -1;
static char *buf = NULL;
static unsigned long size = 0;

static int trigger(void *unused)
{
        {
                struct sched_param sp = { };
                sched_setscheduler(0, SCHED_IDLE, &sp);
        }
        read(zero_fd, buf, size); /* Will cause OOM due to overcommit */
        return 0;
}

int main(int argc, char *argv[])
{
        unsigned long i;
        zero_fd = open("/dev/zero", O_RDONLY);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        /* Let a child thread trigger the OOM killer. */
        clone(trigger, malloc(4096) + 4096, CLONE_SIGHAND | CLONE_VM, NULL);
        {
                struct sched_param sp = { 99 };
                sched_setscheduler(0, SCHED_FIFO, &sp);
        }
        /* Wait until the OOM killer messages appear. */
        while (1) {
                i = klogctl(2, buf, size - 1);
                if (i > 0) {
                        buf[i] = '\0';
                        if (strstr(buf, "Killed process "))
                                break;
                }
        }
        /* Deplete all memory reserve. */
        for (i = size; i; i -= 4096)
                buf[i - 1] = 1;
        return * (char *) NULL; /* Kill all threads. */
}
---------- oom-depleter2.c start ----------

# taskset -c 0 ./oom-depleter2

(Intentionally running two threads with different priority on the same CPU
 in order to increase possibility of invoking preemption.)

---------- console log start ----------
[   47.069197] oom-depleter2 invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[   47.070651] oom-depleter2 cpuset=/ mems_allowed=0
[   47.072982] CPU: 0 PID: 3851 Comm: oom-depleter2 Tainted: G        W       4.2.0-rc7-next-20150824+ #85
[   47.074683] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   47.076583]  0000000000000000 00000000115c5c6c ffff88007ca2f8c8 ffffffff81313283
[   47.078014]  ffff88007890f2c0 ffff88007ca2f970 ffffffff8117ff7d 0000000000000000
[   47.079438]  0000000000000202 0000000000000018 0000000000000001 0000000000000202
[   47.080856] Call Trace:
[   47.081335]  [<ffffffff81313283>] dump_stack+0x4b/0x78
[   47.082233]  [<ffffffff8117ff7d>] dump_header+0x82/0x232
[   47.083234]  [<ffffffff81627645>] ? _raw_spin_unlock_irqrestore+0x25/0x30
[   47.084447]  [<ffffffff810fe041>] ? delayacct_end+0x51/0x60
[   47.085483]  [<ffffffff81114fd2>] oom_kill_process+0x372/0x3c0
[   47.086551]  [<ffffffff81071cd0>] ? has_ns_capability_noaudit+0x30/0x40
[   47.087715]  [<ffffffff81071cf2>] ? has_capability_noaudit+0x12/0x20
[   47.088874]  [<ffffffff8111528d>] out_of_memory+0x21d/0x4a0
[   47.089915]  [<ffffffff8111a774>] __alloc_pages_nodemask+0x904/0x930
[   47.091010]  [<ffffffff8115d080>] alloc_pages_vma+0xb0/0x1f0
[   47.092042]  [<ffffffff8113df77>] handle_mm_fault+0x13a7/0x1950
[   47.093076]  [<ffffffff816287cd>] ? retint_kernel+0x1b/0x1d
[   47.094108]  [<ffffffff81628837>] ? native_iret+0x7/0x7
[   47.095108]  [<ffffffff810565bb>] __do_page_fault+0x18b/0x440
[   47.096109]  [<ffffffff810568a0>] do_page_fault+0x30/0x80
[   47.097052]  [<ffffffff816297e8>] page_fault+0x28/0x30
[   47.098544]  [<ffffffff81320ae0>] ? __clear_user+0x20/0x50
[   47.099651]  [<ffffffff813254b8>] iov_iter_zero+0x68/0x250
[   47.100642]  [<ffffffff810920f6>] ? sched_clock_cpu+0x86/0xc0
[   47.101701]  [<ffffffff813f9018>] read_iter_zero+0x38/0xa0
[   47.102754]  [<ffffffff81183ec4>] __vfs_read+0xc4/0xf0
[   47.103684]  [<ffffffff81184639>] vfs_read+0x79/0x120
[   47.104630]  [<ffffffff81185350>] SyS_read+0x50/0xc0
[   47.105503]  [<ffffffff8108bd9c>] ? do_sched_setscheduler+0x7c/0xb0
[   47.106637]  [<ffffffff81627cae>] entry_SYSCALL_64_fastpath+0x12/0x71
[   47.109307] Mem-Info:
[   47.109801] active_anon:416244 inactive_anon:3737 isolated_anon:0
[   47.109801]  active_file:0 inactive_file:474 isolated_file:0
[   47.109801]  unevictable:0 dirty:0 writeback:0 unstable:0
[   47.109801]  slab_reclaimable:1114 slab_unreclaimable:3896
[   47.109801]  mapped:96 shmem:4188 pagetables:1014 bounce:0
[   47.109801]  free:12368 free_pcp:183 free_cma:0
[   47.118364] Node 0 DMA free:7316kB min:400kB low:500kB high:600kB active_anon:7056kB inactive_anon:232kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:296kB slab_reclaimable:52kB slab_unreclaimable:216kB kernel_stack:16kB pagetables:308kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:28 all_unreclaimable? yes
[   47.129538] lowmem_reserve[]: 0 1731 1731 1731
[   47.131230] Node 0 DMA32 free:44016kB min:44652kB low:55812kB high:66976kB active_anon:1657920kB inactive_anon:14716kB active_file:0kB inactive_file:32kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774256kB mlocked:0kB dirty:0kB writeback:0kB mapped:384kB shmem:16456kB slab_reclaimable:4404kB slab_unreclaimable:15368kB kernel_stack:3264kB pagetables:3748kB unstable:0kB bounce:0kB free_pcp:796kB local_pcp:56kB free_cma:0kB writeback_tmp:0kB pages_scanned:124 all_unreclaimable? no
[   47.143246] lowmem_reserve[]: 0 0 0 0
[   47.145175] Node 0 DMA: 17*4kB (UE) 9*8kB (UE) 9*16kB (UEM) 1*32kB (M) 1*64kB (M) 2*128kB (UE) 2*256kB (EM) 2*512kB (EM) 1*1024kB (E) 2*2048kB (EM) 0*4096kB = 7292kB
[   47.152896] Node 0 DMA32: 1009*4kB (UEM) 617*8kB (UEM) 268*16kB (UEM) 118*32kB (UEM) 43*64kB (UEM) 13*128kB (UEM) 11*256kB (UEM) 10*512kB (UM) 12*1024kB (UM) 1*2048kB (U) 0*4096kB = 43724kB
[   47.161214] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   47.163987] 4649 total pagecache pages
[   47.166121] 0 pages in swap cache
[   47.168500] Swap cache stats: add 0, delete 0, find 0/0
[   47.170238] Free swap  = 0kB
[   47.171764] Total swap = 0kB
[   47.173270] 524157 pages RAM
[   47.174520] 0 pages HighMem/MovableOnly
[   47.175930] 76617 pages reserved
[   47.178043] 0 pages hwpoisoned
[   47.179584] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   47.182065] [ 3820]     0  3820    10756      168      24       3        0             0 systemd-journal
[   47.184504] [ 3823]     0  3823    10262      101      23       3        0         -1000 systemd-udevd
[   47.186847] [ 3824]     0  3824    27503       33      12       3        0             0 agetty
[   47.189291] [ 3825]     0  3825     8673       84      23       3        0             0 systemd-logind
[   47.191691] [ 3826]     0  3826    21787      154      48       3        0             0 login
[   47.193959] [ 3828]    81  3828     6609       82      18       3        0          -900 dbus-daemon
[   47.196297] [ 3831]     0  3831    28878       93      15       3        0             0 bash
[   47.198573] [ 3850]     0  3850   541715   414661     820       6        0             0 oom-depleter2
[   47.200915] [ 3851]     0  3851   541715   414661     820       6        0             0 oom-depleter2
[   47.203410] Out of memory: Kill process 3850 (oom-depleter2) score 900 or sacrifice child
[   47.205695] Killed process 3850 (oom-depleter2) total-vm:2166860kB, anon-rss:1658644kB, file-rss:0kB
[   47.257871] oom-depleter2: page allocation failure: order:0, mode:0x280da
[   47.260006] CPU: 0 PID: 3850 Comm: oom-depleter2 Tainted: G        W       4.2.0-rc7-next-20150824+ #85
[   47.262473] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   47.265184]  0000000000000000 000000000f39672f ffff880036febbe0 ffffffff81313283
[   47.267511]  00000000000280da ffff880036febc70 ffffffff81116e04 0000000000000000
[   47.269815]  ffffffff00000000 ffff88007fc19730 ffff880000000004 ffffffff810a30cf
[   47.272019] Call Trace:
[   47.273283]  [<ffffffff81313283>] dump_stack+0x4b/0x78
[   47.275081]  [<ffffffff81116e04>] warn_alloc_failed+0xf4/0x150
[   47.276962]  [<ffffffff810a30cf>] ? __wake_up+0x3f/0x50
[   47.278700]  [<ffffffff8111a0bc>] __alloc_pages_nodemask+0x24c/0x930
[   47.280664]  [<ffffffff8115d080>] alloc_pages_vma+0xb0/0x1f0
[   47.282422]  [<ffffffff8113df77>] handle_mm_fault+0x13a7/0x1950
[   47.284240]  [<ffffffff810565bb>] __do_page_fault+0x18b/0x440
[   47.286036]  [<ffffffff810568a0>] do_page_fault+0x30/0x80
[   47.287693]  [<ffffffff816297e8>] page_fault+0x28/0x30
[   47.289358] Mem-Info:
[   47.290494] active_anon:429031 inactive_anon:3737 isolated_anon:0
[   47.290494]  active_file:0 inactive_file:0 isolated_file:0
[   47.290494]  unevictable:0 dirty:0 writeback:0 unstable:0
[   47.290494]  slab_reclaimable:1114 slab_unreclaimable:3896
[   47.290494]  mapped:96 shmem:4188 pagetables:1014 bounce:0
[   47.290494]  free:0 free_pcp:180 free_cma:0
[   47.299662] Node 0 DMA free:8kB min:400kB low:500kB high:600kB active_anon:14308kB inactive_anon:232kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:296kB slab_reclaimable:52kB slab_unreclaimable:216kB kernel_stack:16kB pagetables:308kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:28 all_unreclaimable? yes
[   47.309430] lowmem_reserve[]: 0 1731 1731 1731
[   47.311000] Node 0 DMA32 free:0kB min:44652kB low:55812kB high:66976kB active_anon:1701816kB inactive_anon:14716kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1774256kB mlocked:0kB dirty:0kB writeback:0kB mapped:384kB shmem:16456kB slab_reclaimable:4404kB slab_unreclaimable:15368kB kernel_stack:3264kB pagetables:3748kB unstable:0kB bounce:0kB free_pcp:720kB local_pcp:24kB free_cma:0kB writeback_tmp:0kB pages_scanned:5584 all_unreclaimable? yes
[   47.321601] lowmem_reserve[]: 0 0 0 0
[   47.323166] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   47.326070] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   47.329018] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   47.331385] 4189 total pagecache pages
[   47.332896] 0 pages in swap cache
[   47.334262] Swap cache stats: add 0, delete 0, find 0/0
[   47.335990] Free swap  = 0kB
[   47.337390] Total swap = 0kB
[   47.338656] 524157 pages RAM
[   47.339964] 0 pages HighMem/MovableOnly
[   47.341464] 76617 pages reserved
[   47.342808] 0 pages hwpoisoned
(...snipped...)
[   93.082032] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   93.082034] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
---------- console log end ----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20150825.txt.xz .

> 
> The code would be easier then and the race window much smaller. If we
> really needed to prevent from preemption then preempt_{enable,disable}
> aournd the whole task_lock region + do_send_sig_info would be still
> easier to follow than re-taking task_lock.

What's wrong with re-taking task_lock? It seems to me that re-taking
task_lock is more straightforward and easier to follow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
