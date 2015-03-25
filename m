Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C2AB16B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 21:01:48 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so10712912pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:01:48 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id l1si1165209pdm.154.2015.03.24.18.01.46
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 18:01:47 -0700 (PDT)
Message-ID: <551208F8.4020706@lge.com>
Date: Wed, 25 Mar 2015 10:01:44 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space
 caused by vm_map_ram allocator
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com> <1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
In-Reply-To: <1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

> 
> In current patch I simply put newly allocated block to the tail of a free list,
> thus reduce fragmentation, giving a chance to resolve allocation request using
> older blocks with possible holes left.

It's great.
I think this might be helpful for fragmentation by mix of long-time, short-time mappings.
I do thank you for your work.

> 
> Signed-off-by: Roman Pen <r.peniaev@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: WANG Chao <chaowang@redhat.com>
> Cc: Fabian Frederick <fabf@skynet.be>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Gioh Kim <gioh.kim@lge.com>
> Cc: Rob Jones <rob.jones@codethink.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> ---
>   mm/vmalloc.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 39c3388..db6bffb 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -837,7 +837,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>   
>   	vbq = &get_cpu_var(vmap_block_queue);
>   	spin_lock(&vbq->lock);
> -	list_add_rcu(&vb->free_list, &vbq->free);
> +	list_add_tail_rcu(&vb->free_list, &vbq->free);
>   	spin_unlock(&vbq->lock);
>   	put_cpu_var(vmap_block_queue);
>   
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
