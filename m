Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC966B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:34:25 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 186so4748496itu.9
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:34:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l63sor6273495iol.240.2017.10.18.06.34.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 06:34:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171018123427.GA7271@bombadil.infradead.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1> <20171018123427.GA7271@bombadil.infradead.org>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Wed, 18 Oct 2017 16:33:43 +0300
Message-ID: <CAGqmi77nDU+z2PhNFJq3i208mxMbdTdk2=uPwfj42y0G3yyiWw@mail.gmail.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

2017-10-18 15:34 GMT+03:00 Matthew Wilcox <willy@infradead.org>:
> On Wed, Oct 18, 2017 at 10:48:32AM +0000, Srividya Desireddy wrote:
>> +static void zswap_fill_page(void *ptr, unsigned long value)
>> +{
>> +     unsigned int pos;
>> +     unsigned long *page;
>> +
>> +     page = (unsigned long *)ptr;
>> +     if (value == 0)
>> +             memset(page, 0, PAGE_SIZE);
>> +     else {
>> +             for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
>> +                     page[pos] = value;
>> +     }
>> +}
>
> I think you meant:
>
> static void zswap_fill_page(void *ptr, unsigned long value)
> {
>         memset_l(ptr, value, PAGE_SIZE / sizeof(unsigned long));
> }
>
> (and you should see significantly better numbers at least on x86;
> I don't know if anyone's done an arm64 version of memset_l yet).
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

IIRC kernel have special zero page, and if i understand correctly.
You can map all zero pages to that zero page and not touch zswap completely.
(Your situation look like some KSM case (i.e. KSM can handle pages
with same content), but i'm not sure if that applicable there)

Thanks.
-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
