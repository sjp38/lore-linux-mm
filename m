Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AC91C6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 05:33:46 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so6246213pad.33
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 02:33:46 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id ar20so10430626iec.18
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 02:33:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1ffZVEkbifGfV6zZTTOcityHwYuQotJHBG4L9CJF7LXcA@mail.gmail.com>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
	<52118042.30101@oracle.com>
	<20130819054742.GA28062@bbox>
	<CAL1ERfN3AUYwWTctGBjVcgb-mwAmc15-FayLz48P1d0GzogncA@mail.gmail.com>
	<20130821074939.GE3022@bbox>
	<CAL1ERfP70oz=tbVEAfDhgNzgLsvnpbWeOCPOMBpmKTUn0v_Lfg@mail.gmail.com>
	<CAA_GA1ffZVEkbifGfV6zZTTOcityHwYuQotJHBG4L9CJF7LXcA@mail.gmail.com>
Date: Wed, 25 Sep 2013 17:33:43 +0800
Message-ID: <CAL1ERfOqoo+tPNYQn+e=pqP761gk+bAd7AyeXfoxogfNy0N6Lg@mail.gmail.com>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Sep 25, 2013 at 4:31 PM, Bob Liu <lliubbo@gmail.com> wrote:
> On Wed, Sep 25, 2013 at 4:09 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>> I think I find a new issue, for integrity of this mail thread, I reply
>> to this mail.
>>
>> It is a concurrence issue either, when duplicate store and reclaim
>> concurrentlly.
>>
>> zswap entry x with offset A is already stored in zswap backend.
>> Consider the following scenario:
>>
>> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
>>
>> thread 1: store new page with the same offset A, alloc a new zswap entry y.
>>   store finished. shrink_page_list() call __remove_mapping(), and now
>> it is not in swap_cache
>>
>
> But I don't think swap layer will call zswap with the same offset A.

1. store page of offset A in zswap
2. some time later, pagefault occur, load page data from zswap.
  But notice that zswap entry x is still in zswap because it is not
frontswap_tmem_exclusive_gets_enabled.
 this page is with PageSwapCache(page) and page_private(page) = entry.val
3. change this page data, and it become dirty
4. some time later again, swap this page on the same offset A.

so, a duplicate store happens.

what I can think is that use flags and CAS to protect store and reclaim on
the same offset  happens concurrentlly.

>> thread 0: zswap_get_swap_cache_page called. old page data is added to swap_cache
>>
>> Now, swap cache has old data rather than new data for offset A.
>> error will happen If do_swap_page() get page from swap_cache.
>>
>
> --
> Regards,
> --Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
