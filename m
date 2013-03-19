Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3C03D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:47:42 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id c12so123254ieb.20
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:47:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 18 Mar 2013 22:47:41 -0700
Message-ID: <CAE9FiQWXYGdAp82HE8Jg=HYdxWa5nPC5g63E6rNNwYyAQ-B5tg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm, nobootmem: fix wrong usage of max_low_pfn
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

On Mon, Mar 18, 2013 at 10:15 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> max_low_pfn reflect the number of _pages_ in the system,
> not the maximum PFN. You can easily find that fact in init_bootmem().
> So fix it.

I'm confused. for x86, we have max_low_pfn defined in ...

#ifdef CONFIG_X86_32
        /* max_low_pfn get updated here */
        find_low_pfn_range();
#else
        num_physpages = max_pfn;

        check_x2apic();

        /* How many end-of-memory variables you have, grandma! */
        /* need this before calling reserve_initrd */
        if (max_pfn > (1UL<<(32 - PAGE_SHIFT)))
                max_low_pfn = e820_end_of_low_ram_pfn();
        else
                max_low_pfn = max_pfn;

and under max_low_pfn is bootmem.

>
> Additionally, if 'start_pfn == end_pfn', we don't need to go futher,
> so change range check.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 5e07d36..4711e91 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -110,9 +110,9 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
>  {
>         unsigned long start_pfn = PFN_UP(start);
>         unsigned long end_pfn = min_t(unsigned long,
> -                                     PFN_DOWN(end), max_low_pfn);
> +                                     PFN_DOWN(end), min_low_pfn);

what is min_low_pfn ?  is it 0 for x86?

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
