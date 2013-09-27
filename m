Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A8ACD6B0032
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 00:58:08 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so2091449pdj.17
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 21:58:08 -0700 (PDT)
Date: Fri, 27 Sep 2013 13:58:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
Message-ID: <20130927045842.GB22339@bbox>
References: <20130819054742.GA28062@bbox>
 <CAL1ERfN3AUYwWTctGBjVcgb-mwAmc15-FayLz48P1d0GzogncA@mail.gmail.com>
 <20130821074939.GE3022@bbox>
 <CAL1ERfP70oz=tbVEAfDhgNzgLsvnpbWeOCPOMBpmKTUn0v_Lfg@mail.gmail.com>
 <CAA_GA1ffZVEkbifGfV6zZTTOcityHwYuQotJHBG4L9CJF7LXcA@mail.gmail.com>
 <CAL1ERfOqoo+tPNYQn+e=pqP761gk+bAd7AyeXfoxogfNy0N6Lg@mail.gmail.com>
 <20130926055802.GA20634@bbox>
 <CAL1ERfN8PpSZxRmLiwm4i-XZWzRaPJ0A=Af76Dtopcf2xYnBtQ@mail.gmail.com>
 <20130926075725.GA22339@bbox>
 <CAL1ERfNh5ss2F6X8QuYxhZ7f2g6mcJvn6pJow2ecRk8dT13CGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1ERfNh5ss2F6X8QuYxhZ7f2g6mcJvn6pJow2ecRk8dT13CGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

Hello Weijie,

On Thu, Sep 26, 2013 at 04:48:03PM +0800, Weijie Yang wrote:
> On Thu, Sep 26, 2013 at 3:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Thu, Sep 26, 2013 at 03:26:33PM +0800, Weijie Yang wrote:
> >> On Thu, Sep 26, 2013 at 1:58 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > Hello Weigie,
> >> >
> >> > On Wed, Sep 25, 2013 at 05:33:43PM +0800, Weijie Yang wrote:
> >> >> On Wed, Sep 25, 2013 at 4:31 PM, Bob Liu <lliubbo@gmail.com> wrote:
> >> >> > On Wed, Sep 25, 2013 at 4:09 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> >> >> >> I think I find a new issue, for integrity of this mail thread, I reply
> >> >> >> to this mail.
> >> >> >>
> >> >> >> It is a concurrence issue either, when duplicate store and reclaim
> >> >> >> concurrentlly.
> >> >> >>
> >> >> >> zswap entry x with offset A is already stored in zswap backend.
> >> >> >> Consider the following scenario:
> >> >> >>
> >> >> >> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
> >> >> >>
> >> >> >> thread 1: store new page with the same offset A, alloc a new zswap entry y.
> >> >> >>   store finished. shrink_page_list() call __remove_mapping(), and now
> >> >> >> it is not in swap_cache
> >> >> >>
> >> >> >
> >> >> > But I don't think swap layer will call zswap with the same offset A.
> >> >>
> >> >> 1. store page of offset A in zswap
> >> >> 2. some time later, pagefault occur, load page data from zswap.
> >> >>   But notice that zswap entry x is still in zswap because it is not
> >> >> frontswap_tmem_exclusive_gets_enabled.
> >> >
> >> > frontswap_tmem_exclusive_gets_enabled is just option to see tradeoff
> >> > between CPU burining by frequent swapout and memory footprint by duplicate
> >> > copy in swap cache and frontswap backend so it shouldn't affect the stability.
> >>
> >> Thanks for explain this.
> >> I don't mean to say this option affects the stability,  but that zswap
> >> only realize
> >> one option. Maybe it's better to realize both options for different workloads.
> >
> > "zswap only relize one option"
> > What does it mena? Sorry. I couldn't parse your intention. :)
> > You mean zswap should do something special to support frontswap_tmem_exclusive_gets?
> 
> Yes. But I am not sure whether it is worth.
> 
> >>
> >> >>  this page is with PageSwapCache(page) and page_private(page) = entry.val
> >> >> 3. change this page data, and it become dirty
> >> >
> >> > If non-shared swapin page become redirty, it should remove the page from
> >> > swapcache. If shared swapin page become redirty, it should do CoW so it's a
> >> > new page so that it doesn't live in swap cache. It means it should have new
> >> > offset which is different with old's one for swap out.
> >> >
> >> > What's wrong with that?
> >>
> >> It is really not a right scene for duplicate store. And I can not think out one.
> >> If duplicate store is impossible, How about delete the handle code in zswap?
> >> If it does exist, I think there is a potential issue as I described.
> >
> > You mean "zswap_duplicate_entry"?
> > AFAIR, I already had a question to Seth when zswap was born but AFAIRC,
> > he said that he didn't know exact reason but he saw that case during
> > experiement so copy the code peice from zcache.
> >
> > Do you see the case, too?
> 
> Yes, I mean duplicate store.
> I check the /Documentation/vm/frontswap.txt, it mentions "duplicate stores",
> but I am still confused.

It seems that there are two Minchan in LKML.
Other Minchan, not me who have a horrible memory, already was first to
figure it out a few month ago.

https://lkml.org/lkml/2013/1/31/3

/me slaps self.
I'd like to look into that issue more but now I don't have a time.
Just FYI. ;-)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
