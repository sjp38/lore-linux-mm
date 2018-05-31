Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 371356B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 10:12:01 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s133-v6so12234804qke.21
        for <linux-mm@kvack.org>; Thu, 31 May 2018 07:12:01 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id q78-v6si12594169qka.40.2018.05.31.07.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 May 2018 07:12:00 -0700 (PDT)
Date: Thu, 31 May 2018 14:12:00 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Can kfree() sleep at runtime?
In-Reply-To: <20180531140808.GA30221@bombadil.infradead.org>
Message-ID: <01000163b68a8026-56fb6a35-040b-4af9-8b73-eb3b4a41c595-000000@email.amazonses.com>
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com> <20180531140808.GA30221@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia-Ju Bai <baijiaju1990@gmail.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 31 May 2018, Matthew Wilcox wrote:

> On Thu, May 31, 2018 at 09:10:07PM +0800, Jia-Ju Bai wrote:
> > I write a static analysis tool (DSAC), and it finds that kfree() can sleep.
> >
> > Here is the call path for kfree().
> > Please look at it *from the bottom up*.
> >
> > [FUNC] alloc_pages(GFP_KERNEL)
> > arch/x86/mm/pageattr.c, 756: alloc_pages in split_large_page
> > arch/x86/mm/pageattr.c, 1283: split_large_page in __change_page_attr
>
> Here's your bug.  Coming from kfree(), we can't end up in the
> split_large_page() path.  __change_page_attr may be called in several
> different circumstances in which it would have to split a large page,
> but the path from kfree() is not one of them.

Freeing a page in the page allocator also was traditionally not sleeping.
That has changed?
