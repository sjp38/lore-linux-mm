Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AEC436B00B8
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:04:07 -0500 (EST)
Received: by padhz1 with SMTP id hz1so5026096pad.9
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:04:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qs1si20935703pbb.167.2015.02.18.16.04.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 16:04:06 -0800 (PST)
Date: Wed, 18 Feb 2015 16:04:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/3] mm/compaction: enhance compaction finish
 condition
Message-Id: <20150218160405.526418167249559d0ed3efc5@linux-foundation.org>
In-Reply-To: <1423725305-3726-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423725305-3726-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1423725305-3726-3-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Thu, 12 Feb 2015 16:15:05 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Compaction has anti fragmentation algorithm. It is that freepage
> should be more than pageblock order to finish the compaction if we don't
> find any freepage in requested migratetype buddy list. This is for
> mitigating fragmentation, but, there is a lack of migratetype
> consideration and it is too excessive compared to page allocator's anti
> fragmentation algorithm.
> 
> Not considering migratetype would cause premature finish of compaction.
> For example, if allocation request is for unmovable migratetype,
> freepage with CMA migratetype doesn't help that allocation and
> compaction should not be stopped. But, current logic regards this
> situation as compaction is no longer needed, so finish the compaction.
> 
> Secondly, condition is too excessive compared to page allocator's logic.
> We can steal freepage from other migratetype and change pageblock
> migratetype on more relaxed conditions in page allocator. This is designed
> to prevent fragmentation and we can use it here. Imposing hard constraint
> only to the compaction doesn't help much in this case since page allocator
> would cause fragmentation again.
> 
> To solve these problems, this patch borrows anti fragmentation logic from
> page allocator. It will reduce premature compaction finish in some cases
> and reduce excessive compaction work.
> 
> stress-highalloc test in mmtests with non movable order 7 allocation shows
> considerable increase of compaction success rate.
> 
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 31.82 : 42.20
> 
> I tested it on non-reboot 5 runs stress-highalloc benchmark and found that
> there is no more degradation on allocation success rate than before. That
> roughly means that this patch doesn't result in more fragmentations.
> 
> Vlastimil suggests additional idea that we only test for fallbacks
> when migration scanner has scanned a whole pageblock. It looked good for
> fragmentation because chance of stealing increase due to making more
> free pages in certain pageblock. So, I tested it, but, it results in
> decreased compaction success rate, roughly 38.00. I guess the reason that
> if system is low memory condition, watermark check could be failed due to
> not enough order 0 free page and so, sometimes, we can't reach a fallback
> check although migrate_pfn is aligned to pageblock_nr_pages. I can insert
> code to cope with this situation but it makes code more complicated so
> I don't include his idea at this patch.
> 
> ...
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1170,13 +1170,23 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  	/* Direct compactor: Is a suitable page free? */
>  	for (order = cc->order; order < MAX_ORDER; order++) {
>  		struct free_area *area = &zone->free_area[order];
> +		bool can_steal;
>  
>  		/* Job done if page is free of the right migratetype */
>  		if (!list_empty(&area->free_list[migratetype]))
>  			return COMPACT_PARTIAL;
>  
> -		/* Job done if allocation would set block type */
> -		if (order >= pageblock_order && area->nr_free)
> +		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
> +		if (migratetype == MIGRATE_MOVABLE &&
> +			!list_empty(&area->free_list[MIGRATE_CMA]))
> +			return COMPACT_PARTIAL;

MIGRATE_CMA isn't defined if CONFIG_CMA=n.

--- a/mm/compaction.c~mm-compaction-enhance-compaction-finish-condition-fix
+++ a/mm/compaction.c
@@ -1180,11 +1180,12 @@ static int __compact_finished(struct zon
 		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_PARTIAL;
 
+#ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
 			!list_empty(&area->free_list[MIGRATE_CMA]))
 			return COMPACT_PARTIAL;
-
+#endif
 		/*
 		 * Job done if allocation would steal freepages from
 		 * other migratetype buddy lists.

Please review the rest of the patchset for the CONFIG_CMA=n case (is it
all necessary?), runtime test it and let me know?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
