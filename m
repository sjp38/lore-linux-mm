Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C97E56B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 20:19:53 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so39872583pdb.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 17:19:53 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gt2si763729pbb.115.2015.07.07.17.19.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 17:19:52 -0700 (PDT)
Message-ID: <559C6CA6.1050809@lge.com>
Date: Wed, 08 Jul 2015 09:19:50 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv3 0/5] enable migration of driver pages
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>	<20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org>	<559C68B3.3010105@lge.com> <20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>
In-Reply-To: <20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>



2015-07-08 i??i ? 9:07i?? Andrew Morton i?'(e??) i?' e,?:
> On Wed, 08 Jul 2015 09:02:59 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
>
>>
>>
>> 2015-07-08 ______ 7:37___ Andrew Morton ___(___) ___ ___:
>>> On Tue,  7 Jul 2015 13:36:20 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
>>>
>>>> From: Gioh Kim <gurugio@hanmail.net>
>>>>
>>>> Hello,
>>>>
>>>> This series try to enable migration of non-LRU pages, such as driver's page.
>>>>
>>>> My ARM-based platform occured severe fragmentation problem after long-term
>>>> (several days) test. Sometimes even order-3 page allocation failed. It has
>>>> memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
>>>> and 20~30 memory is reserved for zram.
>>>>
>>>> I found that many pages of GPU driver and zram are non-movable pages. So I
>>>> reported Minchan Kim, the maintainer of zram, and he made the internal
>>>> compaction logic of zram. And I made the internal compaction of GPU driver.
>>>>
>>>> They reduced some fragmentation but they are not enough effective.
>>>> They are activated by its own interface, /sys, so they are not cooperative
>>>> with kernel compaction. If there is too much fragmentation and kernel starts
>>>> to compaction, zram and GPU driver cannot work with the kernel compaction.
>>>>
>>>> ...
>>>>
>>>> This patch set is tested:
>>>> - turn on Ubuntu 14.04 with 1G memory on qemu.
>>>> - do kernel building
>>>> - after several seconds check more than 512MB is used with free command
>>>> - command "balloon 512" in qemu monitor
>>>> - check hundreds MB of pages are migrated
>>>
>>> OK, but what happens if the balloon driver is not used to force
>>> compaction?  Does your test machine successfully compact pages on
>>> demand, so those order-3 allocations now succeed?
>>
>> If any driver that has many pages like the balloon driver is forced to compact,
>> the system can get free high-order pages.
>>
>> I have to show how this patch work with a driver existing in the kernel source,
>> for kernel developers' undestanding. So I selected the balloon driver
>> because it has already compaction and working with kernel compaction.
>> I can show how driver pages is compacted with lru-pages together.
>>
>> Actually balloon driver is not best example to show how this patch compacts pages.
>> The balloon driver compaction is decreasing page consumtion, for instance 1024MB -> 512MB.
>> I think it is not compaction precisely. It frees pages.
>> Of course there will be many high-order pages after 512MB is freed.
>
> Can the various in-kernel GPU drivers benefit from this?  If so, wiring
> up one or more of those would be helpful?

I'm sure that other in-kernel GPU drivers can have benefit.
It must be helpful.

If I was familiar with other in-kernel GPU drivers code, I tried to patch them.
It's too bad.

Minchan Kim said he had a plan to apply this patch into zram compaction.
Many embedded machines use several hundreds MB for zram.
The zram can also have benefit with this patch as much as GPU drivers.

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
