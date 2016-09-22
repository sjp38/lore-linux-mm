Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCB76B026D
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 21:36:20 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id t67so140760750ywg.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 18:36:20 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id f126si30285849qke.149.2016.09.21.18.36.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 18:36:19 -0700 (PDT)
Subject: Re: [RFC PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
References: <57E20B54.5020408@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E33581.5030409@zoho.com>
Date: Thu, 22 Sep 2016 09:36:01 +0800
MIME-Version: 1.0
In-Reply-To: <57E20B54.5020408@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/21/2016 12:23 PM, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> correct a few logic error for __insert_vmap_area() since the else
> if condition is always true and meaningless
> 
> in order to fix this issue, if vmap_area inserted is lower than one
> on rbtree then walk around left branch; if higher then right branch
> otherwise intersects with the other then BUG_ON() is triggered
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
i give more explanation to the intent of my change
any comments is welcome
> ---
>  mm/vmalloc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 91f44e7..cc6ecd6 100644
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
this else if condition is always true and meaningless as long as there are no
zero sized vamp_area due to the following expression
va->va_end > va->va_start >= tmp_va->va_end > tmp_va->va_start

> +		if (va->va_end <= tmp_va->va_start)
> +			p = &parent->rb_left;
if the vamp_area to be inserted is lower than that on the rbtree then
we walk around the left branch of the node given
consider va->va_end == tmp_va->va_start as legal case which represent
two neighbor areas tightly
BTW, the available range of a vmap area include the start boundary not the
end, namely, [start, end)
> +		else if (va->va_start >= tmp_va->va_end)
> +			p = &parent->rb_right;
if the vamp_area to be inserted is higher than that on the rbtree then
we walk around the right branch of the node given
>  		else
>  			BUG();
this indicate the vamp_area to be inserted have intersects with that on the rbtree
then we remain the BUG() logic
>  	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
