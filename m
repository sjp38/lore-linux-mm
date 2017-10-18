Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E66E86B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:43:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a192so4262762pge.1
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:43:55 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id l9si7082139pgn.319.2017.10.18.07.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 07:43:54 -0700 (PDT)
Received: from epcas5p1.samsung.com (unknown [182.195.41.39])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20171018144351epoutp02168170887902d8d052cbc1cc188ac429~usUQ9vrNH1414714147epoutp02Z
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 14:43:51 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH] zswap: Same-filled pages handling
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
In-Reply-To: <20171018141116.GA12063@bombadil.infradead.org>
Message-ID: <20171018144350epcms5p1f390fae66f1c9440b8552acec555ca01@epcms5p1>
Date: Wed, 18 Oct 2017 14:43:50 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <20171018141116.GA12063@bombadil.infradead.org>
	<20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	<20171018123427.GA7271@bombadil.infradead.org>
	<CAGqmi77nDU+z2PhNFJq3i208mxMbdTdk2=uPwfj42y0G3yyiWw@mail.gmail.com>
	<CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Timofey Titovets <nefelim4ag@gmail.com>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Oct 18, 2017 at 7:41 PM, Matthew Wilcox wrote: 
> On Wed, Oct 18, 2017 at 04:33:43PM +0300, Timofey Titovets wrote:
>> 2017-10-18 15:34 GMT+03:00 Matthew Wilcox <willy@infradead.org>:
>> > On Wed, Oct 18, 2017 at 10:48:32AM +0000, Srividya Desireddy wrote:
>> >> +static void zswap_fill_page(void *ptr, unsigned long value)
>> >> +{
>> >> +     unsigned int pos;
>> >> +     unsigned long *page;
>> >> +
>> >> +     page = (unsigned long *)ptr;
>> >> +     if (value == 0)
>> >> +             memset(page, 0, PAGE_SIZE);
>> >> +     else {
>> >> +             for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
>> >> +                     page[pos] = value;
>> >> +     }
>> >> +}
>> >
>> > I think you meant:
>> >
>> > static void zswap_fill_page(void *ptr, unsigned long value)
>> > {
>> >         memset_l(ptr, value, PAGE_SIZE / sizeof(unsigned long));
>> > }
>> 
>> IIRC kernel have special zero page, and if i understand correctly.
>> You can map all zero pages to that zero page and not touch zswap completely.
>> (Your situation look like some KSM case (i.e. KSM can handle pages
>> with same content), but i'm not sure if that applicable there)
> 
>You're confused by the word "same".  What Srividya meant was that the
>page is filled with a pattern, eg 0xfffefffefffefffe..., not that it is
>the same as any other page.

In kernel there is a special zero page or empty_zero_page which is in
general allocated in paging_init() function, to map all zero pages. But,
same-value-filled pages including zero pages exist in memory because
applications may be initializing the allocated pages with a value and not
using them; or the actual content written to the memory pages during 
execution itself is same-value, in case of multimedia data for example.

I had earlier posted a patch with similar implementaion of KSM concept 
for Zswap:
https://lkml.org/lkml/2016/8/17/171
https://lkml.org/lkml/2017/2/17/612

- Srividya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
