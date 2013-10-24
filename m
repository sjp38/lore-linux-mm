Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC3D16B0082
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 13:39:49 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un1so2951597pbc.19
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:39:49 -0700 (PDT)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id hb3si2494704pac.326.2013.10.24.10.39.46
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 10:39:47 -0700 (PDT)
Date: Thu, 24 Oct 2013 13:39:38 -0400 (EDT)
From: Mark Hills <mark@xwax.org>
Subject: Re: ps lockups, cgroup memory reclaim
In-Reply-To: <1309180141270.29932@wes.ijneb.com>
Message-ID: <1310241253140.26474@wes.ijneb.com>
References: <1309171621250.11844@wes.ijneb.com> <20130917162807.GF3278@cmpxchg.org> <1309180141270.29932@wes.ijneb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

On Wed, 18 Sep 2013, Mark Hills wrote:

> On Tue, 17 Sep 2013, Johannes Weiner wrote:
> 
> > On Tue, Sep 17, 2013 at 04:50:42PM +0100, Mark Hills wrote:
> > > I'm investigating intermitten kernel lockups in an HPC environment, with 
> > > the RedHat kernel.
> > > 
> > > The symptoms are seen as lockups of multiple ps commands, with one 
> > > consuming full CPU:
> > > 
> > >   # ps aux | grep ps
> > >   root     19557 68.9  0.0 108100   908 ?        D    Sep16 1045:37 ps --ppid 1 -o args=
> > >   root     19871  0.0  0.0 108100   908 ?        D    Sep16   0:00 ps --ppid 1 -o args=
> > > 
> > > SIGKILL on the busy one causes the other ps processes to run to completion 
> > > (TERM has no effect).
> > 
> > Any chance you can get to the stack of the non-busy blocked tasks?
> > 
> > It would be /proc/19871/stack in this case.
> 
> I had to return the machine above to the cluster, but next time I'll log 
> this information.
>  
> > > In this case I was able to run my own ps to see the process list, 
> > > but not always.
> > > 
> > > perf shows the locality of the spinning, roughly:
> > > 
> > >   proc_pid_cmdline
> > >   get_user_pages
> > >   handle_mm_fault
> > >   mem_cgroup_try_charge_swapin
> > >   mem_cgroup_reclaim
> > > 
> > > There are two entry points, the codepaths taken are better shown by 
> > > the attached profile of CPU time.
> > 
> > Looks like it's spinning like crazy in shrink_mem_cgroup_zone(). Maybe 
> > an LRU counter underflow, maybe endlessly looping on the 
> > should_continue_reclaim() compaction condition.  But I don't see an 
> > obvious connection to why killing the busy task wakes up the blocked 
> > one.
> 
> Maybe it's as simple as the lock taken at quite a high level; perhaps even 
> a lock when reading values for /proc.
> 
> But no need for me to guess, we'll find out next time from the /proc 
> information.
>  
> > So yeah, it would be helpful to know what that task is waiting for.
> > 
> > > We've had this behaviour since switching to Scientific Linux 6 (based on 
> > > RHEL6, like CentOS) at kernel 2.6.32-279.9.1.el6.x86_64.
> > > 
> > > The example above is kernel 2.6.32-358.el6.x86_64.
> > 
> > Can you test with the debug build?  That should trap LRU counter
> > underflows at least.
> 
> Ah, excellent -- I did not realise there was a kernel-debug package.
[...]

Ok, it has taken me a while but I now have some automated capture in place 
and the equivalent packaged debug kernel:

  $ uname -r
  2.6.32-358.el6.x86_64.debug

Here is the initial result. The bad news is that there doesn't appear to 
be an obvious BUG or alert to any kind of overflow.

With this in mind, I noted the times of the OOM-killer (which is operating 
on containers that users run their jobs in).

The most recent is less than 5 minutes before lockup was detected, and my 
detection runs every 5 minutes. I have extracted this below (I can post 
the full dmesg elsewhere if interested)

I assume that trace is of pid 8099 is a thread ID, because this process 
does not reside in the cgroup only PID 7919.

Notably the process requesting the memory is itself the memory hog. The 
cgroup contains only a launching shell and a binary process.

Perhaps an expect can see an immediate bug from the call trace; eg. 
killing a process at an awkward time that would cause some kind of counter 
underflow?

I'm unsure where to go next, given there is no obvious BUG here. I think I 
will look next week to find a reproducable test, perhaps I can simulate 
the same out-of-memory condition.

Thanks

-- 
Mark



frenpic.bin invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
frenpic.bin cpuset=manager-7805 mems_allowed=0-1
Pid: 8099, comm: frenpic.bin Not tainted 2.6.32-358.el6.x86_64.debug #1
Call Trace:
 [<ffffffff81541dcb>] ? _spin_unlock+0x2b/0x40
 [<ffffffff811314f3>] ? dump_header+0x83/0x210
 [<ffffffff810b4ffd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff810b504d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811319f2>] ? oom_kill_process+0x82/0x2f0
 [<ffffffff811321e2>] ? mem_cgroup_out_of_memory+0x92/0xb0
 [<ffffffff8118cff4>] ? mem_cgroup_handle_oom+0x274/0x2a0
 [<ffffffff8118a700>] ? memcg_oom_wake_function+0x0/0xa0
 [<ffffffff8118d5e8>] ? __mem_cgroup_try_charge+0x5c8/0x6b0
 [<ffffffff8118d218>] ? __mem_cgroup_try_charge+0x1f8/0x6b0
 [<ffffffff8118eca0>] ? mem_cgroup_charge_common+0x90/0xd0
 [<ffffffff8118ed28>] ? mem_cgroup_newpage_charge+0x48/0x50
 [<ffffffff8115a05a>] ? handle_pte_fault+0x72a/0xa90
 [<ffffffff810a32bd>] ? sched_clock_cpu+0xcd/0x110
 [<ffffffff8115a5fa>] ? handle_mm_fault+0x23a/0x310
 [<ffffffff81047533>] ? __do_page_fault+0x163/0x4e0
 [<ffffffff810b504d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81541d10>] ? _spin_unlock_irq+0x30/0x40
 [<ffffffff8105c43d>] ? finish_task_switch+0x7d/0x110
 [<ffffffff8105c408>] ? finish_task_switch+0x48/0x110
 [<ffffffff8153e853>] ? thread_return+0x4e/0x7db
 [<ffffffff8100bb10>] ? restore_args+0x0/0x30
 [<ffffffff815457be>] ? do_page_fault+0x3e/0xa0
 [<ffffffff81542905>] ? page_fault+0x25/0x30
Task in /manager-7805 killed as a result of limit of /manager-7805
memory: usage 16381840kB, limit 16384000kB, failcnt 250389
memory+swap: usage 18022400kB, limit 18022400kB, failcnt 1117
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
CPU    8: hi:    0, btch:   1 usd:   0
CPU    9: hi:    0, btch:   1 usd:   0
CPU   10: hi:    0, btch:   1 usd:   0
CPU   11: hi:    0, btch:   1 usd:   0
CPU   12: hi:    0, btch:   1 usd:   0
CPU   13: hi:    0, btch:   1 usd:   0
CPU   14: hi:    0, btch:   1 usd:   0
CPU   15: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
CPU    8: hi:  186, btch:  31 usd: 161
CPU    9: hi:  186, btch:  31 usd: 164
CPU   10: hi:  186, btch:  31 usd: 171
CPU   11: hi:  186, btch:  31 usd: 178
CPU   12: hi:  186, btch:  31 usd:   0
CPU   13: hi:  186, btch:  31 usd:   0
CPU   14: hi:  186, btch:  31 usd:   0
CPU   15: hi:  186, btch:  31 usd:   0
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 175
CPU    1: hi:  186, btch:  31 usd: 120
CPU    2: hi:  186, btch:  31 usd:  77
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:  89
CPU    7: hi:  186, btch:  31 usd:   2
CPU    8: hi:  186, btch:  31 usd:  39
CPU    9: hi:  186, btch:  31 usd: 127
CPU   10: hi:  186, btch:  31 usd:   9
CPU   11: hi:  186, btch:  31 usd: 170
CPU   12: hi:  186, btch:  31 usd:   0
CPU   13: hi:  186, btch:  31 usd:   0
CPU   14: hi:  186, btch:  31 usd: 121
CPU   15: hi:  186, btch:  31 usd:   0
Node 1 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  82
CPU    1: hi:  186, btch:  31 usd: 158
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:  89
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:  30
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:  61
CPU    8: hi:  186, btch:  31 usd: 180
CPU    9: hi:  186, btch:  31 usd: 103
CPU   10: hi:  186, btch:  31 usd: 162
CPU   11: hi:  186, btch:  31 usd:  42
CPU   12: hi:  186, btch:  31 usd:   0
CPU   13: hi:  186, btch:  31 usd:   0
CPU   14: hi:  186, btch:  31 usd:   0
CPU   15: hi:  186, btch:  31 usd:  98
active_anon:7716448 inactive_anon:1137356 isolated_anon:128
 active_file:2563426 inactive_file:3632112 isolated_file:0
 unevictable:0 dirty:0 writeback:1676 unstable:0
 free:1033107 slab_reclaimable:222717 slab_unreclaimable:21054
 mapped:12050 shmem:18 pagetables:20595 bounce:0
Node 0 DMA free:15736kB min:20kB low:24kB high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15352kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 3179 32216 32216
Node 0 DMA32 free:1395136kB min:4436kB low:5544kB high:6652kB active_anon:780288kB inactive_anon:376980kB active_file:6968kB inactive_file:25896kB unevictable:0kB isolated(anon):512kB isolated(file):0kB present:3255392kB mlocked:0kB dirty:0kB writeback:6700kB mapped:492kB shmem:0kB slab_reclaimable:3356kB slab_unreclaimable:408kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 29037 29037
Node 0 Normal free:694076kB min:40532kB low:50664kB high:60796kB active_anon:14153412kB inactive_anon:1905888kB active_file:5255884kB inactive_file:7325488kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:29734400kB mlocked:0kB dirty:0kB writeback:0kB mapped:20016kB shmem:68kB slab_reclaimable:533876kB slab_unreclaimable:42860kB kernel_stack:2840kB pagetables:34016kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 1 Normal free:2027480kB min:45116kB low:56392kB high:67672kB active_anon:15932092kB inactive_anon:2266556kB active_file:4990852kB inactive_file:7177064kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:33095680kB mlocked:0kB dirty:0kB writeback:4kB mapped:27692kB shmem:4kB slab_reclaimable:353636kB slab_unreclaimable:40948kB kernel_stack:528kB pagetables:48364kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 2*4kB 2*8kB 2*16kB 2*32kB 2*64kB 1*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15736kB
Node 0 DMA32: 676*4kB 716*8kB 493*16kB 482*32kB 331*64kB 314*128kB 194*256kB 74*512kB 90*1024kB 32*2048kB 258*4096kB = 1395136kB
Node 0 Normal: 409*4kB 355*8kB 360*16kB 90*32kB 48*64kB 1070*128kB 951*256kB 307*512kB 137*1024kB 0*2048kB 0*4096kB = 694076kB
Node 1 Normal: 2112*4kB 480*8kB 251*16kB 65*32kB 40*64kB 18*128kB 1522*256kB 1826*512kB 664*1024kB 0*2048kB 0*4096kB = 2027728kB
6319722 total pagecache pages
124333 pages in swap cache
Swap cache stats: add 8249007, delete 8124674, find 737685/862651
Free swap  = 29529892kB
Total swap = 33013752kB
16777215 pages RAM
322632 pages reserved
176578 pages shared
15249459 pages non-shared
[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[ 7806] 243986  7806    28804      507   9       0             0 tcsh
[ 7919] 243986  7919  5133045  4096768   9       0             0 frenpic.bin
Memory cgroup out of memory: Kill process 7919 (frenpic.bin) score 1000 or sacrifice child
Killed process 7919, UID 243986, (frenpic.bin) total-vm:20532180kB, anon-rss:16373904kB, file-rss:13168kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
