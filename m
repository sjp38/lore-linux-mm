Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8AF976B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 21:29:46 -0400 (EDT)
Received: by qyk36 with SMTP id 36so1067364qyk.12
        for <linux-mm@kvack.org>; Fri, 17 Jul 2009 18:29:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090717174128.36d00972.akpm@linux-foundation.org>
References: <20090704020949.GA3047@localhost.localdomain>
	 <20090717174128.36d00972.akpm@linux-foundation.org>
Date: Sat, 18 Jul 2009 10:29:44 +0900
Message-ID: <961aa3350907171829i52c095aam610ae2dc3d931080@mail.gmail.com>
Subject: Re: [PATCH] mm: add gfp mask checking for __get_free_pages()
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/7/18 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 4 Jul 2009 11:09:50 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
>
>> __get_free_pages() with __GFP_HIGHMEM is not safe because the return
>> address cannot represent a highmem page. get_zeroed_page() already has
>> such a debug checking.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>> ---
>> =A0mm/page_alloc.c | =A0 24 +++++++++---------------
>> =A01 files changed, 9 insertions(+), 15 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index e0f2cdf..4a1a374 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1903,31 +1903,25 @@ EXPORT_SYMBOL(__alloc_pages_nodemask);
>> =A0 */
>> =A0unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
>> =A0{
>> - =A0 =A0 struct page * page;
>> + =A0 =A0 struct page *page;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* __get_free_pages() returns a 32-bit address, which cannot=
 represent
>> + =A0 =A0 =A0* a highmem page
>> + =A0 =A0 =A0*/
>> + =A0 =A0 VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) !=3D 0);
>> +
>> =A0 =A0 =A0 page =3D alloc_pages(gfp_mask, order);
>> =A0 =A0 =A0 if (!page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 return (unsigned long) page_address(page);
>> =A0}
>> -
>> =A0EXPORT_SYMBOL(__get_free_pages);
>>
>> =A0unsigned long get_zeroed_page(gfp_t gfp_mask)
>> =A0{
>> - =A0 =A0 struct page * page;
>> -
>> - =A0 =A0 /*
>> - =A0 =A0 =A0* get_zeroed_page() returns a 32-bit address, which cannot =
represent
>> - =A0 =A0 =A0* a highmem page
>> - =A0 =A0 =A0*/
>> - =A0 =A0 VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) !=3D 0);
>> -
>> - =A0 =A0 page =3D alloc_pages(gfp_mask | __GFP_ZERO, 0);
>> - =A0 =A0 if (page)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return (unsigned long) page_address(page);
>> - =A0 =A0 return 0;
>> + =A0 =A0 return __get_free_pages(gfp_mask | __GFP_ZERO, 0);
>> =A0}
>> -
>> =A0EXPORT_SYMBOL(get_zeroed_page);
>>
>> =A0void __pagevec_free(struct pagevec *pvec)
>
> Fair enough.
>
> I suspect we could just delete that VM_BUG_ON() - we can't go and do
> runtime checking for every darn programmer error, and this would be a
> pretty dumb one.

Maybe. But we had such a bug in c51b1a160b63304720d49479986915e4c475a2cf
(xip: fix get_zeroed_page with __GFP_HIGHME). Even the VM code
had it and did not fixed for a long time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
