Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB756B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:10:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so477281693pfb.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 16:10:28 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a204si14167464pfa.101.2017.01.30.16.10.26
        for <linux-mm@kvack.org>;
        Mon, 30 Jan 2017 16:10:27 -0800 (PST)
Date: Tue, 31 Jan 2017 09:10:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170131001025.GD7942@bbox>
References: <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
 <20170123053056.GB2327@jagdpanzerIV.localdomain>
 <20170123054034.GA12327@bbox>
 <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
 <20170125052614.GB18289@bbox>
 <CALZtONBRK10XwG7GkjSwsyGWw=X6LSjtNtPjJeZtMp671E5MOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBRK10XwG7GkjSwsyGWw=X6LSjtNtPjJeZtMp671E5MOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Chulmin Kim <cmlaika.kim@samsung.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Dan,

On Thu, Jan 26, 2017 at 12:04:03PM -0500, Dan Streetman wrote:
> On Wed, Jan 25, 2017 at 12:26 AM, Minchan Kim <minchan@kernel.org> wrote:
> > On Tue, Jan 24, 2017 at 11:06:51PM -0500, Chulmin Kim wrote:
> >> On 01/23/2017 12:40 AM, Minchan Kim wrote:
> >> >On Mon, Jan 23, 2017 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
> >> >>On (01/23/17 14:22), Minchan Kim wrote:
> >> >>[..]
> >> >>>>Anyway, I will let you know the situation when it gets more clear.
> >> >>>
> >> >>>Yeb, Thanks.
> >> >>>
> >> >>>Perhaps, did you tried flush page before the writing?
> >> >>>I think arm64 have no d-cache alising problem but worth to try it.
> >> >>>Who knows :)
> >> >>
> >> >>I thought that flush_dcache_page() is only for cases when we write
> >> >>to page (store that makes pages dirty), isn't it?
> >> >
> >> >I think we need both because to see recent stores done by the user.
> >> >I'm not sure it should be done by block device driver rather than
> >> >page cache. Anyway, brd added it so worth to try it, I thought. :)
> >> >
> >>
> >> Thanks for the suggestion!
> >> It might be helpful
> >> though proving it is not easy as the problem appears rarely.
> >>
> >> Have you thought about
> >> zram swap or zswap dealing with self modifying code pages (ex. JIT)?
> >> (arm64 may have i-cache aliasing problem)
> >
> > It can happen, I think, although I don't know how arm64 handles it.
> >
> >>
> >> If it is problematic,
> >> especiallly zswap (without flush_dcache_page in zswap_frontswap_load()) may
> >> provide the corrupted data
> >> and even swap out (compressing) may see the corrupted data sooner or later,
> >> i guess.
> >
> > try_to_unmap_one calls flush_cache_page which I hope to handle swap-out side
> > but for swap-in, I think zswap need flushing logic because it's first
> > touch of the user buffer so it's his resposibility.
> 
> Hmm, I don't think zswap needs to, because all the cache aliases were
> flushed when the page was written out.  After that, any access to the
> page will cause a fault, and the fault will cause the page to be read
> back in (via zswap).  I don't see how the page could be cached at any
> time between the swap write-out and swap read-in, so there should be
> no need to flush any caches when it's read back in; am I missing
> something?

Documentation/cachetlb.txt says

  void flush_dcache_page(struct page *page)

        Any time the kernel writes to a page cache page, _OR_
        the kernel is about to read from a page cache page and
        user space shared/writable mappings of this page potentially
        exist, this routine is called.

For swap-in side, I don't see any logic to prevent the aliasing
problem. Let's consider other examples like cow_user_page->
copy_user_highpage. For architectures which can make aliasing,
it has arch specific functions which has flushing function.

IOW, if a kernel makes store operation to the page which will
be mapped to user space address, kernel should call flush function.
Otherwise, user space will miss recent update from kernel side.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
