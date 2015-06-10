Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72C7C6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 21:08:17 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so23472775pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 18:08:17 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id bh8si11144039pdb.2.2015.06.09.18.08.15
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 18:08:16 -0700 (PDT)
Message-ID: <55778DFD.7070704@lge.com>
Date: Wed, 10 Jun 2015 10:08:13 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] enable migration of non-LRU pages
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com> <20150610000850.GC13376@bgram>
In-Reply-To: <20150610000850.GC13376@bgram>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com



2015-06-10 i??i ? 9:08i?? Minchan Kim i?'(e??) i?' e,?:
> Hello Gioh,
>
> On Tue, Jun 02, 2015 at 04:27:40PM +0900, Gioh Kim wrote:
>> Hello,
>>
>> This series try to enable migration of non-LRU pages, such as driver's page.
>>
>> My ARM-based platform occured severe fragmentation problem after long-term
>> (several days) test. Sometimes even order-3 page allocation failed. It has
>> memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
>> and 20~30 memory is reserved for zram.
>>
>> I found that many pages of GPU driver and zram are non-movable pages. So I
>> reported Minchan Kim, the maintainer of zram, and he made the internal
>> compaction logic of zram. And I made the internal compaction of GPU driver.
>>
>> They reduced some fragmentation but they are not enough effective.
>> They are activated by its own interface, /sys, so they are not cooperative
>> with kernel compaction. If there is too much fragmentation and kernel starts
>> to compaction, zram and GPU driver cannot work with the kernel compaction.
>>
>> The first this patch adds a generic isolate/migrate/putback callbacks for page
>> address-space. The zram and GPU, and any other modules can register
>> its own migration method. The kernel compaction can call the registered
>> migration when it works. Therefore all page in the system can be migrated
>> at once.
>>
>> The 2nd the generic migration callbacks are applied into balloon driver.
>> My gpu driver code is not open so I apply generic migration into balloon
>> to show how it works. I've tested it with qemu enabled by kvm like followings:
>> - turn on Ubuntu 14.04 with 1G memory on qemu.
>> - do kernel building
>> - after several seconds check more than 512MB is used with free command
>> - command "balloon 512" in qemu monitor
>> - check hundreds MB of pages are migrated
>>
>> Next kernel compaction code can call generic migration callbacks instead of
>> balloon driver interface.
>> Finally calling migration of balloon driver is removed.
>
> I didn't hava a time to review but it surely will help using zram with
> CMA as well as fragmentation of the system memory via making zram objects
> movable.

I know you are busy. I hope you make time for review.

>
> If it lands on mainline, I will work for zram object migration.
>
> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
