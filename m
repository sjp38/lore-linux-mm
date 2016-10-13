Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C64C6B0264
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:29:29 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rz1so60741860pab.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:29:29 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id 77si11614702pfy.91.2016.10.12.17.29.27
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 17:29:28 -0700 (PDT)
Date: Thu, 13 Oct 2016 11:29:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161013002924.GO23194@dastard>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <20161004203202.GY9806@dastard>
 <20161005113839.GC7138@dhcp22.suse.cz>
 <20161006021142.GC9806@dastard>
 <20161007131814.GL18439@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161007131814.GL18439@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 07, 2016 at 03:18:14PM +0200, Michal Hocko wrote:
> On Thu 06-10-16 13:11:42, Dave Chinner wrote:
> > On Wed, Oct 05, 2016 at 01:38:45PM +0200, Michal Hocko wrote:
> > > On Wed 05-10-16 07:32:02, Dave Chinner wrote:
> > > > On Tue, Oct 04, 2016 at 10:12:15AM +0200, Michal Hocko wrote:
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> > > > > the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> > > > > direct compact when a high-order allocation fails"). The main reason
> > > > > is that the migration of page cache pages might recurse back to fs/io
> > > > > layer and we could potentially deadlock. This is overly conservative
> > > > > because all the anonymous memory is migrateable in the GFP_NOFS context
> > > > > just fine.  This might be a large portion of the memory in many/most
> > > > > workkloads.
> > > > > 
> > > > > Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> > > > > (those with a mapping) while isolating pages to be migrated. We cannot
> > > > > consider clean fs pages because they might need a metadata update so
> > > > > only isolate pages without any mapping for nofs requests.
> > > > > 
> > > > > The effect of this patch will be probably very limited in many/most
> > > > > workloads because higher order GFP_NOFS requests are quite rare,
> > > > 
> > > > You say they are rare only because you don't know how to trigger
> > > > them easily.  :/
> > > 
> > > true
> > > 
> > > > Try this:
> > > > 
> > > > # mkfs.xfs -f -n size=64k <dev>
> > > > # mount <dev> /mnt/scratch
> > > > # time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
> > > >         -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
> > > >         -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
> > > >         -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
> > > >         -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
> > > >         -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
> > > >         -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
> > > >         -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
> > > >         -d  /mnt/scratch/14  -d  /mnt/scratch/15
> > > 
> > > Does this simulate a standard or usual fs workload/configuration?  I am
> > 
> > Unfortunately, there was an era of cargo cult configuration tweaks
> > in the Ceph community that has resulted in a large number of
> > production machines with XFS filesystems configured this way. And a
> > lot of them store large numbers of small files and run under
> > significant sustained memory pressure.
> 
> I see
> 
> > I slowly working towards getting rid of these high order allocations
> > and replacing them with the equivalent number of single page
> > allocations, but I haven't got that (complex) change working yet.
> 
> Definitely a good plan!
> 
> Anyway I was playing with this in my virtual machine (4CPUs, 512MB of
> RAM split into two NUMA nodes). Started on a freshly created fs after
> boot, no other load in the guest. The performance numbers should be
> taken with grain of salt, though, because the host has 4CPUs as well and
> it wasn't completely idle, but should be OK enough to give us at least
> some picture. This is what fs_mark told me:
> Unpatched kernel:
> #       Version 3.3, 16 thread(s) starting at Fri Oct  7 09:55:05 2016
> #       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
> #       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
> #       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
> #       Files info: size 0 bytes, written with an IO size of 16384 bytes per write
> #       App overhead is time in microseconds spent in the test not doing file writing related system calls.
> #
> FSUse%        Count         Size    Files/sec     App Overhead
>      1      1600000            0       4300.1         20745838
>      3      3200000            0       4239.9         23849857
>      5      4800000            0       4243.4         25939543
>      6      6400000            0       4248.4         19514050
>      8      8000000            0       4262.1         20796169
>      9      9600000            0       4257.6         21288675
>     11     11200000            0       4259.7         19375120
>     13     12800000            0       4220.7         22734141
>     14     14400000            0       4238.5         31936458
>     16     16000000            0       4231.5         23409901
>     18     17600000            0       4045.3         23577700
>     19     19200000            0       2783.4         58299526
>     21     20800000            0       2678.2         40616302
>     23     22400000            0       2693.5         83973996
> Ctrl+C because it just took too long.

Try running it on a larger filesystem, or configure the fs with more
AGs and a larger log (i.e. mkfs.xfs -f -dagcount=24 -l size=512m
<dev>). That will speed up modifications and increase concurrency.
This test should be able to run 5-10x faster than this (it
sustains 55,000 files/s @ 300MB/s write on my test fs on a cheap
SSD).


> while it doesn't seem to drop the Files/sec numbers starting with
> Count=19200000. I also see only a single
> 
> [ 3063.815003] XFS: fs_mark(3272) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)

Remember that this is emitted only after /100/ consecutive
allocation failures. So the fact it is still being emitted means
that the situation is not drastically better....

> Unpatched kernel
> all orders
> begin:44.718798 end:5774.618736 allocs:15019288
> order > 0 
> begin:44.718798 end:5773.587195 allocs:10438610
> 
> Patched kernel
> all orders
> begin:64.612804 end:5794.193619 allocs:16110081 [107.2%]
> order > 0
> begin:64.612804 end:5794.193619 allocs:11741492 [112.5%]
> 
> which would suggest that diving into the compaction rather than backing
> off and waiting for kcompactd to make the work for us was indeed a
> better strategy and helped the throughput.

Well, without a success/failure ratio being calculated it's hard to
tell what improvement it made. Did it increase the success rate, or
reduce failure latency so retries happened faster?

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
