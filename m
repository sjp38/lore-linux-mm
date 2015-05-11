Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAA66B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 06:55:29 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so143638746pdb.2
        for <linux-mm@kvack.org>; Mon, 11 May 2015 03:55:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f6si10378773pds.59.2015.05.11.03.55.28
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 03:55:28 -0700 (PDT)
Date: Mon, 11 May 2015 11:55:24 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: record accurate early log buffer count and
 report when exceeded
Message-ID: <20150511105524.GD18655@e104818-lin.cambridge.arm.com>
References: <1431335021-117825-1-git-send-email-morgan.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431335021-117825-1-git-send-email-morgan.wang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Kai <morgan.wang@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, May 11, 2015 at 10:03:41AM +0100, Wang Kai wrote:
> In log_early function, crt_early_log should also count once when
> 'crt_early_log >= ARRAY_SIZE(early_log)'. Otherwise the reported
> count from kmemleak_init is one less than 'actual number'.
> 
> Then, in kmemleak_init, if early_log buffer size equal actual
> number, kmemleak will init sucessful, so change warning condition
> to 'crt_early_log > ARRAY_SIZE(early_log)'.
> 
> Signed-off-by: Wang Kai <morgan.wang@huawei.com>
> ---
>  mm/kmemleak.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 5405aff..6a07748 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -814,6 +814,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
>  	}
>  
>  	if (crt_early_log >= ARRAY_SIZE(early_log)) {
> +		crt_early_log++;
>  		kmemleak_disable();
>  		return;
>  	}
> @@ -1829,7 +1830,7 @@ void __init kmemleak_init(void)
>  	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
>  	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
>  
> -	if (crt_early_log >= ARRAY_SIZE(early_log))
> +	if (crt_early_log > ARRAY_SIZE(early_log))
>  		pr_warning("Early log buffer exceeded (%d), please increase "
>  			   "DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n", crt_early_log);

It looks fine:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks (I assume akpm will pick it up, otherwise I'll send it during the
next merging window; it's not critical)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
