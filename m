Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDC7E6B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 09:18:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i130so9508403wmg.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 06:18:17 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 125si3018828wmz.124.2016.10.07.06.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 06:18:16 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id f193so2958260wmg.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 06:18:16 -0700 (PDT)
Date: Fri, 7 Oct 2016 15:18:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161007131814.GL18439@dhcp22.suse.cz>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <20161004203202.GY9806@dastard>
 <20161005113839.GC7138@dhcp22.suse.cz>
 <20161006021142.GC9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161006021142.GC9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 06-10-16 13:11:42, Dave Chinner wrote:
> On Wed, Oct 05, 2016 at 01:38:45PM +0200, Michal Hocko wrote:
> > On Wed 05-10-16 07:32:02, Dave Chinner wrote:
> > > On Tue, Oct 04, 2016 at 10:12:15AM +0200, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> > > > the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> > > > direct compact when a high-order allocation fails"). The main reason
> > > > is that the migration of page cache pages might recurse back to fs/io
> > > > layer and we could potentially deadlock. This is overly conservative
> > > > because all the anonymous memory is migrateable in the GFP_NOFS context
> > > > just fine.  This might be a large portion of the memory in many/most
> > > > workkloads.
> > > > 
> > > > Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> > > > (those with a mapping) while isolating pages to be migrated. We cannot
> > > > consider clean fs pages because they might need a metadata update so
> > > > only isolate pages without any mapping for nofs requests.
> > > > 
> > > > The effect of this patch will be probably very limited in many/most
> > > > workloads because higher order GFP_NOFS requests are quite rare,
> > > 
> > > You say they are rare only because you don't know how to trigger
> > > them easily.  :/
> > 
> > true
> > 
> > > Try this:
> > > 
> > > # mkfs.xfs -f -n size=64k <dev>
> > > # mount <dev> /mnt/scratch
> > > # time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
> > >         -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
> > >         -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
> > >         -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
> > >         -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
> > >         -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
> > >         -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
> > >         -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
> > >         -d  /mnt/scratch/14  -d  /mnt/scratch/15
> > 
> > Does this simulate a standard or usual fs workload/configuration?  I am
> 
> Unfortunately, there was an era of cargo cult configuration tweaks
> in the Ceph community that has resulted in a large number of
> production machines with XFS filesystems configured this way. And a
> lot of them store large numbers of small files and run under
> significant sustained memory pressure.

I see

> I slowly working towards getting rid of these high order allocations
> and replacing them with the equivalent number of single page
> allocations, but I haven't got that (complex) change working yet.

Definitely a good plan!

Anyway I was playing with this in my virtual machine (4CPUs, 512MB of
RAM split into two NUMA nodes). Started on a freshly created fs after
boot, no other load in the guest. The performance numbers should be
taken with grain of salt, though, because the host has 4CPUs as well and
it wasn't completely idle, but should be OK enough to give us at least
some picture. This is what fs_mark told me:
Unpatched kernel:
#       Version 3.3, 16 thread(s) starting at Fri Oct  7 09:55:05 2016
#       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
#       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
#       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
#       Files info: size 0 bytes, written with an IO size of 16384 bytes per write
#       App overhead is time in microseconds spent in the test not doing file writing related system calls.
#
FSUse%        Count         Size    Files/sec     App Overhead
     1      1600000            0       4300.1         20745838
     3      3200000            0       4239.9         23849857
     5      4800000            0       4243.4         25939543
     6      6400000            0       4248.4         19514050
     8      8000000            0       4262.1         20796169
     9      9600000            0       4257.6         21288675
    11     11200000            0       4259.7         19375120
    13     12800000            0       4220.7         22734141
    14     14400000            0       4238.5         31936458
    16     16000000            0       4231.5         23409901
    18     17600000            0       4045.3         23577700
    19     19200000            0       2783.4         58299526
    21     20800000            0       2678.2         40616302
    23     22400000            0       2693.5         83973996
Ctrl+C because it just took too long.

For me it was much more interesting to see this in the log:
[ 2304.372647] XFS: fs_mark(3289) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)
[ 2304.443323] XFS: fs_mark(3285) possible memory allocation deadlock size 65728 in kmem_alloc (mode:0x2408240)
[ 4796.772477] XFS: fs_mark(3424) possible memory allocation deadlock size 46936 in kmem_alloc (mode:0x2408240)
[ 4796.775329] XFS: fs_mark(3423) possible memory allocation deadlock size 51416 in kmem_alloc (mode:0x2408240)
[ 4797.388808] XFS: fs_mark(3424) possible memory allocation deadlock size 65728 in kmem_alloc (mode:0x2408240)

It means that the allocation failed and xfs was looping while retrying
to move on.

I hooked into page allocation tracepoint and collected all GFP_NOFS
allocations
echo '!(gfp_flags & 0x80) && (gfp_flags &0x400000)' > $TRACE_MNT/events/kmem/mm_page_alloc/filter

and the order distribution looks as follows
5287609 order=0
     37 order=1
1594905 order=2
3048439 order=3
6699207 order=4
  66645 order=5

so there is indeed a _huge_ high order GFP_NOFS pressure. So I've tried
with this patch applied (with the follow up fix pointed by Vlastimil).
I am not very familiar with the benchmark so I am not going to interpret
those numbers but they seem to be very similar for large part of the run

#       Version 3.3, 16 thread(s) starting at Fri Oct  7 12:58:03 2016
#       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
#       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
#       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
#       Files info: size 0 bytes, written with an IO size of 16384 bytes per write
#       App overhead is time in microseconds spent in the test not doing file writing related system calls.
#
FSUse%        Count         Size    Files/sec     App Overhead
     1      1600000            0       4289.1         19243934
     3      3200000            0       4241.6         32828865
     5      4800000            0       4248.7         32884693
     6      6400000            0       4314.4         19608921
     8      8000000            0       4269.9         24953292
     9      9600000            0       4270.7         33235572
    11     11200000            0       4346.4         40817101
    13     12800000            0       4285.3         29972397
    14     14400000            0       4297.2         20539765
    16     16000000            0       4219.6         18596767
    18     17600000            0       4273.8         49611187
    19     19200000            0       4300.4         27944451
    21     20800000            0       4270.6         22324585
    22     22400000            0       4317.6         22650382
    24     24000000            0       4065.2         22297964

while it doesn't seem to drop the Files/sec numbers starting with
Count=19200000. I also see only a single

[ 3063.815003] XFS: fs_mark(3272) possible memory allocation deadlock size 65624 in kmem_alloc (mode:0x2408240)

which happens much later during the load. So I've checked the tracing
output and compared the same time period of the test (5730s - note that
I've stopped the later one slightly later and didn't let any of them
finish). This is not precise but it should give us at least some idea
about how many allocations we could during the same workload during the
same time so it shouldn't be completely bogus.

Unpatched kernel
all orders
begin:44.718798 end:5774.618736 allocs:15019288
order > 0 
begin:44.718798 end:5773.587195 allocs:10438610

Patched kernel
all orders
begin:64.612804 end:5794.193619 allocs:16110081 [107.2%]
order > 0
begin:64.612804 end:5794.193619 allocs:11741492 [112.5%]

which would suggest that diving into the compaction rather than backing
off and waiting for kcompactd to make the work for us was indeed a
better strategy and helped the throughput. All that with a rather
limited amount of anonymous memory because there doesn't seem to be
any large source of those pages during this workload. Quite contrary
AFAIU. I haven't checked latencies of those allocations because we
currently do not have a convenient way to do that. I could measure
compaction latencies but that wouldn't be a full picture and it seems
that the above should tell us that not restricting the compaction is a
good thing to do.

So unless I have grossly misinterpreted something here I can add this to
the changelog to show the effect of the patch on a really heavy NOFS
highorder workload.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
