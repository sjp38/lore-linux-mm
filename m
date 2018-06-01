Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D11C6B0266
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:12:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f5-v6so6804320pgq.19
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:12:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8-v6sor14003602plc.39.2018.05.31.18.12.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 18:12:41 -0700 (PDT)
Subject: Re: Can kfree() sleep at runtime?
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
 <20180531140808.GA30221@bombadil.infradead.org>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <4e3c8b44-67cc-29ca-7d59-daf542d2fcf2@gmail.com>
Date: Fri, 1 Jun 2018 09:12:20 +0800
MIME-Version: 1.0
In-Reply-To: <20180531140808.GA30221@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 2018/5/31 22:08, Matthew Wilcox wrote:
> On Thu, May 31, 2018 at 09:10:07PM +0800, Jia-Ju Bai wrote:
>> I write a static analysis tool (DSAC), and it finds that kfree() can sleep.
>>
>> Here is the call path for kfree().
>> Please look at it *from the bottom up*.
>>
>> [FUNC] alloc_pages(GFP_KERNEL)
>> arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
>> arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr
> Here's your bug.  Coming from kfree(), we can't end up in the
> split_large_page() path.  __change_page_attr may be called in several
> different circumstances in which it would have to split a large page,
> but the path from kfree() is not one of them.
>
> I think the path from kfree() will lead to the 'level == PG_LEVEL_4K'
> path, but I'm not really familiar with this x86 code.

Thanks for reply :)
But from the code in my call path, I cannot find why kfree() will only lead to the 'level == PG_LEVEL_4K' path.
Could you please explain it in more detail?


Best wishes,
Jia-Ju Bai
  
