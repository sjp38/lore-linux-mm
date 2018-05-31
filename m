Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6D76B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 10:08:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c187-v6so12790872pfa.20
        for <linux-mm@kvack.org>; Thu, 31 May 2018 07:08:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b4-v6si29721183pgc.190.2018.05.31.07.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 May 2018 07:08:13 -0700 (PDT)
Date: Thu, 31 May 2018 07:08:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Can kfree() sleep at runtime?
Message-ID: <20180531140808.GA30221@bombadil.infradead.org>
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 31, 2018 at 09:10:07PM +0800, Jia-Ju Bai wrote:
> I write a static analysis tool (DSAC), and it finds that kfree() can sleep.
> 
> Here is the call path for kfree().
> Please look at it *from the bottom up*.
> 
> [FUNC] alloc_pages(GFP_KERNEL)
> arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
> arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr

Here's your bug.  Coming from kfree(), we can't end up in the
split_large_page() path.  __change_page_attr may be called in several
different circumstances in which it would have to split a large page,
but the path from kfree() is not one of them.

I think the path from kfree() will lead to the 'level == PG_LEVEL_4K'
path, but I'm not really familiar with this x86 code.

> arch/x86/mm/pageattr.c, 1391: __change_page_attr in
> __change_page_attr_set_clr
> arch/x86/mm/pageattr.c, 2014: __change_page_attr_set_clr in __set_pages_np
> arch/x86/mm/pageattr.c, 2034: __set_pages_np in __kernel_map_pages
> ./include/linux/mm.h, 2488: __kernel_map_pages in kernel_map_pages
> mm/page_alloc.c, 1074: kernel_map_pages in free_pages_prepare
> mm/page_alloc.c, 1264: free_pages_prepare in __free_pages_ok
> mm/page_alloc.c, 4312: __free_pages_ok in __free_pages
> mm/slub.c, 3914: __free_pages in kfree
> 
> I always have an impression that kfree() never sleeps, so I feel confused
> here.
> So could someone please help me to find the mistake?
> Thanks in advance :)
> 
> Best wishes,
> Jia-Ju Bai
