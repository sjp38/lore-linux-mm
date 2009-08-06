Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 539176B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 22:36:55 -0400 (EDT)
Received: by yxe14 with SMTP id 14so699207yxe.12
        for <linux-mm@kvack.org>; Wed, 05 Aug 2009 19:36:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090805185247.86766d80.akpm@linux-foundation.org>
References: <20090805102817.GE21950@csn.ul.ie>
	 <20090805185247.86766d80.akpm@linux-foundation.org>
Date: Thu, 6 Aug 2009 11:36:56 +0900
Message-ID: <2f11576a0908051936j6be1c7afta9d2004787b2760b@mail.gmail.com>
Subject: Re: [PATCH] page-allocator: Remove dead function free_cold_page()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/8/6 Andrew Morton <akpm@linux-foundation.org>:
> On Wed, 5 Aug 2009 11:28:17 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
>
>> The function free_cold_page() has no callers so delete it.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> ---
>> =A0include/linux/gfp.h | =A0 =A01 -
>> =A0mm/page_alloc.c =A0 =A0 | =A0 =A05 -----
>> =A02 files changed, 6 deletions(-)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 7c777a0..c32bfa8 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -326,7 +326,6 @@ void free_pages_exact(void *virt, size_t size);
>> =A0extern void __free_pages(struct page *page, unsigned int order);
>> =A0extern void free_pages(unsigned long addr, unsigned int order);
>> =A0extern void free_hot_page(struct page *page);
>> -extern void free_cold_page(struct page *page);
>>
>> =A0#define __free_page(page) __free_pages((page), 0)
>> =A0#define free_page(addr) free_pages((addr),0)
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d052abb..36758db 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1065,11 +1065,6 @@ void free_hot_page(struct page *page)
>> =A0 =A0 =A0 free_hot_cold_page(page, 0);
>> =A0}
>>
>> -void free_cold_page(struct page *page)
>> -{
>> - =A0 =A0 free_hot_cold_page(page, 1);
>> -}
>> -
>> =A0/*
>> =A0 * split_page takes a non-compound higher-order page, and splits it i=
nto
>> =A0 * n (1<<order) sub-pages: page[0..n]
>
> Well I spose so. =A0But the function is valid and might need to be
> resurrected at any stage. =A0We could `#if 0' it to save a few bytes of
> text, perhaps.
>
> I wonder how many free_page() callers should really be calling
> free_cold_page(). =A0c'mon, write a thingy to work it out ;) You can
> query a page's hotness by timing how long it takes to read all its
> cachelines.

if we decide to keep this function, I think we also need to consider
make it exporting.
Driver developers never user unexported function.

Or, Can we free_hot_page() and free_cold_page move to inlined function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
