Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4869D280344
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 18:42:45 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so67964960pac.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 15:42:45 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id da5si20762716pbc.20.2015.07.17.15.42.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 15:42:43 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so68301808pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 15:42:42 -0700 (PDT)
Date: Sat, 18 Jul 2015 07:42:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: do not take class lock in
 zs_shrinker_count()
Message-ID: <20150717224233.GA7334@blaptop>
References: <1437131898-2231-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437131898-2231-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi Sergey,

On Fri, Jul 17, 2015 at 08:18:18PM +0900, Sergey Senozhatsky wrote:
> We can avoid taking class ->lock around zs_can_compact() in
> zs_shrinker_count(), because the number that we return back
> is outdated in general case, by design. We have different
> sources that are able to change class's state right after we
> return from zs_can_compact() -- ongoing I/O operations, manually
> triggered compaction, or two of them happening simultaneously.
> 
> We re-do this calculations during compaction on a per class basis
> anyway.
> 
> zs_unregister_shrinker() will not return until we have an
> active shrinker, so classes won't unexpectedly disappear
> while zs_shrinker_count() iterates them.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

I asked to remove the comment of zs_can_compact about lock.
"Should be called under class->lock."

Otherwise,

Acked-by: Minchan Kim <minchan@kernel.org>

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
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
