Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B630B6B0038
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 09:55:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v190so18968537pfb.5
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 06:55:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b4si13647021pli.298.2017.03.04.06.55.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Mar 2017 06:55:07 -0800 (PST)
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
	<20170303133950.GD31582@dhcp22.suse.cz>
	<20170303153720.GC21245@bfoster.bfoster>
	<20170303155258.GJ31499@dhcp22.suse.cz>
	<20170303172904.GE21245@bfoster.bfoster>
In-Reply-To: <20170303172904.GE21245@bfoster.bfoster>
Message-Id: <201703042354.DCH17637.JOHSFOQFFVOMLt@I-love.SAKURA.ne.jp>
Date: Sat, 4 Mar 2017 23:54:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bfoster@redhat.com, mhocko@kernel.org
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org

Brian Foster wrote:
> On Fri, Mar 03, 2017 at 04:52:58PM +0100, Michal Hocko wrote:
> > On Fri 03-03-17 10:37:21, Brian Foster wrote:
> > [...]
> > > That aside, looking through some of the traces in this case...
> > > 
> > > - kswapd0 is waiting on an inode flush lock. This means somebody else
> > >   flushed the inode and it won't be unlocked until the underlying buffer
> > >   I/O is completed. This context is also holding pag_ici_reclaim_lock
> > >   which is what probably blocks other contexts from getting into inode
> > >   reclaim.
> > > - xfsaild is in xfs_iflush(), which means it has the inode flush lock.
> > >   It's waiting on reading the underlying inode buffer. The buffer read
> > >   sets b_ioend_wq to the xfs-buf wq, which is ultimately going to be
> > >   queued in xfs_buf_bio_end_io()->xfs_buf_ioend_async(). The associated
> > >   work item is what eventually triggers the I/O completion in
> > >   xfs_buf_ioend().
> > > 
> > > So at this point reclaim is waiting on a read I/O completion. It's not
> > > clear to me whether the read had completed and the work item was queued
> > > or not. I do see the following in the workqueue lockup BUG output:
> > > 
> > > [  273.412600] workqueue xfs-buf/sda1: flags=0xc
> > > [  273.414486]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
> > > [  273.416415]     pending: xfs_buf_ioend_work [xfs]
> > > 
> > > ... which suggests that it was queued..? I suppose this could be one of
> > > the workqueues waiting on a kthread, but xfs-buf also has a rescuer that
> > > appears to be idle:
> > > 
> > > [ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
> > > [ 1041.556813] Call Trace:
> > > [ 1041.557796]  __schedule+0x336/0xe00
> > > [ 1041.558983]  schedule+0x3d/0x90
> > > [ 1041.560085]  rescuer_thread+0x322/0x3d0
> > > [ 1041.561333]  kthread+0x10f/0x150
> > > [ 1041.562464]  ? worker_thread+0x4b0/0x4b0
> > > [ 1041.563732]  ? kthread_create_on_node+0x70/0x70
> > > [ 1041.565123]  ret_from_fork+0x31/0x40
> > > 
> > > So shouldn't that thread pick up the work item if that is the case?
> > 
> > Is it possible that the progress is done but tediously slow? Keep in
> > mind that the test case is doing write from 1k processes while one
> > process basically consumes all the memory. So I wouldn't be surprised
> > if this just made system to crawl on any attempt to do an IO.
> 
> That would seem like a possibility to me.. either waiting on an actual
> I/O (no guarantee that the pending xfs-buf item is the one we care about
> I suppose) completion or waiting for whatever needs to happen for the wq
> infrastructure to kick off the rescuer. Though I think that's probably
> something Tetsuo would ultimately have to confirm on his setup..

This lockup began from uptime = 444. Thus, please ignore logs up to

[  444.281177] Killed process 9477 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  444.287046] oom_reaper: reaped process 9477 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

line because memory reclaim was making progress and the OOM killer was being invoked.
Also, while it is true that this stressing program tries to create 1024 child processes,
majority of child processes are simply waiting at open() syscall

[ 1056.479865] a.out           D13992  9655   9473 0x00000080
[ 1056.481471] Call Trace:
[ 1056.482474]  __schedule+0x336/0xe00
[ 1056.483690]  schedule+0x3d/0x90
[ 1056.484825]  rwsem_down_write_failed+0x240/0x470
[ 1056.486252]  ? rwsem_down_write_failed+0x65/0x470
[ 1056.487703]  call_rwsem_down_write_failed+0x17/0x30
[ 1056.489185]  ? path_openat+0x60b/0xd50
[ 1056.490441]  down_write+0x95/0xc0
[ 1056.491614]  ? path_openat+0x60b/0xd50
[ 1056.492865]  path_openat+0x60b/0xd50
[ 1056.494089]  ? ___slab_alloc+0x5c6/0x620
[ 1056.495370]  do_filp_open+0x91/0x100
[ 1056.496574]  ? _raw_spin_unlock+0x27/0x40
[ 1056.497873]  ? __alloc_fd+0xf7/0x210
[ 1056.499086]  do_sys_open+0x124/0x210
[ 1056.500290]  SyS_open+0x1e/0x20
[ 1056.501402]  do_syscall_64+0x6c/0x200
[ 1056.502611]  entry_SYSCALL64_slow_path+0x25/0x25

which means that these child processes are irrelevant to this problem.
They are simply trying to make this stressing program last for a few minutes
in order to eliminate time waiting for memory consumer process to consume
all memory again and again.

Only 184 processes were doing memory allocation when lockup began.

[  518.090012] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=8441307
[  553.070829] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=10318507
[  616.394649] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=13908219
[  642.266252] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=15180673
[  702.412189] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=18732529
[  736.787879] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=20565244
[  800.715759] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=24411576
[  837.571405] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=26463562
[  899.021495] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=30144879
[  936.282709] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=32129234
[  997.328119] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=35657983
[ 1033.977265] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=37659912
[ 1095.630961] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40639677
[ 1095.821248] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40646791

But most of processes doing memory allocation were blocked on locks when lockup began.

[  518.092627] MemAlloc: kthreadd(2) flags=0x208840 switches=313 seq=5 gfp=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK) order=2 delay=74546 uninterruptible
[  518.319917] MemAlloc: kworker/2:0(27) flags=0x4208860 switches=14350 seq=21 gfp=0x1400000(GFP_NOIO) order=0 delay=74621
[  518.437336] MemAlloc: khugepaged(47) flags=0x200840 switches=26 seq=8 gfp=0x4742ca(GFP_TRANSHUGE|__GFP_THISNODE) order=9 delay=36854 uninterruptible
[  518.605804] MemAlloc: kworker/1:1(52) flags=0x4228060 switches=4112 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74544
[  518.756891] MemAlloc: kworker/2:1(65) flags=0x4228860 switches=2749 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74504
[  518.900038] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
[  518.963034] MemAlloc: kworker/1:2(193) flags=0x4228060 switches=4426 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545 uninterruptible
[  519.049597] MemAlloc: xfs-data/sda1(451) flags=0x4228860 switches=6525 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74534
[  519.135487] MemAlloc: systemd-journal(526) flags=0x400900 switches=22443 seq=43228 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74224 uninterruptible
[  519.371973] MemAlloc: kworker/2:3(535) flags=0x4228060 switches=29263 seq=57 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545 uninterruptible
[  519.502080] MemAlloc: auditd(564) flags=0x400900 switches=897 seq=250 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=59753 uninterruptible
[  519.681032] MemAlloc: tuned(2526) flags=0x400840 switches=22780 seq=42374 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74205 uninterruptible
[  519.850986] MemAlloc: irqbalance(726) flags=0x400900 switches=17821 seq=18779 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73843 uninterruptible
[  520.003760] MemAlloc: vmtoolsd(737) flags=0x400900 switches=23616 seq=38031 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74364 uninterruptible
[  520.171223] MemAlloc: systemd-logind(817) flags=0x400900 switches=2878 seq=7734 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=56256 uninterruptible
[  520.374034] MemAlloc: crond(859) flags=0x400900 switches=5562 seq=6922 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=43400 uninterruptible
[  520.526133] MemAlloc: gmain(2873) flags=0x400840 switches=19609 seq=19603 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74080 uninterruptible
[  520.749935] MemAlloc: kworker/0:3(2486) flags=0x4228060 switches=37566 seq=10 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74525 uninterruptible
[  520.814386] MemAlloc: master(2491) flags=0x400940 switches=5275 seq=4376 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=46072 uninterruptible
[  520.909697] MemAlloc: vmtoolsd(2497) flags=0x400900 switches=22477 seq=33640 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74173 uninterruptible
[  521.011345] MemAlloc: nmbd(2521) flags=0x400940 switches=22908 seq=36949 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=72001 uninterruptible
[  521.243774] MemAlloc: lpqd(3032) flags=0x400840 switches=7889 seq=11697 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=58023 uninterruptible
[  521.472130] MemAlloc: kworker/3:3(5356) flags=0x4228860 switches=16212 seq=6 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74547
[  521.536605] MemAlloc: kworker/1:3(5357) flags=0x4228860 switches=6647 seq=3 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545
[  521.692946] MemAlloc: kworker/1:4(5358) flags=0x4228060 switches=3718 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545
[  521.817708] MemAlloc: kworker/3:5(6386) flags=0x4228060 switches=30373 seq=15 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74548
[  521.955723] MemAlloc: kworker/2:4(7415) flags=0x4228860 switches=3304 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74539
[  522.115239] MemAlloc: kworker/2:5(7416) flags=0x4228060 switches=2851 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74530 uninterruptible
[  522.246011] MemAlloc: kworker/1:5(7418) flags=0x4208860 switches=17514 seq=5 gfp=0x14002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN) order=0 delay=73160 uninterruptible
[  522.418809] MemAlloc: a.out(9473) flags=0x400800 switches=153 seq=10699 gfp=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=75047 uninterruptible
[  522.576919] MemAlloc: a.out(9477) flags=0x420040 switches=27 uninterruptible dying victim
[  522.797074] MemAlloc: a.out(9480) flags=0x400840 switches=39 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  523.008893] MemAlloc: a.out(9481) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  523.230713] MemAlloc: a.out(9482) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  523.440192] MemAlloc: a.out(9483) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  523.622972] MemAlloc: a.out(9485) flags=0x400840 switches=32 seq=5 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  523.802630] MemAlloc: a.out(9486) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  523.977233] MemAlloc: a.out(9492) flags=0x400840 switches=28 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  524.143441] MemAlloc: a.out(9494) flags=0x400840 switches=30 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  524.303139] MemAlloc: a.out(9495) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  524.477860] MemAlloc: a.out(9496) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  524.605941] MemAlloc: a.out(9497) flags=0x400840 switches=53 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  524.818506] MemAlloc: a.out(9498) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  525.053989] MemAlloc: a.out(9499) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  525.209989] MemAlloc: a.out(9500) flags=0x400840 switches=28 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  525.398782] MemAlloc: a.out(9501) flags=0x400840 switches=34 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  525.575204] MemAlloc: a.out(9502) flags=0x400840 switches=44 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  525.865094] MemAlloc: a.out(9503) flags=0x400840 switches=30 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  526.048023] MemAlloc: a.out(9504) flags=0x400840 switches=30 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  526.228154] MemAlloc: a.out(9505) flags=0x400840 switches=32 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  526.359385] MemAlloc: a.out(9507) flags=0x400840 switches=30 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73842 uninterruptible
[  526.568938] MemAlloc: a.out(9508) flags=0x400840 switches=28 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  526.744746] MemAlloc: a.out(9509) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  526.945986] MemAlloc: a.out(9510) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73963 uninterruptible
[  527.166154] MemAlloc: a.out(9511) flags=0x400040 switches=1996 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74941
[  527.324939] MemAlloc: a.out(9512) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  527.526047] MemAlloc: a.out(9513) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  527.726877] MemAlloc: a.out(9514) flags=0x400840 switches=40 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  527.952047] MemAlloc: a.out(9515) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  528.132160] MemAlloc: a.out(9516) flags=0x400840 switches=63 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73962 uninterruptible
[  528.329563] MemAlloc: a.out(9517) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  528.501754] MemAlloc: a.out(9519) flags=0x400840 switches=24 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  528.649021] MemAlloc: a.out(9520) flags=0x400840 switches=29 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  528.842687] MemAlloc: a.out(9522) flags=0x400840 switches=37 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73961 uninterruptible
[  529.014041] MemAlloc: a.out(9523) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  529.193899] MemAlloc: a.out(9524) flags=0x400840 switches=24 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  529.360486] MemAlloc: a.out(9525) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  529.572691] MemAlloc: a.out(9526) flags=0x400840 switches=39 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  529.924087] MemAlloc: a.out(9527) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  530.137611] MemAlloc: a.out(9528) flags=0x400840 switches=27 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  530.359847] MemAlloc: a.out(9529) flags=0x400840 switches=26 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  530.569215] MemAlloc: a.out(9530) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  530.784715] MemAlloc: a.out(9531) flags=0x400840 switches=25 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  530.993554] MemAlloc: a.out(9532) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  531.163695] MemAlloc: a.out(9533) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  531.340946] MemAlloc: a.out(9534) flags=0x400840 switches=27 seq=5 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  531.517626] MemAlloc: a.out(9536) flags=0x400840 switches=21 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  531.683190] MemAlloc: a.out(9537) flags=0x400840 switches=74 seq=191 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74134 uninterruptible
[  531.843838] MemAlloc: a.out(9538) flags=0x400840 switches=26 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  532.005303] MemAlloc: a.out(9541) flags=0x400840 switches=40 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74231 uninterruptible
[  532.195906] MemAlloc: a.out(9542) flags=0x400840 switches=31 seq=35 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74256 uninterruptible
[  532.430946] MemAlloc: a.out(9545) flags=0x420840 switches=2014 seq=7 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=1 delay=74581
[  532.642039] MemAlloc: a.out(9546) flags=0x400840 switches=23 seq=79 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  532.875209] MemAlloc: a.out(9550) flags=0x400840 switches=21 seq=5 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  532.995120] MemAlloc: a.out(9551) flags=0x420040 switches=2151 seq=3 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=74577
[  533.160574] MemAlloc: a.out(9554) flags=0x400840 switches=20 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73962 uninterruptible
[  533.383124] MemAlloc: a.out(9555) flags=0x400040 switches=2059 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74949
[  533.548238] MemAlloc: a.out(9556) flags=0x400840 switches=22 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  533.793954] MemAlloc: a.out(9558) flags=0x400840 switches=22 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  534.027669] MemAlloc: a.out(9560) flags=0x400840 switches=22 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  534.274691] MemAlloc: a.out(9561) flags=0x400840 switches=21 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  534.479135] MemAlloc: a.out(9562) flags=0x400840 switches=17 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  534.644896] MemAlloc: a.out(9563) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  534.924052] MemAlloc: a.out(9564) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  535.202235] MemAlloc: a.out(9565) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  535.436619] MemAlloc: a.out(9566) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  535.638534] MemAlloc: a.out(9567) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  535.886729] MemAlloc: a.out(9568) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73841 uninterruptible
[  536.123130] MemAlloc: a.out(9569) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  536.358902] MemAlloc: a.out(9570) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  536.603860] MemAlloc: a.out(9571) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  536.709749] MemAlloc: a.out(9572) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  536.942101] MemAlloc: a.out(9573) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  537.127875] MemAlloc: a.out(9574) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73841 uninterruptible
[  537.310662] MemAlloc: a.out(9575) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  537.455864] MemAlloc: a.out(9576) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73841 uninterruptible
[  537.675090] MemAlloc: a.out(9579) flags=0x400040 switches=2251 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74933
[  537.779100] MemAlloc: a.out(9581) flags=0x400840 switches=26 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  537.925518] MemAlloc: a.out(9583) flags=0x400840 switches=46 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  538.169936] MemAlloc: a.out(9586) flags=0x400840 switches=32 seq=129 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=74232 uninterruptible
[  538.406918] MemAlloc: a.out(9587) flags=0x400840 switches=28 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  538.642036] MemAlloc: a.out(9591) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  538.866188] MemAlloc: a.out(9592) flags=0x400840 switches=49 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  539.119566] MemAlloc: a.out(9593) flags=0x400840 switches=65 seq=35 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73960 uninterruptible
[  539.378634] MemAlloc: a.out(9595) flags=0x400040 switches=32 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74939 uninterruptible
[  539.556915] MemAlloc: a.out(9597) flags=0x400840 switches=48 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  539.787355] MemAlloc: a.out(9599) flags=0x400840 switches=24 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  540.015041] MemAlloc: a.out(9600) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  540.148695] MemAlloc: a.out(9605) flags=0x400840 switches=27 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  540.237056] MemAlloc: a.out(9606) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  540.333568] MemAlloc: a.out(9607) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73841 uninterruptible
[  540.434293] MemAlloc: a.out(9608) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  540.590569] MemAlloc: a.out(9609) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  540.732138] MemAlloc: a.out(9610) flags=0x400840 switches=29 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  540.961649] MemAlloc: a.out(9611) flags=0x400840 switches=27 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  541.218220] MemAlloc: a.out(9612) flags=0x400840 switches=16 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  541.375479] MemAlloc: a.out(9613) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  541.571384] MemAlloc: a.out(9614) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  541.754231] MemAlloc: a.out(9615) flags=0x400840 switches=17 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  541.896925] MemAlloc: a.out(9616) flags=0x400840 switches=18 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  542.056536] MemAlloc: a.out(9617) flags=0x400840 switches=17 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  542.229652] MemAlloc: a.out(9618) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  542.364170] MemAlloc: a.out(9619) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  542.493472] MemAlloc: a.out(9620) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  542.679770] MemAlloc: a.out(9621) flags=0x400840 switches=16 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  542.865175] MemAlloc: a.out(9622) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  542.972020] MemAlloc: a.out(9623) flags=0x400840 switches=15 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  543.135246] MemAlloc: a.out(9624) flags=0x400840 switches=18 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  543.358968] MemAlloc: a.out(9625) flags=0x400840 switches=16 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  543.583466] MemAlloc: a.out(9626) flags=0x400840 switches=17 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  543.809065] MemAlloc: a.out(9627) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  544.017351] MemAlloc: a.out(9628) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  544.217362] MemAlloc: a.out(9629) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  544.462068] MemAlloc: a.out(9630) flags=0x400840 switches=21 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  544.699780] MemAlloc: a.out(9631) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  544.895071] MemAlloc: a.out(9632) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  545.080182] MemAlloc: a.out(9633) flags=0x400840 switches=31 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  545.352169] MemAlloc: a.out(9634) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  545.493870] MemAlloc: a.out(9635) flags=0x400840 switches=14 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  545.609266] MemAlloc: a.out(9636) flags=0x400840 switches=16 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  545.725966] MemAlloc: a.out(9637) flags=0x400840 switches=18 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73963 uninterruptible
[  545.812656] MemAlloc: a.out(9638) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73735 uninterruptible
[  545.984346] MemAlloc: a.out(9639) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  546.170187] MemAlloc: a.out(9640) flags=0x400840 switches=15 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  546.351502] MemAlloc: a.out(9641) flags=0x400840 switches=14 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  546.529103] MemAlloc: a.out(9646) flags=0x400840 switches=11 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  546.710185] MemAlloc: a.out(9647) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  546.852608] MemAlloc: a.out(9648) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.014298] MemAlloc: a.out(9650) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.188938] MemAlloc: a.out(9651) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.362058] MemAlloc: a.out(9652) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.471970] MemAlloc: a.out(9653) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.706983] MemAlloc: a.out(9654) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  547.870033] MemAlloc: a.out(9656) flags=0x400840 switches=12 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  548.079204] MemAlloc: a.out(9662) flags=0x400840 switches=12 seq=209 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  548.305820] MemAlloc: a.out(9664) flags=0x400840 switches=20 seq=302 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  548.525819] MemAlloc: a.out(9666) flags=0x400840 switches=11 seq=25 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  548.793002] MemAlloc: a.out(9668) flags=0x400840 switches=12 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  549.006725] MemAlloc: a.out(9670) flags=0x400840 switches=12 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  549.232993] MemAlloc: a.out(9671) flags=0x400840 switches=10 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  549.469884] MemAlloc: a.out(9672) flags=0x400840 switches=11 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  549.727175] MemAlloc: a.out(9673) flags=0x400840 switches=13 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  549.987420] MemAlloc: a.out(9674) flags=0x400840 switches=13 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73839 uninterruptible
[  550.214963] MemAlloc: a.out(9675) flags=0x400840 switches=10 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  550.421057] MemAlloc: a.out(9676) flags=0x400840 switches=11 seq=2 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73835 uninterruptible
[  550.654050] MemAlloc: a.out(9677) flags=0x400840 switches=13 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  550.841175] MemAlloc: a.out(9678) flags=0x400840 switches=13 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  551.030916] MemAlloc: a.out(9679) flags=0x400840 switches=13 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  551.213400] MemAlloc: a.out(9681) flags=0x400840 switches=13 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  551.401337] MemAlloc: a.out(9682) flags=0x400840 switches=13 seq=4 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  551.604094] MemAlloc: a.out(9683) flags=0x400840 switches=12 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  551.783882] MemAlloc: a.out(9684) flags=0x400840 switches=12 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73838 uninterruptible
[  551.971142] MemAlloc: a.out(9685) flags=0x420840 switches=2357 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=74818
[  552.137039] MemAlloc: a.out(9686) flags=0x400840 switches=12 seq=3 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=73836 uninterruptible
[  552.342766] MemAlloc: a.out(9689) flags=0x400040 switches=2370 seq=3 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74818
[  552.453767] MemAlloc: kworker/3:0(10498) flags=0x4228860 switches=4184 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74548

Only 17 out of 186 processes were able to loop inside page allocator.

[  518.319917] MemAlloc: kworker/2:0(27) flags=0x4208860 switches=14350 seq=21 gfp=0x1400000(GFP_NOIO) order=0 delay=74621
[  518.605804] MemAlloc: kworker/1:1(52) flags=0x4228060 switches=4112 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74544
[  518.756891] MemAlloc: kworker/2:1(65) flags=0x4228860 switches=2749 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74504
[  519.049597] MemAlloc: xfs-data/sda1(451) flags=0x4228860 switches=6525 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74534
[  521.472130] MemAlloc: kworker/3:3(5356) flags=0x4228860 switches=16212 seq=6 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74547
[  521.536605] MemAlloc: kworker/1:3(5357) flags=0x4228860 switches=6647 seq=3 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545
[  521.692946] MemAlloc: kworker/1:4(5358) flags=0x4228060 switches=3718 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74545
[  521.817708] MemAlloc: kworker/3:5(6386) flags=0x4228060 switches=30373 seq=15 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74548
[  521.955723] MemAlloc: kworker/2:4(7415) flags=0x4228860 switches=3304 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74539
[  527.166154] MemAlloc: a.out(9511) flags=0x400040 switches=1996 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74941
[  532.430946] MemAlloc: a.out(9545) flags=0x420840 switches=2014 seq=7 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=1 delay=74581
[  532.995120] MemAlloc: a.out(9551) flags=0x420040 switches=2151 seq=3 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=74577
[  533.383124] MemAlloc: a.out(9555) flags=0x400040 switches=2059 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74949
[  537.675090] MemAlloc: a.out(9579) flags=0x400040 switches=2251 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74933
[  551.971142] MemAlloc: a.out(9685) flags=0x420840 switches=2357 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=74818
[  552.342766] MemAlloc: a.out(9689) flags=0x400040 switches=2370 seq=3 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=74818
[  552.453767] MemAlloc: kworker/3:0(10498) flags=0x4228860 switches=4184 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=74548

Situation was similar when I gave up waiting.
Only 20 out of 192 processes were able to loop inside page allocator.

[ 1095.631687] MemAlloc: kworker/2:0(27) flags=0x4208860 switches=38727 seq=21 gfp=0x1400000(GFP_NOIO) order=0 delay=652160
[ 1095.632186] MemAlloc: kworker/1:1(52) flags=0x4228860 switches=28036 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652083
[ 1095.632604] MemAlloc: kworker/2:1(65) flags=0x4228060 switches=22879 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652043
[ 1095.633213] MemAlloc: kworker/1:2(193) flags=0x4228860 switches=28494 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.633625] MemAlloc: xfs-data/sda1(451) flags=0x4228060 switches=45509 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652073
[ 1095.634013] MemAlloc: xfs-eofblocks/s(456) flags=0x4228860 switches=15435 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=293074
[ 1095.635223] MemAlloc: kworker/2:3(535) flags=0x4228860 switches=49285 seq=57 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.638807] MemAlloc: kworker/0:3(2486) flags=0x4228860 switches=76240 seq=10 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652064
[ 1095.644936] MemAlloc: kworker/3:3(5356) flags=0x4228860 switches=29192 seq=6 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652086
[ 1095.645241] MemAlloc: kworker/1:3(5357) flags=0x4228860 switches=30893 seq=3 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.645506] MemAlloc: kworker/1:4(5358) flags=0x4228060 switches=27329 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.647293] MemAlloc: kworker/3:5(6386) flags=0x4228860 switches=43427 seq=15 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652087
[ 1095.691898] MemAlloc: a.out(9511) flags=0x400040 switches=14710 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=652480
[ 1095.726301] MemAlloc: a.out(9545) flags=0x420040 switches=14120 seq=7 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=1 delay=652120
[ 1095.727373] MemAlloc: a.out(9551) flags=0x420840 switches=14617 seq=3 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=652116
[ 1095.728228] MemAlloc: a.out(9555) flags=0x400040 switches=14575 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=652488
[ 1095.739636] MemAlloc: a.out(9579) flags=0x400840 switches=14791 seq=2 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=652472
[ 1095.805447] MemAlloc: a.out(9685) flags=0x420840 switches=14309 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=652357
[ 1095.806316] MemAlloc: a.out(9689) flags=0x400840 switches=14131 seq=3 gfp=0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=652357
[ 1095.806606] MemAlloc: kworker/3:0(10498) flags=0x4228060 switches=16222 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652087

You can't say that 1024 processes were doing write() requests. Many were still
blocked at open(). Only 20 or so processes were able to consume CPU time for
memory allocation. I don't think this is a too insane stress to wait. This is not
a stress which can justify stalls over 10 minutes. The kworker/2:0(27) line
indicates that order-0 GFP_NOIO allocation request was unable to find a page
for more than 10 minutes. Under such situation, how can other GFP_NOFS allocation
requests find a page without boosting priority (unless someone releases memory
voluntarily) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
