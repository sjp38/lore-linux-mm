Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68EC36B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:56:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b6so3722143wra.16
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:56:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e25si3562823wra.213.2017.04.27.10.56.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 10:56:58 -0700 (PDT)
Date: Thu, 27 Apr 2017 19:56:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: Silence vmap() allocation failures based on
 caller gfp_flags
Message-ID: <20170427175653.GB30672@dhcp22.suse.cz>
References: <20170427173900.2538-1-f.fainelli@gmail.com>
 <20170427173900.2538-2-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170427173900.2538-2-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On Thu 27-04-17 10:38:58, Florian Fainelli wrote:
> If the caller has set __GFP_NOWARN don't print the following message:
> vmap allocation for size 15736832 failed: use vmalloc=<size> to increase
> size.
> 
> This can happen with the ARM/Linux or ARM64/Linux module loader built
> with CONFIG_ARM{,64}_MODULE_PLTS=y which does a first attempt at loading
> a large module from module space, then falls back to vmalloc space.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

just a nit

> ---
>  mm/vmalloc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0b057628a7ba..d8a851634674 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -521,9 +521,13 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  		}
>  	}
>  
> +	if (gfp_mask & __GFP_NOWARN)
> +		goto out;
> +
>  	if (printk_ratelimit())

	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
>  		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
>  			size);

would be shorter and you wouldn't need the goto and a label.

> +out:
>  	kfree(va);
>  	return ERR_PTR(-EBUSY);
>  }
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
