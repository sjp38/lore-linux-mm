Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D59A6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 21:02:39 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so216674254pac.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 18:02:39 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id u4si1842930par.185.2016.04.17.18.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 18:02:38 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id vv3so14698752pab.0
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 18:02:38 -0700 (PDT)
Date: Mon, 18 Apr 2016 10:04:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 11/16] zsmalloc: separate free_zspage from
 putback_zspage
Message-ID: <20160418010408.GB5882@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-12-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-12-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello Minchan,

On (03/30/16 16:12), Minchan Kim wrote:
[..]
> @@ -1835,23 +1827,31 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  			if (!migrate_zspage(pool, class, &cc))
>  				break;
>  
> -			putback_zspage(pool, class, dst_page);
> +			VM_BUG_ON_PAGE(putback_zspage(pool, class,
> +				dst_page) == ZS_EMPTY, dst_page);

can this VM_BUG_ON_PAGE() condition ever be true?

>  		}
>  		/* Stop if we couldn't find slot */
>  		if (dst_page == NULL)
>  			break;
> -		putback_zspage(pool, class, dst_page);
> -		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
> +		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> +				dst_page) == ZS_EMPTY, dst_page);

hm... this VM_BUG_ON_PAGE(dst_page) is sort of confusing. under what
circumstances it can be true?

a minor nit, it took me some time (need some coffee I guess) to
correctly parse this macro wrapper

		VM_BUG_ON_PAGE(putback_zspage(pool, class,
			dst_page) == ZS_EMPTY, dst_page);

may be do it like:
		fullness = putback_zspage(pool, class, dst_page);
		VM_BUG_ON_PAGE(fullness == ZS_EMPTY, dst_page);


well, if we want to VM_BUG_ON_PAGE() at all. there haven't been any
problems with compaction, is there any specific reason these macros
were added?



> +		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
>  			pool->stats.pages_compacted += class->pages_per_zspage;
> -		spin_unlock(&class->lock);
> +			spin_unlock(&class->lock);
> +			free_zspage(pool, class, src_page);

do we really need to free_zspage() out of class->lock?
wouldn't something like this

		if (putback_zspage(pool, class, src_page) == ZS_EMPTY) {
			pool->stats.pages_compacted += class->pages_per_zspage;
			free_zspage(pool, class, src_page);
		}
		spin_unlock(&class->lock);

be simpler?

besides, free_zspage() now updates class stats out of class lock,
not critical but still.

	-ss

> +		} else {
> +			spin_unlock(&class->lock);
> +		}
> +
>  		cond_resched();
>  		spin_lock(&class->lock);
>  	}
>  
>  	if (src_page)
> -		putback_zspage(pool, class, src_page);
> +		VM_BUG_ON_PAGE(putback_zspage(pool, class,
> +				src_page) == ZS_EMPTY, src_page);
>  
>  	spin_unlock(&class->lock);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
