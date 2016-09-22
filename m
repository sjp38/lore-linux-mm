Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37C6F280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:47:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so70535624wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:47:39 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id x129si7593919wmg.113.2016.09.22.05.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 05:47:38 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l132so13866085wmf.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:47:38 -0700 (PDT)
Date: Thu, 22 Sep 2016 14:47:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160922124735.GB11204@dhcp22.suse.cz>
References: <57E20A69.5010206@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E20A69.5010206@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Wed 21-09-16 12:19:53, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> endless loop maybe happen if either of parameter addr and end is not
> page aligned for kernel API function ioremap_page_range()

Does this happen in practise or this you found it by reading the code?

> in order to fix this issue and alert improper range parameters to user
> WARN_ON() checkup and rounding down range lower boundary are performed
> firstly, loop end condition within ioremap_pte_range() is optimized due
> to lack of relevant macro pte_addr_end()
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
>  lib/ioremap.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 86c8911..911bdca 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
>  		BUG_ON(!pte_none(*pte));
>  		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
>  		pfn++;
> -	} while (pte++, addr += PAGE_SIZE, addr != end);
> +	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
>  	return 0;
>  }

Ble, this just overcomplicate things. Can we just make sure that the
proper alignment is done in ioremap_page_range which is the only caller
of this (and add VM_BUG_ON in ioremap_pud_range to make sure no new
caller will forget about that).

>  
> @@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
>  	int err;
>  
>  	BUG_ON(addr >= end);
> +	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));

maybe WARN_ON_ONCE would be sufficient to prevent from swamping logs if
something just happens to do this too often in some pathological path.

>  
> +	addr = round_down(addr, PAGE_SIZE);

	end = round_up(end, PAGE_SIZE);

wouldn't work?

>  	start = addr;
>  	phys_addr -= addr;
>  	pgd = pgd_offset_k(addr);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
