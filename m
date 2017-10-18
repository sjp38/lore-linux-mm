Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 264676B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 17:32:00 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id j17so5922935iod.18
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 14:32:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d192sor7357663ith.87.2017.10.18.14.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 14:31:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 19 Oct 2017 00:31:18 +0300
Message-ID: <CAGqmi75Y9wbwBS0ZythcNF1gi6bW7g_XcuMDgLu=Nx4=pWC8Jw@mail.gmail.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srividya Desireddy <srividya.dr@samsung.com>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

> +static int zswap_is_page_same_filled(void *ptr, unsigned long *value)
> +{
> +       unsigned int pos;
> +       unsigned long *page;
> +
> +       page = (unsigned long *)ptr;
> +       for (pos = 1; pos < PAGE_SIZE / sizeof(*page); pos++) {
> +               if (page[pos] != page[0])
> +                       return 0;
> +       }
> +       *value = page[0];
> +       return 1;
> +}
> +

In theory you can speedup that check by memcmp(),
And do something like first:
memcmp(ptr, ptr + PAGE_SIZE/sizeof(*page)/2, PAGE_SIZE/2);
After compare 1/4 with 2/4
Then 1/8 with 2/8.
And after do you check with pattern, only on first 512 bytes.

Just because memcmp() on fresh CPU are crazy fast.
That can easy make you check less expensive.

> +static void zswap_fill_page(void *ptr, unsigned long value)
> +{
> +       unsigned int pos;
> +       unsigned long *page;
> +
> +       page = (unsigned long *)ptr;
> +       if (value == 0)
> +               memset(page, 0, PAGE_SIZE);
> +       else {
> +               for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
> +                       page[pos] = value;
> +       }
> +}

Same here, but with memcpy().

P.S.
I'm just too busy to make fast performance test in user space,
but my recent experience with that CPU commands, show what that make a sense:
KSM patch: https://patchwork.kernel.org/patch/9980803/
User space tests: https://github.com/Nefelim4ag/memcmpe
PAGE_SIZE: 65536, loop count: 1966080
memcmp:  -28                    time: 3216 ms,  th: 40064.644611 MiB/s
memcmpe: -28, offset: 62232     time: 3588 ms,  th: 35902.462390 MiB/s
memcmpe: -28, offset: 62232     time: 71 ms,    th: 1792233.164286 MiB/s

IIRC, with code like our, you must see ~2.5GiB/s

Thanks.
-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
