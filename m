Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 344008D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 08:56:22 -0400 (EDT)
Date: Tue, 19 Apr 2011 20:56:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110419125616.GA20059@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <20110419095740.GC5257@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 19, 2011 at 05:57:40PM +0800, Jan Kara wrote:
> On Tue 19-04-11 17:35:23, Dave Chinner wrote:
> > On Tue, Apr 19, 2011 at 11:00:06AM +0800, Wu Fengguang wrote:
> > > A background flush work may run for ever. So it's reasonable for it to
> > > mimic the kupdate behavior of syncing old/expired inodes first.
> > > 
> > > The policy is
> > > - enqueue all newly expired inodes at each queue_io() time
> > > - enqueue all dirty inodes if there are no more expired inodes to sync
> > > 
> > > This will help reduce the number of dirty pages encountered by page
> > > reclaim, eg. the pageout() calls. Normally older inodes contain older
> > > dirty pages, which are more close to the end of the LRU lists. So
> > > syncing older inodes first helps reducing the dirty pages reached by
> > > the page reclaim code.
> > 
> > Once again I think this is the wrong place to be changing writeback
> > policy decisions. for_background writeback only goes through
> > wb_writeback() and writeback_inodes_wb() (same as for_kupdate
> > writeback), so a decision to change from expired inodes to fresh
> > inodes, IMO, should be made in wb_writeback.
> > 
> > That is, for_background and for_kupdate writeback start with the
> > same policy (older_than_this set) to writeback expired inodes first,
> > then when background writeback runs out of expired inodes, it should
> > switch to all remaining inodes by clearing older_than_this instead
> > of refreshing it for the next loop.
>   Yes, I agree with this and my impression is that Fengguang is trying to
> achieve exactly this behavior.
> 
> > This keeps all the policy decisions in the one place, all using the
> > same (existing) mechanism, and all relatively simple to understand,
> > and easy to tracepoint for debugging.  Changing writeback policy
> > deep in the writeback stack is not a good idea as it will make
> > extending writeback policies in future (e.g. for cgroup awareness)
> > very messy.
>   Hmm, I see. I agree the policy decisions should be at one place if
> reasonably possible. Fengguang moves them from wb_writeback() to inode
> queueing code which looks like a logical place to me as well - there we
> have the largest control over what inodes do we decide to write and don't
> have to pass all the detailed 'instructions' down in wbc structure. So if
> we later want to add cgroup awareness to writeback, I imagine we just add
> the knowledge to inode queueing code.

I actually started with wb_writeback() as a natural choice, and then
found it much easier to do the expired-only=>all-inodes switching in
move_expired_inodes() since it needs to know the @b_dirty and @tmp
lists' emptiness to trigger the switch. It's not sane for
wb_writeback() to look into such details. And once you do the switch
part in move_expired_inodes(), the whole policy naturally follows.

> > > @@ -585,7 +597,8 @@ void writeback_inodes_wb(struct bdi_writ
> > >  	if (!wbc->wb_start)
> > >  		wbc->wb_start = jiffies; /* livelock avoidance */
> > >  	spin_lock(&inode_wb_list_lock);
> > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > +
> > > +	if (list_empty(&wb->b_io))
> > >  		queue_io(wb, wbc);
> > >  
> > >  	while (!list_empty(&wb->b_io)) {
> > > @@ -612,7 +625,7 @@ static void __writeback_inodes_sb(struct
> > >  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> > >  
> > >  	spin_lock(&inode_wb_list_lock);
> > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > +	if (list_empty(&wb->b_io))
> > >  		queue_io(wb, wbc);
> > >  	writeback_sb_inodes(sb, wb, wbc, true);
> > >  	spin_unlock(&inode_wb_list_lock);
> > 
> > That changes the order in which we queue inodes for writeback.
> > Instead of calling every time to move b_more_io inodes onto the b_io
> > list and expiring more aged inodes, we only ever do it when the list
> > is empty. That is, it seems to me that this will tend to give
> > b_more_io inodes a smaller share of writeback because they are being
> > moved back to the b_io list less frequently where there are lots of
> > other inodes being dirtied. Have you tested the impact of this
> > change on mixed workload performance? Indeed, can you starve
> > writeback of a large file simply by creating lots of small files in
> > another thread?
>   Yeah, this change looks suspicious to me as well.

The exact behaviors are indeed rather complex. I personally feel the
new "always refill iff empty" policy more consistent, clean and easy
to understand.

It basically says: at each round started by a b_io refill, setup a
_fixed_ work set with all current expired (or all currently dirtied
inodes if non is expired) and walk through it. "Fixed" work set means
no new inodes will be added to the work set during the walk.  When a
complete walk is done, start over with a new set of inodes that are
eligible at the time.

The figure in page 14 illustrates the "rounds" idea:
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/linux-writeback-queues.pdf

This procedure provides fairness among the inodes and guarantees each
inode to be synced once and only once at each round. So it's free from
starvations.

If you are worried about performance, here is a simple tar+dd benchmark.
Both commands are actually running faster with this patchset:

wfg /tmp% g cpu log-* | g dd
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.658 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 12.961 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.420 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.30s system 9% cpu 13.103 total
log-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.31s system 9% cpu 13.650 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 15.258 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.255 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.443 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 14.051 total
log-no-moving-expire:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.27s system 8% cpu 14.648 total

wfg /tmp% g cpu log-* | g tar
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.49s user 3.99s system 60% cpu 27.285 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.78s user 4.40s system 65% cpu 26.125 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.56s system 64% cpu 26.265 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.18s system 62% cpu 26.766 total
log-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.60s user 4.03s system 60% cpu 27.463 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.42s user 4.17s system 57% cpu 28.688 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.67s user 4.04s system 58% cpu 28.738 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.53s user 4.50s system 58% cpu 29.287 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.38s user 4.28s system 57% cpu 28.861 total
log-no-moving-expire:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.44s user 4.19s system 56% cpu 29.443 total

Total elapsed time (from tar/dd start to sync complete) is
244.36s vs. 239.91s, also a bit faster with patch. 

The base kernel is 2.6.39-rc3+ plus IO-less patchset plus large write
chunk size. The test box has 3G mem and runs XFS. Test script is:

#!/bin/zsh


# we are doing pure write tests
cp /c/linux-2.6.38.3.tar.bz2 /dev/shm/

umount /dev/sda7
mkfs.xfs -f /dev/sda7
mount /dev/sda7 /fs

echo 3 > /proc/sys/vm/drop_caches

echo 1 > /debug/tracing/events/writeback/writeback_single_inode/enable

cat /proc/uptime

cd /fs
time tar jxf /dev/shm/linux-2.6.38.3.tar.bz2 &
time dd if=/dev/zero of=/fs/zero bs=1M count=1000 &

wait
sync
cat /proc/uptime

Thanks,
Fengguang

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=log-no-moving-expire

dt7, no moving target

wfg ~% s fat                                                                                                   [ 255 ]  :-(
Linux fat 2.6.39-rc3-dt7+ #235 SMP Tue Apr 19 19:33:15 CST 2011 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
No mail.
Last login: Tue Apr 19 19:16:05 2011 from 10.255.20.73
wfg@fat ~% su
root@fat /home/wfg# for i in 1 2 3 4 5; do bin/test-tar-dd.sh; sleep 3; done
umount: /dev/sda7: not mounted
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
306.70 2423.01
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 15.2306 s, 68.8 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 15.258 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.42s user 4.17s system 57% cpu 28.688 total
344.05 2662.47
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
351.63 2721.77
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 14.1873 s, 73.9 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.255 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.67s user 4.04s system 58% cpu 28.738 total
388.94 2963.14
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
396.53 3024.20
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 14.385 s, 72.9 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 8% cpu 14.443 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.53s user 4.50s system 58% cpu 29.287 total
434.18 3268.86
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
441.69 3327.58
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.997 s, 74.9 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 8% cpu 14.051 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.38s user 4.28s system 57% cpu 28.861 total
478.91 3569.24
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
486.48 3627.06
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 14.5851 s, 71.9 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.27s system 8% cpu 14.648 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.44s user 4.19s system 56% cpu 29.443 total
524.46 3871.42

3871.42 - 3627.06 = 244.36


ext4:

1855.48 14403.91
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.48s user 3.31s system 86% cpu 18.345 total
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 20.4943 s, 51.2 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.65s system 8% cpu 20.518 total
1884.20 14562.35

14562.35 - 14403.91 = 158.44

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=log-moving-expire

dt7, moving target

wfg ~% s fat                                                                                                   [ 255 ]  :-(
Linux fat 2.6.39-rc3-dt7+ #234 SMP Tue Apr 19 17:23:44 CST 2011 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
No mail.
Last login: Tue Apr 19 17:25:16 2011 from 10.255.20.73
wfg@fat ~% su
root@fat /home/wfg# vi bin/test-tar-dd.sh
root@fat /home/wfg# bin/test-tar-dd.sh
umount: /dev/sda7: not mounted
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
634.16 5029.23
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.6318 s, 76.9 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.658 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.49s user 3.99s system 60% cpu 27.285 total
670.17 5262.84
root@fat /home/wfg# bin/test-tar-dd.sh
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
678.41 5327.07
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 12.9063 s, 81.2 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 12.961 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.78s user 4.40s system 65% cpu 26.125 total
713.93 5559.64
root@fat /home/wfg# bin/test-tar-dd.sh
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
722.54 5626.94
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.3658 s, 78.5 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 13.420 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.56s system 64% cpu 26.265 total
757.98 5855.34
root@fat /home/wfg# bin/test-tar-dd.sh
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
766.10 5918.93
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.0385 s, 80.4 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.30s system 9% cpu 13.103 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 4.18s system 62% cpu 26.766 total
801.72 6152.51
root@fat /home/wfg#
root@fat /home/wfg# bin/test-tar-dd.sh
meta-data=/dev/sda7              isize=256    agcount=4, agsize=6170464 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=24681856, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=12051, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
994.01 7677.81
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.5859 s, 77.2 MB/s
dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.31s system 9% cpu 13.650 total
tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.60s user 4.03s system 60% cpu 27.463 total
1030.08 7917.72

7917.72 - 7677.81 = 239.91

--HlL+5n6rz5pIUxbD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
