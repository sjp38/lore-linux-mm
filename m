Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA686B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 01:48:39 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so65353110igb.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 22:48:39 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id f3si55880141ioa.19.2016.06.01.22.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 22:48:38 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id k19so23847811ioi.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 22:48:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160531131520.GI24936@arm.com>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
	<574D64A0.2070207@arm.com>
	<CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
	<60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
	<20160531131520.GI24936@arm.com>
Date: Thu, 2 Jun 2016 07:48:38 +0200
Message-ID: <CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
Subject: Re: [BUG] Page allocation failures with newest kernels
From: Marcin Wojtas <mw@semihalf.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, =?UTF-8?Q?Gregory_Cl=C3=A9ment?= <gregory.clement@free-electrons.com>, mgorman@techsingularity.net

Hi Will,

I think I found a right trace. Following one-liner fixes the issue
beginning from v4.2-rc1 up to v4.4 included:

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -294,7 +294,7 @@ static inline bool
early_page_uninitialised(unsigned long pfn)

 static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
 {
-       return false;
+       return true;
 }

The regression was introduced by commit 7e18adb4f80b ("mm: meminit:
initialise remaining struct pages in parallel with kswapd"), which in
fact disabled memblock reserve at all for all platfroms not using
CONFIG_DEFERRED_STRUCT_PAGE_INIT (x86 is the only user), hence
temporary shortage of memory possible to allocate during my test.

Since v4.4-rc1 following changes of approach have been introduced:
97a16fc - mm, page_alloc: only enforce watermarks for order-0 allocations
0aaa29a - mm, page_alloc: reserve pageblocks for high-order atomic
allocations on demand
974a786 - mm, page_alloc: remove MIGRATE_RESERVE

>From what I understood, now order-0 allocation keep no reserve at all.
I checked all gathered logs and indeed it was order-0 which failed and
apparently weren't able to reclaim successfully. Since the problem is
very easy to reproduce (at least in my test, as well as stressing
device in NAS setup) is there any chance to avoid destiny of page
alloc failures? Or any trick to play with fragmentation parameters,
etc.?

I would be grateful for any hint.

Best regards,
Marcin

2016-05-31 15:15 GMT+02:00 Will Deacon <will.deacon@arm.com>:
> On Tue, May 31, 2016 at 01:10:44PM +0000, Yehuda Yitschak wrote:
>> During some of the stress tests we also came across a different warning
>> from the arm64  page management code
>> It looks like a race is detected between HW and SW marking a bit in the PTE
>
> A72 (which I believe is the CPU in that SoC) is a v8.0 CPU and therefore
> doesn't have hardware DBM.
>
>> Not sure it's really related but I thought it might give a clue on the issue
>> http://pastebin.com/ASv19vZP
>
> There have been a few patches from Catalin to fix up the hardware DBM
> patches, so it might be worth trying to reproduce this failure with a
> more recent kernel. I doubt this is related to the allocation failures,
> however.
>
> Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
