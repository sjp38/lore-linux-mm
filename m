Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 882D4C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:44:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 318D22339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:44:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="luGclcN1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 318D22339D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5699C6B0003; Wed,  4 Sep 2019 09:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A9B6B0006; Wed,  4 Sep 2019 09:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4080C6B0007; Wed,  4 Sep 2019 09:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id 1B34D6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:44:51 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9110D181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:44:50 +0000 (UTC)
X-FDA: 75897358740.16.star42_646be428c1a0a
X-HE-Tag: star42_646be428c1a0a
X-Filterd-Recvd-Size: 7067
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:44:49 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id s12so6282167pfe.6
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 06:44:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W721XQEkMG8bC4j2PepgMeY0jTQOErIpXztyfiJXOs8=;
        b=luGclcN1dcSuuNyjEd4iVSQhaZ7/plNnDTMPxi9rQNhfhWvSUm52SKtinf2rFBYvXv
         WkUY7zrmOKflAgtEFgIlDdwxNSqASf+eYZIMIOZno6R0+F2WyGjFJAgjSZ4QIsynr/s2
         ODnVlH9pQ8nvqktBpgfoOyAIHBEzgNZe6LLo0mlO0LIalIP8unm77acWwKiMIholXtcx
         rd0SUmY8p+MkPEaF4kb8sFqd7nNFprQXHr3npmQIDeaSJ+orCGo3gH4fjy6lV6eRrABT
         5nNtXJDgdAgHI4Yz0CI2RrNJFbyLrMht5vS5C2Qv1NthNoz3ozyI4WZorI/8tpI2Ehs9
         flxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=W721XQEkMG8bC4j2PepgMeY0jTQOErIpXztyfiJXOs8=;
        b=F6vsvrY7nrZNSSxBRSTVOdN+aVy6/y7gJcNoEwEhsD0zgSsCIkrw1A5MRW4dyPJhZ8
         k1xVqsJwhrnFLrKNm+kIQ4bvWfgLRKtv4NmToYjAgDfZPSaQVzynle3UkVitACeLUEv1
         YZqgOPDZmqGeQDN8IVgumidN4rYW7bZsbPsQYVhjYQZ6lENSe7scq8RXXoXUWO2YXx9q
         GoUpGkVMwf87VqQhduL6IISCh3Hw3KHPlDteHzOMWLLvtXtsSpg4yPnMDKzjKLqcK8gY
         EdyjmvSP12FTJlGEwoQAu90DClbNl4X+RYSJgOVw2br9rCse+ADOyBC+Wz1nez0Y9BV6
         cgtw==
X-Gm-Message-State: APjAAAVEQjJsdln+/UhNiLocSaE5ikC69sRkBHejXVy9BEE2kRoPG4+C
	XOBq0FLvNMy74DVrdAUUQnEPEs62rphSb/WLX/c+PA==
X-Google-Smtp-Source: APXvYqzCww2lW0PtxSg3odpkkA5VJF/XxD5kKaqrmZ1KDA7CF0CBSRDpFDrvufwyLOctz33+u6vqBpksBAlWIGv+72Q=
X-Received: by 2002:a17:90a:ff08:: with SMTP id ce8mr4950627pjb.123.1567604688325;
 Wed, 04 Sep 2019 06:44:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
In-Reply-To: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 4 Sep 2019 15:44:37 +0200
Message-ID: <CAAeHK+wyvLF8=DdEczHLzNXuP+oC0CEhoPmp_LHSKVNyAiRGLQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-mediatek@lists.infradead.org, 
	wsd_upstream@mediatek.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 8:51 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>
> This patch is KASAN report adds the alloc/free stacks for page allocator
> in order to help programmer to see memory corruption caused by page.
>
> By default, KASAN doesn't record alloc/free stack for page allocator.
> It is difficult to fix up page use-after-free issue.
>
> This feature depends on page owner to record the last stack of pages.
> It is very helpful for solving the page use-after-free or out-of-bound.
>
> KASAN report will show the last stack of page, it may be:
> a) If page is in-use state, then it prints alloc stack.
>    It is useful to fix up page out-of-bound issue.
>
> BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x90
> Write of size 1 at addr ffffffc0d64ea00a by task cat/115
> ...
> Allocation stack of page:
>  prep_new_page+0x1a0/0x1d8
>  get_page_from_freelist+0xd78/0x2748
>  __alloc_pages_nodemask+0x1d4/0x1978
>  kmalloc_order+0x28/0x58
>  kmalloc_order_trace+0x28/0xe0
>  kmalloc_pagealloc_oob_right+0x2c/0x90
>
> b) If page is freed state, then it prints free stack.
>    It is useful to fix up page use-after-free issue.
>
> BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
> Write of size 1 at addr ffffffc0d651c000 by task cat/115
> ...
> Free stack of page:
>  kasan_free_pages+0x68/0x70
>  __free_pages_ok+0x3c0/0x1328
>  __free_pages+0x50/0x78
>  kfree+0x1c4/0x250
>  kmalloc_pagealloc_uaf+0x38/0x80
>
>
> This has been discussed, please refer below link.
> https://bugzilla.kernel.org/show_bug.cgi?id=203967
>
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> ---
>  lib/Kconfig.kasan | 9 +++++++++
>  mm/kasan/common.c | 6 ++++++
>  2 files changed, 15 insertions(+)
>
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 4fafba1a923b..ba17f706b5f8 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -135,6 +135,15 @@ config KASAN_S390_4_LEVEL_PAGING
>           to 3TB of RAM with KASan enabled). This options allows to force
>           4-level paging instead.
>
> +config KASAN_DUMP_PAGE
> +       bool "Dump the page last stack information"
> +       depends on KASAN && PAGE_OWNER
> +       help
> +         By default, KASAN doesn't record alloc/free stack for page allocator.
> +         It is difficult to fix up page use-after-free issue.
> +         This feature depends on page owner to record the last stack of page.
> +         It is very helpful for solving the page use-after-free or out-of-bound.

I'm not sure if we need a separate config for this. Is there any
reason to not have this enabled by default?

> +
>  config TEST_KASAN
>         tristate "Module for testing KASAN for bug detection"
>         depends on m && KASAN
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 2277b82902d8..2a32474efa74 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -35,6 +35,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/bug.h>
>  #include <linux/uaccess.h>
> +#include <linux/page_owner.h>
>
>  #include "kasan.h"
>  #include "../slab.h"
> @@ -227,6 +228,11 @@ void kasan_alloc_pages(struct page *page, unsigned int order)
>
>  void kasan_free_pages(struct page *page, unsigned int order)
>  {
> +#ifdef CONFIG_KASAN_DUMP_PAGE
> +       gfp_t gfp_flags = GFP_KERNEL;
> +
> +       set_page_owner(page, order, gfp_flags);
> +#endif
>         if (likely(!PageHighMem(page)))
>                 kasan_poison_shadow(page_address(page),
>                                 PAGE_SIZE << order,
> --
> 2.18.0
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190904065133.20268-1-walter-zh.wu%40mediatek.com.

