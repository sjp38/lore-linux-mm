Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id CFB9D6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 11:22:15 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id up14so807528obb.39
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 08:22:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130819054742.GA28062@bbox>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
	<52118042.30101@oracle.com>
	<20130819054742.GA28062@bbox>
Date: Tue, 20 Aug 2013 23:22:14 +0800
Message-ID: <CAL1ERfN+poSHZGMQR=4OFscW6QTdE_RhGXr-MwQf3f9kOn_-_g@mail.gmail.com>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com, linux-mm@kvack.org

2013/8/19 Minchan Kim <minchan@kernel.org>:
> On Mon, Aug 19, 2013 at 10:17:38AM +0800, Bob Liu wrote:
>> Hi Weijie,
>>
>> On 08/19/2013 12:14 AM, Weijie Yang wrote:
>> > I found a few bugs in zswap when I review Linux-3.11-rc5, and I have
>> > also some questions about it, described as following:
>> >
>> > BUG:
>> > 1. A race condition when reclaim a page
>> > when a handle alloced from zbud, zbud considers this handle is used
>> > validly by upper(zswap) and can be a candidate for reclaim.
>> > But zswap has to initialize it such as setting swapentry and addding
>> > it to rbtree. so there is a race condition, such as:
>> > thread 0: obtain handle x from zbud_alloc
>> > thread 1: zbud_reclaim_page is called
>> > thread 1: callback zswap_writeback_entry to reclaim handle x
>> > thread 1: get swpentry from handle x (it is random value now)
>> > thread 1: bad thing may happen
>> > thread 0: initialize handle x with swapentry
>
> Nice catch!
>
>>
>> Yes, this may happen potentially but in rare case.
>> Because we have a LRU list for page frames, after Thread 0 called
>> zbud_alloc the corresponding page will be add to the head of LRU
>> list,While zbud_reclaim_page(Thread 1 called) is started from the tail
>> of LRU list.
>>
>> > Of course, this situation almost never happen, it is a "theoretical
>> > race condition" issue.
>
> But it's doable and we should prevent that although you feel it's rare
> because system could go hang. When I look at the code, Why should zbud
> have LRU logic instead of zswap? If I missed some history, sorry about that.
> But at least to me, zbud is just allocator so it should have a role
> to handle alloc/free object and how client of the allocator uses objects
> depends on the upper layer so zbud should handle LRU. If so, we wouldn't
> encounter this problem, either.
>
>> >
>> > 2. Pollute swapcache data by add a pre-invalided swap page
>> > when a swap_entry is invalidated, it will be reused by other anon
>> > page. At the same time, zswap is reclaiming old page, pollute
>> > swapcache of new page as a result, because old page and new page use
>> > the same swap_entry, such as:
>> > thread 1: zswap reclaim entry x
>> > thread 0: zswap_frontswap_invalidate_page entry x
>> > thread 0: entry x reused by other anon page
>> > thread 1: add old data to swapcache of entry x
>>
>> I didn't get your idea here, why thread1 will add old data to entry x?
>>
>> > thread 0: swapcache of entry x is polluted
>> > Of course, this situation almost never happen, it is another
>> > "theoretical race condition" issue.
>
> Don't swapcache_prepare close the race?
>

Yes, I made a mistake, there is not a race here.
However, I find another bug here after my more careful review. It is
not only "theoretical", it will happen really. as:
thread 1: zswap reclaim entry x (get the refcount, but not call
zswap_get_swap_cache_page yet)
thread 0: zswap_frontswap_invalidate_page entry x (finished, entry x
and its zbud is not freed as its refcount != 0)
now, the swap_map[x] = 0
thread 1: zswap_get_swap_cache_page called, swapcache_prepare return
-ENOENT because entry x is not used any more
zswap_get_swap_cache_page return ZSWAP_SWAPCACHE_NOMEM
zswap_writeback_entry do nothing except put refcount
now, the memory of zswap_entry x leaks and its zpage become a zombie

Best Regards,
Weijie Yang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
