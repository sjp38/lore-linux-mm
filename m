Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2CF76B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:40:27 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j18so6034531ioe.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:40:27 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q19si30413485ioi.128.2017.01.05.02.40.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:40:27 -0800 (PST)
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
References: <20170102133700.1734-1-mhocko@kernel.org>
 <20170104142022.GL25453@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <05308767-7f1b-6c4d-12d7-3dfcb94376c5@I-love.SAKURA.ne.jp>
Date: Thu, 5 Jan 2017 19:40:10 +0900
MIME-Version: 1.0
In-Reply-To: <20170104142022.GL25453@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-bcache@vger.kernel.org, kent.overstreet@gmail.com

On 2017/01/04 23:20, Michal Hocko wrote:
> OK, so I've checked the open coded implementations and converted most of
> them. There are few which are either confused and need some special
> handling or need double checking.
> 
> diff --git a/drivers/md/bcache/util.h b/drivers/md/bcache/util.h
> index cf2cbc211d83..9dc0f0ff0321 100644
> --- a/drivers/md/bcache/util.h
> +++ b/drivers/md/bcache/util.h
> @@ -44,10 +44,7 @@ struct closure;
>  	(heap)->size = (_size);						\
>  	_bytes = (heap)->size * sizeof(*(heap)->data);			\
>  	(heap)->data = NULL;						\
> -	if (_bytes < KMALLOC_MAX_SIZE)					\
> -		(heap)->data = kmalloc(_bytes, (gfp));			\
> -	if ((!(heap)->data) && ((gfp) & GFP_KERNEL))			\
> -		(heap)->data = vmalloc(_bytes);				\
> +	(heap)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);		\
>  	(heap)->data;							\
>  })
>  
> @@ -138,10 +135,7 @@ do {									\
>  	(fifo)->front = (fifo)->back = 0;				\
>  	(fifo)->data = NULL;						\
>  									\
> -	if (_bytes < KMALLOC_MAX_SIZE)					\
> -		(fifo)->data = kmalloc(_bytes, (gfp));			\
> -	if ((!(fifo)->data) && ((gfp) & GFP_KERNEL))			\
> -		(fifo)->data = vmalloc(_bytes);				\
> +	(fifo)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);		\
>  	(fifo)->data;							\
>  })

These macros are doing strange checks.
((gfp) & GFP_KERNEL) means any bit in GFP_KERNEL is set.
((gfp) & GFP_KERNEL) == GFP_KERNEL might make sense. Actually,
all callers seems to be passing GFP_KERNEL to these macros.

Kent, how do you want to correct this? You want to apply
a patch that removes gfp argument before applying this patch?
Or, you want Michal to directly overwrite by this patch?

Michal, "(fifo)->data = NULL;" line will become redundant
and "(gfp) & GFP_KERNEL" will become "GFP_KERNEL".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
