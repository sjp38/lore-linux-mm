Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5E86B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:42:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z129so1400257wmb.23
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:42:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d32si11117657wma.84.2017.04.27.07.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 07:42:14 -0700 (PDT)
Date: Thu, 27 Apr 2017 16:42:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Silence vmap() allocation failures based on
 caller gfp_flags
Message-ID: <20170427144211.GL4706@dhcp22.suse.cz>
References: <20170425223332.6999-1-f.fainelli@gmail.com>
 <20170425223332.6999-4-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425223332.6999-4-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On Tue 25-04-17 15:33:29, Florian Fainelli wrote:
> If the caller has set __GFP_NOWARN don't print the following message:
> vmap allocation for size 15736832 failed: use vmalloc=<size> to increase
> size.
> 
> This can happen with the ARM/Linux module loader built with
> CONFIG_ARM_MODULE_PLTS=y which does a first attempt at loading a large
> module from module space, then falls back to vmalloc space.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0b057628a7ba..5a788eb58741 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -521,7 +521,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  		}
>  	}
>  
> -	if (printk_ratelimit())
> +	if (printk_ratelimit() && !(gfp_mask & __GFP_NOWARN))

Are you sure about this ordering? Should NOWARN requests alter the
ratelimit state?

>  		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
>  			size);
>  	kfree(va);
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
