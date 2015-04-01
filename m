Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 34E336B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 12:14:09 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so72807978wia.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 09:14:08 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id hk4si4815698wib.4.2015.04.01.09.14.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 09:14:07 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so72807058wia.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 09:14:06 -0700 (PDT)
Date: Wed, 1 Apr 2015 18:13:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 1/3] mm: don't call __page_cache_release for hugetlb
Message-ID: <20150401161358.GA12808@dhcp22.suse.cz>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1427791840-11247-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427791840-11247-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 31-03-15 08:50:45, Naoya Horiguchi wrote:
> __put_compound_page() calls __page_cache_release() to do some freeing works,
> but it's obviously for thps, not for hugetlb. We didn't care it because PageLRU
> is always cleared and page->mem_cgroup is always NULL for hugetlb.
> But it's not correct and has potential risks, so let's make it conditional.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/swap.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git v4.0-rc6.orig/mm/swap.c v4.0-rc6/mm/swap.c
> index cd3a5e64cea9..8e46823c3319 100644
> --- v4.0-rc6.orig/mm/swap.c
> +++ v4.0-rc6/mm/swap.c
> @@ -31,6 +31,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/gfp.h>
>  #include <linux/uio.h>
> +#include <linux/hugetlb.h>
>  
>  #include "internal.h"
>  
> @@ -75,7 +76,14 @@ static void __put_compound_page(struct page *page)
>  {
>  	compound_page_dtor *dtor;
>  
> -	__page_cache_release(page);
> +	/*
> +	 * __page_cache_release() is supposed to be called for thp, not for
> +	 * hugetlb. This is because hugetlb page does never have PageLRU set
> +	 * (it's never listed to any LRU lists) and no memcg routines should
> +	 * be called for hugetlb (it has a separate hugetlb_cgroup.)
> +	 */
> +	if (!PageHuge(page))
> +		__page_cache_release(page);
>  	dtor = get_compound_page_dtor(page);
>  	(*dtor)(page);
>  }
> -- 
> 1.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
