Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6856B0071
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 16:06:37 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so3583wes.15
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 13:06:36 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id o11si6022814wjw.72.2014.06.04.13.06.35
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 13:06:36 -0700 (PDT)
Date: Wed, 4 Jun 2014 22:06:30 +0200
From: Andres Freund <andres@anarazel.de>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140604200630.GD785@awork2.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <20140409092009.GA27519@dastard>
 <20140428234756.GM15995@dastard>
 <20140428235714.GA16070@awork2.anarazel.de>
 <20140523064247.GN8554@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140523064247.GN8554@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>

Hi Dave, Ted, All,

On 2014-05-23 16:42:47 +1000, Dave Chinner wrote:
> On Tue, Apr 29, 2014 at 01:57:14AM +0200, Andres Freund wrote:
> > Hi Dave,
> > 
> > On 2014-04-29 09:47:56 +1000, Dave Chinner wrote:
> > > ping?
> > 
> > I'd replied at http://marc.info/?l=linux-mm&m=139730910307321&w=2
> 
> I missed it, sorry.

No worries. As you can see, I'm not quick answering either :/

> I've had a bit more time to look at this behaviour now and tweaked
> it as you suggested, but I simply can't get XFS to misbehave in the
> manner you demonstrated. However, I can reproduce major read latency
> changes and writeback flush storms with ext4.  I originally only
> tested on XFS.

That's interesting. I know that the problem was reproducable on xfs at
some point, but that was on 2.6.18 or so...

I'll try whether I can make it perform badly on the measly hardware I
have available.

> I'm using the no-op IO scheduler everywhere, too.

And will check whether it's potentially related to that.

> ext4, OTOH, generated a much, much higher periodic write IO load and
> it's regularly causing read IO latencies in the hundreds of
> milliseconds. Every so often this occurred on ext4 (5s sample rate)
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> vdc               0.00     3.00 3142.20  219.20    34.11    19.10    32.42     1.11    0.33    0.33    0.31   0.27  91.92
> vdc               0.00     0.80 3311.60  216.20    35.86    18.90    31.79     1.17    0.33    0.33    0.39   0.26  92.56
> vdc               0.00     0.80 2919.80 2750.60    31.67    48.36    28.90    20.05    3.50    0.36    6.83   0.16  92.96
> vdc               0.00     0.80  435.00 15689.80     4.96   198.10    25.79   113.21    7.03    2.32    7.16   0.06  99.20
> vdc               0.00     0.80 2683.80  216.20    29.72    18.98    34.39     1.13    0.39    0.39    0.40   0.32  91.92
> vdc               0.00     0.80 2853.00  218.20    31.29    19.06    33.57     1.14    0.37    0.37    0.36   0.30  92.56
> 
> Which is, i think, signs of what you'd been trying to demonstrate -
> a major dip in read performance when writeback is flushing.

I've seen *much* worse cases than this, but it's what we're seing in
production.

> What is interesting here is the difference in IO patterns. ext4 is
> doing much larger IOs than XFS - it's average IO size is 16k, while
> XFS's is a bit over 8k. So while the read and background write IOPS
> rates are similar, ext4 is moving a lot more data to/from disk in
> larger chunks.
> 
> This seems also to translate to much larger writeback IO peaks in
> ext4.  I have no idea what this means in terms of actual application
> throughput, but it looks very much to me like the nasty read
> latencies are much more pronounced on ext4 because of the higher
> read bandwidths and write IOPS being seen.

I'll try starting a benchmark of actual postgres showing the differnt
peak/average throughput and latencies.

> So, seeing the differences in behvaiour just by changing
> filesystems, I just ran the workload on btrfs. Ouch - it was
> even worse than ext4 in terms of read latencies - they were highly
> unpredictable, and massively variable even within a read group:

I've essentially given up on btrfs for the forseeable future :(.

> That means it isn't clear that there's any generic infrastructure
> problem here, and it certainly isn't clear that each filesystem has
> the same problem or the issues can be solved by a generic mechanism.
> I think you probably need to engage the ext4 developers drectly to
> understand what ext4 is doing in detail, or work out how to prod XFS
> into displaying that extremely bad read latency behaviour....

I've CCed the ext4 list and Ted. Maybe that'll bring some insigh...

> > > On Wed, Apr 09, 2014 at 07:20:09PM +1000, Dave Chinner wrote:
> > > > I'm not sure how you were generating the behaviour you reported, but
> > > > the test program as it stands does not appear to be causing any
> > > > problems at all on the sort of storage I'd expect large databases to
> > > > be hosted on....
> > 
> > A really really large number of database aren't stored on big enterprise
> > rigs...
> 
> I'm not using a big enterprise rig. I've reproduced these results on
> a low end Dell server with the internal H710 SAS RAID and a pair of
> consumer SSDs in RAID0, as well as via a 4 year old Perc/6e SAS RAID
> HBA with 12 2T nearline SAS drives in RAID0.

There's a *lot* of busy postgres installations out there running on a
single disk of spinning rust. Hopefully replicating to another piece of
spinning rust... In comparison to that that's enterprise hardware ;)

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
