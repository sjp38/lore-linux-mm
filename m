Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5936B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:36:29 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id n12so3547831wgh.12
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:36:28 -0700 (PDT)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id fb6si1915648wic.38.2014.03.28.05.36.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 05:36:26 -0700 (PDT)
Received: by mail-we0-f173.google.com with SMTP id w61so2562851wes.4
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:36:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140327222605.GB16495@medulla.variantweb.net>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
 <20140327222605.GB16495@medulla.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 28 Mar 2014 08:36:04 -0400
Message-ID: <CALZtONDBNzL_S+UUxKgvNjEYu49eM5Fc2yJ37dJ8E+PEK+C7qg@mail.gmail.com>
Subject: Re: Adding compression before/above swapcache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Mar 27, 2014 at 6:26 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Wed, Mar 26, 2014 at 04:28:27PM -0400, Dan Streetman wrote:
>> I'd like some feedback on how possible/useful, or not, it might be to
>> add compression into the page handling code before pages are added to
>> the swapcache.  My thought is that adding a compressed cache at that
>> point may have (at least) two advantages over the existing page
>> compression, zswap and zram, which are both in the swap path.
>>
>> 1) Both zswap and zram are limited in the amount of memory that they
>> can compress/store:
>> -zswap is limited both in the amount of pre-compressed pages, by the
>> total amount of swap configured in the system, and post-compressed
>> pages, by its max_pool_percentage parameter.  These limitations aren't
>> necessarily a bad thing, just requirements for the user (or distro
>> setup tool, etc) to correctly configure them.  And for optimal
>> operation, they need to coordinate; for example, with the default
>> post-compressed 20% of memory zswap's configured to use, the amount of
>> swap in the system must be at least 40% of system memory (if/when
>> zswap is changed to use zsmalloc that number would need to increase).
>> The point being, there is a clear possibility of misconfiguration, or
>> even a simple lack of enough disk space for actual swap, that could
>> artificially reduce the amount of total memory zswap is able to
>> compress.  Additionally, most of that real disk swap is wasted space -
>> all the pages stored compressed in zswap aren't actually written on
>> the disk.
>> -zram is limited only by its pre-compressed size, and of course the
>> amount of actual system memory it can use for compressed storage.  If
>> using without dm-cache, this could allow essentially unlimited
>> compression until no more compressed pages can be stored; however that
>> requires the zram device to be configured as larger than the actual
>> system memory.  If using with dm-cache, it may not be obvious what the
>> optimal zram size is.
>>
>> Pre-swapcache compression would theoretically require no user
>> configuration, and the amount of compressed pages would be unlimited
>> (until there is no more room to store compressed pages).
>
> Yes, these are limitations of the current designs.
>
>>
>> 2) Both zswap and zram (with dm-cache) write uncompressed pages to disk:
>> -zswap rejects any pages being sent to swap that don't compress well
>> enough, and they're passed on to the swap disk in uncompressed form.
>> Also, once zswap is full it starts uncompressing its old compressed
>> pages and writing them back to the swap disk.
>> -zram, with dm-cache, can pass pages on to the swap disk, but IIUC
>> those pages must be uncompressed first, and then written in compressed
>> form on disk.  (Please correct me here if that is wrong).
>
> Yes, again.
>
>>
>> A compressed cache that comes before the swap cache would be able to
>> push pages from its compressed storage to the swap disk, that contain
>> multiple compressed pages (and/or parts of compressed pages, if
>> overlapping page boundries).  I think that would be able to,
>> theoretically at least, improve overall read/write times from a
>> pre-compressed perspective, simply because less actual data would be
>> transferred.  Also, less actual swap disk space would be
>> used/required, which on systems with a very large amount of system
>> memory may be beneficial.
>
> In theory that could be good.
>
> However, there are a lot of missing details about how this could
> actually be done.  Of the top of my head, the reason we choose hook
> into the swap path is because it does all the work in both the page
> selection, being reclaimed from the end of the inactive anon LRU, and
> all the work of unmapping the page from the page table and replacing
> it with a swap entry.  In order to do the unmapping, the page must
> already be in the swap cache.
>
> So I guess I'm not quite sure how you would do this. What did you have
> in mind?

Well my general idea was to modify shrink_page_list() so that instead
of calling add_to_swap() and then pageout(), anonymous pages would be
added to a compressed cache.  I haven't worked out all the specific
details, but I am initially thinking that the compressed cache could
simply repurpose incoming pages to use as the compressed cache storage
(using its own page mapping, similar to swap page mapping), and then
add_to_swap() the storage pages when the compressed cache gets to a
certain size.  Pages that don't compress well could just bypass the
compressed cache, and get sent the current route directly to
add_to_swap().


>
> Seth
>
>>
>>
>> Additionally, a couple other random possible benefits:
>> -like zswap but unlike zram, a pre-swapcache compressed cache would be
>> able to select which pages to store compressed, either based on poor
>> compression results or some other criteria - possibly userspace could
>> madvise that certain pages were or weren't likely compressible.
>> -while zram and zswap are only able to compress and store pages that
>> are passed to them by zswapd or direct reclaim, a pre-swap compressed
>> cache wouldn't necessarily have to wait until the low watermark is
>> reached.
>>
>> Any feedback would be greatly appreciated!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
