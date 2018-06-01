Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D00F6B0266
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:19:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n78-v6so13635195pfj.4
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:19:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g132-v6sor4697077pgc.215.2018.05.31.18.19.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 18:19:06 -0700 (PDT)
Subject: Re: Can kfree() sleep at runtime?
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
 <01000163b6883743-79e003fa-71c2-4e9d-aa4a-35fcd08bb0d8-000000@email.amazonses.com>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <3b65993d-9e96-4354-8761-ae1f87c5ae20@gmail.com>
Date: Fri, 1 Jun 2018 09:18:45 +0800
MIME-Version: 1.0
In-Reply-To: <01000163b6883743-79e003fa-71c2-4e9d-aa4a-35fcd08bb0d8-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 2018/5/31 22:09, Christopher Lameter wrote:
> On Thu, 31 May 2018, Jia-Ju Bai wrote:
>
>> I write a static analysis tool (DSAC), and it finds that kfree() can sleep.
> That should not happen.
>
>> Here is the call path for kfree().
>> Please look at it *from the bottom up*.
>>
>> [FUNC] alloc_pages(GFP_KERNEL)
>> arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
>> arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr
>> arch/x86/mm/pageattr.c, 1391: __change_page_attr in __change_page_attr_set_clr
>> arch/x86/mm/pageattr.c, 2014: __change_page_attr_set_clr in __set_pages_np
>> arch/x86/mm/pageattr.c, 2034: __set_pages_np in __kernel_map_pages
>> ./include/linux/mm.h, 2488: __kernel_map_pages in kernel_map_pages
>> mm/page_alloc.c, 1074: kernel_map_pages in free_pages_prepare
> mapping pages in the page allocator can cause allocations?? How did that
> get in there?

Thanks for reply :)
I am also confused about it.

I get in here according to the definition of free_pages_prepare():
1022. static bool free_pages_prepare(...) {
              ...
1072.    arch_free_page(page, order);
1073.    kernel_poison_pages(page, 1 << order, 0);
1074.    kernel_map_pages(page, 1 << order, 0); // *Here*
1075.    kasan_free_pages(page, order);
1076.
1077.    return true;
1078. }


Best wishes,
Jia-Ju Bai
