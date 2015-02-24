Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id B33AE6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:55:10 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id f12so29181275qad.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:55:10 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id u123si32025728qhd.31.2015.02.24.12.55.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 12:55:09 -0800 (PST)
Received: by mail-qg0-f49.google.com with SMTP id q107so32239513qgd.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:55:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com>
References: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Tue, 24 Feb 2015 12:54:38 -0800
Message-ID: <CADtm3G6UcuLmESz+dFmeMfLfJ=SWwkAiHLUHHKxvmjYTvwZRog@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: fix CMA aligned offset calculation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Danesh Petigara <dpetigara@broadcom.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

[removed stable from cc]

On Tue, Feb 24, 2015 at 11:55 AM, Danesh Petigara
<dpetigara@broadcom.com> wrote:
> diff --git a/mm/cma.c b/mm/cma.c
> index 75016fd..58f37bd 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -70,9 +70,13 @@ static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
>
>         if (align_order <= cma->order_per_bit)
>                 return 0;
> -       alignment = 1UL << (align_order - cma->order_per_bit);
> -       return ALIGN(cma->base_pfn, alignment) -
> -               (cma->base_pfn >> cma->order_per_bit);
> +
> +       /*
> +        * Find a PFN aligned to the specified order and return
> +        * an offset represented in order_per_bits.
> +        */
> +       return (ALIGN(cma->base_pfn, (1UL << align_order))
> +               - cma->base_pfn) >> cma->order_per_bit;

It was noticed that this doesn't remove the now-unused 'alignment'
variable, so I think Danesh is planning to submit an updated patch.

Best regards,
Gregory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
