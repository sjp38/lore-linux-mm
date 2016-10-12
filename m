Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8E8A6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:46:13 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id x79so29057253lff.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:46:13 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id h66si4888023lfd.146.2016.10.12.07.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 07:46:12 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id x23so1767048lfi.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:46:12 -0700 (PDT)
Date: Wed, 12 Oct 2016 16:46:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/vmalloc.c: correct logic errors when insert
 vmap_area
Message-ID: <20161012144610.GN17128@dhcp22.suse.cz>
References: <c2bd0f5d-8d2a-4cba-2663-5c075cd252f2@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2bd0f5d-8d2a-4cba-2663-5c075cd252f2@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, tj@kernel.org, sfr@canb.auug.org.au, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nicholas Piggin <npiggin@gmail.com>

[Let's CC Nick who has written this code]

On Wed 12-10-16 22:30:13, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> the KVA allocator organizes vmap_areas allocated by rbtree. in order to
> insert a new vmap_area @i_va into the rbtree, walk around the rbtree from
> root and compare the vmap_area @t_va met on the rbtree against @i_va; walk
> toward the left branch of @t_va if @i_va is lower than @t_va, and right
> branch if higher, otherwise handle this error case since @i_va has overlay
> with @t_va; however, __insert_vmap_area() don't follow the desired
> procedure rightly, moreover, it includes a meaningless else if condition
> and a redundant else branch as shown by comments in below code segments:
> static void __insert_vmap_area(struct vmap_area *va)
> {
> as a internal interface parameter, we assume vmap_area @va has nonzero size
> ...
> 			if (va->va_start < tmp->va_end)
> 					p = &(*p)->rb_left;
> 			else if (va->va_end > tmp->va_start)
> 					p = &(*p)->rb_right;
> this else if condition is always true and meaningless due to
> va->va_end > va->va_start >= tmp_va->va_end > tmp_va->va_start normally
> 			else
> 					BUG();
> this BUG() is meaningless too due to never be reached normally
> ...
> }
> 
> it looks like the else if condition and else branch are canceled. no errors
> are caused since the vmap_area @va to insert as a internal interface
> parameter doesn't have overlay with any one on the rbtree normally. however
>  __insert_vmap_area() looks weird and really has several logic errors as
> pointed out above when it is viewed as a separate function.

I have tried to read this several times but I am completely lost to
understand what the actual bug is and how it causes vmap_area sorting to
misbehave. So is this a correctness issue, performance improvement or
theoretical fix for an incorrect input?

> fix by walking around vmap_area rbtree as described above to insert
> a vmap_area.
> 
> BTW, (va->va_end == tmp_va->va_start) is consider as legal case since it
> indicates vmap_area @va left neighbors with @tmp_va tightly.
> 
> Fixes: db64fe02258f ("mm: rewrite vmap layer")
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
>  mm/vmalloc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 5daf3211b84f..8b80931654b7 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -321,10 +321,10 @@ static void __insert_vmap_area(struct vmap_area *va)
>  
>  		parent = *p;
>  		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
> -		if (va->va_start < tmp_va->va_end)
> -			p = &(*p)->rb_left;
> -		else if (va->va_end > tmp_va->va_start)
> -			p = &(*p)->rb_right;
> +		if (va->va_end <= tmp_va->va_start)
> +			p = &parent->rb_left;
> +		else if (va->va_start >= tmp_va->va_end)
> +			p = &parent->rb_right;
>  		else
>  			BUG();
>  	}
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
