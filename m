Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1D086B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 00:15:12 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so307560689pgc.1
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 21:15:12 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b62si14275458pli.103.2016.12.17.21.15.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Dec 2016 21:15:11 -0800 (PST)
Subject: Re: OOM: Better, but still there on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161216184655.GA5664@boerne.fritz.box>
	<20161217000203.GC23392@dhcp22.suse.cz>
	<20161217125950.GA3321@boerne.fritz.box>
	<862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
	<20161217210646.GA11358@boerne.fritz.box>
In-Reply-To: <20161217210646.GA11358@boerne.fritz.box>
Message-Id: <201612181414.ICD78142.SVtOFJLOFOFMHQ@I-love.SAKURA.ne.jp>
Date: Sun, 18 Dec 2016 14:14:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nholland@tisys.org, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, dsterba@suse.cz, linux-btrfs@vger.kernel.org

Nils Holland wrote:
> On Sat, Dec 17, 2016 at 11:44:45PM +0900, Tetsuo Handa wrote:
> > On 2016/12/17 21:59, Nils Holland wrote:
> > > On Sat, Dec 17, 2016 at 01:02:03AM +0100, Michal Hocko wrote:
> > >> mount -t tracefs none /debug/trace
> > >> echo 1 > /debug/trace/events/vmscan/enable
> > >> cat /debug/trace/trace_pipe > trace.log
> > >>
> > >> should help
> > >> [...]
> > >
> > > No problem! I enabled writing the trace data to a file and then tried
> > > to trigger another OOM situation. That worked, this time without a
> > > complete kernel panic, but with only my processes being killed and the
> > > system becoming unresponsive.
> >
> > Under OOM situation, writing to a file on disk unlikely works. Maybe
> > logging via network ( "cat /debug/trace/trace_pipe > /dev/udp/$ip/$port"
> > if your are using bash) works better. (I wish we can do it from kernel
> > so that /bin/cat is not disturbed by delays due to page fault.)
> >
> > If you can configure netconsole for logging OOM killer messages and
> > UDP socket for logging trace_pipe messages, udplogger at
> > https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/
> > might fit for logging both output with timestamp into a single file.
>
> Actually, I decided to give this a try once more on machine #2, i.e.
> not the one that produced the previous trace, but the other one.
>
> I logged via netconsole as well as 'cat /debug/trace/trace_pipe' via
> the network to another machine running udplogger. After the machine
> had been frehsly booted and I had set up the logging, unpacking of the
> firefox source tarball started. After it had been unpacking for a
> while, the first load of trace messages started to appear. Some time
> later, OOMs started to appear - I've got quite a lot of them in my
> capture file this time.

Thank you for capturing. I think it worked well. Let's wait for Michal.

The first OOM killer invocation was

  2016-12-17 21:36:56 192.168.17.23:6665 [ 1276.828639] Killed process 3894 (xz) total-vm:68640kB, anon-rss:65920kB, file-rss:1696kB, shmem-rss:0kB

and the last OOM killer invocation was

  2016-12-17 21:39:27 192.168.17.23:6665 [ 1426.800677] Killed process 3070 (screen) total-vm:7440kB, anon-rss:960kB, file-rss:2360kB, shmem-rss:0kB

and trace output was sent until

  2016-12-17 21:37:07 192.168.17.23:48468     kworker/u4:4-3896  [000] ....  1287.202958: mm_shrink_slab_start: super_cache_scan+0x0/0x170 f4436ed4: nid: 0 objects to shrink 86 gfp_flags GFP_NOFS|__GFP_NOFAIL pgs_scanned 32 lru_pgs 406078 cache items 412 delta 0 total_scan 86

which (I hope) should be sufficient for analysis.

>
> Unfortunately, the reclaim trace messages stopped a while after the first
> OOM messages show up - most likely my "cat" had been killed at that
> point or became unresponsive. :-/
>
> In the end, the machine didn't completely panic, but after nothing new
> showed up being logged via the network, I walked up to the
> machine and found it in a state where I couldn't really log in to it
> anymore, but all that worked was, as always, a magic SysRequest reboot.

There is a known issue (since Linux 2.6.32) that all memory allocation requests
get stuck due to kswapd v.s. shrink_inactive_list() livelock which occurs under
almost OOM situation ( http://lkml.kernel.org/r/20160211225929.GU14668@dastard ).
If we hit it, even "page allocation stalls for " messages do not show up.

Even if we didn't hit it, although agetty and sshd were still alive

  2016-12-17 21:39:27 192.168.17.23:6665 [ 1426.800614] [ 2800]     0  2800     1152      494       6       3        0             0 agetty
  2016-12-17 21:39:27 192.168.17.23:6665 [ 1426.800618] [ 2802]     0  2802     1457     1055       6       3        0         -1000 sshd

memory allocation was delaying too much

  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034624] btrfs-transacti: page alloction stalls for 93995ms, order:0, mode:0x2400840(GFP_NOFS|__GFP_NOFAIL)
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034628] CPU: 1 PID: 1949 Comm: btrfs-transacti Not tainted 4.9.0-gentoo #3
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034630] Hardware name: Hewlett-Packard Compaq 15 Notebook PC/21F7, BIOS F.22 08/06/2014
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034638]  f162f94c c142bd8e 00000001 00000000 f162f970 c110ad7e c1b58833 02400840
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034645]  f162f978 f162f980 c1b55814 f162f960 00000160 f162fa38 c110b78c 02400840
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034652]  c1b55814 00016f2b 00000000 00400000 00000000 f21d0000 f21d0000 00000001
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034653] Call Trace:
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034660]  [<c142bd8e>] dump_stack+0x47/0x69
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034666]  [<c110ad7e>] warn_alloc+0xce/0xf0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034671]  [<c110b78c>] __alloc_pages_nodemask+0x97c/0xd30
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034678]  [<c1103fbd>] ? find_get_entry+0x1d/0x100
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034681]  [<c1102fc1>] ? add_to_page_cache_lru+0x61/0xc0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034685]  [<c110414d>] pagecache_get_page+0xad/0x270
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034692]  [<c1366556>] alloc_extent_buffer+0x116/0x3e0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034699]  [<c1334ade>] btrfs_find_create_tree_block+0xe/0x10
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034704]  [<c132a62f>] btrfs_alloc_tree_block+0x1ef/0x5f0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034710]  [<c1079050>] ? autoremove_wake_function+0x40/0x40
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034716]  [<c130f873>] __btrfs_cow_block+0x143/0x5f0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034723]  [<c130feca>] btrfs_cow_block+0x13a/0x220
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034727]  [<c13133a1>] btrfs_search_slot+0x1d1/0x870
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034731]  [<c131a74a>] lookup_inline_extent_backref+0x10a/0x6d0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034736]  [<c19b656c>] ? common_interrupt+0x2c/0x34
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034742]  [<c131c959>] __btrfs_free_extent+0x129/0xe80
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034750]  [<c1322160>] __btrfs_run_delayed_refs+0xaf0/0x13e0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034754]  [<c106f759>] ? set_next_entity+0x659/0xec0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034757]  [<c106c351>] ? put_prev_entity+0x21/0xcf0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034801]  [<fa83b2da>] ? xfs_attr3_leaf_add_work+0x25a/0x420 [xfs]
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034808]  [<c13259f1>] btrfs_run_delayed_refs+0x71/0x260
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034813]  [<c10903ef>] ? lock_timer_base+0x5f/0x80
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034818]  [<c133cefb>] btrfs_commit_transaction+0x2b/0xd30
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034821]  [<c133dc65>] ? start_transaction+0x65/0x4b0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034826]  [<c1337f65>] transaction_kthread+0x1b5/0x1d0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034830]  [<c1337db0>] ? btrfs_cleanup_transaction+0x490/0x490
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034833]  [<c10552e7>] kthread+0x97/0xb0
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034837]  [<c1055250>] ? __kthread_parkme+0x60/0x60
  2016-12-17 21:41:03 192.168.17.23:6665 [ 1521.034842]  [<c19b5d77>] ret_from_fork+0x1b/0x28

and therefore memory allocation by page fault by trying to login was too slow to wait.

>
> The complete log, from machine boot right up to the point where it
> wouldn't really do anything anymore, is up again on my web server (~42
> MB, 928 KB packed):
>
> http://ftp.tisys.org/pub/misc/teela_2016-12-17.log.xz
>
> Greetings
> Nils
>

It might be pointless to check, but is your 4.9.0-gentoo kernel using 4.9.0 final source?
The typo "page alloction stalls" was fixed in v4.9-rc5. Maybe some last minute changes are
missing...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
