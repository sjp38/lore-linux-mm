Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DC4B5280277
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 00:06:43 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so17771101pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 21:06:43 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id z5si5150321pbw.233.2015.07.14.21.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 21:06:43 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so17770803pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 21:06:42 -0700 (PDT)
Date: Wed, 15 Jul 2015 13:07:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] zsmalloc: do not take class lock in
 zs_pages_to_compact()
Message-ID: <20150715040703.GA545@swordfish>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436607932-7116-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436607932-7116-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (07/11/15 18:45), Sergey Senozhatsky wrote:
[..]
> We re-do this calculations during compaction on a per class basis
> anyway.
> 
> zs_unregister_shrinker() will not return until we have an active
> shrinker, so classes won't unexpectedly disappear while
> zs_pages_to_compact(), invoked by zs_shrinker_count(), iterates
> them.
> 
> When called from zram, we are protected by zram's ->init_lock,
> so, again, classes will be there until zs_pages_to_compact()
> iterates them.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b10a228..824c182 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1811,9 +1811,7 @@ unsigned long zs_pages_to_compact(struct zs_pool *pool)
>  		if (class->index != i)
>  			continue;
>  
> -		spin_lock(&class->lock);
>  		pages_to_free += zs_can_compact(class);
> -		spin_unlock(&class->lock);
>  	}
>  
>  	return pages_to_free;

This patch still makes sense. Agree?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
