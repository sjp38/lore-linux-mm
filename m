Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21C6A6B0338
	for <linux-mm@kvack.org>; Wed, 24 May 2017 08:11:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so38030969wme.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:11:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h90si23843266edd.327.2017.05.24.05.11.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 05:11:38 -0700 (PDT)
Date: Wed, 24 May 2017 14:11:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in
 __insert_vmap_area()
Message-ID: <20170524121135.GF14733@dhcp22.suse.cz>
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524100347.8131-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 24-05-17 18:03:47, Wei Yang wrote:
> The vmap RB tree store the elements in order and no overlap between any of
> them. The comparison in __insert_vmap_area() is to decide which direction
> the search should follow and make sure the new vmap_area is not overlap
> with any other.
> 
> Current implementation fails to do the overlap check.
> 
> When first "if" is not true, it means
> 
>     va->va_start >= tmp_va->va_end
> 
> And with the truth
> 
>     xxx->va_end > xxx->va_start
> 
> The deduction is
> 
>     va->va_end > tmp_va->va_start
> 
> which is the condition in second "if".
> 
> This patch changes a little of the comparison in __insert_vmap_area() to
> make sure it forbids the overlapped vmap_area.

Why do we care about overlapping vmap areas at this level. This is an
internal function and all the sanity checks should have been done by
that time AFAIR. Could you describe the problem which you are trying to
fix/address?

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/vmalloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 0b057628a7ba..8087451cb332 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -360,9 +360,9 @@ static void __insert_vmap_area(struct vmap_area *va)
>  
>  		parent = *p;
>  		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
> -		if (va->va_start < tmp_va->va_end)
> +		if (va->va_end <= tmp_va->va_start)
>  			p = &(*p)->rb_left;
> -		else if (va->va_end > tmp_va->va_start)
> +		else if (va->va_start >= tmp_va->va_end)
>  			p = &(*p)->rb_right;
>  		else
>  			BUG();
> -- 
> 2.11.0
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
