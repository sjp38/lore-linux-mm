Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 127D66B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 15:01:57 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id jt9so34685071obc.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:01:57 -0700 (PDT)
Received: from mail-it0-x22c.google.com (mail-it0-x22c.google.com. [2607:f8b0:4001:c0b::22c])
        by mx.google.com with ESMTPS id a15si1106336oib.120.2016.06.02.12.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 12:01:55 -0700 (PDT)
Received: by mail-it0-x22c.google.com with SMTP id e62so134728839ita.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:01:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160602135226.GX2527@techsingularity.net>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
	<574D64A0.2070207@arm.com>
	<CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
	<60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
	<20160531131520.GI24936@arm.com>
	<CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
	<20160602135226.GX2527@techsingularity.net>
Date: Thu, 2 Jun 2016 21:01:55 +0200
Message-ID: <CAPv3WKd8Zdcv5nhr2euN7L4W5JYLex_Hmn+9AVd6reyD-Vw4kg@mail.gmail.com>
Subject: Re: [BUG] Page allocation failures with newest kernels
From: Marcin Wojtas <mw@semihalf.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Will Deacon <will.deacon@arm.com>, Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, =?UTF-8?Q?Gregory_Cl=C3=A9ment?= <gregory.clement@free-electrons.com>

Hi Mel,

2016-06-02 15:52 GMT+02:00 Mel Gorman <mgorman@techsingularity.net>:
> On Thu, Jun 02, 2016 at 07:48:38AM +0200, Marcin Wojtas wrote:
>> Hi Will,
>>
>> I think I found a right trace. Following one-liner fixes the issue
>> beginning from v4.2-rc1 up to v4.4 included:
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -294,7 +294,7 @@ static inline bool
>> early_page_uninitialised(unsigned long pfn)
>>
>>  static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
>>  {
>> -       return false;
>> +       return true;
>>  }
>>
>
> How does that make a difference in v4.4 since commit
> 974a786e63c96a2401a78ddba926f34c128474f1 removed the only
> early_page_nid_uninitialised() ? It further doesn't make sense if deferred
> memory initialisation is not enabled as the pages will always be
> initialised.
>

Right, it should be "v4.3 included". Your changes were merged to
v4.4-rc1 and indeed deferred initialization doesn't play a role from
then, but the behavior remained identical.

>> From what I understood, now order-0 allocation keep no reserve at all.
>
> Watermarks should still be preserved. zone_watermark_ok is still there.
> What might change is the size of reserves for high-order atomic
> allocations only. Fragmentation shouldn't be a factor. I'm missing some
> major part of the picture.
>

I CC'ed you in the last email, as I found out your authorship of
interesting patches - please see problem description
https://lkml.org/lkml/2016/5/30/1056

Anyway when using v4.4.8 baseline, after reverting below patches:
97a16fc - mm, page_alloc: only enforce watermarks for order-0 allocations
0aaa29a - mm, page_alloc: reserve pageblocks for high-order atomic
allocations on demand
974a786 - mm, page_alloc: remove MIGRATE_RESERVE
+ adding early_page_nid_uninitialised() modification

I stop receiving page alloc fail dumps like this one
http://pastebin.com/FhRW5DsF, also performance in my test looks very
similar. I'd like to understand this phenomenon and check if it's
possible to avoid such page-alloc-fail hickups in a nice way.
Afterwards, once the dumps finish, the kernel remain stable, but is
such behavior expected and intended?

What interested me from above-mentioned patches is that last-resort
migration on page-alloc fail ('retry_reserve') was removed from
rmqueue() in patch:
974a786 - mm, page_alloc: remove MIGRATE_RESERVE
Also a section next commit log (0aaa29a - mm, page_alloc: reserve
pageblocks for high-order atomic allocations on demand) caught my
attention - it began from words: "The reserved pageblocks can not be
used for order-0 allocations." This is why I understood that for this
kind of allocation there is no reserve kept and we need to count on
successful reclaim. However under big stress it seems that the
mechanism may not be sufficient. Am I interpreting it correctly?

For the record: the newest kernel I was able to reproduce the dumps
was v4.6: http://pastebin.com/ekDdACn5. I've just checked v4.7-rc1,
which comprise a lot (mainly yours) changes in mm, and I'm wondering
if there may be a spot fix or rather a series of improvements. I'm
looking forward to your opinion and would be grateful for any advice.

Best regards,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
