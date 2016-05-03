Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9554D6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 04:50:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so12922662wme.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 01:50:42 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id 204si25764847wmg.36.2016.05.03.01.50.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 May 2016 01:50:41 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id EF68A987C9
	for <linux-mm@kvack.org>; Tue,  3 May 2016 08:50:40 +0000 (UTC)
Date: Tue, 3 May 2016 09:50:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/6] Optimise page alloc/free fast paths followup v2
Message-ID: <20160503085039.GS2858@techsingularity.net>
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
 <572715BF.3000003@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <572715BF.3000003@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 02, 2016 at 10:54:23AM +0200, Vlastimil Babka wrote:
> On 04/27/2016 04:57 PM, Mel Gorman wrote:
> > as the patch "mm, page_alloc: inline the fast path of the zonelist iterator"
> > is fine. The nodemask pointer is the same between cpuset retries. If the
> > zonelist changes due to ALLOC_NO_WATERMARKS *and* it races with a cpuset
> > change then there is a second harmless pass through the page allocator.
> 
> True. But I just realized (while working on direct compaction priorities)
> that there's another subtle issue with the ALLOC_NO_WATERMARKS part.
> According to the comment it should be ignoring mempolicies, but it still
> honours ac.nodemask, and your patch is replacing NULL ac.nodemask with the
> mempolicy one.
> 
> I think it's possibly easily fixed outside the fast path like this. If
> you agree, consider it has my s-o-b:
> 

While I see your point, I don't necessarily see why this fixes it as the
original nodemask may also be a restricted set that ALLOC_NO_WATERMARKS
should ignore. How about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 79100583b9de..dbb08d102d41 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3432,9 +3432,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		/*
 		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
 		 * the allocation is high priority and these type of
-		 * allocations are system rather than user orientated
+		 * allocations are system rather than user orientated. If a
+		 * cpuset retry occurs then these values persist across the
+		 * retry but that's ok for a context ignoring watermarks.
 		 */
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->high_zoneidx = MAX_NR_ZONES - 1;
+		ac->nodemask = NULL;
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 		if (page)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
