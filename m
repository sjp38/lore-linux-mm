Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE946B0071
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:06:55 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so4409333yhz.27
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:06:55 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id p5si15113462yho.9.2013.12.10.13.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 13:06:54 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id ar20so9628940iec.2
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:06:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52A6D9B0.7040506@huawei.com>
References: <52A6D9B0.7040506@huawei.com>
Date: Tue, 10 Dec 2013 13:06:53 -0800
Message-ID: <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Tue, Dec 10, 2013 at 1:06 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> In the following case, e820_all_mapped() will return 1.
> A < start < B-1 and B < end < C, it means <start, end> spans two regions.
> <start, end>:           [start - end]
> e820 addr:          ...[A - B-1][B - C]...

should be [start, end) right?
and
[A, B),[B, C)

>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  arch/x86/kernel/e820.c |   15 +++------------
>  1 files changed, 3 insertions(+), 12 deletions(-)
>
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index 174da5f..31ecab2 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -85,20 +85,11 @@ int __init e820_all_mapped(u64 start, u64 end, unsigned type)
>
>                 if (type && ei->type != type)
>                         continue;
> -               /* is the region (part) in overlap with the current region ?*/
> +               /* is the region (part) in overlap with the current region ? */
>                 if (ei->addr >= end || ei->addr + ei->size <= start)
>                         continue;
> -
> -               /* if the region is at the beginning of <start,end> we move
> -                * start to the end of the region since it's ok until there
> -                */
> -               if (ei->addr <= start)
> -                       start = ei->addr + ei->size;

so in your case new start will be B ?

next run will be C

> -               /*
> -                * if start is now at or beyond end, we're done, full
> -                * coverage
> -                */
> -               if (start >= end)


> +               /* is the region full coverage of <start, end> ? */
> +               if (ei->addr <= start && ei->addr + ei->size >= end)
>                         return 1;
>         }
>         return 0;

also e820 should be sanitized already to have [A,C).

or you are talking about [A,B), [B+1, C)
first run start will be B,  and next run with [B+1, ...), that will be
skipped...
will not return 1.

so old code should be ok.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
