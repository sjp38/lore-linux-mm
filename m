Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D79476B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 01:13:33 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w185so136703625ita.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 22:13:33 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j68si904886itb.14.2017.02.07.22.13.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 22:13:33 -0800 (PST)
Message-ID: <589AB6EA.1060409@huawei.com>
Date: Wed, 8 Feb 2017 14:12:58 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix a overflow in test_pages_in_a_zone()
References: <1486467299-22648-1-git-send-email-zhongjiang@huawei.com> <1486492248.2029.34.camel@hpe.com>
In-Reply-To: <1486492248.2029.34.camel@hpe.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "vbabka@suse.cz" <vbabka@suse.cz>

On 2017/2/8 1:35, Kani, Toshimitsu wrote:
> On Tue, 2017-02-07 at 19:34 +0800, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when the mailline introduce the commit a96dfddbcc04
>> ("base/memory, hotplug: fix a kernel oops in show_valid_zones()"),
>> it obtains the valid start and end pfn from the given pfn range.
>> The valid start pfn can fix the actual issue, but it introduce
>> another issue. The valid end pfn will may exceed the given end_pfn.
>>
>> Ahthough the incorrect overflow will not result in actual problem
>> at present, but I think it need to be fixed.
> Yes, test_pages_in_a_zone() assumes that end_pfn is aligned by
> MAX_ORDER_NR_PAGES.  This is true for both callers, show_valid_zones()
> and __offline_pages().  I did not introduce this assumption. :-)
>
> As you pointed out, it is prudent to remove this assumption for future
> usages.  In this case, I think we need the following change as well.
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a40c0c2..09c8b99 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1513,7 +1513,7 @@ int test_pages_in_a_zone(unsigned long start_pfn,
> unsigned long end_pfn,
>                 while ((i < MAX_ORDER_NR_PAGES) &&
>                         !pfn_valid_within(pfn + i))
>                         i++;
> -               if (i == MAX_ORDER_NR_PAGES)
> +               if ((i == MAX_ORDER_NR_PAGES) || (pfn + i >= end_pfn))
>                         continue;
>                 page = pfn_to_page(pfn + i);
>                 if (zone && page_zone(page) != zone)
>
>
> Thanks,
> -Toshi
>
 Indeed, sorry, I forget the change.

 Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
