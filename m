Date: Fri, 27 Jul 2007 01:47:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070727014749.85370e77.akpm@linux-foundation.org>
In-Reply-To: <1185521021.6295.50.camel@Homer.simpson.net>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<p73abtkrz37.fsf@bingen.suse.de>
	<46A85D95.509@kingswood-consulting.co.uk>
	<20070726092025.GA9157@elte.hu>
	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	<20070726094024.GA15583@elte.hu>
	<20070726030902.02f5eab0.akpm@linux-foundation.org>
	<1185454019.6449.12.camel@Homer.simpson.net>
	<20070726110549.da3a7a0d.akpm@linux-foundation.org>
	<1185513177.6295.21.camel@Homer.simpson.net>
	<1185521021.6295.50.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 09:23:41 +0200 Mike Galbraith <efault@gmx.de> wrote:

> On Fri, 2007-07-27 at 07:13 +0200, Mike Galbraith wrote:
> > On Thu, 2007-07-26 at 11:05 -0700, Andrew Morton wrote:
> > > > drops caches prior to both updatedb runs.
> > > 
> > > I think that was the wrong thing to do.  That will leave gobs of free
> > > memory for updatedb to populate with dentries and inodes.
> > > 
> > > Instead, fill all of memory up with pagecache, then do the updatedb.  See
> > > how much pagecache is left behind and see how large the vfs caches end up.
> 
> I didn't _fill_ memory, but loaded it up a bit with some real workload
> data...
> 
> I tried time sh -c 'git diff v2.6.11 HEAD > /dev/null' to populate the
> cache, and tried different values for vfs_cache_pressure.  Nothing
> prevented git's data from being trashed by updatedb.  Turning the knob
> downward rapidly became very unpleasant due to swap, (with 0 not
> surprisingly being a true horror) but turning it up didn't help git one
> bit.  The amount of data that had to be re-read with stock 100 or 10000
> was the same, or at least so close that you couldn't see a difference in
> vmstat and wall-clock.  Cache sizes varied, but the bottom line didn't.
> (wasn't surprised, seems quite reasonable that git's data looks old and
> useless to the reclaim logic when updatedb runs in between git runs)
> 

Did a bit of playing with this with 128MB of memory.

- drop caches
- read a 1MB file
- run slocate.cron

With vfs_cache_pressure=100:

MemTotal:       116316 kB
MemFree:          3196 kB
Buffers:         54408 kB
Cached:           5128 kB
SwapCached:          0 kB
Active:          41728 kB
Inactive:        27540 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       116316 kB
LowFree:          3196 kB
SwapTotal:     1020116 kB
SwapFree:      1019496 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:        9760 kB
Mapped:           3808 kB
Slab:            40468 kB
SReclaimable:    34824 kB
SUnreclaim:       5644 kB
PageTables:        720 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   1078272 kB
Committed_AS:    25988 kB
VmallocTotal:   901112 kB
VmallocUsed:       656 kB
VmallocChunk:   900412 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     4096 kB

WIth vfs_cache_pressure=10000:

MemTotal:       116316 kB
MemFree:          3060 kB
Buffers:         80792 kB
Cached:           5052 kB
SwapCached:          0 kB
Active:          59432 kB
Inactive:        36140 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       116316 kB
LowFree:          3060 kB
SwapTotal:     1020116 kB
SwapFree:      1019512 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:        9756 kB
Mapped:           3832 kB
Slab:            14304 kB
SReclaimable:     7992 kB
SUnreclaim:       6312 kB
PageTables:        732 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   1078272 kB
Committed_AS:    26000 kB
VmallocTotal:   901112 kB
VmallocUsed:       656 kB
VmallocChunk:   900412 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     4096 kB

so we reaped quite a lot more slab with the higher vfs_cache_pressure.

What I think is killing us here is the blockdev pagecache: the pagecache
which backs those directory entries and inodes.  These pages get read
multiple times because they hold multiple directory entries and multiple
inodes.  These multiple touches will put those pages onto the active list
so they stick around for a long time and everything else gets evicted.


I've never been very sure about this policy for the metadata pagecache.  We
read the filesystem objects into the dcache and icache and then we won't
read from that page again for a long time (I expect).  But the page will
still hang around for a long time.

It could be that we should leave those pages inactive.

<tries it>

diff -puN include/linux/buffer_head.h~a include/linux/buffer_head.h
--- a/include/linux/buffer_head.h~a
+++ a/include/linux/buffer_head.h
@@ -130,7 +130,7 @@ BUFFER_FNS(Eopnotsupp, eopnotsupp)
 BUFFER_FNS(Unwritten, unwritten)
 
 #define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
-#define touch_buffer(bh)	mark_page_accessed(bh->b_page)
+#define touch_buffer(bh)	do { } while(0)
 
 /* If we *know* page->private refers to buffer_heads */
 #define page_buffers(page)					\
_

vfs_cache_pressure=100:

vmm:/home/akpm# cat /proc/meminfo 
MemTotal:       116524 kB
MemFree:          2692 kB
Buffers:         51044 kB
Cached:           5440 kB
SwapCached:          0 kB
Active:          19248 kB
Inactive:        46996 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       116524 kB
LowFree:          2692 kB
SwapTotal:     1020116 kB
SwapFree:      1019492 kB
Dirty:            2008 kB
Writeback:           0 kB
AnonPages:        9772 kB
Mapped:           3812 kB
Slab:            44336 kB
SReclaimable:    38792 kB
SUnreclaim:       5544 kB
PageTables:        720 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   1078376 kB
Committed_AS:    26108 kB
VmallocTotal:   901112 kB
VmallocUsed:       648 kB
VmallocChunk:   900412 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     4096 kB


vfs_cache_pressure=10000

vmm:/home/akpm# cat /proc/meminfo                       
MemTotal:       116524 kB
MemFree:          3720 kB
Buffers:         79832 kB
Cached:           6260 kB
SwapCached:          0 kB
Active:          18276 kB
Inactive:        77584 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       116524 kB
LowFree:          3720 kB
SwapTotal:     1020116 kB
SwapFree:      1019500 kB
Dirty:            2228 kB
Writeback:           0 kB
AnonPages:        9788 kB
Mapped:           3828 kB
Slab:            13680 kB
SReclaimable:     7676 kB
SUnreclaim:       6004 kB
PageTables:        736 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   1078376 kB
Committed_AS:    26112 kB
VmallocTotal:   901112 kB
VmallocUsed:       648 kB
VmallocChunk:   900412 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     4096 kB


So again, slab was trimmed a lot more, but all our pagecache still got
evicted.

ah, but I started that pagecache out on the inactive list.  Try again. 
This time, instead of reading a 1GB file once, let's read an 80MB file four
times.

<no difference>

OK, I saw what happened then.  The inode for my 80MB file got reclaimed
from icache and that instantly reclaimed all 80MB of pagecache.

A single large file probably isn't a good testcase, but the same will
happen with multiple files.  Higher vfs_cache_pressure will worsen this
effect.  But it won't happen with mapped files because their inodes aren't
reclaimable.  More sophisticated testing is needed - there's something in
ext3-tools which will mmap, page in and hold a file for you.


Anyway, blockdev pagecache is a problem, I expect.  It's worth playing with
that patch.

Another problem is atime updates.  You really do want to mount noatime. 
Because with atimes enabled, each touch of a file will touch its inode and
will keep its backing blockdev pagecache page in core.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
