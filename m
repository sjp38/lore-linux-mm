Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA616B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:28:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x64so105873827pgd.6
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:28:16 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0127.outbound.protection.outlook.com. [104.47.2.127])
        by mx.google.com with ESMTPS id z84si10155031pfk.178.2017.05.15.01.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 May 2017 01:28:15 -0700 (PDT)
Subject: Re: [PATCH] mm/kasan: use kasan_zero_pud for p4d table
References: <1494829255-23946-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <60aff3a2-35d5-53f4-65eb-f28d577dab55@virtuozzo.com>
Date: Mon, 15 May 2017 11:29:57 +0300
MIME-Version: 1.0
In-Reply-To: <1494829255-23946-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/15/2017 09:20 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There is missing optimization in zero_p4d_populate() that can save
> some memory when mapping zero shadow. Implement it like as others.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


> ---
>  mm/kasan/kasan_init.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index b96a5f7..554e4c0 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -118,6 +118,18 @@ static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
>  
>  	do {
>  		next = p4d_addr_end(addr, end);
> +		if (IS_ALIGNED(addr, P4D_SIZE) && end - addr >= P4D_SIZE) {
> +			pud_t *pud;
> +			pmd_t *pmd;
> +
> +			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
> +			pud = pud_offset(p4d, addr);
> +			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
> +			pmd = pmd_offset(pud, addr);
> +			pmd_populate_kernel(&init_mm, pmd,
> +						lm_alias(kasan_zero_pte));
> +			continue;
> +		}
>  
>  		if (p4d_none(*p4d)) {
>  			p4d_populate(&init_mm, p4d,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
