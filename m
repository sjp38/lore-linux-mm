Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67C9D6B0409
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 06:26:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g19so5514321wrb.4
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 03:26:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si1939463wrm.255.2017.04.06.03.26.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 03:26:18 -0700 (PDT)
Subject: Re: [patch for-4.11] mm, thp: fix setting of defer+madvise thp defrag
 mode
References: <alpine.DEB.2.10.1704051814420.137626@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5a543cb5-c356-71e9-4424-bfbbf66b4d11@suse.cz>
Date: Thu, 6 Apr 2017 12:26:16 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1704051814420.137626@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/06/2017 03:17 AM, David Rientjes wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
