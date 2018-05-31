Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE5C96B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 10:09:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 12-v6so2383894qtq.8
        for <linux-mm@kvack.org>; Thu, 31 May 2018 07:09:31 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id c3-v6si467771qvj.82.2018.05.31.07.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 May 2018 07:09:30 -0700 (PDT)
Date: Thu, 31 May 2018 14:09:30 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Can kfree() sleep at runtime?
In-Reply-To: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
Message-ID: <01000163b6883743-79e003fa-71c2-4e9d-aa4a-35fcd08bb0d8-000000@email.amazonses.com>
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 31 May 2018, Jia-Ju Bai wrote:

> I write a static analysis tool (DSAC), and it finds that kfree() can sleep.

That should not happen.

> Here is the call path for kfree().
> Please look at it *from the bottom up*.
>
> [FUNC] alloc_pages(GFP_KERNEL)
> arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
> arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr
> arch/x86/mm/pageattr.c, 1391: __change_page_attr in __change_page_attr_set_clr
> arch/x86/mm/pageattr.c, 2014: __change_page_attr_set_clr in __set_pages_np
> arch/x86/mm/pageattr.c, 2034: __set_pages_np in __kernel_map_pages
> ./include/linux/mm.h, 2488: __kernel_map_pages in kernel_map_pages
> mm/page_alloc.c, 1074: kernel_map_pages in free_pages_prepare

mapping pages in the page allocator can cause allocations?? How did that
get in there?

> mm/page_alloc.c, 1264: free_pages_prepare in __free_pages_ok
> mm/page_alloc.c, 4312: __free_pages_ok in __free_pages
> mm/slub.c, 3914: __free_pages in kfree
>
> I always have an impression that kfree() never sleeps, so I feel confused
> here.

Correct.
