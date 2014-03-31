Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2293D6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 00:55:44 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so7589147pbb.5
        for <linux-mm@kvack.org>; Sun, 30 Mar 2014 21:55:43 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id a8si8351939pbs.457.2014.03.30.21.55.41
        for <linux-mm@kvack.org>;
        Sun, 30 Mar 2014 21:55:43 -0700 (PDT)
Date: Mon, 31 Mar 2014 13:56:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Adding compression before/above swapcache
Message-ID: <20140331045626.GA6281@bbox>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello Dan,

On Wed, Mar 26, 2014 at 04:28:27PM -0400, Dan Streetman wrote:
> I'd like some feedback on how possible/useful, or not, it might be to
> add compression into the page handling code before pages are added to
> the swapcache.  My thought is that adding a compressed cache at that
> point may have (at least) two advantages over the existing page
> compression, zswap and zram, which are both in the swap path.
> 
> 1) Both zswap and zram are limited in the amount of memory that they
> can compress/store:
> -zswap is limited both in the amount of pre-compressed pages, by the
> total amount of swap configured in the system, and post-compressed
> pages, by its max_pool_percentage parameter.  These limitations aren't
> necessarily a bad thing, just requirements for the user (or distro
> setup tool, etc) to correctly configure them.  And for optimal
> operation, they need to coordinate; for example, with the default
> post-compressed 20% of memory zswap's configured to use, the amount of
> swap in the system must be at least 40% of system memory (if/when
> zswap is changed to use zsmalloc that number would need to increase).
> The point being, there is a clear possibility of misconfiguration, or
> even a simple lack of enough disk space for actual swap, that could
> artificially reduce the amount of total memory zswap is able to

Potentailly, there is risk in tuning knob so admin should be careful.
Surely, kernel should do best effort to prevent such confusion and
I think well-written documentation would be enough.

> compress.  Additionally, most of that real disk swap is wasted space -
> all the pages stored compressed in zswap aren't actually written on
> the disk.

It's same with normal swap. If there isn't memory pressure, it's wasted
space, too.

> -zram is limited only by its pre-compressed size, and of course the
> amount of actual system memory it can use for compressed storage.  If
> using without dm-cache, this could allow essentially unlimited

It's because no requirement until now. If someone ask it or report
the problem, we could support it easily.

> compression until no more compressed pages can be stored; however that
> requires the zram device to be configured as larger than the actual
> system memory.  If using with dm-cache, it may not be obvious what the

Normally, the method we have used is to measure avg compr ratio
and 

> optimal zram size is.

It's not a problem of zram. It seems dm-cache folks pass the decision
to userspace because there would be various choices depends on policy
dm-cache have supported.

> 
> Pre-swapcache compression would theoretically require no user
> configuration, and the amount of compressed pages would be unlimited
> (until there is no more room to store compressed pages).

Could you elaborate it more?
You mean pre-swapcache doesn't need real storage(mkswap + swapn)?

> 
> 2) Both zswap and zram (with dm-cache) write uncompressed pages to disk:
> -zswap rejects any pages being sent to swap that don't compress well
> enough, and they're passed on to the swap disk in uncompressed form.
> Also, once zswap is full it starts uncompressing its old compressed
> pages and writing them back to the swap disk.
> -zram, with dm-cache, can pass pages on to the swap disk, but IIUC
> those pages must be uncompressed first, and then written in compressed
> form on disk.  (Please correct me here if that is wrong).

I didn't look that code but I guess if dm-cache decides moving the page
from zram device to real storage, it would decompress a page from zram
and write it to storage without compressing. So it's not a compressed
form.

> 
> A compressed cache that comes before the swap cache would be able to
> push pages from its compressed storage to the swap disk, that contain
> multiple compressed pages (and/or parts of compressed pages, if
> overlapping page boundries).  I think that would be able to,
> theoretically at least, improve overall read/write times from a
> pre-compressed perspective, simply because less actual data would be
> transferred.  Also, less actual swap disk space would be
> used/required, which on systems with a very large amount of system
> memory may be beneficial.

I agree part of your claim but couldn't.
If we write a page which includes several compressed pages, it surely
enhance write bandwidth but we should give extra pages for *reading*
a page. You might argue swap already have done it via page-cluster.
But the difference is that we could control it by knob so we could
reduce window size if swap readahead hit ratio isn't good.

With your proposal, we couldn't control it so it would be likely to
fail swap-read than old if memory pressure is severe because we 
might need many pages to decompress just a page. For prevent,
we need large buffer to decompress pages and we should limit the
number of pages which put together a page, which can make system
more predictable but it needs serialization of buffer so might hurt
performance, too.

> 
> 
> Additionally, a couple other random possible benefits:
> -like zswap but unlike zram, a pre-swapcache compressed cache would be
> able to select which pages to store compressed, either based on poor
> compression results or some other criteria - possibly userspace could
> madvise that certain pages were or weren't likely compressible.

In your proposal, If it turns out poor compression after doing comp work,
it would go to swap. It's same with zswap.

Another suggestion on madvise is more general and I believe it could
help zram/zswap as well as your proposal.

It's already known problem and I suggested using mlock.
If mlock is really big overhead for that, we might introduce another
hint which just mark vma->vm_flags to *VMA_NOT_GOOD_COMPRESS*.
In that case, mm layer could skip zswap and it might work with zram
if there is support like BDI_CAP_SWAP_BACKED_INCOMPRAM.

> -while zram and zswap are only able to compress and store pages that
> are passed to them by zswapd or direct reclaim, a pre-swap compressed
> cache wouldn't necessarily have to wait until the low watermark is
> reached.

I couldn't understand the benefit.
Why should we compress memory before system is no memory pressure?

> 
> Any feedback would be greatly appreciated!

Having said that, I'd like to have such feature(ie, copmressed-form writeout)
for zram because zram supports zram-blk as well as zram-swap so zram-blk
case could be no problem for memory-pressure so it would be happy to
allocate multiple pages to store data when *read* happens and decompress
a page into multiple pages.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
