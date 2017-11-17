Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id F26586B0261
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:11:14 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id b80so8300439iob.23
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:11:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor2799443itf.106.2017.11.17.14.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 14:11:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171102150820epcms5p307052ef7697592b3b4e2848bf4968f7b@epcms5p3>
References: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <CAGqmi75Y9wbwBS0ZythcNF1gi6bW7g_XcuMDgLu=Nx4=pWC8Jw@mail.gmail.com>
 <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p3>
 <20171019010841.GA17308@bombadil.infradead.org> <20171102150820epcms5p307052ef7697592b3b4e2848bf4968f7b@epcms5p3>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 17 Nov 2017 17:10:33 -0500
Message-ID: <CALZtONBh5vmfnC4G1d66AQtmBB8DJA8c3yZWZYg01maKCjVagA@mail.gmail.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, Matthew Wilcox <willy@infradead.org>, Timofey Titovets <nefelim4ag@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Thu, Nov 2, 2017 at 11:08 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
>
> On Wed, Oct 19, 2017 at 6:38 AM, Matthew Wilcox wrote:
>> On Thu, Oct 19, 2017 at 12:31:18AM +0300, Timofey Titovets wrote:
>>> > +static void zswap_fill_page(void *ptr, unsigned long value)
>>> > +{
>>> > +       unsigned int pos;
>>> > +       unsigned long *page;
>>> > +
>>> > +       page = (unsigned long *)ptr;
>>> > +       if (value == 0)
>>> > +               memset(page, 0, PAGE_SIZE);
>>> > +       else {
>>> > +               for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
>>> > +                       page[pos] = value;
>>> > +       }
>>> > +}
>>>
>>> Same here, but with memcpy().
>>
>>No.  Use memset_l which is optimised for this specific job.
>
> I have tested this patch using memset_l() function in zswap_fill_page() on
> x86 64-bit system with 2GB RAM. The performance remains same.
> But, memset_l() funcion might be optimised in future.
> @Seth Jennings/Dan Streetman:  Should I use memset_l() function in this patch.

my testing showed also showed minimal if any difference when using
memset_l(), but it's simpler code and should never be slower than
looping.  I'll ack it if you want to send an additional patch making
this change (on top of the one I already acked).

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
