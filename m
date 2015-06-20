Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 93B796B009C
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 02:55:42 -0400 (EDT)
Received: by wguu7 with SMTP id u7so32167346wgu.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 23:55:42 -0700 (PDT)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id c17si23909269wjx.3.2015.06.19.23.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 23:55:41 -0700 (PDT)
Received: by wgfq1 with SMTP id q1so57729789wgf.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 23:55:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434725914-14300-2-git-send-email-vladimir.murzin@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com> <1434725914-14300-2-git-send-email-vladimir.murzin@arm.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Sat, 20 Jun 2015 09:55:19 +0300
Message-ID: <CALq1K=J6ZKvBM5aqFGeE_hcZTrLxwuaP=N_8xb_no_LCjjTT9g@mail.gmail.com>
Subject: Re: [PATCH 1/3] memtest: use kstrtouint instead of simple_strtoul
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 19, 2015 at 5:58 PM, Vladimir Murzin
<vladimir.murzin@arm.com> wrote:
> Since simple_strtoul is obsolete and memtest_pattern is type of int, use
> kstrtouint instead.
>
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
> ---
>  mm/memtest.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memtest.c b/mm/memtest.c
> index 1997d93..895a43c 100644
> --- a/mm/memtest.c
> +++ b/mm/memtest.c
> @@ -88,14 +88,18 @@ static void __init do_one_pass(u64 pattern, phys_addr_t start, phys_addr_t end)
>  }
>
>  /* default is disabled */
> -static int memtest_pattern __initdata;
> +static unsigned int memtest_pattern __initdata;
>
>  static int __init parse_memtest(char *arg)
>  {
> -       if (arg)
> -               memtest_pattern = simple_strtoul(arg, NULL, 0);
> -       else
> -               memtest_pattern = ARRAY_SIZE(patterns);
> +       if (arg) {
> +               int err = kstrtouint(arg, 0, &memtest_pattern);
> +
> +               if (!err)
> +                       return 0;
kstrtouint returns 0 for success, in case of error you will fallback
and execute following line. It is definetely change of behaviour.
> +       }
> +
> +       memtest_pattern = ARRAY_SIZE(patterns);
>
>         return 0;
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
