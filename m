Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 38AC7900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 13:19:19 -0400 (EDT)
Received: by vnbf7 with SMTP id f7so9865544vnb.7
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 10:19:19 -0700 (PDT)
Received: from mail-vn0-x230.google.com (mail-vn0-x230.google.com. [2607:f8b0:400c:c0f::230])
        by mx.google.com with ESMTPS id if6si14389607vdb.58.2015.06.05.10.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 10:19:18 -0700 (PDT)
Received: by vnbf7 with SMTP id f7so9881896vnb.13
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 10:19:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5571BFBE.3070209@redhat.com>
References: <000001d09f66$056b67f0$104237d0$@yang@samsung.com>
	<5571BFBE.3070209@redhat.com>
Date: Sat, 6 Jun 2015 02:19:17 +0900
Message-ID: <CA+pa1O2xTnWdP6bbPNnBM=P2oMAaLJf9hWZd+KOL12BJp4R-3Q@mail.gmail.com>
Subject: Re: [PATCH] cma: allow concurrent cma pages allocation for multi-cma areas
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang.kh@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 05 2015, Laura Abbott wrote:
> On 06/05/2015 01:01 AM, Weijie Yang wrote:
>> Currently we have to hold the single cma_mutex when alloc cma pages,
>> it is ok when there is only one cma area in system.
>> However, when there are several cma areas, such as in our Android smart
>> phone, the single cma_mutex prevents concurrent cma page allocation.
>>
>> This patch removes the single cma_mutex and uses per-cma area alloc_lock=
,
>> this allows concurrent cma pages allocation for different cma areas whil=
e
>> protects access to the same pageblocks.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

> Last I knew alloc_contig_range needed to be serialized which is why we
> still had the global CMA mutex. https://lkml.org/lkml/2014/2/18/462
>
> So NAK unless something has changed to allow this.

This patch should be fine.

Change you=E2=80=99ve pointed to would get rid of any serialisation around
alloc_contig_range which is dangerous, but since CMA regions are
pageblock-aligned:

    /*
     * Sanitise input arguments.
     * Pages both ends in CMA area could be merged into adjacent unmovable
     * migratetype page by page allocator's buddy algorithm. In the case,
     * you couldn't get a contiguous memory, which is not what we want.
     */
    alignment =3D max(alignment,
        (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
    base =3D ALIGN(base, alignment);
    size =3D ALIGN(size, alignment);
    limit &=3D ~(alignment - 1);

synchronising allocation in each area should work fine.

>> ---
>>   mm/cma.c |    6 +++---
>>   mm/cma.h |    1 +
>>   2 files changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index 3a7a67b..eaf1afe 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -41,7 +41,6 @@
>>
>>   struct cma cma_areas[MAX_CMA_AREAS];
>>   unsigned cma_area_count;
>> -static DEFINE_MUTEX(cma_mutex);
>>
>>   phys_addr_t cma_get_base(const struct cma *cma)
>>   {
>> @@ -128,6 +127,7 @@ static int __init cma_activate_area(struct cma *cma)
>>       } while (--i);
>>
>>       mutex_init(&cma->lock);

Since now we have two mutexes in the structure, rename this one to
bitmap_lock.

>> +    mutex_init(&cma->alloc_lock);
>>
>>   #ifdef CONFIG_CMA_DEBUGFS
>>       INIT_HLIST_HEAD(&cma->mem_head);
>> @@ -398,9 +398,9 @@ struct page *cma_alloc(struct cma *cma, unsigned int=
 count, unsigned int align)
>>           mutex_unlock(&cma->lock);
>>
>>           pfn =3D cma->base_pfn + (bitmap_no << cma->order_per_bit);
>> -        mutex_lock(&cma_mutex);
>> +        mutex_lock(&cma->alloc_lock);
>>           ret =3D alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
>> -        mutex_unlock(&cma_mutex);
>> +        mutex_unlock(&cma->alloc_lock);
>>           if (ret =3D=3D 0) {
>>               page =3D pfn_to_page(pfn);
>>               break;
>> diff --git a/mm/cma.h b/mm/cma.h
>> index 1132d73..2084c9f 100644
>> --- a/mm/cma.h
>> +++ b/mm/cma.h
>> @@ -7,6 +7,7 @@ struct cma {
>>       unsigned long   *bitmap;
>>       unsigned int order_per_bit; /* Order of pages represented by one b=
it */
>>       struct mutex    lock;
>> +    struct mutex    alloc_lock;
>>   #ifdef CONFIG_CMA_DEBUGFS
>>       struct hlist_head mem_head;
>>       spinlock_t mem_head_lock;

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
