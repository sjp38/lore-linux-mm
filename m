Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 611816B0164
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:05:17 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so3975324pbb.28
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:05:17 -0700 (PDT)
Received: from psmtp.com ([74.125.245.127])
        by mx.google.com with SMTP id u7si1703224pau.194.2013.10.18.08.05.15
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 08:05:16 -0700 (PDT)
Received: by mail-wg0-f46.google.com with SMTP id m15so3834319wgh.1
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:05:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000141c7d66282-aa92b1f2-2a69-424b-9498-8e5367304d32-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
	<00000141c7d66282-aa92b1f2-2a69-424b-9498-8e5367304d32-000000@email.amazonses.com>
Date: Sat, 19 Oct 2013 00:05:12 +0900
Message-ID: <CAAmzW4PsEfGR8TMDiP4LTX7Oj3nr+F4Pxo2DyOEV4ab1pPmwkw@mail.gmail.com>
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

2013/10/18 Christoph Lameter <cl@linux.com>:
> On Wed, 16 Oct 2013, Joonsoo Kim wrote:
>
>> -                                      * see PAGE_MAPPING_ANON below.
>> -                                      */
>> +     union {
>> +             struct address_space *mapping;  /* If low bit clear, points to
>> +                                              * inode address_space, or NULL.
>> +                                              * If page mapped as anonymous
>> +                                              * memory, low bit is set, and
>> +                                              * it points to anon_vma object:
>> +                                              * see PAGE_MAPPING_ANON below.
>> +                                              */
>> +             void *s_mem;                    /* slab first object */
>> +     };
>
> The overloading of mapping has caused problems in the past since slab
> pages are (or are they no longer?) used for DMA to disk. At that point the
> I/O subsystem may be expecting a mapping in the page struct if this field
> is not NULL.

I search the history of struct page and find that the SLUB use mapping field
in past (2007 year). At that time, you inserted VM_BUG_ON(PageSlab(page))
('b5fab14') into page_mapping() function to find remaining use. Recently,
I never hear that this is triggered and 6 years have passed since inserting
VM_BUG_ON(), so I guess there is no problem to use it.
If this argument is reasonable, please give me an ACK :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
