Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B3AB96B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 00:32:20 -0400 (EDT)
Received: by qwa26 with SMTP id 26so868899qwa.14
        for <linux-mm@kvack.org>; Tue, 26 Jul 2011 21:32:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Date: Wed, 27 Jul 2011 13:32:17 +0900
Message-ID: <CAEwNFnA_OGUYfCQrLCMt9NuU0O0ftWWBB4_Si8NypKyaeuRg2A@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

Hi Mel,

On Fri, Jul 22, 2011 at 1:28 AM, Mel Gorman <mgorman@suse.de> wrote:
> Warning: Long post with lots of figures. If you normally drink coffee
> and you don't have a cup, get one or you may end up with a case of
> keyboard face.
>
> Changelog since v1
> =C2=A0o Drop prio-inode patch. There is now a dependency that the flusher
> =C2=A0 =C2=A0threads find these dirty pages quickly.
> =C2=A0o Drop nr_vmscan_throttled counter
> =C2=A0o SetPageReclaim instead of deactivate_page which was wrong
> =C2=A0o Add warning to main filesystems if called from direct reclaim con=
text
> =C2=A0o Add patch to completely disable filesystem writeback from reclaim
>
> Testing from the XFS folk revealed that there is still too much
> I/O from the end of the LRU in kswapd. Previously it was considered
> acceptable by VM people for a small number of pages to be written
> back from reclaim with testing generally showing about 0.3% of pages
> reclaimed were written back (higher if memory was low). That writing
> back a small number of pages is ok has been heavily disputed for
> quite some time and Dave Chinner explained it well;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0It doesn't have to be a very high number to be=
 a problem. IO
> =C2=A0 =C2=A0 =C2=A0 =C2=A0is orders of magnitude slower than the CPU tim=
e it takes to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0flush a page, so the cost of making a bad flus=
h decision is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0very high. And single page writeback from the =
LRU is almost
> =C2=A0 =C2=A0 =C2=A0 =C2=A0always a bad flush decision.
>
> To complicate matters, filesystems respond very differently to requests
> from reclaim according to Christoph Hellwig;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0xfs tries to write it back if the requester is=
 kswapd
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ext4 ignores the request if it's a delayed all=
ocation
> =C2=A0 =C2=A0 =C2=A0 =C2=A0btrfs ignores the request
>
> As a result, each filesystem has different performance characteristics
> when under memory pressure and there are many pages being dirties. In
> some cases, the request is ignored entirely so the VM cannot depend
> on the IO being dispatched.
>
> The objective of this series to to reduce writing of filesystem-backed
> pages from reclaim, play nicely with writeback that is already in
> progress and throttle reclaim appropriately when dirty pages are
> encountered. The assumption is that the flushers will always write
> pages faster than if reclaim issues the IO. The new problem is that
> reclaim has very little control over how long before a page in a
> particular zone or container is cleaned which is discussed later. A
> secondary goal is to avoid the problem whereby direct reclaim splices
> two potentially deep call stacks together.
>
> Patch 1 disables writeback of filesystem pages from direct reclaim
> =C2=A0 =C2=A0 =C2=A0 =C2=A0entirely. Anonymous pages are still written.
>
> Patches 2-4 add warnings to XFS, ext4 and btrfs if called from
> =C2=A0 =C2=A0 =C2=A0 =C2=A0direct reclaim. With patch 1, this "never happ=
ens" and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0is intended to catch regressions in this logic=
 in the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0future.
>
> Patch 5 disables writeback of filesystem pages from kswapd unless
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the priority is raised to the point where kswa=
pd is considered
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to be in trouble.
>
> Patch 6 throttles reclaimers if too many dirty pages are being
> =C2=A0 =C2=A0 =C2=A0 =C2=A0encountered and the zones or backing devices a=
re congested.
>
> Patch 7 invalidates dirty pages found at the end of the LRU so they
> =C2=A0 =C2=A0 =C2=A0 =C2=A0are reclaimed quickly after being written back=
 rather than
> =C2=A0 =C2=A0 =C2=A0 =C2=A0waiting for a reclaimer to find them
>
> Patch 8 disables writeback of filesystem pages from kswapd and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends entirely on the flusher threads for cl=
eaning pages.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This is potentially a problem if the flusher t=
hreads take a
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long time to wake or are not discovering the p=
ages we need
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cleaned. By placing the patch last, it's more =
likely that
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bisection can catch if this situation occurs a=
nd can be
> =C2=A0 =C2=A0 =C2=A0 =C2=A0easily reverted.
>
> I consider this series to be orthogonal to the writeback work but
> it is worth noting that the writeback work affects the viability of
> patch 8 in particular.
>
> I tested this on ext4 and xfs using fs_mark and a micro benchmark
> that does a streaming write to a large mapping (exercises use-once
> LRU logic) followed by streaming writes to a mix of anonymous and
> file-backed mappings. The command line for fs_mark when botted with
> 512M looked something like
>
> ./fs_mark =C2=A0-d =C2=A0/tmp/fsmark-2676 =C2=A0-D =C2=A0100 =C2=A0-N =C2=
=A0150 =C2=A0-n =C2=A0150 =C2=A0-L =C2=A025 =C2=A0-t =C2=A01 =C2=A0-S0 =C2=
=A0-s =C2=A010485760
>
> The number of files was adjusted depending on the amount of available
> memory so that the files created was about 3xRAM. For multiple threads,
> the -d switch is specified multiple times.
>
> 3 kernels are tested.
>
> vanilla 3.0-rc6
> kswapdwb-v2r5 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 patches 1-7
> nokswapdwb-v2r5 =C2=A0 =C2=A0 =C2=A0 =C2=A0 patches 1-8
>
> The test machine is x86-64 with an older generation of AMD processor
> with 4 cores. The underlying storage was 4 disks configured as RAID-0
> as this was the best configuration of storage I had available. Swap
> is on a separate disk. Dirty ratio was tuned to 40% instead of the
> default of 20%.
>
> Testing was run with and without monitors to both verify that the
> patches were operating as expected and that any performance gain was
> real and not due to interference from monitors.
>
> I've posted the raw reports for each filesystem at
>
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721
>
> Unfortunately, the volume of data is excessive but here is a partial
> summary of what was interesting for XFS.

Could you clarify the notation?
1P :  1 Processor?
512M: system memory size?
2X , 4X, 16X: the size of files created during test

>
> 512M1P-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Files/s =C2=A0mean =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 32.99 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 35.16 ( 6.18%) =C2=
=A0 =C2=A0 =C2=A0 35.08 ( 5.94%)
> 512M1P-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time fsmark =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 122.54 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 115.54 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 115.21
> 512M1P-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time mmap-strm =C2=
=A0 =C2=A0 =C2=A0 =C2=A0105.09 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 104.44 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 106.12
> 512M-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Files/s =C2=A0mean =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 30.50 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 33.30 ( 8.40%)=
 =C2=A0 =C2=A0 =C2=A0 34.68 (12.06%)
> 512M-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time fsmark =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 136.14 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 124.26 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1=
20.33
> 512M-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time mmap-strm=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0154.68 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 145.91 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 138.83
> 512M-2X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Files/s =C2=A0mean =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 28.48 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 32.90 (13.45%) =C2=
=A0 =C2=A0 =C2=A0 32.83 (13.26%)
> 512M-2X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Elapsed Time fsmark =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 145.64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 128.67 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 128.67
> 512M-2X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Elapsed Time mmap-strm =C2=
=A0 =C2=A0 =C2=A0 =C2=A0145.92 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 136.65 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 137.67
> 512M-4X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Files/s =C2=A0mean =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 29.06 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 32.82 (11.46%) =C2=
=A0 =C2=A0 =C2=A0 33.32 (12.81%)
> 512M-4X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Elapsed Time fsmark =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 153.69 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 136.74 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 135.11
> 512M-4X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Elapsed Time mmap-strm =C2=
=A0 =C2=A0 =C2=A0 =C2=A0159.47 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 128.64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 132.59
> 512M-16X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 Files/s =C2=A0mean =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 48.80 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 41.80 (-16.77%) =C2=A0 =
=C2=A0 =C2=A0 56.61 (13.79%)
> 512M-16X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time fsmark =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 161.48 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 144.61 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 141.19
> 512M-16X-xfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 Elapsed Time mmap-strm =C2=A0 =
=C2=A0 =C2=A0 =C2=A0167.04 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 150.62 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 147.83
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
