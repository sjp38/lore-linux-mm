Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1830D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 10:15:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id p22-v6so2244149ioh.7
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:15:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m10-v6sor10562030ioh.170.2018.09.18.07.15.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 07:15:57 -0700 (PDT)
MIME-Version: 1.0
References: <D4C91DBA-CF56-4991-BD7F-6BE334A2C048@amazon.com>
In-Reply-To: <D4C91DBA-CF56-4991-BD7F-6BE334A2C048@amazon.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 18 Sep 2018 10:15:20 -0400
Message-ID: <CALZtONDpUDAz_PLrt03CaajzAoY_Wr6Tm=PgvqAWyir9=fCd8A@mail.gmail.com>
Subject: Re: zswap: use PAGE_SIZE * 2 for compression dst buffer size when
 calling crypto compression API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: taeilum@amazon.com
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>

On Mon, Sep 17, 2018 at 7:10 PM Um, Taeil <taeilum@amazon.com> wrote:
>
> Currently, we allocate PAGE_SIZE * 2 for zswap_dstmem which is used as compression destination buffer.
>
> However, we pass only half of the size (PAGE_SIZE) to crypto_comp_compress.
>
> This might not be a problem for CPU based existing lzo, lz4 crypto compression driver implantation.
>
> However, this could be a problem for some H/W acceleration compression drivers, which honor destination buffer size when it prepares H/W resources.

How exactly could it be a problem?

>
> Actually, this patch is aligned with what zram is passing when it calls crypto_comp_compress.
>
> The following simple patch will solve this problem. I tested it with existing crypto/lzo.c and crypto/lz4.c compression driver and it works fine.
>
>
>
>
>
> --- mm/zswap.c.orig       2018-09-14 14:36:37.984199232 -0700
>
> +++ mm/zswap.c             2018-09-14 14:36:53.340189681 -0700
>
> @@ -1001,7 +1001,7 @@ static int zswap_frontswap_store(unsigne
>
>                 struct zswap_entry *entry, *dupentry;
>
>                 struct crypto_comp *tfm;
>
>                 int ret;
>
> -              unsigned int hlen, dlen = PAGE_SIZE;
>
> +             unsigned int hlen, dlen = PAGE_SIZE * 2;
>
>                 unsigned long handle, value;
>
>                 char *buf;
>
>                 u8 *src, *dst;
>
>
>
>
>
>
>
> Thank you,
>
> Taeil
>
>
