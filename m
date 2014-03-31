Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id BC4026B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:21:01 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id w62so4999420wes.28
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:21:01 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id nd8si7746679wic.41.2014.03.31.08.20.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 08:21:00 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id u56so4823046wes.23
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:20:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140331045626.GA6281@bbox>
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com>
 <20140331045626.GA6281@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 31 Mar 2014 11:20:39 -0400
Message-ID: <CALZtONA9DTEJ0JH2hLC9-UOppzcdTxumTHXkFei12CvYS5wHrg@mail.gmail.com>
Subject: Re: Adding compression before/above swapcache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Mar 31, 2014 at 12:56 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hello Dan,
>
> On Wed, Mar 26, 2014 at 04:28:27PM -0400, Dan Streetman wrote:
>> compress.  Additionally, most of that real disk swap is wasted space -
>> all the pages stored compressed in zswap aren't actually written on
>> the disk.
>
> It's same with normal swap. If there isn't memory pressure, it's wasted
> space, too.

My point here is that with normal swap, all the swap might potentially
get used.  With any frontswap backend (like zswap), for any pages that
zswap stores, the corresponding page blocks on real disk will never be
used.

For example consider 10G of RAM and 10G of swap, with zswap at default
20% of RAM.

With zswap off, that 10G of swap will gradually get used up completely
until there is a total of 20G of used memory (approximately of course,
OOM killer will get invoked sometime before total memory exhaustion).

With zswap on, the 2G of compressed page storage in zswap will
gradually get filled up with none of the 10G on disk getting used
(except some uncompressible pages), and once zswap's storage is full
pages will get uncompressed and written to disk until there is
(appoximately) 2G of compressed pages in RAM, 8G of other used memory
in RAM, and only 6G of pages actually written to disk.  That's a total
of 8G + 6G + 4G (with zswap at 2:1 compression) = 18G.  So with the
same amount of real swap on disk, using zswap (or any frontswap
backend) actually reduces the amount of usable swap space.

(As an aside, a frontswap backend that uses transient memory and not
system memory won't actually reduce the amount of usable swap space,
but it also doesn't increase the amount of usable swap space - it just
trades putting pages onto transient memory instead of the real swap
disk).

>> -zram is limited only by its pre-compressed size, and of course the
>> amount of actual system memory it can use for compressed storage.  If
>> using without dm-cache, this could allow essentially unlimited
>
> It's because no requirement until now. If someone ask it or report
> the problem, we could support it easily.

How would you support an unlimited size block device?  By dynamically
changing its size as needed?

>> Pre-swapcache compression would theoretically require no user
>> configuration, and the amount of compressed pages would be unlimited
>> (until there is no more room to store compressed pages).
>
> Could you elaborate it more?
> You mean pre-swapcache doesn't need real storage(mkswap + swapn)?

it would store compressed pages before they are sent to swap.  Yes, it
would be able to do that completely independent of swap, so no
mkswap/swapn would be needed.

I think a simplification of the current process is:

active LRU
    v
inactive LRU
    v
swapcache
    v
pageout
    v
frontswap  -> zswap
    v
swap disk

With no disk swap, everything from swapcache down is out of the
picture (zram of course takes the place of "swap disk").

With a pre-swapcache compressed cache, it would look like

active LRU
    v
inactive LRU
    v
compressed cache
    v
swap cache
    v
pageout
    v
frontswap
    v
swap disk

With no actual swap disk, the picture is just

active LRU
    v
inactive LRU
    v
compressed cache


>> 2) Both zswap and zram (with dm-cache) write uncompressed pages to disk:
>> -zswap rejects any pages being sent to swap that don't compress well
>> enough, and they're passed on to the swap disk in uncompressed form.
>> Also, once zswap is full it starts uncompressing its old compressed
>> pages and writing them back to the swap disk.
>> -zram, with dm-cache, can pass pages on to the swap disk, but IIUC
>> those pages must be uncompressed first, and then written in compressed
>> form on disk.  (Please correct me here if that is wrong).
>
> I didn't look that code but I guess if dm-cache decides moving the page
> from zram device to real storage, it would decompress a page from zram
> and write it to storage without compressing. So it's not a compressed
> form.

I also haven't looked at if/how it would be possible, but it seems
like it would be very difficult in the context of dm-cache - I think
zram would have to take in uncompressed pages, but then somehow pass
compressed pages back to dm-cache for writing to disk.

Alternately (just throwing out thoughts here) maybe zram could
internally get configured with a real block device (disk or partition)
and write compressed pages to that device itself.  That would kind of
be duplicating most of the swap subsystem though.  Or maybe zram could
hook back into the top of the swap subsystem and re-write compressed
pages through swap but somehow ensure those compressed pages go to a
real swap disk instead of back to zram - that seems awfully
complicated as well.

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
> I agree part of your claim but couldn't.
> If we write a page which includes several compressed pages, it surely
> enhance write bandwidth but we should give extra pages for *reading*
> a page. You might argue swap already have done it via page-cluster.
> But the difference is that we could control it by knob so we could
> reduce window size if swap readahead hit ratio isn't good.

Well no compressed page would ever span more than 2 storage pages, and
I think the majority of compressed pages would be located only on a
single storage page.  So in most cases only 1 page would need to be
read from disk, and in the worst case only 2 pages would need to be
read back.

But, also consider that if a sequence of pages need to be read back
from disk, and they're stored together, then the additional free page
requirement would be much less than above.  I think there would be a
lot of room for optimization of storing used-together pages closely in
the compressed storage.

Additionally, this particular issue is only an argument about whether
reading/writing compressed pages is better or worse than
reading/writing uncompressed pages, which any compression method would
face if reading/writing compressed pages to disk.  And any compression
method that is able to write compressed pages to disk would also be
able to uncompress pages before writing to disk.  So there could be a
parameter the chooses to write compressed or uncompressed pages to
disk.

> With your proposal, we couldn't control it so it would be likely to
> fail swap-read than old if memory pressure is severe because we
> might need many pages to decompress just a page. For prevent,
> we need large buffer to decompress pages and we should limit the
> number of pages which put together a page, which can make system
> more predictable but it needs serialization of buffer so might hurt
> performance, too.

The question is would the ability to free pages by writing pages out
more quickly, and not needing to uncompress pages, overcome the
additional need for free pages during swap-read.  For example in zswap
or zram, when memory pressure is severe and you need free pages to
read into, free pages are required to decompress into before they're
written to disk.  Where do those pages come from?  You can't empty
your compressed storage without free pages to uncompress to before
writing them to disk.  A failure to find a free page somewhere outside
of the compressed storage would fail the swap-out which would then
fail the swap-in, unless there were dedicated pages just for
decompression and swap-out.

If compressed pages are written to swap, the compressed storage pages
can go directly to the swap disk with no free pages required for
swap-out.

So reading/writing compressed vs. uncompressed pages is simply moving
the failure case between swap-out and swap-in.  I think it may be
better to be able to swap-out pages with no extra free pages required,
but as I said above - a parameter could allow selecting whether
compressed or uncompressed pages are written to disk.

>> Additionally, a couple other random possible benefits:
>> -like zswap but unlike zram, a pre-swapcache compressed cache would be
>> able to select which pages to store compressed, either based on poor
>> compression results or some other criteria - possibly userspace could
>> madvise that certain pages were or weren't likely compressible.
>
> In your proposal, If it turns out poor compression after doing comp work,
> it would go to swap. It's same with zswap.

yep, as i said like zswap but unlike zram.

> Another suggestion on madvise is more general and I believe it could
> help zram/zswap as well as your proposal.
>
> It's already known problem and I suggested using mlock.
> If mlock is really big overhead for that, we might introduce another
> hint which just mark vma->vm_flags to *VMA_NOT_GOOD_COMPRESS*.
> In that case, mm layer could skip zswap and it might work with zram
> if there is support like BDI_CAP_SWAP_BACKED_INCOMPRAM.

yes a madvise or other uncompressible flag would be usable by zswap or
zram too (although as you mention it would be somewhat more work for
zram to get the information).  I was actually thinking more about how
code that's pre-swap would be able to skip uncompressible pages, maybe
temporarily.  Since zram and zswap are part of the swap path they have
no choice - the page is being swapped, so either store it or pass it
to disk.  What if under extreme memory pressure, when shrinking the
inactive LRU only compressible pages are compressed and remove, and
uncompressible pages are skipped?  That would invalidate the whole
point of LRU I know, but it would also be able to free pages more
quickly than if some were sent to physical swap disk.  I'm just
pointing out that the choice is there, it might be beneficial, or
maybe not.

>
>> -while zram and zswap are only able to compress and store pages that
>> are passed to them by zswapd or direct reclaim, a pre-swap compressed
>> cache wouldn't necessarily have to wait until the low watermark is
>> reached.
>
> I couldn't understand the benefit.
> Why should we compress memory before system is no memory pressure?

Well memory pressure is a relative term, isn't it?  The existing
watermarks make sense when swap is, relatively speaking, very
expensive to do - it would be crazy to start swapping too early,
because it takes so long to write to and read from disk.  However with
page compression, especially if (when?) hardware compressors become
more common, the expense of compressing/decompressing pages is much
less than disk IO, and it may make sense to have a second set of
watermarks to trigger page compression earlier; for example,
compression watermarks that only compress pages but don't swap; and
the existing watermarks that when reached start swapping the
compressed page storage to disk.

>> Any feedback would be greatly appreciated!
>
> Having said that, I'd like to have such feature(ie, copmressed-form writeout)
> for zram because zram supports zram-blk as well as zram-swap so zram-blk
> case could be no problem for memory-pressure so it would be happy to
> allocate multiple pages to store data when *read* happens and decompress
> a page into multiple pages.

How would that work, do you mean zram and dm-cache would work together
to write compressed pages to disk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
