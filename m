Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0C77D6B009C
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 02:59:46 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so104405804wgb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 23:59:45 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id v10si23889543wja.89.2015.06.19.23.59.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 23:59:44 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so34880886wib.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 23:59:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434725914-14300-3-git-send-email-vladimir.murzin@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com> <1434725914-14300-3-git-send-email-vladimir.murzin@arm.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Sat, 20 Jun 2015 09:59:22 +0300
Message-ID: <CALq1K=KU5+s+u-py2oAh9U9iu3Z3yx9CbVNS8xNjpSd7o7639g@mail.gmail.com>
Subject: Re: [PATCH 2/3] memtest: cleanup log messages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 19, 2015 at 5:58 PM, Vladimir Murzin
<vladimir.murzin@arm.com> wrote:
> - prefer pr_info(...  to printk(KERN_INFO ...
> - use %pa for phys_addr_t
> - use cpu_to_be64 while printing pattern in reserve_bad_mem()
>
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
> ---
>  mm/memtest.c |   14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
>
> diff --git a/mm/memtest.c b/mm/memtest.c
> index 895a43c..ccaed3e 100644
> --- a/mm/memtest.c
> +++ b/mm/memtest.c
> @@ -31,10 +31,8 @@ static u64 patterns[] __initdata = {
>
>  static void __init reserve_bad_mem(u64 pattern, phys_addr_t start_bad, phys_addr_t end_bad)
>  {
> -       printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reserved\n",
> -              (unsigned long long) pattern,
> -              (unsigned long long) start_bad,
> -              (unsigned long long) end_bad);
> +       pr_info("%016llx bad mem addr %pa - %pa reserved\n",
> +               cpu_to_be64(pattern), &start_bad, &end_bad);
>         memblock_reserve(start_bad, end_bad - start_bad);
>  }
>
> @@ -78,10 +76,8 @@ static void __init do_one_pass(u64 pattern, phys_addr_t start, phys_addr_t end)
>                 this_start = clamp(this_start, start, end);
>                 this_end = clamp(this_end, start, end);
>                 if (this_start < this_end) {
> -                       printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
> -                              (unsigned long long)this_start,
> -                              (unsigned long long)this_end,
> -                              (unsigned long long)cpu_to_be64(pattern));
> +                       pr_info("  %pa - %pa pattern %016llx\n",
s/(" %pa/("%pa
> +                               &this_start, &this_end, cpu_to_be64(pattern));
>                         memtest(pattern, this_start, this_end - this_start);
>                 }
>         }
> @@ -114,7 +110,7 @@ void __init early_memtest(phys_addr_t start, phys_addr_t end)
>         if (!memtest_pattern)
>                 return;
>
> -       printk(KERN_INFO "early_memtest: # of tests: %d\n", memtest_pattern);
> +       pr_info("early_memtest: # of tests: %u\n", memtest_pattern);
>         for (i = memtest_pattern-1; i < UINT_MAX; --i) {
>                 idx = i % ARRAY_SIZE(patterns);
>                 do_one_pass(patterns[idx], start, end);
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
