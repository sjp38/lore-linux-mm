Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C79416B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 23:06:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p86so214270131pfl.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 20:06:40 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id j1si26130545pld.54.2017.05.24.20.06.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 20:06:39 -0700 (PDT)
Message-ID: <592649CC.8090702@huawei.com>
Date: Thu, 25 May 2017 11:04:44 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in __insert_vmap_area()
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
In-Reply-To: <20170524100347.8131-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I hit the overlap issue, but it  is hard to reproduced. if you think it is safe. and the situation
is not happen. AFAIC, it is no need to add the code.

if you insist on the point. Maybe VM_WARN_ON is a choice.

Regards
zhongjiang
On 2017/5/24 18:03, Wei Yang wrote:
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
>
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
