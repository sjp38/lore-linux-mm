Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 59F566B0044
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:05:33 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id z12so1054223wgg.16
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:05:32 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id ch6si8308313wjb.106.2014.09.12.10.05.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 10:05:31 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id x12so1007546wgg.2
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:05:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140912054640.GB2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org> <20140912054640.GB2160@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 12 Sep 2014 13:05:11 -0400
Message-ID: <CALZtONAzfUaXpxPc83KA6edB21uptWWGZkWZZa5DTFi=CMpgXA@mail.gmail.com>
Subject: Re: [PATCH 00/10] implement zsmalloc shrinking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Sep 12, 2014 at 1:46 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Thu, Sep 11, 2014 at 04:53:51PM -0400, Dan Streetman wrote:
>> Now that zswap can use zsmalloc as a storage pool via zpool, it will
>> try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
>> limit.  These patches implement zsmalloc shrinking.  The way the pool is
>> shrunk is by finding a zspage and reclaiming it, by evicting each of its
>> objects that is in use.
>>
>> Without these patches zswap, and any other future user of zpool/zsmalloc
>> that attempts to shrink the zpool/zs_pool, will only get errors and will
>> be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
>> can keep the most recent compressed pages in memory.
>>
>> Note that the design of zsmalloc makes it impossible to actually find the
>> LRU zspage, so each class and fullness group is searched in a round-robin
>> method to find the next zspage to reclaim.  Each fullness group orders its
>> zspages in LRU order, so the oldest zspage is used for each fullness group.
>>
>
> 1. Pz, Cc Mel who was strong against zswap with zsmalloc.
> 2. I don't think LRU stuff should be in allocator layer. Exp, it's really
>    hard to work well in zsmalloc design.

I didn't add any LRU - the existing fullness group LRU ordering is
already there.  And yes, the zsmalloc design prevents any real LRU
ordering, beyond per-fullness-group LRU ordering.

> 3. If you want to add another writeback, make zswap writeback sane first.
>    current implemenation(zswap store -> zbud reclaim -> zswap writeback,
>    even) is really ugly.

why what's wrong with that?  how else can zbud/zsmalloc evict stored objects?

> 4. Don't make zsmalloc complicated without any data(benefit, regression)
>    I will never ack if you don't give any number and real usecase.

ok, i'll run performance tests then, but let me know if you see any
technical problems with any of the patches before then.

thanks!

>
>> ---
>>
>> This patch set applies to linux-next.
>>
>> Dan Streetman (10):
>>   zsmalloc: fix init_zspage free obj linking
>>   zsmalloc: add fullness group list for ZS_FULL zspages
>>   zsmalloc: always update lru ordering of each zspage
>>   zsmalloc: move zspage obj freeing to separate function
>>   zsmalloc: add atomic index to find zspage to reclaim
>>   zsmalloc: add zs_ops to zs_pool
>>   zsmalloc: add obj_handle_is_free()
>>   zsmalloc: add reclaim_zspage()
>>   zsmalloc: add zs_shrink()
>>   zsmalloc: implement zs_zpool_shrink() with zs_shrink()
>>
>>  drivers/block/zram/zram_drv.c |   2 +-
>>  include/linux/zsmalloc.h      |   7 +-
>>  mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
>>  3 files changed, 290 insertions(+), 33 deletions(-)
>>
>> --
>> 1.8.3.1
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
