Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 53B896B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 20:16:07 -0400 (EDT)
Received: by qyk4 with SMTP id 4so3360524qyk.14
        for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:16:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
Date: Tue, 26 Jul 2011 09:16:04 +0900
Message-ID: <CAEwNFnCwXkzLdd-G1z=y=0kGWQ6VxO-Lr0M8n8_UDSnOESN32A@mail.gmail.com>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Jul 26, 2011 at 5:19 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> Hello!
>
> Writing back single file pages during reclaim exhibits bad IO
> patterns, but we can't just stop doing that before the VM has other
> means to ensure the pages in a zone are reclaimable.
>
> Over time there were several suggestions of at least doing
> write-around of the pages in inode-proximity when the need arises to
> clean pages during memory pressure. =C2=A0But even that would interrupt
> writeback from the flushers, without any guarantees that the nearby
> inode-pages are even sitting on the same troubled zone.
>
> The reason why dirty pages reach the end of LRU lists in the first
> place is in part because the dirty limits are a global restriction
> while most systems have more than one LRU list that are different in
> size. =C2=A0Multiple nodes have multiple zones have multiple file lists b=
ut
> at the same time there is nothing to balance the dirty pages between
> the lists except for reclaim writing them out upon encounter.
>
> With around 4G of RAM, a x86_64 machine of mine has a DMA32 zone of a
> bit over 3G, a Normal zone of 500M, and a DMA zone of 15M.
>
> A linear writer can quickly fill up the Normal zone, then the DMA32
> zone, throttled by the dirty limit initially. =C2=A0The flushers catch up=
,
> the zones are now mostly full of clean pages and memory reclaim kicks
> in on subsequent allocations. =C2=A0The pages it frees from the Normal zo=
ne
> are quickly filled with dirty pages (unthrottled, as the much bigger
> DMA32 zone allows for a huge number of dirty pages in comparison to
> the Normal zone). =C2=A0As there are also anon and active file pages on t=
he
> Normal zone, it is not unlikely that a significant amount of its
> inactive file pages are now dirty [ foo=3Dzone(global) ]:
>
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D112313(821289=
) active=3D9942(10039) isolated=3D27(27) dirty=3D59709(146944) writeback=3D=
739(4017)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D111102(806876=
) active=3D9925(10022) isolated=3D32(32) dirty=3D72125(146914) writeback=3D=
957(3972)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D110493(803374=
) active=3D9871(9978) isolated=3D32(32) dirty=3D57274(146618) writeback=3D4=
088(4088)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D111957(806559=
) active=3D9871(9978) isolated=3D32(32) dirty=3D65125(147329) writeback=3D4=
56(3866)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D110601(803978=
) active=3D9860(9973) isolated=3D27(27) dirty=3D63792(146590) writeback=3D6=
1(4276)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D111786(804032=
) active=3D9860(9973) isolated=3D0(64) dirty=3D64310(146998) writeback=3D12=
82(3847)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D111643(805651=
) active=3D9860(9982) isolated=3D32(32) dirty=3D63778(147217) writeback=3D1=
127(4156)
> reclaim: blkdev_writepage+0x0/0x20 zone=3DNormal inactive=3D111678(804709=
) active=3D9859(10112) isolated=3D27(27) dirty=3D81673(148224) writeback=3D=
29(4233)
>
> [ These prints occur only once per reclaim invocation, so the actual
> ->writepage calls are more frequent than the timestamp may suggest. ]
>
> In the scenario without the Normal zone, first the DMA32 zone fills
> up, then the DMA zone. =C2=A0When reclaim kicks in, it is presented with =
a
> DMA zone whose inactive pages are all dirty -- and dirtied most
> recently at that, so the flushers really had abysmal chances at making
> some headway:
>
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D776(430813) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D814(68649) writeback=3D0(18765)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D726(430344) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D764(67790) writeback=3D0(17146)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D729(430838) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D293(65303) writeback=3D468(20122)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D757(431181) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D63(68851) writeback=3D731(15926)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D758(432808) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D645(64106) writeback=3D0(19666)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D726(431018) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D740(65770) writeback=3D10(17907)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D697(430467) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D743(63757) writeback=3D0(18826)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=3DDMA inactive=3D693(430951) act=
ive=3D2(2931) isolated=3D32(32) dirty=3D626(54529) writeback=3D91(16198)
>
> The idea behind this patch set is to take the ratio the global dirty
> limits have to the global memory state and put it into proportion to
> the individual zone. =C2=A0The allocator ensures that pages allocated for
> being written to in the page cache are distributed across zones such
> that there are always enough clean pages on a zone to begin with.
>
> I am not yet really satisfied as it's not really orthogonal or
> integrated with the other writeback throttling much, and has rough
> edges here and there, but test results do look rather promising so
> far:
>
> --- Copying 8G to fuse-ntfs on USB stick in 4G machine
>
> 3.0:
>
> =C2=A0Performance counter stats for 'dd if=3D/dev/zero of=3Dzeroes bs=3D3=
2k count=3D262144' (6 runs):
>
> =C2=A0 =C2=A0 =C2=A0 140,671,831 cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A04.923 M/sec =C2=A0 ( +- =C2=A0 0.198% =
) =C2=A0(scaled from 82.80%)
> =C2=A0 =C2=A0 =C2=A0 726,265,014 cache-references =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 # =C2=A0 =C2=A0 25.417 M/sec =C2=A0 ( +- =C2=A0 1.104% ) =C2=A0(scal=
ed from 83.06%)
> =C2=A0 =C2=A0 =C2=A0 144,092,383 branch-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A0 =C2=A04.157 % =C2=A0 =C2=A0 =C2=A0 ( +- =
=C2=A0 0.493% ) =C2=A0(scaled from 83.17%)
> =C2=A0 =C2=A0 3,466,608,296 branches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A0121.319 M/sec =C2=A0 ( +- =C2=A0 0.421%=
 ) =C2=A0(scaled from 67.89%)
> =C2=A0 =C2=A017,882,351,343 instructions =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.417 IPC =C2=A0 =C2=A0 ( +- =C2=A0 0.457%=
 ) =C2=A0(scaled from 84.73%)
> =C2=A0 =C2=A042,848,633,897 cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 1499.554 M/sec =C2=A0 ( +- =C2=A0 0.604% =
) =C2=A0(scaled from 83.08%)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 236 page-faults =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A0 =C2=A00.000 M/sec =
=C2=A0 ( +- =C2=A0 0.323% )
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 8,026 CPU-migrations =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.000 M/sec =C2=A0 ( +- =C2=
=A0 6.291% )
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 2,372,358 context-switches =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.083 M/sec =C2=A0 ( +- =C2=A0 0.003% )
> =C2=A0 =C2=A0 =C2=A028574.255540 task-clock-msecs =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 # =C2=A0 =C2=A0 =C2=A00.031 CPUs =C2=A0 =C2=A0( +- =C2=A0 0.409% )
>
> =C2=A0 =C2=A0 =C2=A0912.625436885 =C2=A0seconds time elapsed =C2=A0 ( +- =
=C2=A0 3.851% )
>
> =C2=A0nr_vmscan_write 667839
>
> 3.0-per-zone-dirty:
>
> =C2=A0Performance counter stats for 'dd if=3D/dev/zero of=3Dzeroes bs=3D3=
2k count=3D262144' (6 runs):
>
> =C2=A0 =C2=A0 =C2=A0 140,791,501 cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A03.887 M/sec =C2=A0 ( +- =C2=A0 0.186% =
) =C2=A0(scaled from 83.09%)
> =C2=A0 =C2=A0 =C2=A0 816,474,193 cache-references =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 # =C2=A0 =C2=A0 22.540 M/sec =C2=A0 ( +- =C2=A0 0.923% ) =C2=A0(scal=
ed from 83.16%)
> =C2=A0 =C2=A0 =C2=A0 154,500,577 branch-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A0 =C2=A04.302 % =C2=A0 =C2=A0 =C2=A0 ( +- =
=C2=A0 0.495% ) =C2=A0(scaled from 83.15%)
> =C2=A0 =C2=A0 3,591,344,338 branches =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A0 99.143 M/sec =C2=A0 ( +- =C2=A0 0.402%=
 ) =C2=A0(scaled from 67.32%)
> =C2=A0 =C2=A018,713,190,183 instructions =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.338 IPC =C2=A0 =C2=A0 ( +- =C2=A0 0.448%=
 ) =C2=A0(scaled from 83.96%)
> =C2=A0 =C2=A055,285,320,107 cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 1526.208 M/sec =C2=A0 ( +- =C2=A0 0.588% =
) =C2=A0(scaled from 83.28%)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 237 page-faults =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A0 =C2=A00.000 M/sec =
=C2=A0 ( +- =C2=A0 0.302% )
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A028,028 CPU-migrations =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.001 M/sec =C2=A0 ( +- =C2=
=A0 3.070% )
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 2,369,897 context-switches =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 # =C2=A0 =C2=A0 =C2=A00.065 M/sec =C2=A0 ( +- =C2=A0 0.006% )
> =C2=A0 =C2=A0 =C2=A036223.970238 task-clock-msecs =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 # =C2=A0 =C2=A0 =C2=A00.060 CPUs =C2=A0 =C2=A0( +- =C2=A0 1.062% )
>
> =C2=A0 =C2=A0 =C2=A0605.909769823 =C2=A0seconds time elapsed =C2=A0 ( +- =
=C2=A0 0.783% )
>
> =C2=A0nr_vmscan_write 0
>
> That's an increase of throughput by 30% and no writeback interference
> from reclaim.
>
> As not every other allocation has to reclaim from a Normal zone full
> of dirty pages anymore, the patched kernel is also more responsive in
> general during the copy.
>
> I am also running fs_mark on XFS on a 2G machine, but the final
> results are not in yet. =C2=A0The preliminary results appear to be in thi=
s
> ballpark:
>
> --- fs_mark -d fsmark-one -d fsmark-two -D 100 -N 150 -n 150 -L 25 -t 1 -=
S 0 -s $((10 << 20))
>
> 3.0:
>
> real =C2=A0 =C2=A020m43.901s
> user =C2=A0 =C2=A00m8.988s
> sys =C2=A0 =C2=A0 0m58.227s
> nr_vmscan_write 3347
>
> 3.0-per-zone-dirty:
>
> real =C2=A0 =C2=A020m8.012s
> user =C2=A0 =C2=A00m8.862s
> sys =C2=A0 =C2=A0 1m2.585s
> nr_vmscan_write 161
>
> Patch #1 is more or less an unrelated fix that subsequent patches
> depend upon as they modify the same code. =C2=A0It should go upstream
> immediately, me thinks.
>
> #2 and #3 are boring cleanup, guess they can go in right away as well.
>
> #4 adds per-zone dirty throttling for __GFP_WRITE allocators, #5
> passes __GFP_WRITE from the grab_cache_page* functions in the hope to
> get most writers and no readers; I haven't checked all sites yet.
>
> Discuss! :-)
>
> =C2=A0include/linux/gfp.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 +-
> =C2=A0include/linux/pagemap.h =C2=A0 | =C2=A0 =C2=A06 +-
> =C2=A0include/linux/writeback.h | =C2=A0 =C2=A05 +-
> =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A08 +-
> =C2=A0mm/page-writeback.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0225 ++++++++++++++=
++++++++++++++++--------------
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 27 ++++=
++
> =C2=A06 files changed, 196 insertions(+), 79 deletions(-)
>
>

IMHO, looks promising!
I like *round-robin* allocation like this although we have problems
should be solved.
What I concern is that it's a kind of big change so we need many
testing and time in various environment to find edge.

Actually I had a idea that VM doesn't write out dirty pages(although
it's a victim) if other fallback zones have enough free pages. Because
root problem is small LRU zone which doesn't have enough time to
activate/reference the page. It's unfair. Even high zone is first
target on most of allocation for user so it would be severe than other
zones.

But your solution is more simple if we can use __GFP_WRITE well.
Although it has problems at the moment,  we can solve it step by step, I th=
ink.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
