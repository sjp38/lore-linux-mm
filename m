Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDFEB6B0038
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 08:00:02 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so39897082wjb.3
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 05:00:02 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id ue16si11696916wjb.138.2016.12.17.04.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Dec 2016 04:59:59 -0800 (PST)
Date: Sat, 17 Dec 2016 13:59:51 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161217125950.GA3321@boerne.fritz.box>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161217000203.GC23392@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Sat, Dec 17, 2016 at 01:02:03AM +0100, Michal Hocko wrote:
> On Fri 16-12-16 19:47:00, Nils Holland wrote:
> > 
> > Dec 16 18:56:24 boerne.fritz.box kernel: Purging GPU memory, 37 pages freed, 10219 pages still pinned.
> > Dec 16 18:56:29 boerne.fritz.box kernel: kthreadd invoked oom-killer: gfp_mask=0x27080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=0, order=1, oom_score_adj=0
> > Dec 16 18:56:29 boerne.fritz.box kernel: kthreadd cpuset=/ mems_allowed=0
> [...]
> > Dec 16 18:56:29 boerne.fritz.box kernel: Normal free:41008kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:470556kB inactive_file:148kB unevictable:0kB writepending:1616kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:213172kB slab_unreclaimable:86236kB kernel_stack:1864kB pagetables:3572kB bounce:0kB free_pcp:532kB local_pcp:456kB free_cma:0kB
> 
> this is a GFP_KERNEL allocation so it cannot use the highmem zone again.
> There is no anonymous memory in this zone but the allocation
> context implies the full reclaim context so the file LRU should be
> reclaimable. For some reason ~470MB of the active file LRU is still
> there. This is quite unexpected. It is harder to tell more without
> further data. It would be great if you could enable reclaim related
> tracepoints:
> 
> mount -t tracefs none /debug/trace
> echo 1 > /debug/trace/events/vmscan/enable
> cat /debug/trace/trace_pipe > trace.log
> 
> should help
> [...]

No problem! I enabled writing the trace data to a file and then tried
to trigger another OOM situation. That worked, this time without a
complete kernel panic, but with only my processes being killed and the
system becoming unresponsive. When that happened, I let it run for
another minute or two so that in case it was still logging something
to the trace file, it could continue to do so some time longer. Then I
rebooted with the only thing that still worked, i.e. by means of magic
SysRequest.

The trace file has actually become rather big (around 21 MB). I didn't
dare to cut anything from it because I didn't want to risk deleting
something that might turn out important. So, due to the size, I'm not
attaching the trace file to this message, but it's up compressed
(about 536 KB) to be grabbed at:

http://ftp.tisys.org/pub/misc/trace.log.xz

For reference, here's the OOM report that goes along with this
incident and the trace file:

Dec 17 13:31:06 boerne.fritz.box kernel: Purging GPU memory, 145 pages freed, 10287 pages still pinned.
Dec 17 13:31:07 boerne.fritz.box kernel: awesome invoked oom-killer: gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
Dec 17 13:31:07 boerne.fritz.box kernel: awesome cpuset=/ mems_allowed=0
Dec 17 13:31:07 boerne.fritz.box kernel: CPU: 1 PID: 5599 Comm: awesome Not tainted 4.9.0-gentoo #3
Dec 17 13:31:07 boerne.fritz.box kernel: Hardware name: TOSHIBA Satellite L500/KSWAA, BIOS V1.80 10/28/2009
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c18
Dec 17 13:31:07 boerne.fritz.box kernel:  c1433406
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37d48
Dec 17 13:31:07 boerne.fritz.box kernel:  c5319280
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c48
Dec 17 13:31:07 boerne.fritz.box kernel:  c1170011
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c9c
Dec 17 13:31:07 boerne.fritz.box kernel:  00200286
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c48
Dec 17 13:31:07 boerne.fritz.box kernel:  c1438fff
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c4c
Dec 17 13:31:07 boerne.fritz.box kernel:  c72479c0
Dec 17 13:31:07 boerne.fritz.box kernel:  c60dd200
Dec 17 13:31:07 boerne.fritz.box kernel:  c5319280
Dec 17 13:31:07 boerne.fritz.box kernel:  c1ad1899
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37d48
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c8c
Dec 17 13:31:07 boerne.fritz.box kernel:  c1114407
Dec 17 13:31:07 boerne.fritz.box kernel:  c10513a5
Dec 17 13:31:07 boerne.fritz.box kernel:  c5a37c78
Dec 17 13:31:07 boerne.fritz.box kernel:  c11140a1
Dec 17 13:31:07 boerne.fritz.box kernel:  00000005
Dec 17 13:31:07 boerne.fritz.box kernel:  00000000
Dec 17 13:31:07 boerne.fritz.box kernel:  00000000
Dec 17 13:31:07 boerne.fritz.box kernel: Call Trace:
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1433406>] dump_stack+0x47/0x61
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1170011>] dump_header+0x5f/0x175
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1438fff>] ? ___ratelimit+0x7f/0xe0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1114407>] oom_kill_process+0x207/0x3c0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c10513a5>] ? has_capability_noaudit+0x15/0x20
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c11140a1>] ? oom_badness.part.13+0xb1/0x120
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c11148c4>] out_of_memory+0xd4/0x270
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1118615>] __alloc_pages_nodemask+0xcf5/0xd60
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1758900>] ? skb_queue_purge+0x30/0x30
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c175dcde>] alloc_skb_with_frags+0xee/0x1a0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1753dba>] sock_alloc_send_pskb+0x19a/0x1c0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1825880>] ? wait_for_unix_gc+0x20/0x90
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1823fc0>] unix_stream_sendmsg+0x2a0/0x350
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1750b3d>] sock_sendmsg+0x2d/0x40
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1750bb7>] sock_write_iter+0x67/0xc0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1172c42>] do_readv_writev+0x1e2/0x380
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1750b50>] ? sock_sendmsg+0x40/0x40
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c10806f2>] ? pick_next_task_fair+0x3f2/0x510
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1033763>] ? lapic_next_event+0x13/0x20
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1173d16>] vfs_writev+0x36/0x60
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1173d85>] do_writev+0x45/0xc0
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c1173efb>] SyS_writev+0x1b/0x20
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c10018ec>] do_fast_syscall_32+0x7c/0x130
Dec 17 13:31:07 boerne.fritz.box kernel:  [<c194232b>] sysenter_past_esp+0x40/0x6a
Dec 17 13:31:07 boerne.fritz.box kernel: Mem-Info:
Dec 17 13:31:07 boerne.fritz.box kernel: active_anon:99962 inactive_anon:10651 isolated_anon:0
                                          active_file:305350 inactive_file:411946 isolated_file:36
                                          unevictable:0 dirty:5961 writeback:0 unstable:0
                                          slab_reclaimable:50496 slab_unreclaimable:21852
                                          mapped:36866 shmem:10990 pagetables:973 bounce:0
                                          free:82280 free_pcp:103 free_cma:0
Dec 17 13:31:07 boerne.fritz.box kernel: Node 0 active_anon:399848kB inactive_anon:42604kB active_file:1221400kB inactive_file:1647784kB unevictable:0kB isolated(anon):0kB isolated(file):144kB mapped:147464kB dirty:23844kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 165888kB anon_thp: 43960kB writeback_tmp:0kB unstable:0kB pages_scanned:56194255 all_unreclaimable? yes
Dec 17 13:31:07 boerne.fritz.box kernel: DMA free:3944kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:6504kB inactive_file:0kB unevictable:0kB writepending:120kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:2712kB slab_unreclaimable:1016kB kernel_stack:360kB pagetables:1132kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Dec 17 13:31:07 boerne.fritz.box kernel: lowmem_reserve[]:
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  808
Dec 17 13:31:07 boerne.fritz.box kernel:  3849
Dec 17 13:31:07 boerne.fritz.box kernel:  3849
Dec 17 13:31:07 boerne.fritz.box kernel: Normal free:41056kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:483028kB inactive_file:4kB unevictable:0kB writepending:2056kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:199272kB slab_unreclaimable:86392kB kernel_stack:1656kB pagetables:2760kB bounce:0kB free_pcp:252kB local_pcp:144kB free_cma:0kB
Dec 17 13:31:07 boerne.fritz.box kernel: lowmem_reserve[]:
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  24330
Dec 17 13:31:07 boerne.fritz.box kernel:  24330
Dec 17 13:31:07 boerne.fritz.box kernel: HighMem free:284120kB min:512kB low:39184kB high:77856kB active_anon:399848kB inactive_anon:42604kB active_file:731868kB inactive_file:1647684kB unevictable:0kB writepending:21668kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:160kB local_pcp:84kB free_cma:0kB
Dec 17 13:31:07 boerne.fritz.box kernel: lowmem_reserve[]:
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel:  0
Dec 17 13:31:07 boerne.fritz.box kernel: DMA: 
Dec 17 13:31:07 boerne.fritz.box kernel: 4*4kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (U) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*8kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (E) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*16kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (U) 
Dec 17 13:31:07 boerne.fritz.box kernel: 8*32kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UE) 
Dec 17 13:31:07 boerne.fritz.box kernel: 3*64kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UE) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*128kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (U) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*256kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (E) 
Dec 17 13:31:07 boerne.fritz.box kernel: 0*512kB 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*1024kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (E) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*2048kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (M) 
Dec 17 13:31:07 boerne.fritz.box kernel: 0*4096kB 
Dec 17 13:31:07 boerne.fritz.box kernel: = 3944kB
Dec 17 13:31:07 boerne.fritz.box kernel: Normal: 
Dec 17 13:31:07 boerne.fritz.box kernel: 40*4kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UM) 
Dec 17 13:31:07 boerne.fritz.box kernel: 28*8kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 22*16kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 20*32kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (M) 
Dec 17 13:31:07 boerne.fritz.box kernel: 92*64kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UM) 
Dec 17 13:31:07 boerne.fritz.box kernel: 76*128kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 20*256kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 3*512kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UM) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1*1024kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (E) 
Dec 17 13:31:07 boerne.fritz.box kernel: 2*2048kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UM) 
Dec 17 13:31:07 boerne.fritz.box kernel: 3*4096kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (M) 
Dec 17 13:31:07 boerne.fritz.box kernel: = 41056kB
Dec 17 13:31:07 boerne.fritz.box kernel: HighMem: 
Dec 17 13:31:07 boerne.fritz.box kernel: 1452*4kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 1347*8kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 903*16kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 443*32kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 135*64kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 33*128kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 11*256kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (ME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 10*512kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 7*1024kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UME) 
Dec 17 13:31:07 boerne.fritz.box kernel: 3*2048kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UE) 
Dec 17 13:31:07 boerne.fritz.box kernel: 50*4096kB 
Dec 17 13:31:07 boerne.fritz.box kernel: (UM) 
Dec 17 13:31:07 boerne.fritz.box kernel: = 284120kB
Dec 17 13:31:07 boerne.fritz.box kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 17 13:31:07 boerne.fritz.box kernel: 728298 total pagecache pages
Dec 17 13:31:07 boerne.fritz.box kernel: 0 pages in swap cache
Dec 17 13:31:07 boerne.fritz.box kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 17 13:31:07 boerne.fritz.box kernel: Free swap  = 3781628kB
Dec 17 13:31:07 boerne.fritz.box kernel: Total swap = 3781628kB
Dec 17 13:31:07 boerne.fritz.box kernel: 1006816 pages RAM
Dec 17 13:31:07 boerne.fritz.box kernel: 778564 pages HighMem/MovableOnly
Dec 17 13:31:07 boerne.fritz.box kernel: 16403 pages reserved
Dec 17 13:31:07 boerne.fritz.box kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
Dec 17 13:31:07 boerne.fritz.box kernel: [ 1876]     0  1876     6165      985      10       3        0             0 systemd-journal
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2497]     0  2497     2965      915       6       3        0         -1000 systemd-udevd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2582]   107  2582     3874      902       8       3        0             0 systemd-timesyn
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2585]    88  2585     1158      567       6       3        0             0 nullmailer-send
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2588]   108  2588     1271      848       7       3        0          -900 dbus-daemon
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2590]     0  2590     1510      459       5       3        0             0 fcron
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2594]     0  2594     1521      994       6       3        0             0 systemd-logind
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2595]     0  2595    22001     3143      21       3        0             0 NetworkManager
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2649]     0  2649      768      579       5       3        0             0 dhcpcd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2655]     0  2655      639      416       5       3        0             0 vnstatd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2656]     0  2656     1235      843       6       3        0             0 login
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2657]     0  2657     1460     1047       6       3        0         -1000 sshd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2684]     0  2684     1972     1291       7       3        0             0 systemd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2713]     0  2713     2279      569       7       3        0             0 (sd-pam)
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2728]     0  2728     1836      914       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2768]   109  2768    16725     3172      19       3        0             0 polkitd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2798]     0  2798     2157     1375       7       3        0             0 wpa_supplicant
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2864]     0  2864     1743      703       7       3        0             0 start_trace
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2866]     0  2866     1395      390       7       3        0             0 cat
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2867]     0  2867     1370      422       6       3        0             0 tail
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2916]     0  2916     1235      845       6       3        0             0 login
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2917]     0  2917     1836      870       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2956]     0  2956    16257    14998      36       3        0             0 emerge
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2963]     0  2963     1235      846       6       3        0             0 login
Dec 17 13:31:07 boerne.fritz.box kernel: [ 2972]     0  2972     1836      906       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 3021]     0  3021     6058     1745      15       3        0             0 journalctl
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5253]   250  5253      549      356       5       3        0             0 sandbox
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5255]   250  5255     2629     1567       8       3        0             0 ebuild.sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5272]   250  5272     2995     1763       8       3        0             0 ebuild.sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5335]     0  5335     1235      843       6       3        0             0 login
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5343]   250  5343     1123      724       5       3        0             0 emake
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5345]   250  5345      909      661       6       3        0             0 make
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5467]  1000  5467     2033     1374       7       3        0             0 systemd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5483]  1000  5483     6633      597      10       3        0             0 (sd-pam)
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5506]  1000  5506     1836      887       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5530]   250  5530     1057      674       4       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5531]   250  5531     3204     2648      10       3        0             0 python2.7
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5536]  1000  5536    25339     2203      18       3        0             0 pulseaudio
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5537]   111  5537     5763      643       9       3        0             0 rtkit-daemon
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5560]  1000  5560     3575     1420      10       3        0             0 gconf-helper
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5567]  1000  5567     1743      709       7       3        0             0 startx
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5588]  1000  5588     1001      579       5       3        0             0 xinit
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5589]  1000  5589    23142     6927      42       3        0             0 X
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5599]  1000  5599    10592     4532      21       3        0             0 awesome
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5625]  1000  5625     1571      616       7       3        0             0 dbus-launch
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5626]  1000  5626     1238      636       6       3        0             0 dbus-daemon
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5631]  1000  5631     1571      621       7       3        0             0 dbus-launch
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5632]  1000  5632     1238      703       6       3        0             0 dbus-daemon
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5659]   250  5659     3749     3243      11       3        0             0 python
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5671]  1000  5671    31584     7782      39       3        0             0 nm-applet
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5707]  1000  5707    11224     1897      14       3        0             0 at-spi-bus-laun
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5718]  1000  5718     1238      806       6       3        0             0 dbus-daemon
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5725]  1000  5725     7480     2144      12       3        0             0 at-spi2-registr
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5732]  1000  5732    10179     1469      14       3        0             0 gvfsd
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5765]  1000  5765   194951    71017     247       3        0             0 firefox
Dec 17 13:31:07 boerne.fritz.box kernel: [ 5825]   250  5825     1209      839       5       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 7253]  1000  7253    21521     7455      32       3        0             0 xfce4-terminal
Dec 17 13:31:07 boerne.fritz.box kernel: [ 7359]  1000  7359     1836      891       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 8641]  1000  8641     1533      593       6       3        0             0 tar
Dec 17 13:31:07 boerne.fritz.box kernel: [ 8642]  1000  8642    17834    16879      38       3        0             0 xz
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9059]   250  9059    10070     2536      13       3        0             0 python
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9063]   250  9063     3155     1923      10       3        0             0 python
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9064]   250  9064     3155     1926      10       3        0             0 python
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9068]   250  9068     1211      826       5       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9075]   250  9075     3847     3307      11       3        0             0 python
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9417]  1000  9417     1829      901       7       3        0             0 bash
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9459]  1000  9459     2246     1206       9       3        0             0 ssh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9499]   250  9499     1087      710       5       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9567]   250  9567     1087      532       5       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: [ 9570]   250  9570     1088      618       5       3        0             0 sh
Dec 17 13:31:07 boerne.fritz.box kernel: Out of memory: Kill process 5765 (firefox) score 36 or sacrifice child
Dec 17 13:31:07 boerne.fritz.box kernel: Killed process 5765 (firefox) total-vm:779804kB, anon-rss:183712kB, file-rss:100332kB, shmem-rss:24kB
Dec 17 13:31:08 boerne.fritz.box kernel: awesome invoked oom-killer: gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
Dec 17 13:31:08 boerne.fritz.box kernel: awesome cpuset=/ mems_allowed=0
Dec 17 13:31:08 boerne.fritz.box kernel: CPU: 0 PID: 5599 Comm: awesome Not tainted 4.9.0-gentoo #3
Dec 17 13:31:08 boerne.fritz.box kernel: Hardware name: TOSHIBA Satellite L500/KSWAA, BIOS V1.80 10/28/2009
Dec 17 13:31:08 boerne.fritz.box kernel:  c5a37c18 c1433406 c5a37d48 c531ca00 c5a37c48 c1170011 c5a37c9c 00000286
Dec 17 13:31:08 boerne.fritz.box kernel:  c5a37c48 c1438fff c5a37c4c c7246c00 e737e800 c531ca00 c1ad1899 c5a37d48
Dec 17 13:31:08 boerne.fritz.box kernel:  c5a37c8c c1114407 001d89cc c5a37c78 c1114000 00000005 00000000 00000000
Dec 17 13:31:08 boerne.fritz.box kernel: Call Trace:
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1433406>] dump_stack+0x47/0x61
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1170011>] dump_header+0x5f/0x175
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1438fff>] ? ___ratelimit+0x7f/0xe0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1114407>] oom_kill_process+0x207/0x3c0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1114000>] ? oom_badness.part.13+0x10/0x120
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c11148c4>] out_of_memory+0xd4/0x270
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1118615>] __alloc_pages_nodemask+0xcf5/0xd60
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1758900>] ? skb_queue_purge+0x30/0x30
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c175dcde>] alloc_skb_with_frags+0xee/0x1a0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1753dba>] sock_alloc_send_pskb+0x19a/0x1c0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1825880>] ? wait_for_unix_gc+0x20/0x90
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1823fc0>] unix_stream_sendmsg+0x2a0/0x350
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1750b3d>] sock_sendmsg+0x2d/0x40
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1750bb7>] sock_write_iter+0x67/0xc0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1172c42>] do_readv_writev+0x1e2/0x380
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1750b50>] ? sock_sendmsg+0x40/0x40
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1033763>] ? lapic_next_event+0x13/0x20
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c10ae675>] ? clockevents_program_event+0x95/0x190
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c10a074a>] ? __hrtimer_run_queues+0x20a/0x280
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1173d16>] vfs_writev+0x36/0x60
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1173d85>] do_writev+0x45/0xc0
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c1173efb>] SyS_writev+0x1b/0x20
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c10018ec>] do_fast_syscall_32+0x7c/0x130
Dec 17 13:31:08 boerne.fritz.box kernel:  [<c194232b>] sysenter_past_esp+0x40/0x6a
Dec 17 13:31:08 boerne.fritz.box kernel: Mem-Info:
Dec 17 13:31:08 boerne.fritz.box kernel: active_anon:53993 inactive_anon:7042 isolated_anon:0
                                          active_file:310474 inactive_file:411136 isolated_file:0
                                          unevictable:0 dirty:9093 writeback:0 unstable:0
                                          slab_reclaimable:50588 slab_unreclaimable:21858
                                          mapped:18104 shmem:7404 pagetables:732 bounce:0
                                          free:127428 free_pcp:488 free_cma:0
Dec 17 13:31:08 boerne.fritz.box kernel: Node 0 active_anon:215972kB inactive_anon:28168kB active_file:1241896kB inactive_file:1644544kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:72416kB dirty:36372kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 112640kB anon_thp: 29616kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
Dec 17 13:31:08 boerne.fritz.box kernel: DMA free:3928kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:6964kB inactive_file:44kB unevictable:0kB writepending:596kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:3016kB slab_unreclaimable:1176kB kernel_stack:96kB pagetables:388kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Dec 17 13:31:08 boerne.fritz.box kernel: lowmem_reserve[]: 0 808 3849 3849
Dec 17 13:31:08 boerne.fritz.box kernel: Normal free:40944kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:483096kB inactive_file:80kB unevictable:0kB writepending:2060kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:199336kB slab_unreclaimable:86256kB kernel_stack:1632kB pagetables:2540kB bounce:0kB free_pcp:692kB local_pcp:396kB free_cma:0kB
Dec 17 13:31:08 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 24330 24330
Dec 17 13:31:08 boerne.fritz.box kernel: HighMem free:464840kB min:512kB low:39184kB high:77856kB active_anon:215972kB inactive_anon:28168kB active_file:751836kB inactive_file:1644320kB unevictable:0kB writepending:33716kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:1260kB local_pcp:628kB free_cma:0kB
Dec 17 13:31:08 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 0 0
Dec 17 13:31:08 boerne.fritz.box kernel: DMA: 6*4kB (U) 14*8kB (U) 15*16kB (U) 7*32kB (U) 2*64kB (U) 1*128kB (U) 0*256kB 0*512kB 1*1024kB (E) 1*2048kB (M) 0*4096kB = 3928kB
Dec 17 13:31:08 boerne.fritz.box kernel: Normal: 40*4kB (UM) 30*8kB (UM) 22*16kB (UME) 24*32kB (UM) 92*64kB (UM) 76*128kB (UME) 19*256kB (UM) 3*512kB (UM) 1*1024kB (E) 2*2048kB (UM) 3*4096kB (M) = 40944kB
Dec 17 13:31:08 boerne.fritz.box kernel: HighMem: 14*4kB (UE) 1256*8kB (ME) 869*16kB (UME) 520*32kB (UME) 210*64kB (UME) 93*128kB (UME) 42*256kB (ME) 22*512kB (UME) 12*1024kB (UME) 30*2048kB (UME) 74*4096kB (UM) = 464840kB
Dec 17 13:31:08 boerne.fritz.box kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 17 13:31:08 boerne.fritz.box kernel: 729003 total pagecache pages
Dec 17 13:31:08 boerne.fritz.box kernel: 0 pages in swap cache
Dec 17 13:31:08 boerne.fritz.box kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 17 13:31:08 boerne.fritz.box kernel: Free swap  = 3781628kB
Dec 17 13:31:08 boerne.fritz.box kernel: Total swap = 3781628kB
Dec 17 13:31:08 boerne.fritz.box kernel: 1006816 pages RAM
Dec 17 13:31:08 boerne.fritz.box kernel: 778564 pages HighMem/MovableOnly
Dec 17 13:31:08 boerne.fritz.box kernel: 16403 pages reserved
Dec 17 13:31:08 boerne.fritz.box kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
Dec 17 13:31:08 boerne.fritz.box kernel: [ 1876]     0  1876     6165     1016      10       3        0             0 systemd-journal
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2497]     0  2497     2965      915       6       3        0         -1000 systemd-udevd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2582]   107  2582     3874      902       8       3        0             0 systemd-timesyn
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2585]    88  2585     1158      567       6       3        0             0 nullmailer-send
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2588]   108  2588     1271      848       7       3        0          -900 dbus-daemon
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2590]     0  2590     1510      459       5       3        0             0 fcron
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2594]     0  2594     1521      994       6       3        0             0 systemd-logind
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2595]     0  2595    22001     3143      21       3        0             0 NetworkManager
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2649]     0  2649      768      579       5       3        0             0 dhcpcd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2655]     0  2655      639      416       5       3        0             0 vnstatd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2656]     0  2656     1235      843       6       3        0             0 login
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2657]     0  2657     1460     1047       6       3        0         -1000 sshd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2684]     0  2684     1972     1291       7       3        0             0 systemd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2713]     0  2713     2279      569       7       3        0             0 (sd-pam)
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2728]     0  2728     1836      914       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2768]   109  2768    16725     3172      19       3        0             0 polkitd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2798]     0  2798     2157     1375       7       3        0             0 wpa_supplicant
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2864]     0  2864     1743      703       7       3        0             0 start_trace
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2866]     0  2866     1395      390       7       3        0             0 cat
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2867]     0  2867     1370      422       6       3        0             0 tail
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2916]     0  2916     1235      845       6       3        0             0 login
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2917]     0  2917     1836      870       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2956]     0  2956    16257    14998      36       3        0             0 emerge
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2963]     0  2963     1235      846       6       3        0             0 login
Dec 17 13:31:08 boerne.fritz.box kernel: [ 2972]     0  2972     1836      906       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 3021]     0  3021     6058     1761      15       3        0             0 journalctl
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5253]   250  5253      549      356       5       3        0             0 sandbox
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5255]   250  5255     2629     1567       8       3        0             0 ebuild.sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5272]   250  5272     2995     1763       8       3        0             0 ebuild.sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5335]     0  5335     1235      843       6       3        0             0 login
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5343]   250  5343     1123      724       5       3        0             0 emake
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5345]   250  5345      909      661       6       3        0             0 make
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5467]  1000  5467     2033     1374       7       3        0             0 systemd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5483]  1000  5483     6633      597      10       3        0             0 (sd-pam)
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5506]  1000  5506     1836      887       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5530]   250  5530     1057      674       4       3        0             0 sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5531]   250  5531     3204     2648      10       3        0             0 python2.7
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5536]  1000  5536    25339     2203      18       3        0             0 pulseaudio
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5537]   111  5537     5763      643       9       3        0             0 rtkit-daemon
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5560]  1000  5560     3575     1420      10       3        0             0 gconf-helper
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5567]  1000  5567     1743      709       7       3        0             0 startx
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5588]  1000  5588     1001      579       5       3        0             0 xinit
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5589]  1000  5589    23069     6556      42       3        0             0 X
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5599]  1000  5599    10592     4532      21       3        0             0 awesome
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5625]  1000  5625     1571      616       7       3        0             0 dbus-launch
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5626]  1000  5626     1238      636       6       3        0             0 dbus-daemon
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5631]  1000  5631     1571      621       7       3        0             0 dbus-launch
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5632]  1000  5632     1238      703       6       3        0             0 dbus-daemon
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5659]   250  5659     3749     3243      11       3        0             0 python
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5671]  1000  5671    31584     7782      39       3        0             0 nm-applet
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5707]  1000  5707    11224     1897      14       3        0             0 at-spi-bus-laun
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5718]  1000  5718     1238      806       6       3        0             0 dbus-daemon
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5725]  1000  5725     7480     2144      12       3        0             0 at-spi2-registr
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5732]  1000  5732    10179     1469      14       3        0             0 gvfsd
Dec 17 13:31:08 boerne.fritz.box kernel: [ 5825]   250  5825     1209      839       5       3        0             0 sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 7253]  1000  7253    21521     7455      32       3        0             0 xfce4-terminal
Dec 17 13:31:08 boerne.fritz.box kernel: [ 7359]  1000  7359     1836      891       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 8641]  1000  8641     1533      593       6       3        0             0 tar
Dec 17 13:31:08 boerne.fritz.box kernel: [ 8642]  1000  8642    17834    16879      38       3        0             0 xz
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9059]   250  9059    10070     2536      13       3        0             0 python
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9063]   250  9063     3155     1923      10       3        0             0 python
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9064]   250  9064     3155     1926      10       3        0             0 python
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9068]   250  9068     1211      826       5       3        0             0 sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9075]   250  9075     3847     3307      11       3        0             0 python
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9417]  1000  9417     1829      901       7       3        0             0 bash
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9459]  1000  9459     2246     1206       9       3        0             0 ssh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9499]   250  9499     1087      711       5       3        0             0 sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9607]   250  9607     1211      755       5       3        0             0 sh
Dec 17 13:31:08 boerne.fritz.box kernel: [ 9608]   250  9608     1087      533       5       3        0             0 sh

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
