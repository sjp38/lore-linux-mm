Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81FE46B0418
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 09:39:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i18so6204631wrb.21
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 06:39:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w191si3041616wme.142.2017.04.06.06.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 06:39:16 -0700 (PDT)
Date: Thu, 6 Apr 2017 15:39:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch for-4.11] mm, thp: fix setting of defer+madvise thp
 defrag mode
Message-ID: <20170406133901.GM5497@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704051814420.137626@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1704051814420.137626@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 05-04-17 18:17:42, David Rientjes wrote:
> Setting thp defrag mode of "defer+madvise" actually sets "defer" in the 
> kernel due to the name similarity and the out-of-order way the string is 
> checked in defrag_store().
> 
> Check the string in the correct order so that 
> TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG is set appropriately for 
> "defer+madvise".
> 
> Fixes: 21440d7eb904 ("mm, thp: add new defer+madvise defrag option") 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

I will just note that this wouldn't be necessary if you didn't ignore
the review feedback from Vlastimil [1].

[1] http://lkml.kernel.org/r/2099d74d-fa2c-e67e-b528-66598d072329@suse.cz

> ---
>  mm/huge_memory.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -240,18 +240,18 @@ static ssize_t defrag_store(struct kobject *kobj,
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
>  		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> -	} else if (!memcmp("defer", buf,
> -		    min(sizeof("defer")-1, count))) {
> -		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> -		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> -		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> -		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
>  	} else if (!memcmp("defer+madvise", buf,
>  		    min(sizeof("defer+madvise")-1, count))) {
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
>  		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +	} else if (!memcmp("defer", buf,
> +		    min(sizeof("defer")-1, count))) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags);
>  	} else if (!memcmp("madvise", buf,
>  			   min(sizeof("madvise")-1, count))) {
>  		clear_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
