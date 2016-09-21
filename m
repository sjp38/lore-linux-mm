Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7638A6B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:05:22 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n185so90690524qke.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:05:22 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id m123si21479952qkf.103.2016.09.20.22.05.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 22:05:21 -0700 (PDT)
Subject: Re: [PATCH 2/3] lib/ioremap.c: avoid endless loop under ioremapping
 improper ranges
References: <57E0CE04.2070605@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E214DA.4020304@zoho.com>
Date: Wed, 21 Sep 2016 13:04:26 +0800
MIME-Version: 1.0
In-Reply-To: <57E0CE04.2070605@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/20/2016 01:49 PM, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> for ioremap_page_range(), endless loop maybe happen if either of parameter
> addr and end is not page aligned, in order to fix this issue and hint range
> parameter requirements BUG_ON() checkup are performed firstly
> 
> for ioremap_pte_range(), loop end condition is optimized due to lack of
> relevant macro pte_addr_end()
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
>  lib/ioremap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 86c8911..0058cc8 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
>  		BUG_ON(!pte_none(*pte));
>  		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
>  		pfn++;
> -	} while (pte++, addr += PAGE_SIZE, addr != end);
> +	} while (pte++, addr += PAGE_SIZE, addr < end);
>  	return 0;
>  }
>  
> @@ -129,6 +129,7 @@ int ioremap_page_range(unsigned long addr,
>  	int err;
>  
>  	BUG_ON(addr >= end);
> +	BUG_ON(!PAGE_ALIGNED(addr | end));
>  
>  	start = addr;
>  	phys_addr -= addr;
> 
another approach is provided in another mail thread as below
i don't known which is more appropriate

From: zijun_hu <zijun_hu@htc.com>
Subject: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping page
unaligned ranges

endless loop maybe happen if either of parameter addr and end is not
page aligned for kernel API function ioremap_page_range()

in order to fix this issue and alert improper range parameters to user
WARN_ON() checkup and rounding down range lower boundary are performed
firstly, loop end condition within ioremap_pte_range() is optimized due
to lack of relevant macro pte_addr_end()

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 lib/ioremap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..911bdca 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
 		pfn++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
 	return 0;
 }
 
@@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
 	int err;
 
 	BUG_ON(addr >= end);
+	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
 
+	addr = round_down(addr, PAGE_SIZE);
 	start = addr;
 	phys_addr -= addr;
 	pgd = pgd_offset_k(addr);
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
