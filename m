Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 063836B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 03:29:26 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so18754986pac.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:29:25 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id e3si1933326pdj.210.2015.07.01.00.29.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 00:29:24 -0700 (PDT)
Received: by pdcu2 with SMTP id u2so21288155pdc.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 00:29:24 -0700 (PDT)
Date: Wed, 1 Jul 2015 16:29:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv4 6/7] zsmalloc: account the number of compacted
 pages
Message-ID: <20150701072952.GA537@swordfish>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1435667758-14075-7-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435667758-14075-7-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/30/15 21:35), Sergey Senozhatsky wrote:
[..]
>  	if (src_page)
>  		putback_zspage(pool, class, src_page);
>  
> -	pool->num_migrated += cc.nr_migrated;
> +	cc.nr_migrated /= get_maxobj_per_zspage(class->size,
> +			class->pages_per_zspage);
> +
> +	pool->num_migrated += cc.nr_migrated *
> +		get_pages_per_zspage(class->size);
>  
>  	spin_unlock(&class->lock);

Oh, well. This is bloody wrong, sorry. We don't pick up src_page-s that we
can completely drain. Thus, the fact that we can't compact (!zs_can_compact())
anymore doesn't mean that we actually have released any zspages.

So...

(a) we can isolate_source_page() more accurately -- iterate list and
look for pages that have ->inuse less or equal to the amount of unused
objects. So we can guarantee that this particular zspage will be released
at the end. It adds O(n) every time we isolate_source_page(), because
the number of unused objects changes. But it's sort of worth it, I
think. Otherwise we still can move M objects w/o releasing any pages
after all. If we consider compaction as a slow path (and I think we do)
then this option doesn't look so bad.



(b) if (a) is not an option, then we need to know that we have drained the
src_page. And it seems that the easiest way to do it is to change
'void putback_zspage(...)' to 'bool putback_zspage(...)' and return `true'
from putback_zspage() when putback resulted in free_zspage() (IOW, the page
was ZS_EMPTY). And in __zs_compact() do something like

	if (putback_zspage(.. src_page))
		pool->num_migrated++;



(c) or we can check src_page fullness (or simply if src_page->inuse == 0)
in __zs_compact() and increment ->num_migrated for ZS_EMPTY page. But this
is what free_zspage() already does.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
