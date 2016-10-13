Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 298C66B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:39:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n3so43011569lfn.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 00:39:52 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id m204si7388894lfm.410.2016.10.13.00.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 00:39:50 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id x79so11232804lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 00:39:50 -0700 (PDT)
Date: Thu, 13 Oct 2016 09:39:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161013073947.GF21678@dhcp22.suse.cz>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <20161004203202.GY9806@dastard>
 <20161005113839.GC7138@dhcp22.suse.cz>
 <20161006021142.GC9806@dastard>
 <20161007131814.GL18439@dhcp22.suse.cz>
 <20161013002924.GO23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013002924.GO23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 13-10-16 11:29:24, Dave Chinner wrote:
> On Fri, Oct 07, 2016 at 03:18:14PM +0200, Michal Hocko wrote:
[...]
> > Unpatched kernel:
> > #       Version 3.3, 16 thread(s) starting at Fri Oct  7 09:55:05 2016
> > #       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
> > #       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
> > #       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
> > #       Files info: size 0 bytes, written with an IO size of 16384 bytes per write
> > #       App overhead is time in microseconds spent in the test not doing file writing related system calls.
> > #
> > FSUse%        Count         Size    Files/sec     App Overhead
> >      1      1600000            0       4300.1         20745838
> >      3      3200000            0       4239.9         23849857
> >      5      4800000            0       4243.4         25939543
> >      6      6400000            0       4248.4         19514050
> >      8      8000000            0       4262.1         20796169
> >      9      9600000            0       4257.6         21288675
> >     11     11200000            0       4259.7         19375120
> >     13     12800000            0       4220.7         22734141
> >     14     14400000            0       4238.5         31936458
> >     16     16000000            0       4231.5         23409901
> >     18     17600000            0       4045.3         23577700
> >     19     19200000            0       2783.4         58299526
> >     21     20800000            0       2678.2         40616302
> >     23     22400000            0       2693.5         83973996
> > Ctrl+C because it just took too long.
> 
> Try running it on a larger filesystem, or configure the fs with more
> AGs and a larger log (i.e. mkfs.xfs -f -dagcount=24 -l size=512m
> <dev>). That will speed up modifications and increase concurrency.
> This test should be able to run 5-10x faster than this (it
> sustains 55,000 files/s @ 300MB/s write on my test fs on a cheap
> SSD).

Will add more memory to the machine. Will report back on that.
 
> > while it doesn't seem to drop the Files/sec numbers starting with
> > Count=19200000. I also see only a single
> > 
> > [ 3063.815003] XFS: fs_mark(3272) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)
> 
> Remember that this is emitted only after /100/ consecutive
> allocation failures. So the fact it is still being emitted means
> that the situation is not drastically better....

yes, but we also should consider that with this particular workload
which doesn't have a lot of anonymous memory there is simply not all
that much to migrate so we eventually have to wait for the reclaim
to free up fs bound memory. This patch should put some relief but it
is not a general remedy.

> > Unpatched kernel
> > all orders
> > begin:44.718798 end:5774.618736 allocs:15019288
> > order > 0 
> > begin:44.718798 end:5773.587195 allocs:10438610
> > 
> > Patched kernel
> > all orders
> > begin:64.612804 end:5794.193619 allocs:16110081 [107.2%]
> > order > 0
> > begin:64.612804 end:5794.193619 allocs:11741492 [112.5%]
> > 
> > which would suggest that diving into the compaction rather than backing
> > off and waiting for kcompactd to make the work for us was indeed a
> > better strategy and helped the throughput.
> 
> Well, without a success/failure ratio being calculated it's hard to
> tell what improvement it made. Did it increase the success rate, or
> reduce failure latency so retries happened faster?

I have just noticed that the tracepoint also reports allocation failures
(page==(null) and pfn==0) so I actually can calculate that. Note that
only order > 3 fail with the current page allocator so I have filtered
only those

Unpatched
begin:44.718798 end:5773.587195 allocs:6162244 fail:145

Patched
begin:64.612804 end:5794.193574 allocs:6869496 fail:104

So the success rate is slightly higher but this is negligible but we
seem to manage perform ~10% more allocations so I assume this helped the
throughput and in turn recycle memory better.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
