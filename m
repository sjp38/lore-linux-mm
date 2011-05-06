Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AF6886B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 01:30:03 -0400 (EDT)
Date: Fri, 6 May 2011 13:29:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] writeback: refill b_io iff empty
Message-ID: <20110506052955.GA24904@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
 <20110505163708.GN5323@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110505163708.GN5323@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 06, 2011 at 12:37:08AM +0800, Jan Kara wrote:
> On Wed 04-05-11 15:39:31, Wu Fengguang wrote:
> > To help understand the behavior change, I wrote the writeback_queue_io
> > trace event, and found very different patterns between
> > - vanilla kernel
> > - this patchset plus the sync livelock fixes
> > 
> > Basically the vanilla kernel each time pulls a random number of inodes
> > from b_dirty, while the patched kernel tends to pull a fixed number of
> > inodes (enqueue=1031) from b_dirty. The new behavior is very interesting...
>   This regularity is really strange. Did you have a chance to look more into
> it? I find it highly unlikely that there would be exactly 1031 dirty inodes
> in b_dirty list every time you call move_expired_inodes()...

Jan, I got some results for ext4. The total dd+tar+sync time is
decreased from 177s to 167s. The other numbers are either raised or
dropped.

dd-tar-ext4-patched:elapsed: 177.4900000000016
dd-tar-ext4-patched:elapsed: 166.40000000000146
dd-tar-ext4-patched:elapsed: 164.33000000000175
dd-tar-ext4-patched:elapsed: 176.36999999999898
dd-tar-ext4-patched:elapsed: 152.84000000000015

avg        167.486
stddev       8.996

dd-tar-ext4-vanilla:elapsed: 172.08999999999924
dd-tar-ext4-vanilla:elapsed: 170.50999999999931
dd-tar-ext4-vanilla:elapsed: 183.61999999999989
dd-tar-ext4-vanilla:elapsed: 187.69999999999982
dd-tar-ext4-vanilla:elapsed: 174.8100000000004

avg        177.746
stddev       6.731


dd-tar-ext4-patched:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.66s system 9% cpu 16.922 total
dd-tar-ext4-patched:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.70s system 8% cpu 19.681 total
dd-tar-ext4-patched:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.69s system 8% cpu 19.041 total
dd-tar-ext4-patched:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.69s system 9% cpu 18.632 total
dd-tar-ext4-patched:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.70s system 9% cpu 18.478 total

avg          0.000      1.688      8.600     18.551
stddev       0.000      0.015      0.490      0.915

dd-tar-ext4-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.67s system 8% cpu 19.658 total
dd-tar-ext4-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.67s system 8% cpu 18.663 total
dd-tar-ext4-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.70s system 8% cpu 19.970 total
dd-tar-ext4-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.66s system 7% cpu 20.985 total
dd-tar-ext4-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.66s system 8% cpu 19.806 total

avg          0.000      1.672      7.800     19.816
stddev       0.000      0.015      0.400      0.741


dd-tar-ext4-patched:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.08s user 3.51s system 71% cpu 21.677 total
dd-tar-ext4-patched:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.07s user 3.73s system 80% cpu 19.679 total
dd-tar-ext4-patched:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.43s user 3.09s system 79% cpu 19.444 total
dd-tar-ext4-patched:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.52s user 3.14s system 80% cpu 19.510 total
dd-tar-ext4-patched:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.38s user 3.15s system 92% cpu 16.701 total

avg         12.296      3.324     80.400     19.402
stddev       0.186      0.252      6.711      1.585

dd-tar-ext4-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.34s user 3.26s system 96% cpu 16.155 total
dd-tar-ext4-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.70s user 3.52s system 97% cpu 16.694 total
dd-tar-ext4-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.47s user 3.31s system 92% cpu 17.017 total
dd-tar-ext4-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.36s user 3.19s system 86% cpu 17.885 total
dd-tar-ext4-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.46s user 3.17s system 101% cpu 15.382 total

avg         12.466      3.290     94.400     16.627
stddev       0.128      0.125      5.083      0.838

patched trace-tar-dd-ext4-2.6.39-rc3+

       flush-8:0-3048  [000]  1902.672610: writeback_queue_io: bdi 8:0: older=4296543506 age=30000 enqueue=0
       flush-8:0-3048  [000]  1905.209570: writeback_queue_io: bdi 8:0: older=4296546051 age=30000 enqueue=0
       flush-8:0-3048  [000]  1907.294936: writeback_queue_io: bdi 8:0: older=4296548143 age=30000 enqueue=0
       flush-8:0-3048  [004]  1909.607301: writeback_queue_io: bdi 8:0: older=4296550462 age=30000 enqueue=0
       flush-8:0-3048  [003]  1912.290627: writeback_queue_io: bdi 8:0: older=4296553154 age=30000 enqueue=0
       flush-8:0-3048  [001]  1914.331197: writeback_queue_io: bdi 8:0: older=4296555201 age=30000 enqueue=0
      flush-0:15-2283  [002]  1924.729828: writeback_queue_io: bdi 0:15: older=4296565632 age=30000 enqueue=1
       flush-8:0-3048  [000]  1927.275838: writeback_queue_io: bdi 8:0: older=4296568186 age=30000 enqueue=0
       flush-8:0-3048  [000]  1927.277794: writeback_queue_io: bdi 8:0: older=4296568188 age=30000 enqueue=0
       flush-8:0-3048  [000]  1927.279504: writeback_queue_io: bdi 8:0: older=4296568189 age=30000 enqueue=0
       flush-8:0-3048  [000]  1927.279923: writeback_queue_io: bdi 8:0: older=4296568190 age=30000 enqueue=0
      flush-0:15-2283  [002]  1929.714335: writeback_queue_io: bdi 0:15: older=4296570632 age=30000 enqueue=2
      flush-0:15-2283  [002]  1929.979616: writeback_queue_io: bdi 0:15: older=4296600898 age=0 enqueue=10
      flush-0:15-2283  [002]  1929.979675: writeback_queue_io: bdi 0:15: older=4296600898 age=0 enqueue=10
       flush-8:0-3048  [004]  1929.981734: writeback_queue_io: bdi 8:0: older=4296600898 age=2 enqueue=13227
       flush-8:0-3048  [000]  1932.840150: writeback_queue_io: bdi 8:0: older=4296600898 age=2869 enqueue=0
       flush-8:0-3048  [000]  1932.840781: writeback_queue_io: bdi 8:0: older=4296603768 age=0 enqueue=0
       flush-8:0-3048  [000]  1932.840787: writeback_queue_io: bdi 8:0: older=4296573768 age=30000 enqueue=0
      flush-0:15-2283  [002]  1932.991221: writeback_queue_io: bdi 0:15: older=4296603919 age=0 enqueue=10
      flush-0:15-2283  [002]  1932.991282: writeback_queue_io: bdi 0:15: older=4296603919 age=0 enqueue=0
       flush-8:0-3048  [004]  1932.991596: writeback_queue_io: bdi 8:0: older=4296603919 age=0 enqueue=1
       flush-8:0-3048  [004]  1937.975765: writeback_queue_io: bdi 8:0: older=4296578919 age=30000 enqueue=0
       flush-8:0-3048  [004]  1942.960305: writeback_queue_io: bdi 8:0: older=4296583919 age=30000 enqueue=0
       flush-8:0-3048  [004]  1947.944925: writeback_queue_io: bdi 8:0: older=4296588919 age=30000 enqueue=0
       flush-8:0-3048  [004]  1952.929427: writeback_queue_io: bdi 8:0: older=4296593919 age=30000 enqueue=0
       flush-8:0-3048  [004]  1957.914031: writeback_queue_io: bdi 8:0: older=4296598919 age=30000 enqueue=0
       flush-8:0-3048  [004]  1962.898507: writeback_queue_io: bdi 8:0: older=4296603919 age=30000 enqueue=1
       flush-8:0-3048  [004]  1962.898518: writeback_queue_io: bdi 8:0: older=4296603919 age=30000 enqueue=0

vanilla trace-tar-dd-ext4-2.6.39-rc3

       flush-8:0-2911  [002]    53.756624: writeback_queue_io: bdi 8:0: older=4294690962 age=30000 enqueue=1
       flush-8:0-2911  [002]    53.756738: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=1184
      flush-0:15-2214  [001]    56.960369: writeback_queue_io: bdi 0:15: older=4294694176 age=30000 enqueue=0
      flush-0:15-2214  [001]    56.960373: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
       flush-8:0-2911  [004]    57.447062: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=4479
       flush-8:0-2911  [004]    57.482760: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=58
       flush-8:0-2911  [004]    57.492041: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=12
       flush-8:0-2911  [004]    57.613401: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=198
       flush-8:0-2911  [004]    61.569241: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=229
       flush-8:0-2911  [004]    61.589268: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=141
       flush-8:0-2911  [004]    61.607471: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=209
       flush-8:0-2911  [004]    61.619094: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [004]    61.629282: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
      flush-0:15-2214  [001]    61.945027: writeback_queue_io: bdi 0:15: older=4294699176 age=30000 enqueue=0
      flush-0:15-2214  [001]    61.945032: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
       flush-8:0-2911  [001]    63.715007: writeback_queue_io: bdi 8:0: older=4294698964 age=31987 enqueue=0
       flush-8:0-2911  [000]    66.469285: writeback_queue_io: bdi 8:0: older=4294698964 age=34750 enqueue=0
      flush-0:15-2214  [005]    66.929422: writeback_queue_io: bdi 0:15: older=4294704176 age=30000 enqueue=0
      flush-0:15-2214  [005]    66.929428: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
       flush-8:0-2911  [000]    68.377843: writeback_queue_io: bdi 8:0: older=4294698964 age=36664 enqueue=0
      flush-0:15-2214  [005]    71.913983: writeback_queue_io: bdi 0:15: older=4294709176 age=30000 enqueue=1
       flush-8:0-2911  [004]    74.365281: writeback_queue_io: bdi 8:0: older=4294711634 age=30000 enqueue=0
       flush-8:0-2911  [000]    74.821770: writeback_queue_io: bdi 8:0: older=4294711634 age=30458 enqueue=0
      flush-0:15-2214  [005]    76.898540: writeback_queue_io: bdi 0:15: older=4294714176 age=30000 enqueue=5
       flush-8:0-2911  [004]    77.158312: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=18938
       flush-8:0-2911  [004]    77.235169: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=185
       flush-8:0-2911  [004]    77.388776: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=455
       flush-8:0-2911  [004]    77.462484: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=187
       flush-8:0-2911  [004]    77.541086: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=97
       flush-8:0-2911  [004]    77.619482: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=126
       flush-8:0-2911  [004]    77.810862: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=265
       flush-8:0-2911  [006]    77.924553: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=209
       flush-8:0-2911  [003]    78.034276: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=234
       flush-8:0-2911  [003]    78.108989: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=148
       flush-8:0-2911  [003]    78.179240: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=162
       flush-8:0-2911  [003]    78.348585: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=406
       flush-8:0-2911  [003]    78.476980: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=36
       flush-8:0-2911  [003]    78.580621: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=144
       flush-8:0-2911  [003]    78.754257: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=366
       flush-8:0-2911  [003]    78.858451: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=184
       flush-8:0-2911  [003]    78.945059: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=228
       flush-8:0-2911  [003]    79.075494: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=267
       flush-8:0-2911  [003]    79.152004: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=56
       flush-8:0-2911  [003]    79.238366: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=145
      flush-0:15-2214  [005]    81.883169: writeback_queue_io: bdi 0:15: older=4294719176 age=30000 enqueue=1
      flush-0:15-2214  [005]    82.457961: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
      flush-0:15-2214  [005]    82.457985: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
       flush-8:0-2911  [000]    82.461064: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=6957
       flush-8:0-2911  [000]    82.465738: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.084199: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.091283: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.097138: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.101489: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.105795: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.111433: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.113795: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.118674: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.123061: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.127796: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.318828: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.335335: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.513142: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.671440: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.727269: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.800181: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.827915: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.890632: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.930052: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.950224: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    83.980423: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.022254: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.140787: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.312729: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.379059: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.420117: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.473221: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.501959: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.589525: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.696628: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.699403: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.792484: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    84.920198: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    85.003982: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    85.006321: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    85.008473: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    85.009997: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=0
       flush-8:0-2911  [000]    85.010003: writeback_queue_io: bdi 8:0: older=4294722312 age=30000 enqueue=0
      flush-0:15-2214  [005]    85.245018: writeback_queue_io: bdi 0:15: older=0 age=-1 enqueue=7
       flush-8:0-2911  [000]    85.245369: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=1
       flush-8:0-2911  [000]    90.229292: writeback_queue_io: bdi 8:0: older=4294727548 age=30000 enqueue=0
       flush-8:0-2911  [000]    95.213838: writeback_queue_io: bdi 8:0: older=4294732548 age=30000 enqueue=0
      flush-0:15-2214  [005]    98.671161: writeback_queue_io: bdi 0:15: older=4294736016 age=30000 enqueue=0
       flush-8:0-2911  [000]   100.198391: writeback_queue_io: bdi 8:0: older=4294737548 age=30000 enqueue=0
      flush-0:15-2214  [005]   103.655662: writeback_queue_io: bdi 0:15: older=4294741016 age=30000 enqueue=0
       flush-8:0-2911  [000]   105.182941: writeback_queue_io: bdi 8:0: older=4294742548 age=30000 enqueue=1
      flush-0:15-2214  [005]   108.640284: writeback_queue_io: bdi 0:15: older=4294746016 age=30000 enqueue=0
      flush-0:15-2214  [005]   113.624829: writeback_queue_io: bdi 0:15: older=4294751016 age=30000 enqueue=0
      flush-0:15-2214  [005]   118.609396: writeback_queue_io: bdi 0:15: older=4294756016 age=30000 enqueue=0
      flush-0:15-2214  [005]   123.593932: writeback_queue_io: bdi 0:15: older=4294761016 age=30000 enqueue=1
      flush-0:15-2214  [005]   128.578494: writeback_queue_io: bdi 0:15: older=4294766016 age=30000 enqueue=0
      flush-0:15-2214  [005]   133.563026: writeback_queue_io: bdi 0:15: older=4294771016 age=30000 enqueue=0
      flush-0:15-2214  [005]   138.547592: writeback_queue_io: bdi 0:15: older=4294776016 age=30000 enqueue=0
      flush-0:15-2214  [005]   143.532126: writeback_queue_io: bdi 0:15: older=4294781016 age=30000 enqueue=0
      flush-0:15-2214  [005]   148.516696: writeback_queue_io: bdi 0:15: older=4294786016 age=30000 enqueue=2
      flush-0:15-2214  [005]   153.501234: writeback_queue_io: bdi 0:15: older=4294791016 age=30000 enqueue=1
      flush-0:15-2214  [005]   158.485800: writeback_queue_io: bdi 0:15: older=4294796016 age=30000 enqueue=0
      flush-0:15-2214  [005]   163.470348: writeback_queue_io: bdi 0:15: older=4294801016 age=30000 enqueue=0
      flush-0:15-2214  [005]   168.454905: writeback_queue_io: bdi 0:15: older=4294806016 age=30000 enqueue=0
      flush-0:15-2214  [005]   173.439445: writeback_queue_io: bdi 0:15: older=4294811016 age=30000 enqueue=0
      flush-0:15-2214  [005]   178.424001: writeback_queue_io: bdi 0:15: older=4294816016 age=30000 enqueue=2
      flush-0:15-2214  [005]   183.408546: writeback_queue_io: bdi 0:15: older=4294821016 age=30000 enqueue=1
      flush-0:15-2214  [005]   188.393102: writeback_queue_io: bdi 0:15: older=4294826016 age=30000 enqueue=0
      flush-0:15-2214  [005]   193.377653: writeback_queue_io: bdi 0:15: older=4294831016 age=30000 enqueue=0
      flush-0:15-2214  [005]   198.362203: writeback_queue_io: bdi 0:15: older=4294836016 age=30000 enqueue=0
      flush-0:15-2214  [005]   203.346749: writeback_queue_io: bdi 0:15: older=4294841016 age=30000 enqueue=0
      flush-0:15-2214  [005]   208.331306: writeback_queue_io: bdi 0:15: older=4294846016 age=30000 enqueue=2
      flush-0:15-2214  [005]   213.315844: writeback_queue_io: bdi 0:15: older=4294851016 age=30000 enqueue=1
      flush-0:15-2214  [005]   218.300404: writeback_queue_io: bdi 0:15: older=4294856016 age=30000 enqueue=0
      flush-0:15-2214  [005]   223.284955: writeback_queue_io: bdi 0:15: older=4294861016 age=30000 enqueue=0
      flush-0:15-2214  [005]   228.269515: writeback_queue_io: bdi 0:15: older=4294866016 age=30000 enqueue=0
      flush-0:15-2214  [005]   233.254057: writeback_queue_io: bdi 0:15: older=4294871016 age=30000 enqueue=0
      flush-0:15-2214  [005]   238.238619: writeback_queue_io: bdi 0:15: older=4294876016 age=30000 enqueue=2
      flush-0:15-2214  [005]   243.223157: writeback_queue_io: bdi 0:15: older=4294881016 age=30000 enqueue=1
      flush-0:15-2214  [005]   248.207715: writeback_queue_io: bdi 0:15: older=4294886016 age=30000 enqueue=0
      flush-0:15-2214  [005]   253.192251: writeback_queue_io: bdi 0:15: older=4294891016 age=30000 enqueue=0
      flush-0:15-2214  [005]   258.176824: writeback_queue_io: bdi 0:15: older=4294896016 age=30000 enqueue=0
      flush-0:15-2214  [005]   263.161348: writeback_queue_io: bdi 0:15: older=4294901016 age=30000 enqueue=0
      flush-0:15-2214  [005]   268.145922: writeback_queue_io: bdi 0:15: older=4294906016 age=30000 enqueue=2
      flush-0:15-2214  [005]   273.130463: writeback_queue_io: bdi 0:15: older=4294911016 age=30000 enqueue=1
      flush-0:15-2214  [005]   278.115008: writeback_queue_io: bdi 0:15: older=4294916016 age=30000 enqueue=0
      flush-0:15-2214  [005]   283.099572: writeback_queue_io: bdi 0:15: older=4294921016 age=30000 enqueue=0
      flush-0:15-2214  [005]   288.084050: writeback_queue_io: bdi 0:15: older=4294926016 age=30000 enqueue=0
      flush-0:15-2214  [005]   293.068668: writeback_queue_io: bdi 0:15: older=4294931016 age=30000 enqueue=0
      flush-0:15-2214  [005]   298.053228: writeback_queue_io: bdi 0:15: older=4294936016 age=30000 enqueue=2
      flush-0:15-2214  [005]   303.037756: writeback_queue_io: bdi 0:15: older=4294941016 age=30000 enqueue=1
      flush-0:15-2214  [005]   308.022329: writeback_queue_io: bdi 0:15: older=4294946016 age=30000 enqueue=0
      flush-0:15-2214  [005]   313.006864: writeback_queue_io: bdi 0:15: older=4294951016 age=30000 enqueue=0
      flush-0:15-2214  [005]   317.991431: writeback_queue_io: bdi 0:15: older=4294956016 age=30000 enqueue=0
      flush-0:15-2214  [005]   322.975973: writeback_queue_io: bdi 0:15: older=4294961016 age=30000 enqueue=0
      flush-0:15-2214  [005]   327.960530: writeback_queue_io: bdi 0:15: older=4294966016 age=30000 enqueue=2
      flush-0:15-2214  [005]   332.945074: writeback_queue_io: bdi 0:15: older=4294971016 age=30000 enqueue=1
      flush-0:15-2214  [005]   337.929629: writeback_queue_io: bdi 0:15: older=4294976016 age=30000 enqueue=0
      flush-0:15-2214  [005]   342.914183: writeback_queue_io: bdi 0:15: older=4294981016 age=30000 enqueue=0
      flush-0:15-2214  [005]   347.898736: writeback_queue_io: bdi 0:15: older=4294986016 age=30000 enqueue=0
      flush-0:15-2214  [005]   352.883285: writeback_queue_io: bdi 0:15: older=4294991016 age=30000 enqueue=0
      flush-0:15-2214  [005]   357.867829: writeback_queue_io: bdi 0:15: older=4294996016 age=30000 enqueue=2
      flush-0:15-2214  [005]   362.852371: writeback_queue_io: bdi 0:15: older=4295001016 age=30000 enqueue=1
      flush-0:15-2214  [005]   367.836939: writeback_queue_io: bdi 0:15: older=4295006016 age=30000 enqueue=0
      flush-0:15-2214  [005]   372.821491: writeback_queue_io: bdi 0:15: older=4295011016 age=30000 enqueue=0
      flush-0:15-2214  [005]   377.806047: writeback_queue_io: bdi 0:15: older=4295016016 age=30000 enqueue=0
      flush-0:15-2214  [005]   382.790584: writeback_queue_io: bdi 0:15: older=4295021016 age=30000 enqueue=0
      flush-0:15-2214  [005]   387.775142: writeback_queue_io: bdi 0:15: older=4295026016 age=30000 enqueue=2
      flush-0:15-2214  [005]   392.759681: writeback_queue_io: bdi 0:15: older=4295031016 age=30000 enqueue=1
      flush-0:15-2214  [005]   397.744251: writeback_queue_io: bdi 0:15: older=4295036016 age=30000 enqueue=0
      flush-0:15-2214  [005]   402.728786: writeback_queue_io: bdi 0:15: older=4295041016 age=30000 enqueue=0
      flush-0:15-2214  [005]   407.713347: writeback_queue_io: bdi 0:15: older=4295046016 age=30000 enqueue=0
      flush-0:15-2214  [005]   412.697887: writeback_queue_io: bdi 0:15: older=4295051016 age=30000 enqueue=0
      flush-0:15-2214  [005]   417.682447: writeback_queue_io: bdi 0:15: older=4295056016 age=30000 enqueue=2
      flush-0:15-2214  [005]   422.666987: writeback_queue_io: bdi 0:15: older=4295061016 age=30000 enqueue=1
      flush-0:15-2214  [005]   427.651550: writeback_queue_io: bdi 0:15: older=4295066016 age=30000 enqueue=0
      flush-0:15-2214  [005]   432.636088: writeback_queue_io: bdi 0:15: older=4295071016 age=30000 enqueue=0
      flush-0:15-2214  [005]   437.620649: writeback_queue_io: bdi 0:15: older=4295076016 age=30000 enqueue=0
      flush-0:15-2214  [005]   442.605199: writeback_queue_io: bdi 0:15: older=4295081016 age=30000 enqueue=0
      flush-0:15-2214  [005]   447.589750: writeback_queue_io: bdi 0:15: older=4295086016 age=30000 enqueue=2
      flush-0:15-2214  [005]   452.574296: writeback_queue_io: bdi 0:15: older=4295091016 age=30000 enqueue=1
      flush-0:15-2214  [005]   457.558861: writeback_queue_io: bdi 0:15: older=4295096016 age=30000 enqueue=0
      flush-0:15-2214  [005]   462.543399: writeback_queue_io: bdi 0:15: older=4295101016 age=30000 enqueue=0
      flush-0:15-2214  [005]   467.527961: writeback_queue_io: bdi 0:15: older=4295106016 age=30000 enqueue=0
      flush-0:15-2214  [005]   472.512492: writeback_queue_io: bdi 0:15: older=4295111016 age=30000 enqueue=0
      flush-0:15-2214  [005]   477.497055: writeback_queue_io: bdi 0:15: older=4295116016 age=30000 enqueue=2
      flush-0:15-2214  [005]   482.481630: writeback_queue_io: bdi 0:15: older=4295121016 age=30000 enqueue=1
      flush-0:15-2214  [005]   487.466162: writeback_queue_io: bdi 0:15: older=4295126016 age=30000 enqueue=0
      flush-0:15-2214  [005]   492.450709: writeback_queue_io: bdi 0:15: older=4295131016 age=30000 enqueue=0
      flush-0:15-2214  [005]   497.435268: writeback_queue_io: bdi 0:15: older=4295136016 age=30000 enqueue=0
      flush-0:15-2214  [005]   502.419812: writeback_queue_io: bdi 0:15: older=4295141016 age=30000 enqueue=0
      flush-0:15-2214  [005]   507.404385: writeback_queue_io: bdi 0:15: older=4295146016 age=30000 enqueue=2
      flush-0:15-2214  [005]   512.388906: writeback_queue_io: bdi 0:15: older=4295151016 age=30000 enqueue=1
      flush-0:15-2214  [005]   517.373458: writeback_queue_io: bdi 0:15: older=4295156016 age=30000 enqueue=0
      flush-0:15-2214  [005]   522.358005: writeback_queue_io: bdi 0:15: older=4295161016 age=30000 enqueue=0
      flush-0:15-2214  [005]   527.342587: writeback_queue_io: bdi 0:15: older=4295166016 age=30000 enqueue=0
      flush-0:15-2214  [005]   532.327116: writeback_queue_io: bdi 0:15: older=4295171016 age=30000 enqueue=0

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
