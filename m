Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD376B0259
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:01:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so25723931wmw.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:01:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pj7si25383515wjb.131.2015.11.13.04.01.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 04:01:19 -0800 (PST)
Subject: Re: [PATCH] mm: change may_enter_fs check condition
References: <1447415255-832-1-git-send-email-yalin.wang2010@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5645D10C.701@suse.cz>
Date: Fri, 13 Nov 2015 13:01:16 +0100
MIME-Version: 1.0
In-Reply-To: <1447415255-832-1-git-send-email-yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, hannes@cmpxchg.org, mgorman@techsingularity.net, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/13/2015 12:47 PM, yalin wang wrote:
> Add page_is_file_cache() for __GFP_FS check,
> otherwise, a Pageswapcache() && PageDirty() page can always be write
> back if the gfp flag is __GFP_FS, this is not the expected behavior.

I'm not sure I understand your point correctly *), but you seem to imply 
that there would be an allocation that has __GFP_FS but doesn't have 
__GFP_IO? Are there such allocations and does it make sense?

*) It helps to state which problem you actually observed and are trying 
to fix. Or was this found by code inspection? In that case describe the 
theoretical problem, as "expected behavior" isn't always understood by 
everyone the same.

> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>   mm/vmscan.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bd2918e..f8fc8c1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -930,7 +930,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   		if (page_mapped(page) || PageSwapCache(page))
>   			sc->nr_scanned++;
>
> -		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> +		may_enter_fs = (page_is_file_cache(page) && (sc->gfp_mask & __GFP_FS)) ||
>   			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
>
>   		/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
