Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDB056B025E
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:14:37 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so22143889ith.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 01:14:37 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j123si12864230ith.70.2016.06.28.01.14.36
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 01:14:37 -0700 (PDT)
Date: Tue, 28 Jun 2016 17:17:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/6] mm/cma: remove MIGRATE_CMA
Message-ID: <20160628081731.GC19731@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-6-git-send-email-iamjoonsoo.kim@lge.com>
 <087368b2-19d3-30e0-e420-456c291f16c9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <087368b2-19d3-30e0-e420-456c291f16c9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 27, 2016 at 11:46:39AM +0200, Vlastimil Babka wrote:
> On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Now, all reserved pages for CMA region are belong to the ZONE_CMA
> >and there is no other type of pages. Therefore, we don't need to
> >use MIGRATE_CMA to distinguish and handle differently for CMA pages
> >and ordinary pages. Remove MIGRATE_CMA.
> >
> >Unfortunately, this patch make free CMA counter incorrect because
> >we count it when pages are on the MIGRATE_CMA. It will be fixed
> >by next patch. I can squash next patch here but it makes changes
> >complicated and hard to review so I separate that.
> 
> Doesn't sound like a big deal.

Okay.

> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> [...]
> 
> >@@ -7442,14 +7401,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> > 	 * allocator removing them from the buddy system.  This way
> > 	 * page allocator will never consider using them.
> > 	 *
> >-	 * This lets us mark the pageblocks back as
> >-	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
> >-	 * aligned range but not in the unaligned, original range are
> >-	 * put back to page allocator so that buddy can use them.
> >+	 * This lets us mark the pageblocks back as MIGRATE_MOVABLE
> >+	 * so that free pages in the aligned range but not in the
> >+	 * unaligned, original range are put back to page allocator
> >+	 * so that buddy can use them.
> > 	 */
> >
> > 	ret = start_isolate_page_range(pfn_max_align_down(start),
> >-				       pfn_max_align_up(end), migratetype,
> >+				       pfn_max_align_up(end), MIGRATE_MOVABLE,
> > 				       false);
> > 	if (ret)
> > 		return ret;
> >@@ -7528,7 +7487,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> >
> > done:
> > 	undo_isolate_page_range(pfn_max_align_down(start),
> >-				pfn_max_align_up(end), migratetype);
> >+				pfn_max_align_up(end), MIGRATE_MOVABLE);
> > 	return ret;
> > }
> 
> Looks like all callers of {start,undo}_isolate_page_range() now use
> MIGRATE_MOVABLE, so it could be removed.

You're right. Will do in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
