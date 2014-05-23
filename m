Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id F217F6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 02:42:53 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3675822pbb.5
        for <linux-mm@kvack.org>; Thu, 22 May 2014 23:42:53 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id xq7si2558663pab.27.2014.05.22.23.42.51
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 23:42:52 -0700 (PDT)
Date: Fri, 23 May 2014 16:42:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140523064247.GN8554@dastard>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <20140409092009.GA27519@dastard>
 <20140428234756.GM15995@dastard>
 <20140428235714.GA16070@awork2.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140428235714.GA16070@awork2.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, rhaas@anarazel.de, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

On Tue, Apr 29, 2014 at 01:57:14AM +0200, Andres Freund wrote:
> Hi Dave,
> 
> On 2014-04-29 09:47:56 +1000, Dave Chinner wrote:
> > ping?
> 
> I'd replied at http://marc.info/?l=linux-mm&m=139730910307321&w=2

I missed it, sorry.

I've had a bit more time to look at this behaviour now and tweaked
it as you suggested, but I simply can't get XFS to misbehave in the
manner you demonstrated. However, I can reproduce major read latency
changes and writeback flush storms with ext4.  I originally only
tested on XFS. I'm using the no-op IO scheduler everywhere, too.

I ran the tweaked version I have for a couple of hours on XFS, and
only saw a handful abnormal writeback events where the write IOPS
spiked above the normal periodic peaks and was sufficient to cause
any noticable increase in read latency. Even then the maximums were
in the 40ms range, nothing much higher.

ext4, OTOH, generated a much, much higher periodic write IO load and
it's regularly causing read IO latencies in the hundreds of
milliseconds. Every so often this occurred on ext4 (5s sample rate)

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
vdc               0.00     3.00 3142.20  219.20    34.11    19.10    32.42     1.11    0.33    0.33    0.31   0.27  91.92
vdc               0.00     0.80 3311.60  216.20    35.86    18.90    31.79     1.17    0.33    0.33    0.39   0.26  92.56
vdc               0.00     0.80 2919.80 2750.60    31.67    48.36    28.90    20.05    3.50    0.36    6.83   0.16  92.96
vdc               0.00     0.80  435.00 15689.80     4.96   198.10    25.79   113.21    7.03    2.32    7.16   0.06  99.20
vdc               0.00     0.80 2683.80  216.20    29.72    18.98    34.39     1.13    0.39    0.39    0.40   0.32  91.92
vdc               0.00     0.80 2853.00  218.20    31.29    19.06    33.57     1.14    0.37    0.37    0.36   0.30  92.56

Which is, i think, signs of what you'd been trying to demonstrate -
a major dip in read performance when writeback is flushing.

In comparison, this is from XFS:

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
vdc               0.00     0.00 2416.40  335.00    21.02     7.85    21.49     0.78    0.28    0.30    0.19   0.24  65.28
vdc               0.00     0.00 2575.80  336.00    22.68     7.88    21.49     0.81    0.28    0.29    0.16   0.23  66.32
vdc               0.00     0.00 1740.20 4645.20    15.60    58.22    23.68    21.21    3.32    0.41    4.41   0.11  68.56
vdc               0.00     0.00 2082.80  329.00    18.28     7.71    22.07     0.81    0.34    0.35    0.26   0.28  67.44
vdc               0.00     0.00 2347.80  333.20    19.53     7.80    20.88     0.83    0.31    0.32    0.25   0.25  67.52

You can see how much less load XFS putting on the storage - it's
only 65-70% utilised compared to the 90-100% load that ext4 is
generating.

What is interesting here is the difference in IO patterns. ext4 is
doing much larger IOs than XFS - it's average IO size is 16k, while
XFS's is a bit over 8k. So while the read and background write IOPS
rates are similar, ext4 is moving a lot more data to/from disk in
larger chunks.

This seems also to translate to much larger writeback IO peaks in
ext4.  I have no idea what this means in terms of actual application
throughput, but it looks very much to me like the nasty read
latencies are much more pronounced on ext4 because of the higher
read bandwidths and write IOPS being seen.

The screen shot of the recorded behaviour is attached - the left
hand side is the tail end (~30min) of the 2 hour long XFS run, and
the first half an hour of ext4 running. The difference in IO
behaviour is quite obvious....

What is interesting is that CPU usage is not very much different
between the two filesystems, but IOWait is much, much higher for
ext4. That indicates that ext4 is definitely loading the storage
more, and so much more likely to have IO load related
latencies..

So, seeing the differences in behvaiour just by changing
filesystems, I just ran the workload on btrfs. Ouch - it was
even worse than ext4 in terms of read latencies - they were highly
unpredictable, and massively variable even within a read group:

....
read[11331]: avg: 0.3 msec; max: 7.0 msec
read[11340]: avg: 0.3 msec; max: 7.1 msec
read[11334]: avg: 0.3 msec; max: 7.0 msec
read[11329]: avg: 0.3 msec; max: 7.0 msec
read[11328]: avg: 0.3 msec; max: 7.0 msec
read[11332]: avg: 0.6 msec; max: 4481.2 msec
read[11342]: avg: 0.6 msec; max: 4480.6 msec
read[11332]: avg: 0.0 msec; max: 0.7 msec
read[11342]: avg: 0.0 msec; max: 1.6 msec
wal[11326]: avg: 0.0 msec; max: 0.1 msec
.....

It was also not uncommon to see major commit latencies:

read[11335]: avg: 0.2 msec; max: 8.3 msec
read[11341]: avg: 0.2 msec; max: 8.5 msec
wal[11326]: avg: 0.0 msec; max: 0.1 msec
commit[11326]: avg: 0.7 msec; max: 5302.3 msec
wal[11326]: avg: 0.0 msec; max: 0.1 msec
wal[11326]: avg: 0.0 msec; max: 0.1 msec
wal[11326]: avg: 0.0 msec; max: 0.1 msec
commit[11326]: avg: 0.0 msec; max: 6.1 msec
read[11337]: avg: 0.2 msec; max: 6.2 msec

So, what it appears to me right now is that filesystem choice alone
has a major impact on writeback behaviour and read latencies. Each
of these filesystems implements writeback aggregation differently
(ext4 completely replaces the generic writeback path, XFS optimises
below ->writepage, and btrfs has super magic COW powers).

That means it isn't clear that there's any generic infrastructure
problem here, and it certainly isn't clear that each filesystem has
the same problem or the issues can be solved by a generic mechanism.
I think you probably need to engage the ext4 developers drectly to
understand what ext4 is doing in detail, or work out how to prod XFS
into displaying that extremely bad read latency behaviour....

> As an additional note:
> 
> > On Wed, Apr 09, 2014 at 07:20:09PM +1000, Dave Chinner wrote:
> > > I'm not sure how you were generating the behaviour you reported, but
> > > the test program as it stands does not appear to be causing any
> > > problems at all on the sort of storage I'd expect large databases to
> > > be hosted on....
> 
> A really really large number of database aren't stored on big enterprise
> rigs...

I'm not using a big enterprise rig. I've reproduced these results on
a low end Dell server with the internal H710 SAS RAID and a pair of
consumer SSDs in RAID0, as well as via a 4 year old Perc/6e SAS RAID
HBA with 12 2T nearline SAS drives in RAID0.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
