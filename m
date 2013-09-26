Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B1D566B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 22:06:42 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so458069pbc.17
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:06:42 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id tp5so612859ieb.0
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:06:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1eBS642zSsAd8W=n6oAD7hpKumXTneoSSMqWZxyr4QWng@mail.gmail.com>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
	<52118042.30101@oracle.com>
	<20130819054742.GA28062@bbox>
	<CAL1ERfN3AUYwWTctGBjVcgb-mwAmc15-FayLz48P1d0GzogncA@mail.gmail.com>
	<20130821074939.GE3022@bbox>
	<CAL1ERfP70oz=tbVEAfDhgNzgLsvnpbWeOCPOMBpmKTUn0v_Lfg@mail.gmail.com>
	<CAA_GA1ffZVEkbifGfV6zZTTOcityHwYuQotJHBG4L9CJF7LXcA@mail.gmail.com>
	<CAL1ERfOqoo+tPNYQn+e=pqP761gk+bAd7AyeXfoxogfNy0N6Lg@mail.gmail.com>
	<CAA_GA1eBS642zSsAd8W=n6oAD7hpKumXTneoSSMqWZxyr4QWng@mail.gmail.com>
Date: Thu, 26 Sep 2013 10:06:39 +0800
Message-ID: <CAL1ERfOkpH_T6-3tXVrh6k5rmDsMT-Evt5Gj3--ZR--rJHe4ig@mail.gmail.com>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Sep 25, 2013 at 6:02 PM, Bob Liu <lliubbo@gmail.com> wrote:
> On Wed, Sep 25, 2013 at 5:33 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>> On Wed, Sep 25, 2013 at 4:31 PM, Bob Liu <lliubbo@gmail.com> wrote:
>>> On Wed, Sep 25, 2013 at 4:09 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>>>> I think I find a new issue, for integrity of this mail thread, I reply
>>>> to this mail.
>>>>
>>>> It is a concurrence issue either, when duplicate store and reclaim
>>>> concurrentlly.
>>>>
>>>> zswap entry x with offset A is already stored in zswap backend.
>>>> Consider the following scenario:
>>>>
>>>> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
>>>>
>>>> thread 1: store new page with the same offset A, alloc a new zswap entry y.
>>>>   store finished. shrink_page_list() call __remove_mapping(), and now
>>>> it is not in swap_cache
>>>>
>>>
>>> But I don't think swap layer will call zswap with the same offset A.
>>
>> 1. store page of offset A in zswap
>> 2. some time later, pagefault occur, load page data from zswap.
>>   But notice that zswap entry x is still in zswap because it is not
>
> Sorry I didn't notice that zswap_frontswap_load() doesn't call rb_erase().
>
>> frontswap_tmem_exclusive_gets_enabled.
>>  this page is with PageSwapCache(page) and page_private(page) = entry.val
>> 3. change this page data, and it become dirty
>> 4. some time later again, swap this page on the same offset A.
>>
>> so, a duplicate store happens.
>>
>
> Then I think we should erase the entry from rbtree in zswap_frontswap_load().
> After the page is decompressed and loaded from zswap, still storing
> the compressed data in zswap is meanless.

Of cause, erasing the entry after load() can resolve this.
However, this problem is not simple and interesting.

If we drop the entry after load(), we should SetPageDirty, it will
generate more swap
even if we don't change this page data.
I think that is why frontswap has two load mode: default(used now) and
exclusive_gets.

I don't have test data, but I think which mode is better is decided by
corresponding workload.
It's better to realize these two modes, I will try it.

> --
> Regards,
> --Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
