Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 695486B0272
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:53:18 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so186081858pab.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:53:18 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id 69si6064633pfj.165.2016.09.22.22.53.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 22:53:17 -0700 (PDT)
Subject: Re: [PATCH v2 1/1] lib/ioremap.c: avoid endless loop under
 ioremapping page unaligned ranges
References: <57E20A69.5010206@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E4C33F.4080401@zoho.com>
Date: Fri, 23 Sep 2016 13:53:03 +0800
MIME-Version: 1.0
In-Reply-To: <57E20A69.5010206@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/21/2016 12:19 PM, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> endless loop maybe happen if either of parameter addr and end is not
> page aligned for kernel API function ioremap_page_range()
> 
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
>  
> @@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
>  	int err;
>  
>  	BUG_ON(addr >= end);
> +	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
>  
> +	addr = round_down(addr, PAGE_SIZE);
>  	start = addr;
>  	phys_addr -= addr;
>  	pgd = pgd_offset_k(addr);
>
From: zijun_hu <zijun_hu@htc.com>

s/WARN_ON()/WARN_ON_ONCE()/ to reduce warning messages

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 lib/ioremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 911bdca..974e88b 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -129,7 +129,7 @@ int ioremap_page_range(unsigned long addr,
 	int err;
 
 	BUG_ON(addr >= end);
-	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
+	WARN_ON_ONCE(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
 
 	addr = round_down(addr, PAGE_SIZE);
 	start = addr;
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
