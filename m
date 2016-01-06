Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A6D316B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 14:48:44 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so91214858wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 11:48:44 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id m205si14674077wma.21.2016.01.06.11.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 11:48:43 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id u188so72707487wmu.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 11:48:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
Date: Wed, 6 Jan 2016 22:48:43 +0300
Message-ID: <CAPAsAGxmjF-_ZZFwtaxZsXN9g7J2sn6O0L+pBiPdARsKC_644g@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: map KASAN zero page read only
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, mingo <mingo@kernel.org>

2016-01-06 18:54 GMT+03:00 Ard Biesheuvel <ard.biesheuvel@linaro.org>:
> The original x86_64-only version of KASAN mapped its zero page
> read-only, but this got lost when the code was generalised and
> ported to arm64, since, at the time, the PAGE_KERNEL_RO define
> did not exist. It has been added to arm64 in the mean time, so
> let's use it.
>

Read-only wasn't lost. Just look at the next line:
     zero_pte = pte_wrprotect(zero_pte);

PAGE_KERNEL_RO is not available on all architectures, thus it would be better
to not use it in generic code.


> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  mm/kasan/kasan_init.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index 3f9a41cf0ac6..8726a92604ad 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -49,7 +49,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
>         pte_t *pte = pte_offset_kernel(pmd, addr);
>         pte_t zero_pte;
>
> -       zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
> +       zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL_RO);
>         zero_pte = pte_wrprotect(zero_pte);
>
>         while (addr + PAGE_SIZE <= end) {
> --
> 2.5.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
