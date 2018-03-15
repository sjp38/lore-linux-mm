Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D84286B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 14:30:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j8so3616314pfh.13
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:30:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v23-v6si4444768plo.276.2018.03.15.11.30.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 11:30:34 -0700 (PDT)
Date: Thu, 15 Mar 2018 19:30:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/thp: Do not wait for lock_page() in
 deferred_split_scan()
Message-ID: <20180315183031.GS23100@dhcp22.suse.cz>
References: <20180315150747.31945-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180315150747.31945-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Eric Wheeler <linux-mm@lists.ewheeler.net>

On Thu 15-03-18 18:07:47, Kirill A. Shutemov wrote:
> deferred_split_scan() gets called from reclaim path. Waiting for page
> lock may lead to deadlock there.
> 
> Replace lock_page() with trylock_page() and skip the page if we failed
> to lock it. We will get to the page on the next scan.
> 

Fixes: 9a982250f773 ("thp: introduce deferred_split_huge_page()")
and maybe even Cc: stable as this can lead to deadlocks AFAICS.

Btw. other THP shrinker does suffer from the same problem and a deadlock
has been reported[1]. Thanks for Tetsuo to point that out [2].

[1] http://lkml.kernel.org/r/alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net
[2] http://lkml.kernel.org/r/04bbbd39-a1c0-b84b-28a2-0a3876be1054@i-love.sakura.ne.jp

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Anyway feel free to add 
Acked-by: Michal Hocko <mhocko@suse.com>
to this patch but a deeper audit is due I suspect

> ---
>  mm/huge_memory.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 87ab9b8f56b5..529cf36b7edb 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2783,11 +2783,13 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  
>  	list_for_each_safe(pos, next, &list) {
>  		page = list_entry((void *)pos, struct page, mapping);
> -		lock_page(page);
> +		if (!trylock_page(page))
> +			goto next;
>  		/* split_huge_page() removes page from list on success */
>  		if (!split_huge_page(page))
>  			split++;
>  		unlock_page(page);
> +next:
>  		put_page(page);
>  	}
>  
> -- 
> 2.16.1

-- 
Michal Hocko
SUSE Labs
