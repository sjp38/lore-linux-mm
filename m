Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B04C6B0073
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 07:46:53 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id x12so22464559qac.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 04:46:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e3si11500815qac.81.2015.03.02.04.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 04:46:52 -0800 (PST)
Date: Mon, 2 Mar 2015 07:46:26 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302124626.GA25593@laptop.bfoster>
References: <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
 <20150228164158.GE5404@thunk.org>
 <20150228221558.GA23028@phnom.home.cmpxchg.org>
 <20150301214805.GN4251@dastard>
 <20150302001723.GO4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302001723.GO4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Theodore Ts'o <tytso@mit.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, oleg@redhat.com, xfs@oss.sgi.com, mhocko@suse.cz, linux-mm@kvack.org, mgorman@suse.de, rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Mon, Mar 02, 2015 at 11:17:23AM +1100, Dave Chinner wrote:
> On Mon, Mar 02, 2015 at 08:48:05AM +1100, Dave Chinner wrote:
> > On Sat, Feb 28, 2015 at 05:15:58PM -0500, Johannes Weiner wrote:
> > > On Sat, Feb 28, 2015 at 11:41:58AM -0500, Theodore Ts'o wrote:
> > > > On Sat, Feb 28, 2015 at 11:29:43AM -0500, Johannes Weiner wrote:
> > > > > 
> > > > > I'm trying to figure out if the current nofail allocators can get
> > > > > their memory needs figured out beforehand.  And reliably so - what
> > > > > good are estimates that are right 90% of the time, when failing the
> > > > > allocation means corrupting user data?  What is the contingency plan?
> > > > 
> > > > In the ideal world, we can figure out the exact memory needs
> > > > beforehand.  But we live in an imperfect world, and given that block
> > > > devices *also* need memory, the answer is "of course not".  We can't
> > > > be perfect.  But we can least give some kind of hint, and we can offer
> > > > to wait before we get into a situation where we need to loop in
> > > > GFP_NOWAIT --- which is the contingency/fallback plan.
> > > 
> > > Overestimating should be fine, the result would a bit of false memory
> > > pressure.  But underestimating and looping can't be an option or the
> > > original lockups will still be there.  We need to guarantee forward
> > > progress or the problem is somewhat mitigated at best - only now with
> > > quite a bit more complexity in the allocator and the filesystems.
> > 
> > The additional complexity in XFS is actually quite minor, and
> > initial "rough worst case" memory usage estimates are not that hard
> > to measure....
> 
> And, just to point out that the OOM killer can be invoked without a
> single transaction-based filesystem ENOMEM failure, here's what
> xfs/084 does on 4.0-rc1:
> 
> [  148.820369] resvtest invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
> [  148.822113] resvtest cpuset=/ mems_allowed=0
> [  148.823124] CPU: 0 PID: 4342 Comm: resvtest Not tainted 4.0.0-rc1-dgc+ #825
> [  148.824648] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> [  148.826471]  0000000000000000 ffff88003ba2b988 ffffffff81dcb570 000000000000000c
> [  148.828220]  ffff88003bb06380 ffff88003ba2ba08 ffffffff81dc5c2f 0000000000000000
> [  148.829958]  0000000000000000 ffff88003ba2b9a8 0000000000000206 ffff88003ba2b9d8
> [  148.831734] Call Trace:
> [  148.832325]  [<ffffffff81dcb570>] dump_stack+0x4c/0x65
> [  148.833493]  [<ffffffff81dc5c2f>] dump_header.isra.12+0x79/0x1cb
> [  148.834855]  [<ffffffff8117db69>] oom_kill_process+0x1c9/0x3b0
> [  148.836195]  [<ffffffff810a7105>] ? has_capability_noaudit+0x25/0x40
> [  148.837633]  [<ffffffff8117e0c5>] __out_of_memory+0x315/0x500
> [  148.838925]  [<ffffffff8117e44b>] out_of_memory+0x5b/0x80
> [  148.840162]  [<ffffffff811830d9>] __alloc_pages_nodemask+0x7d9/0x810
> [  148.841592]  [<ffffffff811c0531>] alloc_pages_current+0x91/0x100
> [  148.842950]  [<ffffffff8117a427>] __page_cache_alloc+0xa7/0xc0
> [  148.844286]  [<ffffffff8117c688>] filemap_fault+0x1b8/0x420
> [  148.845545]  [<ffffffff811a05ed>] __do_fault+0x3d/0x70
> [  148.846706]  [<ffffffff811a4478>] handle_mm_fault+0x988/0x1230
> [  148.848042]  [<ffffffff81090305>] __do_page_fault+0x1a5/0x460
> [  148.849333]  [<ffffffff81090675>] trace_do_page_fault+0x45/0x130
> [  148.850681]  [<ffffffff8108b8ce>] do_async_page_fault+0x1e/0xd0
> [  148.852025]  [<ffffffff81dd1567>] ? schedule+0x37/0x90
> [  148.853187]  [<ffffffff81dd8b88>] async_page_fault+0x28/0x30
> [  148.854456] Mem-Info:
> [  148.854986] Node 0 DMA per-cpu:
> [  148.855727] CPU    0: hi:    0, btch:   1 usd:   0
> [  148.856820] Node 0 DMA32 per-cpu:
> [  148.857600] CPU    0: hi:  186, btch:  31 usd:   0
> [  148.858688] active_anon:119251 inactive_anon:119329 isolated_anon:0
> [  148.858688]  active_file:19 inactive_file:2 isolated_file:0
> [  148.858688]  unevictable:0 dirty:0 writeback:0 unstable:0
> [  148.858688]  free:1965 slab_reclaimable:2816 slab_unreclaimable:2184
> [  148.858688]  mapped:3 shmem:2 pagetables:1259 bounce:0
> [  148.858688]  free_cma:0
> [  148.865606] Node 0 DMA free:3916kB min:60kB low:72kB high:88kB active_anon:5100kB inactive_anon:5324kB active_file:0kB inactive_file:8kB unevictable:0kB isolated(as
> [  148.874431] lowmem_reserve[]: 0 966 966 966
> [  148.875504] Node 0 DMA32 free:3944kB min:3944kB low:4928kB high:5916kB active_anon:471904kB inactive_anon:471992kB active_file:76kB inactive_file:0kB unevictable:0s
> [  148.884817] lowmem_reserve[]: 0 0 0 0
> [  148.885770] Node 0 DMA: 1*4kB (M) 1*8kB (U) 2*16kB (UM) 3*32kB (UM) 1*64kB (M) 1*128kB (M) 0*256kB 1*512kB (M) 1*1024kB (M) 1*2048kB (R) 0*4096kB = 3916kB
> [  148.889385] Node 0 DMA32: 8*4kB (UEM) 2*8kB (UR) 3*16kB (M) 1*32kB (M) 2*64kB (MR) 1*128kB (R) 0*256kB 1*512kB (R) 1*1024kB (R) 1*2048kB (R) 0*4096kB = 3968kB
> [  148.893068] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [  148.894949] 47361 total pagecache pages
> [  148.895816] 47334 pages in swap cache
> [  148.896657] Swap cache stats: add 124669, delete 77335, find 83/169
> [  148.898057] Free swap  = 0kB
> [  148.898714] Total swap = 497976kB
> [  148.899470] 262044 pages RAM
> [  148.900145] 0 pages HighMem/MovableOnly
> [  148.901006] 10253 pages reserved
> [  148.901735] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [  148.903637] [ 1204]     0  1204     6039        1      15       3      163         -1000 udevd
> [  148.905571] [ 1323]     0  1323     6038        1      14       3      165         -1000 udevd
> [  148.907499] [ 1324]     0  1324     6038        1      14       3      164         -1000 udevd
> [  148.909439] [ 2176]     0  2176     2524        0       6       2      571             0 dhclient
> [  148.911427] [ 2227]     0  2227     9267        0      22       3       95             0 rpcbind
> [  148.913392] [ 2632]     0  2632    64981       30      29       3      136             0 rsyslogd
> [  148.915391] [ 2686]     0  2686     1062        1       6       3       36             0 acpid
> [  148.917325] [ 2826]     0  2826     4753        0      12       2       44             0 atd
> [  148.919209] [ 2877]     0  2877     6473        0      17       3       66             0 cron
> [  148.921120] [ 2911]   104  2911     7078        1      17       3       81             0 dbus-daemon
> [  148.923150] [ 3591]     0  3591    13731        0      28       2      165         -1000 sshd
> [  148.925073] [ 3603]     0  3603    22024        0      43       2      215             0 winbindd
> [  148.927066] [ 3612]     0  3612    22024        0      42       2      216             0 winbindd
> [  148.929062] [ 3636]     0  3636     3722        1      11       3       41             0 getty
> [  148.930981] [ 3637]     0  3637     3722        1      11       3       40             0 getty
> [  148.932915] [ 3638]     0  3638     3722        1      11       3       39             0 getty
> [  148.934835] [ 3639]     0  3639     3722        1      11       3       40             0 getty
> [  148.936789] [ 3640]     0  3640     3722        1      11       3       40             0 getty
> [  148.938704] [ 3641]     0  3641     3722        1      10       3       38             0 getty
> [  148.940635] [ 3642]     0  3642     3677        1      11       3       40             0 getty
> [  148.942550] [ 3643]     0  3643    25894        2      52       2      248             0 sshd
> [  148.944469] [ 3649]     0  3649   146652        1      35       4      320             0 console-kit-dae
> [  148.946578] [ 3716]     0  3716    48287        1      31       4      171             0 polkitd
> [  148.948552] [ 3722]  1000  3722    25894        0      51       2      250             0 sshd
> [  148.950457] [ 3723]  1000  3723     5435        3      15       3      495             0 bash
> [  148.952375] [ 3742]     0  3742    17157        1      37       2      160             0 sudo
> [  148.954275] [ 3743]     0  3743     3365        1      11       3      516             0 check
> [  148.956229] [ 4130]     0  4130     3334        1      11       3      484             0 084
> [  148.958108] [ 4342]     0  4342   314556   191159     619       4   119808             0 resvtest
> [  148.960104] [ 4343]     0  4343     3334        0      11       3      485             0 084
> [  148.961990] [ 4344]     0  4344     3334        0      11       3      485             0 084
> [  148.963876] [ 4345]     0  4345     3305        0      11       3       36             0 sed
> [  148.965766] [ 4346]     0  4346     3305        0      11       3       37             0 sed
> [  148.967652] Out of memory: Kill process 4342 (resvtest) score 803 or sacrifice child
> [  148.969390] Killed process 4342 (resvtest) total-vm:1258224kB, anon-rss:764636kB, file-rss:0kB
> [  149.415288] XFS (vda): Unmounting Filesystem
> [  150.211229] XFS (vda): Mounting V5 Filesystem
> [  150.292092] XFS (vda): Ending clean mount
> [  150.342307] XFS (vda): Unmounting Filesystem
> [  150.346522] XFS (vdb): Unmounting Filesystem
> [  151.264135] XFS: kmalloc allocations by trans type
> [  151.265195] XFS: 3: count 7, bytes 3992, fails 0, max_size 1024
> [  151.266479] XFS: 4: count 3, bytes 400, fails 0, max_size 144
> [  151.267735] XFS: 7: count 9, bytes 2784, fails 0, max_size 536
> [  151.269022] XFS: 16: count 1, bytes 696, fails 0, max_size 696
> [  151.270286] XFS: 26: count 1, bytes 384, fails 0, max_size 384
> [  151.271550] XFS: 35: count 1, bytes 696, fails 0, max_size 696
> [  151.272833] XFS: slab allocations by trans type
> [  151.273818] XFS: 3: count 22, bytes 0, fails 0, max_size 0
> [  151.275010] XFS: 4: count 13, bytes 0, fails 0, max_size 0
> [  151.276212] XFS: 7: count 12, bytes 0, fails 0, max_size 0
> [  151.277406] XFS: 15: count 2, bytes 0, fails 0, max_size 0
> [  151.278595] XFS: 16: count 10, bytes 0, fails 0, max_size 0
> [  151.279854] XFS: 18: count 2, bytes 0, fails 0, max_size 0
> [  151.281080] XFS: 26: count 3, bytes 0, fails 0, max_size 0
> [  151.282275] XFS: 35: count 2, bytes 0, fails 0, max_size 0
> [  151.283476] XFS: vmalloc allocations by trans type
> [  151.284535] XFS: page allocations by trans type
> 
> Those XFS allocation stats are largest measured allocations done
> under transaction context broken down by allocation and transaction
> type.  No failures that would result in looping, even though the
> system invoked the OOM killer on a filesystem workload....
> 
> I need to break the slab allocations down further by cache (other
> workloads are generating over 50 slab allocations per transaction),
> but another hour's work and a few days of observation of the stats
> in my normal day-to-day work wll get me all the information I need
> to do a decent first pass at memory reservation requirements for
> XFS.
> 

This sounds like something that would serve us well under sysfs,
particularly if we do adopt the kind of reservation model being
discussed in this thread. I wouldn't expect these values to change
drastically or that often, but they could certainly adjust over time to
the point of being out of line with a reservation. A tool like this
combined with Johannes' idea of a warning or something along those lines
for a reservation overrun should give us all we need to identify
something is wrong and have the ability to fix it.

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
