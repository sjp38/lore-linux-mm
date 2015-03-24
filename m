Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EE6526B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:00:56 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so6607691pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:00:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ue8si699402pbc.96.2015.03.24.15.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:00:56 -0700 (PDT)
Date: Tue, 24 Mar 2015 15:00:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2 1/3] mm/vmalloc: fix possible exhaustion of vmalloc
 space caused by vm_map_ram allocator
Message-Id: <20150324150054.a9050b7814860790e1d9b0d0@linux-foundation.org>
In-Reply-To: <1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
	<1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, 19 Mar 2015 23:04:39 +0900 Roman Pen <r.peniaev@gmail.com> wrote:

> If suitable block can't be found, new block is allocated and put into a head
> of a free list, so on next iteration this new block will be found first.
> 
> ...
>
> Cc: stable@vger.kernel.org
>
> ...
>
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -837,7 +837,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>  
>  	vbq = &get_cpu_var(vmap_block_queue);
>  	spin_lock(&vbq->lock);
> -	list_add_rcu(&vb->free_list, &vbq->free);
> +	list_add_tail_rcu(&vb->free_list, &vbq->free);
>  	spin_unlock(&vbq->lock);
>  	put_cpu_var(vmap_block_queue);
>  

I'm not sure about the cc:stable here.  There is potential for
unexpected side-effects and I don't *think* people are hurting from
this issue in real life.  Or maybe I'm wrong about that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
