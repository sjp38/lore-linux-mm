Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFD1B6B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:29:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n189so140366022qke.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:29:24 -0700 (PDT)
Received: from mail-qt0-f193.google.com (mail-qt0-f193.google.com. [209.85.216.193])
        by mx.google.com with ESMTPS id r32si20806118qtb.104.2016.10.18.05.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 05:29:24 -0700 (PDT)
Received: by mail-qt0-f193.google.com with SMTP id f6so7316119qtd.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:29:23 -0700 (PDT)
Date: Tue, 18 Oct 2016 14:29:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161018122921.GF12092@dhcp22.suse.cz>
References: <20161004203202.GY9806@dastard>
 <20161005113839.GC7138@dhcp22.suse.cz>
 <20161006021142.GC9806@dastard>
 <20161007131814.GL18439@dhcp22.suse.cz>
 <20161013002924.GO23194@dastard>
 <20161013073947.GF21678@dhcp22.suse.cz>
 <20161013110456.GK21678@dhcp22.suse.cz>
 <20161016204959.GH27872@dastard>
 <20161017082255.GE23322@dhcp22.suse.cz>
 <20161018062446.GD14023@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018062446.GD14023@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 18-10-16 17:24:46, Dave Chinner wrote:
> On Mon, Oct 17, 2016 at 10:22:56AM +0200, Michal Hocko wrote:
> > On Mon 17-10-16 07:49:59, Dave Chinner wrote:
> > > On Thu, Oct 13, 2016 at 01:04:56PM +0200, Michal Hocko wrote:
> > > > On Thu 13-10-16 09:39:47, Michal Hocko wrote:
> > > > > On Thu 13-10-16 11:29:24, Dave Chinner wrote:
> > > > > > On Fri, Oct 07, 2016 at 03:18:14PM +0200, Michal Hocko wrote:
> > > > > [...]
> > > > > > > Unpatched kernel:
> > > > > > > #       Version 3.3, 16 thread(s) starting at Fri Oct  7 09:55:05 2016
> > > > > > > #       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
> > > > > > > #       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
> > > > > > > #       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
> > > > > > > #       Files info: size 0 bytes, written with an IO size of 16384 bytes per write
> > > > > > > #       App overhead is time in microseconds spent in the test not doing file writing related system calls.
> > > > > > > #
> > > > > > > FSUse%        Count         Size    Files/sec     App Overhead
> > > > > > >      1      1600000            0       4300.1         20745838
> > > > > > >      3      3200000            0       4239.9         23849857
> > > > > > >      5      4800000            0       4243.4         25939543
> > > > > > >      6      6400000            0       4248.4         19514050
> > > > > > >      8      8000000            0       4262.1         20796169
> > > > > > >      9      9600000            0       4257.6         21288675
> > > > > > >     11     11200000            0       4259.7         19375120
> > > > > > >     13     12800000            0       4220.7         22734141
> > > > > > >     14     14400000            0       4238.5         31936458
> > > > > > >     16     16000000            0       4231.5         23409901
> > > > > > >     18     17600000            0       4045.3         23577700
> > > > > > >     19     19200000            0       2783.4         58299526
> > > > > > >     21     20800000            0       2678.2         40616302
> > > > > > >     23     22400000            0       2693.5         83973996
> > > > > > > Ctrl+C because it just took too long.
> > > > > > 
> > > > > > Try running it on a larger filesystem, or configure the fs with more
> > > > > > AGs and a larger log (i.e. mkfs.xfs -f -dagcount=24 -l size=512m
> > > > > > <dev>). That will speed up modifications and increase concurrency.
> > > > > > This test should be able to run 5-10x faster than this (it
> > > > > > sustains 55,000 files/s @ 300MB/s write on my test fs on a cheap
> > > > > > SSD).
> > > > > 
> > > > > Will add more memory to the machine. Will report back on that.
> > > > 
> > > > increasing the memory to 1G didn't help. So I've tried to add
> > > > -dagcount=24 -l size=512m and that didn't help much either. I am at 5k
> > > > files/s so nowhere close to your 55k. I thought this is more about CPUs
> > > > count than about the amount of memory. So I've tried a larger machine
> > > > with 24 CPUs (no dagcount etc...), this one doesn't have a fast storage
> > > > so I've backed the fs image by ramdisk but even then I am getting very
> > > > similar results. No idea what is wrong with my kvm setup.
> > > 
> > > What's the backing storage? I use an image file in an XFS
> > > filesystem, configured with virtio,cache=none so it's concurrency
> > > model matches that of a real disk...
> > 
> > I am using qcow qemu image exported to qemu by
> > -drive file=storage.img,if=ide,index=1,cache=none
> > parameter.
> 
> storage.img is on what type of filesystem?

ext3 on the host system

> Only XFs will give you
> proper IO concurrency with direct IO, and you really need to use a
> raw image file rather than qcow2. If you're not using the special
> capabilities of qcow2 (e.g. snapshots), there's no reason to use
> it...

OK, I will try with the raw image as soon as I have some more time
(hopefully this week).

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
