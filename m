Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id F37E16B00A0
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 15:59:10 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so952943qeb.26
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 12:59:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i2si3296686qaz.140.2013.12.06.12.59.08
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 12:59:09 -0800 (PST)
Date: Fri, 06 Dec 2013 15:59:01 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386363541-yueai7w7-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386319310-28016-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386319310-28016-4-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/4] mm/compaction: respect ignore_skip_hint in
 update_pageblock_skip
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 05:41:50PM +0900, Joonsoo Kim wrote:
> update_pageblock_skip() only fits to compaction which tries to isolate by
> pageblock unit. If isolate_migratepages_range() is called by CMA, it try to
> isolate regardless of pageblock unit and it don't reference
> get_pageblock_skip() by ignore_skip_hint. We should also respect it on
> update_pageblock_skip() to prevent from setting the wrong information.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Yes, get/set_pageblock_skip() is irrelevant if ignore_skip_hint is true.
This bug was introduced in v3.7-rc, so this patch would go to stable-3.7
and later.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 805165b..f58bcd0 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -134,6 +134,10 @@ static void update_pageblock_skip(struct compact_control *cc,
>  			bool migrate_scanner)
>  {
>  	struct zone *zone = cc->zone;
> +
> +	if (cc->ignore_skip_hint)
> +		return;
> +
>  	if (!page)
>  		return;
>  
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
