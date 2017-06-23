Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9C26B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:24:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so12765330wrc.7
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:24:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m131si3863758wmb.140.2017.06.23.06.24.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 06:24:39 -0700 (PDT)
Date: Fri, 23 Jun 2017 15:24:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch for-4.12] mm, thp: remove cond_resched from
 __collapse_huge_page_copy
Message-ID: <20170623132436.GA5314@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706191341550.97821@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706191341550.97821@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Larry Finger <Larry.Finger@lwfinger.net>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 19-06-17 13:43:11, David Rientjes wrote:
> This is a partial revert of commit 338a16ba1549 ("mm, thp: copying user
> pages must schedule on collapse") which added a cond_resched() to
> __collapse_huge_page_copy().
> 
> On x86 with CONFIG_HIGHPTE, __collapse_huge_page_copy is called in atomic
> context and thus scheduling is not possible.  This is only a possible
> config on arm and i386.
> 
> Although need_resched has been shown to be set for over 100 jiffies while
> doing the iteration in __collapse_huge_page_copy, this is better than
> doing
> 
> 	if (in_atomic())
> 		cond_resched()
> 
> to cover only non-CONFIG_HIGHPTE configs.
> 
> Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Note: Larry should be back as of June 17 to test if this fixes the
>  reported issue.
> 
>  mm/khugepaged.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -652,7 +652,6 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  			spin_unlock(ptl);
>  			free_page_and_swap_cache(src_page);
>  		}
> -		cond_resched();
>  	}
>  }
>  
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
