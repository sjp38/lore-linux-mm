Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E2D46B0055
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:26:51 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2797345yxh.26
        for <linux-mm@kvack.org>; Fri, 29 May 2009 22:27:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090528095904.GD10334@csn.ul.ie>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
	 <20090528095904.GD10334@csn.ul.ie>
Date: Sat, 30 May 2009 17:27:15 +1200
Message-ID: <202cde0e0905292227tc619a17h41df83d22bc922fa@mail.gmail.com>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order allocations
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

Hi,
>> To allocate memory I use standard function alloc_apges(gfp_mask,
>> order) which asks buddy allocator to give a chunk of memory of given
>> "order".
>> Allocator returns page and also sets page count to 1 but for page of
>> high order. I.e. pages 2,3 etc inside high order allocation will have
>> page->_count==0.
>> If I try to mmap allocated area to user space vm_insert_page will
>> return error as pages 2,3, etc are not refcounted.
>>
>
> page = alloc_pages(high_order);
> split_page(page, high_order);
>
> That will fix up the ref-counting of each of the individual pages. You are
> then responsible for freeing them individually. As you are inserting these
> into userspace, I suspect that's ok.

It seems it is the only way I have now. It is not so elegant - but should work.
Thanks for good advise.

BTW: Just out of curiosity what limits mapping high ordered pages into
user space. I tried to find any except the check in vm_insert but
failed. Is this checks caused by possible swapping?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
