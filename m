Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 57B8E6B0071
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 07:54:42 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so7850650lbd.6
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 04:54:41 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id d2si32845264lbv.18.2014.10.08.04.54.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 04:54:40 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so7843038lbd.20
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 04:54:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
Date: Wed, 8 Oct 2014 13:54:40 +0200
Message-ID: <CAMuHMdUDxemAOsE1E1Ba3zjhtMSp-k=n4_YxRJ2k_C_kZdBr=Q@mail.gmail.com>
Subject: Re: [PATCH resend] arm:extend the reserved memory for initrd to be
 page aligned
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Catalin Marinas <Catalin.Marinas@arm.com>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

On Fri, Sep 19, 2014 at 9:09 AM, Wang, Yalin <Yalin.Wang@sonymobile.com> wrote:
> this patch extend the start and end address of initrd to be page aligned,
> so that we can free all memory including the un-page aligned head or tail
> page of initrd, if the start or end address of initrd are not page
> aligned, the page can't be freed by free_initrd_mem() function.
>
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/mm/init.c   | 5 +++++
>  arch/arm64/mm/init.c | 8 +++++++-
>  2 files changed, 12 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 659c75d..9221645 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -636,6 +636,11 @@ static int keep_initrd;
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {
>         if (!keep_initrd) {
> +               if (start == initrd_start)
> +                       start = round_down(start, PAGE_SIZE);
> +               if (end == initrd_end)
> +                       end = round_up(end, PAGE_SIZE);
> +
>                 poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
>                 free_reserved_area((void *)start, (void *)end, -1, "initrd");
>         }

Who guarantees there's no valuable data in [start, initrd_start)
and [initrd_end, end) being corrupted?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
