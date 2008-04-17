Received: by ug-out-1314.google.com with SMTP id u40so1232472ugc.29
        for <linux-mm@kvack.org>; Thu, 17 Apr 2008 12:23:21 -0700 (PDT)
Message-ID: <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
Date: Thu, 17 Apr 2008 12:23:20 -0700
From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080417182121.A8CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <ab3f9b940804141716x755787f5h8e0122c394922a83@mail.gmail.com>
	 <20080417182121.A8CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 2:30 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Tom
>
>
>  > Here's a test program that allocates memory and frees on notification.
>  >  It takes an argument which is the number of pages to use; use a
>  > number considerably higher than the amount of memory in the system.
>  > I'm running this on a system without swap.  Each time it gets a
>  > notification, it frees memory and writes out the /proc/meminfo
>  > contents.  What I see is that Cached gradually decreases, then Mapped
>  > decreases, and eventually the kernel invokes the oom killer.  It may
>  > be necessary to tune some of the constants that control the allocation
>  > and free rates and latency; these values work for my system.
>
>  may be...
>
>  I think you misunderstand madvise(MADV_DONTNEED).
>  madvise(DONTNEED) indicate drop process page table.
>  it mean become easily swap.
>
>  when run on system without swap, madvise(DONTNEED) almost doesn't work
>  as your expected.

madvise can be replaced with munmap and the same behavior occurs.

--- test.c.orig 2008-04-17 11:41:47.000000000 -0700
+++ test.c 2008-04-17 11:44:04.000000000 -0700
@@ -127,7 +127,7 @@
    /* Release FREE_CHUNK pages. */

    for (i = 0; i < FREE_CHUNK; i++) {
-       int r = madvise(p + page*PAGESIZE, PAGESIZE, MADV_DONTNEED);
+       int r = munmap(p + page*PAGESIZE, PAGESIZE);
        if (r == -1) {
            perror("madvise");
            exit(1);

Here's what I'm seeing on my system.  This is with munmap, but I see
the same thing with madvise.  First, /proc/meminfo on my system before
running the test:

# cat /proc/meminfo
MemTotal:       127612 kB
MemFree:         71348 kB
Buffers:          1404 kB
Cached:          52324 kB
SwapCached:          0 kB
Active:           2336 kB
Inactive:        51656 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              80 kB
Writeback:           0 kB
AnonPages:         276 kB
Mapped:            376 kB
Slab:             1680 kB
SReclaimable:      824 kB
SUnreclaim:        856 kB
PageTables:         52 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      908 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

Here is the start and end of the output from the test program.  At
each /dev/mem_notify notification Cached decreases, then eventually
Mapped decreases as well, which means the amount of time the program
has to free memory gets smaller and smaller.  Finally the oom killer
is invoked because the program can't react quickly enough to free
memory, even though it can free at a faster rate than it can use
memory.  My test is slow to free because it calls nanosleep, but this
is just a simulation of my actual program that has to perform garbage
collection before it can free memory.

# ./test_unmap 250000
time: 1208458019
MemTotal:       127612 kB
MemFree:          5524 kB
Buffers:           872 kB
Cached:          18388 kB
SwapCached:          0 kB
Active:         101468 kB
Inactive:        18220 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      100436 kB
Mapped:            504 kB
Slab:             1608 kB
SReclaimable:      816 kB
SUnreclaim:        792 kB
PageTables:        152 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

time: 1208458020
MemTotal:       127612 kB
MemFree:          5732 kB
Buffers:           820 kB
Cached:          17928 kB
SwapCached:          0 kB
Active:         101708 kB
Inactive:        17752 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      100712 kB
Mapped:            504 kB
Slab:             1608 kB
SReclaimable:      816 kB
SUnreclaim:        792 kB
PageTables:        156 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

time: 1208458021
MemTotal:       127612 kB
MemFree:          5660 kB
Buffers:           820 kB
Cached:          17416 kB
SwapCached:          0 kB
Active:         102228 kB
Inactive:        17316 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      101308 kB
Mapped:            504 kB
Slab:             1608 kB
SReclaimable:      816 kB
SUnreclaim:        792 kB
PageTables:        156 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

--- snip --- now Mapped is decreasing: ---

time: 1208458049
MemTotal:       127612 kB
MemFree:          5568 kB
Buffers:            40 kB
Cached:            868 kB
SwapCached:          0 kB
Active:         119036 kB
Inactive:          720 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      118848 kB
Mapped:            488 kB
Slab:             1456 kB
SReclaimable:      724 kB
SUnreclaim:        732 kB
PageTables:        172 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

time: 1208458050
MemTotal:       127612 kB
MemFree:          5608 kB
Buffers:            40 kB
Cached:            356 kB
SwapCached:          0 kB
Active:         119392 kB
Inactive:          328 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      119324 kB
Mapped:            268 kB
Slab:             1456 kB
SReclaimable:      724 kB
SUnreclaim:        732 kB
PageTables:        172 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB

time: 1208458051
MemTotal:       127612 kB
MemFree:          5428 kB
Buffers:            40 kB
Cached:            116 kB
SwapCached:          0 kB
Active:         119832 kB
Inactive:           84 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:      119760 kB
Mapped:             60 kB
Slab:             1440 kB
SReclaimable:      720 kB
SUnreclaim:        720 kB
PageTables:        172 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     63804 kB
Committed_AS:      944 kB
VmallocTotal:   909280 kB
VmallocUsed:       304 kB
VmallocChunk:   908976 kB
test_unmap invoked oom-killer: gfp_mask=0xa80d2, order=0, oomkilladj=0
 [<c012f1db>] out_of_memory+0x16f/0x1a0
 [<c01308dd>] __alloc_pages+0x2c1/0x300
 [<c013757a>] handle_mm_fault+0x262/0x3e4
 [<c010906b>] do_page_fault+0x407/0x638
 [<c011fba0>] hrtimer_wakeup+0x0/0x18
 [<c0108c64>] do_page_fault+0x0/0x638
 [<c024d822>] error_code+0x6a/0x70

If it's possible to get a notification when MemFree + Cached + Mapped
(I'm not sure whether this is the right formula) falls below some
threshold, so that the program has time to find memory to discard
before the system runs out, that would prevent the oom -- as long as
the application(s) can ensure that there is not too much memory
allocated while it is looking for memory to free.   But at least the
threshold would give it a reasonable amount of time to handle the
notification.

Thanks,
.tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
