Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id F0BA56B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 03:00:33 -0500 (EST)
Received: by obbww6 with SMTP id ww6so107833402obb.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 00:00:33 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id lx7si5671712oeb.2.2015.11.09.00.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 00:00:33 -0800 (PST)
Received: by obbww6 with SMTP id ww6so107833107obb.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 00:00:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151109075337.GC472@swordfish>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20151109075337.GC472@swordfish>
Date: Mon, 9 Nov 2015 17:00:32 +0900
Message-ID: <CAAmzW4MugYCu1+ZsRp63o=26eTuJG22C+nNrGBhDJvQDOzbQJw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce page reference manipulation functions
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2015-11-09 16:53 GMT+09:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> Hi,
>
> On (11/09/15 16:23), Joonsoo Kim wrote:
> [..]
>> +static inline int page_count(struct page *page)
>> +{
>> +     return atomic_read(&compound_head(page)->_count);
>> +}
>> +
>> +static inline void set_page_count(struct page *page, int v)
>> +{
>> +     atomic_set(&page->_count, v);
>> +}
>> +
>> +/*
>> + * Setup the page count before being freed into the page allocator for
>> + * the first time (boot or memory hotplug)
>> + */
>> +static inline void init_page_count(struct page *page)
>> +{
>> +     set_page_count(page, 1);
>> +}
>> +
>> +static inline void page_ref_add(struct page *page, int nr)
>> +{
>> +     atomic_add(nr, &page->_count);
>> +}
>
> Since page_ref_FOO wrappers operate with page->_count and there
> are already page_count()/set_page_count()/etc. may be name new
> wrappers in page_count_FOO() manner?

Hello,

I used that page_count_ before but change my mind.
I think that ref is more relevant to this operation.
Perhaps, it'd be better to change page_count()/set_page_count()
to page_ref()/set_page_ref().

FYI, some functions such as page_(un)freeze_refs uses ref. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
