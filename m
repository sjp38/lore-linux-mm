Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5A43A6B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 03:26:36 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so748545pbc.23
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 00:26:36 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id x13so893190ief.3
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 00:26:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130926055802.GA20634@bbox>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
	<52118042.30101@oracle.com>
	<20130819054742.GA28062@bbox>
	<CAL1ERfN3AUYwWTctGBjVcgb-mwAmc15-FayLz48P1d0GzogncA@mail.gmail.com>
	<20130821074939.GE3022@bbox>
	<CAL1ERfP70oz=tbVEAfDhgNzgLsvnpbWeOCPOMBpmKTUn0v_Lfg@mail.gmail.com>
	<CAA_GA1ffZVEkbifGfV6zZTTOcityHwYuQotJHBG4L9CJF7LXcA@mail.gmail.com>
	<CAL1ERfOqoo+tPNYQn+e=pqP761gk+bAd7AyeXfoxogfNy0N6Lg@mail.gmail.com>
	<20130926055802.GA20634@bbox>
Date: Thu, 26 Sep 2013 15:26:33 +0800
Message-ID: <CAL1ERfN8PpSZxRmLiwm4i-XZWzRaPJ0A=Af76Dtopcf2xYnBtQ@mail.gmail.com>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bob Liu <lliubbo@gmail.com>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 26, 2013 at 1:58 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hello Weigie,
>
> On Wed, Sep 25, 2013 at 05:33:43PM +0800, Weijie Yang wrote:
>> On Wed, Sep 25, 2013 at 4:31 PM, Bob Liu <lliubbo@gmail.com> wrote:
>> > On Wed, Sep 25, 2013 at 4:09 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>> >> I think I find a new issue, for integrity of this mail thread, I reply
>> >> to this mail.
>> >>
>> >> It is a concurrence issue either, when duplicate store and reclaim
>> >> concurrentlly.
>> >>
>> >> zswap entry x with offset A is already stored in zswap backend.
>> >> Consider the following scenario:
>> >>
>> >> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
>> >>
>> >> thread 1: store new page with the same offset A, alloc a new zswap entry y.
>> >>   store finished. shrink_page_list() call __remove_mapping(), and now
>> >> it is not in swap_cache
>> >>
>> >
>> > But I don't think swap layer will call zswap with the same offset A.
>>
>> 1. store page of offset A in zswap
>> 2. some time later, pagefault occur, load page data from zswap.
>>   But notice that zswap entry x is still in zswap because it is not
>> frontswap_tmem_exclusive_gets_enabled.
>
> frontswap_tmem_exclusive_gets_enabled is just option to see tradeoff
> between CPU burining by frequent swapout and memory footprint by duplicate
> copy in swap cache and frontswap backend so it shouldn't affect the stability.

Thanks for explain this.
I don't mean to say this option affects the stability,  but that zswap
only realize
one option. Maybe it's better to realize both options for different workloads.

>>  this page is with PageSwapCache(page) and page_private(page) = entry.val
>> 3. change this page data, and it become dirty
>
> If non-shared swapin page become redirty, it should remove the page from
> swapcache. If shared swapin page become redirty, it should do CoW so it's a
> new page so that it doesn't live in swap cache. It means it should have new
> offset which is different with old's one for swap out.
>
> What's wrong with that?

It is really not a right scene for duplicate store. And I can not think out one.
If duplicate store is impossible, How about delete the handle code in zswap?
If it does exist, I think there is a potential issue as I described.

>> 4. some time later again, swap this page on the same offset A.
>>
>> so, a duplicate store happens.
>>
>> what I can think is that use flags and CAS to protect store and reclaim on
>> the same offset  happens concurrentlly.
>>
>> >> thread 0: zswap_get_swap_cache_page called. old page data is added to swap_cache
>> >>
>> >> Now, swap cache has old data rather than new data for offset A.
>> >> error will happen If do_swap_page() get page from swap_cache.
>> >>
>> >
>> > --
>> > Regards,
>> > --Bob
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
