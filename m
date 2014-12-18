Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEAA6B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 20:50:23 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id nt9so525067obb.5
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 17:50:22 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id wq3si3376455obb.89.2014.12.17.17.50.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 17:50:21 -0800 (PST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so477346obc.4
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 17:50:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141217231930.GA13582@cerebellum.variantweb.net>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
	<20141217231930.GA13582@cerebellum.variantweb.net>
Date: Thu, 18 Dec 2014 09:50:20 +0800
Message-ID: <CADAEsF8AMf0U8JSf3Bhmm5xBf-XsQYMJijRXKZUYXYToAiW3oA@mail.gmail.com>
Subject: Re: [RFC 0/6] zsmalloc support compaction
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com

2014-12-18 7:19 GMT+08:00 Seth Jennings <sjennings@variantweb.net>:
> On Tue, Dec 02, 2014 at 11:49:41AM +0900, Minchan Kim wrote:
>> Recently, there was issue about zsmalloc fragmentation and
>> I got a report from Juno that new fork failed although there
>> are plenty of free pages in the system.
>> His investigation revealed zram is one of the culprit to make
>> heavy fragmentation so there was no more contiguous 16K page
>> for pgd to fork in the ARM.
>>
>> This patchset implement *basic* zsmalloc compaction support
>> and zram utilizes it so admin can do
>>       "echo 1 > /sys/block/zram0/compact"
>>
>> Actually, ideal is that mm migrate code is aware of zram pages and
>> migrate them out automatically without admin's manual opeartion
>> when system is out of contiguous page. Howver, we need more thinking
>> before adding more hooks to migrate.c. Even though we implement it,
>> we need manual trigger mode, too so I hope we could enhance
>> zram migration stuff based on this primitive functions in future.
>>
>> I just tested it on only x86 so need more testing on other arches.
>> Additionally, I should have a number for zsmalloc regression
>> caused by indirect layering. Unfortunately, I don't have any
>> ARM test machine on my desk. I will get it soon and test it.
>> Anyway, before further work, I'd like to hear opinion.
>>
>> Pathset is based on v3.18-rc6-mmotm-2014-11-26-15-45.
>
> Hey Minchan, sorry it has taken a while for me to look at this.
>
> I have prototyped this for zbud to and I see you face some of the same
> issues, some of them much worse for zsmalloc like large number of
> objects to move to reclaim a page (with zbud, the max is 1).
>
> I see you are using zsmalloc itself for allocating the handles.  Why not
> kmalloc()?  Then you wouldn't need to track the handle_class stuff and
> adjust the class sizes (just in the interest of changing only what is
> need to achieve the functionality).
>
> I used kmalloc() but that is not without issue as the handles can be
> allocated from many slabs and any slab that contains a handle can't be
> freed, basically resulting in the handles themselves needing to be
> compacted, which they can't be because the user handle is a pointer to
> them.
>
> One way to fix this, but it would be some amount of work, is to have the
> user (zswap/zbud) provide the space for the handle to zbud/zsmalloc.
> The zswap/zbud layer knows the size of the device (i.e. handle space)
> and could allocate a statically sized vmalloc area for holding handles
> so they don't get spread all over memory.  I haven't fully explored this
> idea yet.
>
> It is pretty limiting having the user trigger the compaction. Can we
> have a work item that periodically does some amount of compaction?
> Maybe also have something analogous to direct reclaim that, when
> zs_malloc fails to secure a new page, it will try to compact to get one?
> I understand this is a first step.  Maybe too much.

Yes, User do not know when to do the compaction.
Actually, zsmalloc's responsibility is to keep the fragmentation in a low level.
How about dynamically monitoring the fragmentation and do the compaction when
there are too much fragmentation.

I am working on another patch to collect statistics of zsmalloc
objects. Maybe that will
be helpful for this.

Thanks.

>
> Also worth pointing out that the fullness groups are very coarse.
> Combining the objects from a ZS_ALMOST_EMPTY zspage and ZS_ALMOST_FULL
> zspage, might not result in very tight packing.  In the worst case, the
> destination zspage would be slightly over 1/4 full (see
> fullness_threshold_frac)
>
> It also seems that you start with the smallest size classes first.
> Seems like if we start with the biggest first, we move fewer objects and
> reclaim more pages.
>
> It does add a lot of code :-/  Not sure if there is any way around that
> though if we want this functionality for zsmalloc.
>
> Seth
>
>>
>> Thanks.
>>
>> Minchan Kim (6):
>>   zsmalloc: expand size class to support sizeof(unsigned long)
>>   zsmalloc: add indrection layer to decouple handle from object
>>   zsmalloc: implement reverse mapping
>>   zsmalloc: encode alloced mark in handle object
>>   zsmalloc: support compaction
>>   zram: support compaction
>>
>>  drivers/block/zram/zram_drv.c |  24 ++
>>  drivers/block/zram/zram_drv.h |   1 +
>>  include/linux/zsmalloc.h      |   1 +
>>  mm/zsmalloc.c                 | 596 +++++++++++++++++++++++++++++++++++++-----
>>  4 files changed, 552 insertions(+), 70 deletions(-)
>>
>> --
>> 2.0.0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
