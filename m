Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1FD6B0292
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 22:58:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n13so95261451ita.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 19:58:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 70si4457960itp.90.2017.06.02.19.58.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 19:58:02 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
	<20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
In-Reply-To: <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
Message-Id: <201706031157.JCC51567.LOFSQHVMOJFtOF@I-love.SAKURA.ne.jp>
Date: Sat, 3 Jun 2017 11:57:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com, akataria@vmware.com, syeh@vmware.com, thellstrom@vmware.com, charmainel@vmware.com, brianp@vmware.com, sbhatewara@vmware.com

(Adding printk() and VMware folks.)

Andrew Morton wrote:
> On Fri, 2 Jun 2017 09:18:18 +0200 Michal Hocko <mhocko@suse.com> wrote:
>
> > On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > > On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > > > >
> > > > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > > > on the vanilla up-to-date kernel?
> > > > >
> > > > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > > > enterprise distributions would choose for their next long term supported
> > > > > version.
> > > > >
> > > > > And please stop saying "can you reproduce your problem with latest
> > > > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > > > up-to-date kernel!
> > > >
> > > > The changelog mentioned that the source of stalls is not clear so this
> > > > might be out-of-tree patches doing something wrong and dump_stack
> > > > showing up just because it is called often. This wouldn't be the first
> > > > time I have seen something like that. I am not really keen on adding
> > > > heavy lifting for something that is not clearly debugged and based on
> > > > hand waving and speculations.
> > >
> > > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > > output from concurrent calls getting all jumbled together?
> >
> > dump_stack already serializes concurrent calls.

I don't think offloading serialization to dump_stack() is a polite behavior
when the caller can do serialization. Not only it wastes a lot of CPU time
but also just passes the DOS stress through to lower layers. printk() needs
CPU time to write to console.

If printk() flooding starts, I can observe that

   (1) timestamp in printk() output does not get incremented timely

   (2) printk() output is not written to virtual serial console timely

which makes me give up observing whether situation is changing over time.

Results from http://I-love.SAKURA.ne.jp/tmp/serial-20170602-2.txt.xz :
----------------------------------------
[  123.771523] mmap-write invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
[  124.808940] mmap-write cpuset=/ mems_allowed=0
[  124.811595] CPU: 0 PID: 2852 Comm: mmap-write Not tainted 4.12.0-rc3-next-20170602 #99
[  124.815842] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  124.821171] Call Trace:
[  124.823106]  dump_stack+0x86/0xcf
[  124.825336]  dump_header+0x97/0x26d
[  124.827668]  ? trace_hardirqs_on+0xd/0x10
[  124.830222]  oom_kill_process+0x203/0x470
[  124.832778]  out_of_memory+0x138/0x580
[  124.835223]  __alloc_pages_slowpath+0x1100/0x11f0
[  124.838085]  __alloc_pages_nodemask+0x308/0x3c0
[  124.840850]  alloc_pages_current+0x6a/0xe0
[  124.843332]  __page_cache_alloc+0x119/0x150
[  124.845723]  filemap_fault+0x3dc/0x950
[  124.847932]  ? debug_lockdep_rcu_enabled+0x1d/0x20
[  124.850683]  ? xfs_filemap_fault+0x5b/0x180 [xfs]
[  124.853427]  ? down_read_nested+0x73/0xb0
[  124.855792]  xfs_filemap_fault+0x63/0x180 [xfs]
[  124.858327]  __do_fault+0x1e/0x140
[  124.860383]  __handle_mm_fault+0xb2c/0x1090
[  124.862760]  handle_mm_fault+0x190/0x350
[  124.865161]  __do_page_fault+0x266/0x520
[  124.867409]  do_page_fault+0x30/0x80
[  124.869846]  page_fault+0x28/0x30
[  124.871803] RIP: 0033:0x7fb997682dca
[  124.873875] RSP: 002b:0000000000777fe8 EFLAGS: 00010246
[  124.876601] RAX: 00007fb997b6e000 RBX: 0000000000000000 RCX: 00007fb997682dca
[  124.880077] RDX: 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
[  124.883551] RBP: 0000000000001000 R08: 0000000000000003 R09: 0000000000000000
[  124.886933] R10: 0000000000000002 R11: 0000000000000246 R12: 0000000000000002
[  124.890336] R13: 0000000000000000 R14: 0000000000000003 R15: 0000000000000001
[  124.893853] Mem-Info:
[  126.408131] mmap-read: page allocation stalls for 10005ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[  126.408137] mmap-read cpuset=/ mems_allowed=0
(...snipped...)
[  350.182442] mmap-read: page allocation stalls for 230016ms, order:0, mode:0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null)
[  350.182446] mmap-read cpuset=/ mems_allowed=0
[  350.182450] CPU: 0 PID: 2749 Comm: mmap-read Not tainted 4.12.0-rc3-next-20170602 #99
[  350.182451] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  350.182451] Call Trace:
[  350.182455]  dump_stack+0x86/0xcf
[  350.182457]  warn_alloc+0x114/0x1c0
[  350.182466]  __alloc_pages_slowpath+0xbb8/0x11f0
[  350.182481]  __alloc_pages_nodemask+0x308/0x3c0
[  350.182491]  alloc_pages_current+0x6a/0xe0
[  350.182495]  __page_cache_alloc+0x119/0x150
[  350.182498]  filemap_fault+0x3dc/0x950
[  350.182501]  ? debug_lockdep_rcu_enabled+0x1d/0x20
[  350.182525]  ? xfs_filemap_fault+0x5b/0x180 [xfs]
[  350.182528]  ? down_read_nested+0x73/0xb0
[  350.182550]  xfs_filemap_fault+0x63/0x180 [xfs]
[  350.182554]  __do_fault+0x1e/0x140
[  350.182557]  __handle_mm_fault+0xb2c/0x1090
[  350.182566]  handle_mm_fault+0x190/0x350
[  350.182569]  __do_page_fault+0x266/0x520
[  350.182575]  do_page_fault+0x30/0x80
[  350.182578]  page_fault+0x28/0x30
[  350.182580] RIP: 0033:0x400bfb
[  350.182581] RSP: 002b:00000000007cf570 EFLAGS: 00010207
[  350.182582] RAX: 000000000000010d RBX: 0000000000000003 RCX: 00007fb997678443
[  350.182583] RDX: 0000000000001000 RSI: 00000000006021a0 RDI: 0000000000000003
[  350.182583] RBP: 0000000000000000 R08: 0000000000000000 R09: 000000000000000a
[  350.182584] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffd42a62438
[  350.182585] R13: 00007ffd42a62540 R14: 0000000000000000 R15: 0000000000000000
[  350.836483] sysrq: SysRq : Kill All Tasks
[  350.876112] cleanupd (2180) used greatest stack depth: 10240 bytes left
[  351.219055] audit: type=1131 audit(1496388867.600:97): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=systemd-journald comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.219060] audit: type=1131 audit(1496388867.603:98): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=systemd-udevd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.219064] audit: type=1131 audit(1496388867.607:99): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.229083] audit: type=1131 audit(1496388867.610:100): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=abrtd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.229092] audit: type=1131 audit(1496388867.613:101): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=dbus comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.229095] audit: type=1131 audit(1496388867.617:102): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=polkit comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.229636] audit: type=1131 audit(1496388867.621:103): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=avahi-daemon comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.233058] audit: type=1131 audit(1496388867.624:104): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=irqbalance comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.236596] audit: type=1131 audit(1496388867.628:105): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=atd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  351.239144] audit: type=1131 audit(1496388867.630:106): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=crond comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
[  389.308085] active_anon:1146 inactive_anon:2777 isolated_anon:0
[  389.308085]  active_file:479 inactive_file:508 isolated_file:0
[  389.308085]  unevictable:0 dirty:0 writeback:0 unstable:0
[  389.308085]  slab_reclaimable:9536 slab_unreclaimable:15265
[  389.308085]  mapped:629 shmem:3535 pagetables:34 bounce:0
[  389.308085]  free:356689 free_pcp:596 free_cma:0
[  389.308089] Node 0 active_anon:4584kB inactive_anon:11108kB active_file:1916kB inactive_file:2032kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2516kB dirty:0kB writeback:0kB shmem:14140kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  389.308090] Node 0 DMA free:15872kB min:440kB low:548kB high:656kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  389.308093] lowmem_reserve[]: 0 1561 1561 1561
[  389.308097] Node 0 DMA32 free:1410884kB min:44612kB low:55764kB high:66916kB active_anon:4584kB inactive_anon:11108kB active_file:1916kB inactive_file:2032kB unevictable:0kB writepending:0kB present:2080640kB managed:1599404kB mlocked:0kB slab_reclaimable:38144kB slab_unreclaimable:61028kB kernel_stack:3808kB pagetables:136kB bounce:0kB free_pcp:2384kB local_pcp:696kB free_cma:0kB
[  389.308099] lowmem_reserve[]: 0 0 0 0
[  389.308103] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15872kB
[  389.308121] Node 0 DMA32: 975*4kB (UME) 1199*8kB (UME) 1031*16kB (UME) 973*32kB (UME) 564*64kB (UME) 303*128kB (UME) 160*256kB (UME) 70*512kB (UME) 40*1024kB (UME) 21*2048kB (M) 272*4096kB (M) = 1410884kB
[  389.308142] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  389.308143] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  389.308143] 4522 total pagecache pages
[  389.308147] 0 pages in swap cache
[  389.308148] Swap cache stats: add 0, delete 0, find 0/0
[  389.308149] Free swap  = 0kB
[  389.308149] Total swap = 0kB
[  389.308150] 524157 pages RAM
[  389.308151] 0 pages HighMem/MovableOnly
[  389.308152] 120330 pages reserved
[  389.308153] 0 pages cma reserved
[  389.308153] 0 pages hwpoisoned
[  389.308155] Out of memory: Kill process 2649 (mmap-mem) score 783 or sacrifice child
----------------------------------------
Notice the timestamp jump between [  351.239144] and [  389.308085].
There was no such silence between the two lines. Rather, increment of
timestamp obviously started delaying after printk() flooding started
(e.g. regarding line-A and line-B where timestamp delta is only a few
microseconds, line-B is written to console after magnitudes of many
seconds of silence after line-A was written to console). And the delay
of timestamp in the log (i.e. about 39 seconds in above example) is
recovered (i.e. timestamp reflects actual uptime) only after I pressed
SysRq-i in order to allow the rest of the system to use CPU time.

I don't know why such delaying occurs (problem in printk() or VMware ?) but
what I can say is that threads spinning inside __alloc_pages_slowpath() is
giving too much stress to printk() and the rest of the system.

Now, similar CPU time wasting situation is reported by Cong as soft lockup
on a physical hardware.

You say "Your system is already DOSed. You should configure your system not
to allow giving such stress to MM subsystem." and I say back "printk() is
already DOSed. You should configure MM subsystem not to allow giving such
stress to printk()."

>
> Sure.  But warn_alloc() doesn't.
>

I agree with Andrew. Callers of dump_stack() must do, if the callers are
in schedulable context, a sensible flow-control so that lower layers are
not annoyed .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
