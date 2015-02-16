Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7AD6B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:45:27 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id hi2so25403090wib.4
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:45:26 -0800 (PST)
Received: from mail-wi0-x244.google.com (mail-wi0-x244.google.com. [2a00:1450:400c:c05::244])
        by mx.google.com with ESMTPS id yz6si21451947wjc.111.2015.02.16.03.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 03:45:25 -0800 (PST)
Received: by mail-wi0-f196.google.com with SMTP id em10so12232512wid.3
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:45:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PrXpv_znYUekFb=K70JqFXDWFmdhLa7jzx-7Ky7c7X5A@mail.gmail.com>
References: <CALszF6DP-RSX2-fp=a=gdcHMF3O0TE_JKom3AWcLFm5q80RrYw@mail.gmail.com>
	<CAAmzW4PrXpv_znYUekFb=K70JqFXDWFmdhLa7jzx-7Ky7c7X5A@mail.gmail.com>
Date: Mon, 16 Feb 2015 12:45:24 +0100
Message-ID: <CALszF6DaFo7Xnehtt7vom32ydenhEFhx-YjH4BtLxLL6QwMmvA@mail.gmail.com>
Subject: Re: [Regression]: mm: nommu: Memory leak introduced with commit
 "mm/nommu: use alloc_pages_exact() rather than its own implementation"
From: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello Joonsoo,

2015-02-16 5:43 GMT+01:00 Joonsoo Kim <js1304@gmail.com>:
>
> Hello,
>
> Sorry for my mistake.
> Problem happens because when we allocate memory through
> __get_free_pages(), refcount of each pages is not 1 except
> head page. Below modification will fix your problem. Could you
> test it, please?

I just tested it, and confirm it fixes the regression.

You can add my:
Tested-by: Maxime Coquelin <mcoquelin.stm32@gmail.com>

Thanks for the quick fix!
Maxime

>
> Thanks.
>
> ------------>8-------------
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 28bd8c4..ff6c1e2 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1189,11 +1189,9 @@ static int do_mmap_private(struct vm_area_struct *vma,
>         if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages) {
>                 total = point;
>                 kdebug("try to alloc exact %lu pages", total);
> -               base = alloc_pages_exact(len, GFP_KERNEL);
> -       } else {
> -               base = (void *)__get_free_pages(GFP_KERNEL, order);
>         }
>
> +       base = alloc_pages_exact(total << PAGE_SHIFT, GFP_KERNEL);
>         if (!base)
>                 goto enomem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
