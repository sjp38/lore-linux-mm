Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 34DFE6B005D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 11:14:11 -0400 (EDT)
Date: Mon, 29 Jun 2009 23:14:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090629151417.GA29796@localhost>
References: <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com> <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost> <29432.1246285300@redhat.com> <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Howells <dhowells@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 29, 2009 at 11:00:26PM +0800, Minchan Kim wrote:
> On Mon, Jun 29, 2009 at 11:21 PM, David Howells<dhowells@redhat.com> wrote:
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> >
> >> Sorry! This one compiles OK:
> >
> > Sadly that doesn't seem to work either:
> >
> > msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
> > msgctl11 cpuset=/ mems_allowed=0
> > Pid: 30858, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #146
> > Call Trace:
> > A [<ffffffff8107207e>] ? oom_kill_process.clone.0+0xa9/0x245
> > A [<ffffffff81072345>] ? __out_of_memory+0x12b/0x142
> > A [<ffffffff810723c6>] ? out_of_memory+0x6a/0x94
> > A [<ffffffff81074a90>] ? __alloc_pages_nodemask+0x42e/0x51d
> > A [<ffffffff81080843>] ? do_wp_page+0x2c6/0x5f5
> > A [<ffffffff810820c1>] ? handle_mm_fault+0x5dd/0x62f
> > A [<ffffffff81022c32>] ? do_page_fault+0x1f8/0x20d
> > A [<ffffffff812e069f>] ? page_fault+0x1f/0x30
> > Mem-Info:
> > DMA per-cpu:
> > CPU A  A 0: hi: A  A 0, btch: A  1 usd: A  0
> > CPU A  A 1: hi: A  A 0, btch: A  1 usd: A  0
> > DMA32 per-cpu:
> > CPU A  A 0: hi: A 186, btch: A 31 usd: A 38
> > CPU A  A 1: hi: A 186, btch: A 31 usd: 106
> > Active_anon:75040 active_file:0 inactive_anon:2031
> > A inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> > A free:1951 slab:41499 mapped:301 pagetables:60674 bounce:0
> > DMA free:3932kB min:60kB low:72kB high:88kB active_anon:2868kB inactive_anon:384kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 968 968 968
> > DMA32 free:3872kB min:3948kB low:4932kB high:5920kB active_anon:297292kB inactive_anon:7740kB active_file:0kB inactive_file:0kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0 0
> > DMA: 7*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3932kB
> > DMA32: 500*4kB 2*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 3872kB
> > 1928 total pagecache pages
> > 0 pages in swap cache
> > Swap cache stats: add 0, delete 0, find 0/0
> > Free swap A = 0kB
> > Total swap = 0kB
> > 255744 pages RAM
> > 5589 pages reserved
> > 238251 pages shared
> > 216210 pages non-shared
> > Out of memory: kill process 25221 (msgctl11) score 130560 or a child
> > Killed process 26379 (msgctl11)
> 
> Totally, I can't understand this situation.
> Now, this page allocation is order zero and It is just likely GFP_HIGHUSER.
> So it's unlikely interrupt context.
> 
> Buddy already has enough fallback DMA32, I think.
> Why kernel can't allocate page for order 0 ?
> Is it allocator bug ?

Yes this time the OOM order/flags are much different from all previous OOMs.

btw, I found that msgctl11 is pretty good at making a lot of SUnreclaim and PageTables pages:

before                           during 1                       during 2                       after

MemTotal:        3931880 kB      MemTotal:        3931880 kB    MemTotal:        3931880 kB    MemTotal:        3931880 kB
MemFree:          985944 kB      MemFree:         1489364 kB    MemFree:         2069184 kB    MemFree:         2853900 kB
Buffers:           41704 kB      Buffers:           16080 kB    Buffers:           16104 kB    Buffers:           16200 kB
Cached:          1899740 kB      Cached:           126780 kB    Cached:           129092 kB    Cached:           130552 kB
SwapCached:            0 kB      SwapCached:            0 kB    SwapCached:            0 kB    SwapCached:            0 kB
Active:           402420 kB      Active:           812320 kB    Active:           643868 kB    Active:           354880 kB
Inactive:        2325644 kB      Inactive:         576732 kB    Inactive:         578792 kB    Inactive:         579640 kB
Active(anon):     333720 kB      Active(anon):     781264 kB    Active(anon):     612632 kB    Active(anon):     323448 kB
Inactive(anon):   470764 kB      Inactive(anon):   482792 kB    Inactive(anon):   482680 kB    Inactive(anon):   482268 kB
Active(file):      68700 kB      Active(file):      31056 kB    Active(file):      31236 kB    Active(file):      31432 kB
Inactive(file):  1854880 kB      Inactive(file):    93940 kB    Inactive(file):    96112 kB    Inactive(file):    97372 kB
Unevictable:           4 kB      Unevictable:           4 kB    Unevictable:           4 kB    Unevictable:           4 kB
Mlocked:               4 kB      Mlocked:               4 kB    Mlocked:               4 kB    Mlocked:               4 kB
SwapTotal:             0 kB      SwapTotal:             0 kB    SwapTotal:             0 kB    SwapTotal:             0 kB
SwapFree:              0 kB      SwapFree:              0 kB    SwapFree:              0 kB    SwapFree:              0 kB
Dirty:               996 kB      Dirty:               536 kB    Dirty:              1348 kB    Dirty:               212 kB
Writeback:             0 kB      Writeback:             0 kB    Writeback:             0 kB    Writeback:             0 kB
AnonPages:        786772 kB      AnonPages:       1246280 kB    AnonPages:       1077352 kB    AnonPages:        787856 kB
Mapped:            53504 kB      Mapped:            50420 kB    Mapped:            50668 kB    Mapped:            50716 kB
Slab:             159340 kB      Slab:             339708 kB    Slab:             227164 kB    Slab:              85272 kB
SReclaimable:     125152 kB      SReclaimable:      49188 kB    SReclaimable:      48944 kB    SReclaimable:      48508 kB
SUnreclaim:        34188 kB      SUnreclaim:       290520 kB    SUnreclaim:       178220 kB    SUnreclaim:        36764 kB
PageTables:        17068 kB      PageTables:       363716 kB    PageTables:       204336 kB    PageTables:        16620 kB
NFS_Unstable:          0 kB      NFS_Unstable:          0 kB    NFS_Unstable:          0 kB    NFS_Unstable:          0 kB
Bounce:                0 kB      Bounce:                0 kB    Bounce:                0 kB    Bounce:                0 kB
WritebackTmp:          0 kB      WritebackTmp:          0 kB    WritebackTmp:          0 kB    WritebackTmp:          0 kB
CommitLimit:     1965940 kB      CommitLimit:     1965940 kB    CommitLimit:     1965940 kB    CommitLimit:     1965940 kB
Committed_AS:    1130516 kB      Committed_AS:   79437584 kB    Committed_AS:   43472636 kB    Committed_AS:    1122240 kB
VmallocTotal:   34359738367 kB   VmallocTotal:   34359738367 kB VmallocTotal:   34359738367 kB VmallocTotal:   34359738367 kB
VmallocUsed:       91504 kB      VmallocUsed:       91504 kB    VmallocUsed:       91504 kB    VmallocUsed:       91504 kB
VmallocChunk:   34359582075 kB   VmallocChunk:   34359582075 kB VmallocChunk:   34359582075 kB VmallocChunk:   34359582075 kB
HugePages_Total:       0         HugePages_Total:       0       HugePages_Total:       0       HugePages_Total:       0
HugePages_Free:        0         HugePages_Free:        0       HugePages_Free:        0       HugePages_Free:        0
HugePages_Rsvd:        0         HugePages_Rsvd:        0       HugePages_Rsvd:        0       HugePages_Rsvd:        0
HugePages_Surp:        0         HugePages_Surp:        0       HugePages_Surp:        0       HugePages_Surp:        0
Hugepagesize:       2048 kB      Hugepagesize:       2048 kB    Hugepagesize:       2048 kB    Hugepagesize:       2048 kB
DirectMap4k:        6848 kB      DirectMap4k:        6848 kB    DirectMap4k:        6848 kB    DirectMap4k:        6848 kB
DirectMap2M:     4120576 kB      DirectMap2M:     4120576 kB    DirectMap2M:     4120576 kB    DirectMap2M:     4120576 kB


My kernel is 2.6.30.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
