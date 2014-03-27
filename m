Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 502616B0035
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 18:26:15 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j17so5235358oag.28
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 15:26:15 -0700 (PDT)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id i4si3452704obk.28.2014.03.27.15.26.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 15:26:14 -0700 (PDT)
Received: by mail-ob0-f169.google.com with SMTP id va2so5108104obc.28
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 15:26:14 -0700 (PDT)
Date: Thu, 27 Mar 2014 17:26:05 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: Adding compression before/above swapcache
Message-ID: <20140327222605.GB16495@medulla.variantweb.net>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

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
> compress.  Additionally, most of that real disk swap is wasted space -
> all the pages stored compressed in zswap aren't actually written on
> the disk.
> -zram is limited only by its pre-compressed size, and of course the
> amount of actual system memory it can use for compressed storage.  If
> using without dm-cache, this could allow essentially unlimited
> compression until no more compressed pages can be stored; however that
> requires the zram device to be configured as larger than the actual
> system memory.  If using with dm-cache, it may not be obvious what the
> optimal zram size is.
> 
> Pre-swapcache compression would theoretically require no user
> configuration, and the amount of compressed pages would be unlimited
> (until there is no more room to store compressed pages).

Yes, these are limitations of the current designs.

> 
> 2) Both zswap and zram (with dm-cache) write uncompressed pages to disk:
> -zswap rejects any pages being sent to swap that don't compress well
> enough, and they're passed on to the swap disk in uncompressed form.
> Also, once zswap is full it starts uncompressing its old compressed
> pages and writing them back to the swap disk.
> -zram, with dm-cache, can pass pages on to the swap disk, but IIUC
> those pages must be uncompressed first, and then written in compressed
> form on disk.  (Please correct me here if that is wrong).

Yes, again.

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

In theory that could be good.

However, there are a lot of missing details about how this could
actually be done.  Of the top of my head, the reason we choose hook
into the swap path is because it does all the work in both the page
selection, being reclaimed from the end of the inactive anon LRU, and
all the work of unmapping the page from the page table and replacing
it with a swap entry.  In order to do the unmapping, the page must
already be in the swap cache.

So I guess I'm not quite sure how you would do this. What did you have
in mind?

Seth

> 
> 
> Additionally, a couple other random possible benefits:
> -like zswap but unlike zram, a pre-swapcache compressed cache would be
> able to select which pages to store compressed, either based on poor
> compression results or some other criteria - possibly userspace could
> madvise that certain pages were or weren't likely compressible.
> -while zram and zswap are only able to compress and store pages that
> are passed to them by zswapd or direct reclaim, a pre-swap compressed
> cache wouldn't necessarily have to wait until the low watermark is
> reached.
> 
> Any feedback would be greatly appreciated!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
