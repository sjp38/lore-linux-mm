Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDF346B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:51:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so477658889pge.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:51:34 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t186si13537893pgd.213.2017.01.31.22.51.33
        for <linux-mm@kvack.org>;
        Tue, 31 Jan 2017 22:51:34 -0800 (PST)
Date: Wed, 1 Feb 2017 15:51:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170201065131.GB10342@bbox>
References: <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
 <20170123053056.GB2327@jagdpanzerIV.localdomain>
 <20170123054034.GA12327@bbox>
 <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
 <20170125052614.GB18289@bbox>
 <CALZtONBRK10XwG7GkjSwsyGWw=X6LSjtNtPjJeZtMp671E5MOQ@mail.gmail.com>
 <20170131001025.GD7942@bbox>
 <CALZtONDQ5yQKV6-jpJGBg7gakV8-7XXmmAATSQq346Tby4WLsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDQ5yQKV6-jpJGBg7gakV8-7XXmmAATSQq346Tby4WLsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Chulmin Kim <cmlaika.kim@samsung.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Dan,

On Tue, Jan 31, 2017 at 08:09:53AM -0500, Dan Streetman wrote:
> On Mon, Jan 30, 2017 at 7:10 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi Dan,
> >
> > On Thu, Jan 26, 2017 at 12:04:03PM -0500, Dan Streetman wrote:
> >> On Wed, Jan 25, 2017 at 12:26 AM, Minchan Kim <minchan@kernel.org> wrote:
> >> > On Tue, Jan 24, 2017 at 11:06:51PM -0500, Chulmin Kim wrote:
> >> >> On 01/23/2017 12:40 AM, Minchan Kim wrote:
> >> >> >On Mon, Jan 23, 2017 at 02:30:56PM +0900, Sergey Senozhatsky wrote:
> >> >> >>On (01/23/17 14:22), Minchan Kim wrote:
> >> >> >>[..]
> >> >> >>>>Anyway, I will let you know the situation when it gets more clear.
> >> >> >>>
> >> >> >>>Yeb, Thanks.
> >> >> >>>
> >> >> >>>Perhaps, did you tried flush page before the writing?
> >> >> >>>I think arm64 have no d-cache alising problem but worth to try it.
> >> >> >>>Who knows :)
> >> >> >>
> >> >> >>I thought that flush_dcache_page() is only for cases when we write
> >> >> >>to page (store that makes pages dirty), isn't it?
> >> >> >
> >> >> >I think we need both because to see recent stores done by the user.
> >> >> >I'm not sure it should be done by block device driver rather than
> >> >> >page cache. Anyway, brd added it so worth to try it, I thought. :)
> >> >> >
> >> >>
> >> >> Thanks for the suggestion!
> >> >> It might be helpful
> >> >> though proving it is not easy as the problem appears rarely.
> >> >>
> >> >> Have you thought about
> >> >> zram swap or zswap dealing with self modifying code pages (ex. JIT)?
> >> >> (arm64 may have i-cache aliasing problem)
> >> >
> >> > It can happen, I think, although I don't know how arm64 handles it.
> >> >
> >> >>
> >> >> If it is problematic,
> >> >> especiallly zswap (without flush_dcache_page in zswap_frontswap_load()) may
> >> >> provide the corrupted data
> >> >> and even swap out (compressing) may see the corrupted data sooner or later,
> >> >> i guess.
> >> >
> >> > try_to_unmap_one calls flush_cache_page which I hope to handle swap-out side
> >> > but for swap-in, I think zswap need flushing logic because it's first
> >> > touch of the user buffer so it's his resposibility.
> >>
> >> Hmm, I don't think zswap needs to, because all the cache aliases were
> >> flushed when the page was written out.  After that, any access to the
> >> page will cause a fault, and the fault will cause the page to be read
> >> back in (via zswap).  I don't see how the page could be cached at any
> >> time between the swap write-out and swap read-in, so there should be
> >> no need to flush any caches when it's read back in; am I missing
> >> something?
> >
> > Documentation/cachetlb.txt says
> >
> >   void flush_dcache_page(struct page *page)
> >
> >         Any time the kernel writes to a page cache page, _OR_
> >         the kernel is about to read from a page cache page and
> >         user space shared/writable mappings of this page potentially
> >         exist, this routine is called.
> >
> > For swap-in side, I don't see any logic to prevent the aliasing
> > problem. Let's consider other examples like cow_user_page->
> > copy_user_highpage. For architectures which can make aliasing,
> > it has arch specific functions which has flushing function.
> 
> COW works with a page that has a physical backing.  swap-in does not.
> COW pages can be accessed normally; swapped out pages cannot.
> 
> >
> > IOW, if a kernel makes store operation to the page which will
> > be mapped to user space address, kernel should call flush function.
> > Otherwise, user space will miss recent update from kernel side.
> 
> as I said before, when it's swapped out caches are flushed, and the
> page mapping invalidated, so it will cause a fault on any access, and
> thus cause swap to re-load the page from disk (or zswap).  So how
> would a cache of the page be created after swap-out, but before
> swap-in?  It's not possible for user space to have any caches to the
> page, unless (as I said) I'm missing something?

I'm saying H/W cache, not S/W cache.
Please think over VIVT architecture. The virtual address kernel is using
for store is different with the one user will use so it's cache-aliasing
candidate.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
