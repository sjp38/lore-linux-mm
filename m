Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86E40800E4
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 17:50:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b193so1119265wmd.7
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 14:50:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b47si944566wra.526.2018.01.23.14.50.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 14:50:40 -0800 (PST)
Date: Tue, 23 Jan 2018 14:50:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/slub.c: Fix wrong address during slab padding
 restoration
Message-Id: <20180123145026.b7ca0a338cd0f2de2787b9c1@linux-foundation.org>
In-Reply-To: <1516604578-4577-1-git-send-email-balasubramani_vivekanandan@mentor.com>
References: <1516604578-4577-1-git-send-email-balasubramani_vivekanandan@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
Cc: linux-mm@kvack.org

On Mon, 22 Jan 2018 12:32:58 +0530 Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com> wrote:

> From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
> 
> Start address calculated for slab padding restoration was wrong.
> Wrong address would point to some section before padding and
> could cause corruption
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -838,6 +838,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
>  	u8 *start;
>  	u8 *fault;
>  	u8 *end;
> +	u8 *pad;
>  	int length;
>  	int remainder;
>  
> @@ -851,8 +852,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
>  	if (!remainder)
>  		return 1;
>  
> +	pad = end - remainder;
>  	metadata_access_enable();
> -	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
> +	fault = memchr_inv(pad, POISON_INUSE, remainder);
>  	metadata_access_disable();
>  	if (!fault)
>  		return 1;
> @@ -860,9 +862,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
>  		end--;
>  
>  	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
> -	print_section(KERN_ERR, "Padding ", end - remainder, remainder);
> +	print_section(KERN_ERR, "Padding ", pad, remainder);
>  
> -	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
> +	restore_bytes(s, "slab padding", POISON_INUSE, fault, end);
>  	return 0;
>  }

I don't see why it matters?  The current code will overwrite
POISON_INUSE bytes with POISON_INUSE, won't it?

That's a bit strange but not incorrect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
