Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 64C0F8309B
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 23:09:57 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id w5so63671621oie.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 20:09:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o1si10519120oep.86.2016.02.06.20.09.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Feb 2016 20:09:55 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160203132718.GI6757@dhcp22.suse.cz>
	<alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
	<20160204125700.GA14425@dhcp22.suse.cz>
	<201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
	<20160204133905.GB14425@dhcp22.suse.cz>
In-Reply-To: <20160204133905.GB14425@dhcp22.suse.cz>
Message-Id: <201602071309.EJD59750.FOVMSFOOFHtJQL@I-love.SAKURA.ne.jp>
Date: Sun, 7 Feb 2016 13:09:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 04-02-16 22:10:54, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I am not sure we can fix these pathological loads where we hit the
> > > higher order depletion and there is a chance that one of the thousands
> > > tasks terminates in an unpredictable way which happens to race with the
> > > OOM killer.
> > 
> > When I hit this problem on Dec 24th, I didn't run thousands of tasks.
> > I think there were less than one hundred tasks in the system and only
> > a few tasks were running. Not a pathological load at all.
> 
> But as the OOM report clearly stated there were no > order-1 pages
> available in that particular case. And that happened after the direct
> reclaim and compaction were already invoked.
> 
> As I've mentioned in the referenced email, we can try to do multiple
> retries e.g. do not give up on the higher order requests until we hit
> the maximum number of retries but I consider it quite ugly to be honest.
> I think that a proper communication with compaction is a more
> appropriate way to go long term. E.g. I find it interesting that
> try_to_compact_pages doesn't even care about PAGE_ALLOC_COSTLY_ORDER
> and treat is as any other high order request.
> 

FYI, I again hit unexpected OOM-killer during genxref on linux-4.5-rc2 source.
I think current patchset is too fragile to merge.
----------------------------------------
[ 3101.626995] smbd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[ 3101.629148] smbd cpuset=/ mems_allowed=0
[ 3101.630332] CPU: 1 PID: 3941 Comm: smbd Not tainted 4.5.0-rc2-next-20160205 #293
[ 3101.632335] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 3101.634567]  0000000000000286 000000005784a8f9 ffff88007c47bad0 ffffffff8139abbd
[ 3101.636533]  0000000000000000 ffff88007c47bd00 ffff88007c47bb70 ffffffff811bdc6c
[ 3101.638381]  0000000000000206 ffffffff81810b30 ffff88007c47bb10 ffffffff810be079
[ 3101.640215] Call Trace:
[ 3101.641169]  [<ffffffff8139abbd>] dump_stack+0x85/0xc8
[ 3101.642560]  [<ffffffff811bdc6c>] dump_header+0x5b/0x3b0
[ 3101.643983]  [<ffffffff810be079>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[ 3101.645616]  [<ffffffff810be14d>] ? trace_hardirqs_on+0xd/0x10
[ 3101.647081]  [<ffffffff81143fb6>] oom_kill_process+0x366/0x550
[ 3101.648631]  [<ffffffff811443df>] out_of_memory+0x1ef/0x5a0
[ 3101.650081]  [<ffffffff8114449d>] ? out_of_memory+0x2ad/0x5a0
[ 3101.651624]  [<ffffffff81149d0d>] __alloc_pages_nodemask+0xbad/0xd90
[ 3101.653207]  [<ffffffff8114a0ac>] alloc_kmem_pages_node+0x4c/0xc0
[ 3101.654767]  [<ffffffff8106d5c1>] copy_process.part.31+0x131/0x1b40
[ 3101.656381]  [<ffffffff8111d9ea>] ? __audit_syscall_entry+0xaa/0xf0
[ 3101.657952]  [<ffffffff810e8119>] ? current_kernel_time64+0xa9/0xc0
[ 3101.659492]  [<ffffffff8106f19b>] _do_fork+0xdb/0x5d0
[ 3101.660814]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[ 3101.662305]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[ 3101.663988]  [<ffffffff81703d2c>] ? return_from_SYSCALL_64+0x2d/0x7a
[ 3101.665572]  [<ffffffff810035ec>] ? do_syscall_64+0x1c/0x180
[ 3101.667067]  [<ffffffff8106f714>] SyS_clone+0x14/0x20
[ 3101.668510]  [<ffffffff8100362d>] do_syscall_64+0x5d/0x180
[ 3101.669931]  [<ffffffff81703cff>] entry_SYSCALL64_slow_path+0x25/0x25
[ 3101.671642] Mem-Info:
[ 3101.672612] active_anon:46842 inactive_anon:2094 isolated_anon:0
 active_file:108974 inactive_file:131350 isolated_file:0
 unevictable:0 dirty:1174 writeback:0 unstable:0
 slab_reclaimable:107536 slab_unreclaimable:14287
 mapped:4199 shmem:2166 pagetables:1524 bounce:0
 free:6260 free_pcp:31 free_cma:0
[ 3101.681294] Node 0 DMA free:6884kB min:44kB low:52kB high:64kB active_anon:3488kB inactive_anon:100kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:100kB slab_reclaimable:3852kB slab_unreclaimable:444kB kernel_stack:80kB pagetables:112kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 3101.691319] lowmem_reserve[]: 0 1714 1714 1714
[ 3101.692847] Node 0 DMA32 free:18156kB min:5172kB low:6464kB high:7756kB active_anon:183880kB inactive_anon:8276kB active_file:435896kB inactive_file:525396kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1759480kB mlocked:0kB dirty:4696kB writeback:0kB mapped:16792kB shmem:8564kB slab_reclaimable:426292kB slab_unreclaimable:56704kB kernel_stack:3328kB pagetables:5984kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 3101.704239] lowmem_reserve[]: 0 0 0 0
[ 3101.705887] Node 0 DMA: 75*4kB (UME) 69*8kB (UME) 43*16kB (UM) 23*32kB (UME) 8*64kB (UM) 4*128kB (UME) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 0*4096kB = 6884kB
[ 3101.710581] Node 0 DMA32: 4513*4kB (UME) 15*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18172kB
[ 3101.713857] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 3101.716332] 242517 total pagecache pages
[ 3101.717878] 0 pages in swap cache
[ 3101.719332] Swap cache stats: add 0, delete 0, find 0/0
[ 3101.721577] Free swap  = 0kB
[ 3101.722980] Total swap = 0kB
[ 3101.724364] 524157 pages RAM
[ 3101.725697] 0 pages HighMem/MovableOnly
[ 3101.727165] 80311 pages reserved
[ 3101.728482] 0 pages hwpoisoned
[ 3101.729754] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 3101.732071] [  492]     0   492     9206      975      20       4        0             0 systemd-journal
[ 3101.734357] [  520]     0   520    10479      631      22       3        0         -1000 systemd-udevd
[ 3101.737036] [  527]     0   527    12805      682      24       3        0         -1000 auditd
[ 3101.739505] [ 1174]     0  1174     4830      556      14       3        0             0 irqbalance
[ 3101.741876] [ 1180]    81  1180     6672      604      20       3        0          -900 dbus-daemon
[ 3101.744728] [ 1817]     0  1817    56009      880      40       4        0             0 rsyslogd
[ 3101.747164] [ 1818]     0  1818     1096      349       8       3        0             0 rngd
[ 3101.749788] [ 1820]     0  1820    52575     1074      56       3        0             0 abrtd
[ 3101.752135] [ 1821]     0  1821    80901     5160      80       4        0             0 firewalld
[ 3101.754532] [ 1823]     0  1823     6602      681      20       3        0             0 systemd-logind
[ 3101.757342] [ 1825]    70  1825     6999      458      20       3        0             0 avahi-daemon
[ 3101.759784] [ 1827]     0  1827    51995      986      55       3        0             0 abrt-watch-log
[ 3101.762465] [ 1838]     0  1838    31586      647      21       3        0             0 crond
[ 3101.764797] [ 1946]    70  1946     6999       58      19       3        0             0 avahi-daemon
[ 3101.767262] [ 2043]     0  2043    65187      858      43       3        0             0 vmtoolsd
[ 3101.769665] [ 2618]     0  2618    27631     3112      53       3        0             0 dhclient
[ 3101.772203] [ 2622]   999  2622   130827     2570      56       3        0             0 polkitd
[ 3101.774645] [ 2704]     0  2704   138263     3351      91       4        0             0 tuned
[ 3101.777114] [ 2709]     0  2709    20640      773      45       3        0         -1000 sshd
[ 3101.779428] [ 2711]     0  2711     7328      551      19       3        0             0 xinetd
[ 3101.782016] [ 3883]     0  3883    22785      827      45       3        0             0 master
[ 3101.784576] [ 3884]    89  3884    22811      924      46       4        0             0 pickup
[ 3101.786898] [ 3885]    89  3885    22828      886      44       3        0             0 qmgr
[ 3101.789287] [ 3916]     0  3916    23203      736      50       3        0             0 login
[ 3101.791666] [ 3927]     0  3927    27511      381      13       3        0             0 agetty
[ 3101.794116] [ 3930]     0  3930    79392     1063     105       3        0             0 nmbd
[ 3101.796387] [ 3941]     0  3941    96485     1544     138       4        0             0 smbd
[ 3101.798602] [ 3944]     0  3944    96485     1290     131       4        0             0 smbd
[ 3101.800783] [ 7471]     0  7471    28886      732      15       3        0             0 bash
[ 3101.803013] [ 7580]     0  7580     2380      613      10       3        0             0 makelxr.sh
[ 3101.805147] [ 7786]     0  7786    27511      395      10       3        0             0 agetty
[ 3101.807198] [ 8139]     0  8139    35888      974      72       3        0             0 sshd
[ 3101.809255] [ 8144]     0  8144    28896      761      15       4        0             0 bash
[ 3101.811335] [15286]     0 15286    38294    30474      81       3        0             0 genxref
[ 3101.813512] Out of memory: Kill process 15286 (genxref) score 66 or sacrifice child
[ 3101.815659] Killed process 15286 (genxref) total-vm:153176kB, anon-rss:117092kB, file-rss:4804kB, shmem-rss:0kB
----------------------------------------

> Something like the following:
Yes, I do think we need something like it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
