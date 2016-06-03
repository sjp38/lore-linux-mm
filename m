Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7B26B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 07:57:08 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id lp2so117089295igb.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 04:57:08 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id f65si6468853itb.61.2016.06.03.04.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 04:57:07 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id f67so6944602ith.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 04:57:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160603095344.GZ2527@techsingularity.net>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
	<574D64A0.2070207@arm.com>
	<CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
	<60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
	<20160531131520.GI24936@arm.com>
	<CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
	<20160602135226.GX2527@techsingularity.net>
	<CAPv3WKd8Zdcv5nhr2euN7L4W5JYLex_Hmn+9AVd6reyD-Vw4kg@mail.gmail.com>
	<20160603095344.GZ2527@techsingularity.net>
Date: Fri, 3 Jun 2016 13:57:06 +0200
Message-ID: <CAPv3WKfrgNg00M4oE3VKLYimYqN6NO6ziR7LWYXQ1d_M-bo67A@mail.gmail.com>
Subject: Re: [BUG] Page allocation failures with newest kernels
From: Marcin Wojtas <mw@semihalf.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Will Deacon <will.deacon@arm.com>, Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, =?UTF-8?Q?Gregory_Cl=C3=A9ment?= <gregory.clement@free-electrons.com>

Hi Mel,


2016-06-03 11:53 GMT+02:00 Mel Gorman <mgorman@techsingularity.net>:
> On Thu, Jun 02, 2016 at 09:01:55PM +0200, Marcin Wojtas wrote:
>> >> From what I understood, now order-0 allocation keep no reserve at all.
>> >
>> > Watermarks should still be preserved. zone_watermark_ok is still there.
>> > What might change is the size of reserves for high-order atomic
>> > allocations only. Fragmentation shouldn't be a factor. I'm missing some
>> > major part of the picture.
>> >
>>
>> I CC'ed you in the last email, as I found out your authorship of
>> interesting patches - please see problem description
>> https://lkml.org/lkml/2016/5/30/1056
>>
>> Anyway when using v4.4.8 baseline, after reverting below patches:
>> 97a16fc - mm, page_alloc: only enforce watermarks for order-0 allocations
>> 0aaa29a - mm, page_alloc: reserve pageblocks for high-order atomic
>> allocations on demand
>> 974a786 - mm, page_alloc: remove MIGRATE_RESERVE
>> + adding early_page_nid_uninitialised() modification
>>
>
> The early_page check is wrong because of the check itself rather than
> the function so that was the bug there.

Regardless if it was reasonable to do this check here, behavior for
all archs other than x86 was changed silently because of 7e18adb4f80b
("mm: meminit:
initialise remaining struct pages in parallel with kswapd"), so I'd
consider it as a bug as well.

>
>> I stop receiving page alloc fail dumps like this one
>> http://pastebin.com/FhRW5DsF, also performance in my test looks very
>> similar. I'd like to understand this phenomenon and check if it's
>> possible to avoid such page-alloc-fail hickups in a nice way.
>> Afterwards, once the dumps finish, the kernel remain stable, but is
>> such behavior expected and intended?
>>
>
> Looking at the pastebin, the page allocation failure appears to be partially
> due to CMA. If the free_cma pages are substracted from the free pages then
> it's very close to the low watermark. I suspect kswapd was already active
> but it had not acted in time to prevent the first allocation. The impact
> of MIGRATE_RESERVE was to give a larger window for kswapd to do work in
> but it's a co-incidence. By relying on it for an order-0 allocation it
> would fragment that area which in your particular case may not matter but
> actually violates what MIGRATE_RESERVE was for.

Indeed it's very fragile problem and seems like basing on coincidents
- e.g. contrary to buildroot in ubuntu same test can't end up with
dumping fail information, so I suspect some timings are satisfied,
because e.g. more services run in background. Indeed free_cma is very
close to free pages overall, but usually (especially in older kernels
(v4.4.8: http://pastebin.com/FhRW5DsF) the gap is much bigger. This
may show that the root cause may have varied in time.

>
>> For the record: the newest kernel I was able to reproduce the dumps
>> was v4.6: http://pastebin.com/ekDdACn5. I've just checked v4.7-rc1,
>> which comprise a lot (mainly yours) changes in mm, and I'm wondering
>> if there may be a spot fix or rather a series of improvements. I'm
>> looking forward to your opinion and would be grateful for any advice.
>>
>
> I don't believe we want to reintroduce the reserve to cope with CMA. One
> option would be to widen the gap between low and min watermark by the
> size of the CMA region. The effect would be to wake kswapd earlier which
> matters considering the context of the failing allocation was
> GFP_ATOMIC.

Of course my intention is not reintroducing anything that's gone
forever, but just to find out way to overcome current issues. Do you
mean increasing CMA size? At the very beginning I played with CMA size
(even increased it from 16M to 96M), but it didn't help. Do you think
is there any other way to trigger kswapd earlier?

>
> The GFP_ATOMIC itself is interesting. If I'm reading this correctly,
> scsi_get_cmd_from_req() was called from scsi_prep() where it was passing
> in GFP_ATOMIC but in the page allocation failure, __GFP_ATOMIC is not
> set. It would be worth chasing down if the allocation site really was
> GFP_ATOMIC and if so, isolate what stripped that flag and see if it was
> a mistake.
>

Printing flags was introduced recently and I didn't check them (apart
of playing with GFP_NOWARN in various places) in older kernels. Thanks
for this observation, I'll try to track this down.

Best regards,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
