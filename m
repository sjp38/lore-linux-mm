Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 838C6280314
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:43:02 -0400 (EDT)
Received: by pacan13 with SMTP id an13so50694220pac.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:43:02 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id ri10si15386404pdb.167.2015.07.16.16.43.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:43:01 -0700 (PDT)
Received: by pacgq4 with SMTP id gq4so5495806pac.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:43:01 -0700 (PDT)
Date: Fri, 17 Jul 2015 08:43:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: do not take class lock in zs_shrinker_count()
Message-ID: <20150716233516.GA2766@swordfish>
References: <1437048054-4916-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437048054-4916-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/16/15 21:00), Sergey Senozhatsky wrote:
> Subject: [PATCH] zsmalloc: do not take class lock in zs_shrinker_count()
> X-Mailer: git-send-email 2.4.6
> 
> We can avoid taking class ->lock around zs_can_compact() in
> zs_pages_to_compact(), because the number that we return back

eek... a leftover

s/zs_pages_to_compact/zs_shrinker_count/

I'll resend the patch later today.

	-ss

> is outdated in general case, by design. We have different
> sources that are able to change class's state right after we
> return from zs_can_compact() -- ongoing I/O operations, manually
> triggered compaction, or two of them happening simultaneously.
> 
> We re-do this calculations during compaction on a per class basis
> anyway.
> 
> zs_unregister_shrinker() will not return until we have an active
> shrinker, so classes won't unexpectedly disappear while
> zs_pages_to_compact(), invoked by zs_shrinker_count(), iterates
> them.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 1edd8a0..ed64cf5 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1836,9 +1836,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
>  		if (class->index != i)
>  			continue;
>  
> -		spin_lock(&class->lock);
>  		pages_to_free += zs_can_compact(class);
> -		spin_unlock(&class->lock);
>  	}
>  
>  	return pages_to_free;
> -- 
> 2.4.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
