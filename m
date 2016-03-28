Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BB1166B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 15:30:02 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id zm5so19380092pac.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 12:30:02 -0700 (PDT)
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id p28si4713165pfi.167.2016.03.28.12.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 12:30:01 -0700 (PDT)
Received: by mail-pf0-f181.google.com with SMTP id x3so144571857pfb.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 12:30:01 -0700 (PDT)
Subject: Re: [RFC PATCH] Add support for eXclusive Page Frame Ownership (XPFO)
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <56D4F0D6.2060308@redhat.com> <56EFB2DB.3090602@hpe.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56F98637.4070705@redhat.com>
Date: Mon, 28 Mar 2016 12:29:59 -0700
MIME-Version: 1.0
In-Reply-To: <56EFB2DB.3090602@hpe.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: vpk@cs.brown.edu, Kees Cook <keescook@chromium.org>

On 03/21/2016 01:37 AM, Juerg Haefliger wrote:
...
>>> +void xpfo_free_page(struct page *page, int order)
>>> +{
>>> +    int i;
>>> +    unsigned long kaddr;
>>> +
>>> +    for (i = 0; i < (1 << order); i++) {
>>> +
>>> +        /* The page frame was previously allocated to user space */
>>> +        if (TEST_AND_CLEAR_XPFO_FLAG(user, page + i)) {
>>> +            kaddr = (unsigned long)page_address(page + i);
>>> +
>>> +            /* Clear the page and mark it accordingly */
>>> +            clear_page((void *)kaddr);
>>
>> Clearing the page isn't related to XPFO. There's other work ongoing to
>> do clearing of the page on free.
>
> It's not strictly related to XPFO but adds another layer of security. Do you
> happen to have a pointer to the ongoing work that you mentioned?
>
>

The work was merged for the 4.6 merge window
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8823b1dbc05fab1a8bec275eeae4709257c2661d

This is a separate option to clear the page.

...

>>> @@ -2072,10 +2076,11 @@ void free_hot_cold_page(struct page *page, bool cold)
>>>        }
>>>
>>>        pcp = &this_cpu_ptr(zone->pageset)->pcp;
>>> -    if (!cold)
>>> +    if (!cold && !xpfo_test_kernel(page))
>>>            list_add(&page->lru, &pcp->lists[migratetype]);
>>>        else
>>>            list_add_tail(&page->lru, &pcp->lists[migratetype]);
>>> +
>>
>> What's the advantage of this?
>
> Allocating a page to userspace that was previously allocated to kernel space
> requires an expensive TLB shootdown. The above will put previously
> kernel-allocated pages in the cold page cache to postpone their allocation as
> long as possible to minimize TLB shootdowns.
>
>

That makes sense. You probably want to make this a separate commmit with
this explanation as the commit text.


>>>        pcp->count++;
>>>        if (pcp->count >= pcp->high) {
>>>            unsigned long batch = READ_ONCE(pcp->batch);
>>>
>
> Thanks for the review and comments! It's highly appreciated.
>
> ...Juerg
>
>
>> Thanks,
>> Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
