Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C99B76B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 04:54:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so71495258wme.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 01:54:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cz8si33012833wjd.11.2016.05.02.01.54.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 01:54:25 -0700 (PDT)
Subject: Re: [PATCH 0/6] Optimise page alloc/free fast paths followup v2
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <572715BF.3000003@suse.cz>
Date: Mon, 2 May 2016 10:54:23 +0200
MIME-Version: 1.0
In-Reply-To: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/27/2016 04:57 PM, Mel Gorman wrote:
> as the patch "mm, page_alloc: inline the fast path of the zonelist iterator"
> is fine. The nodemask pointer is the same between cpuset retries. If the
> zonelist changes due to ALLOC_NO_WATERMARKS *and* it races with a cpuset
> change then there is a second harmless pass through the page allocator.

True. But I just realized (while working on direct compaction priorities)
that there's another subtle issue with the ALLOC_NO_WATERMARKS part.
According to the comment it should be ignoring mempolicies, but it still
honours ac.nodemask, and your patch is replacing NULL ac.nodemask with the
mempolicy one.

I think it's possibly easily fixed outside the fast path like this. If
you agree, consider it has my s-o-b:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f052bbca41d..7ccaa6e023f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3834,6 +3834,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	alloc_mask = memalloc_noio_flags(gfp_mask);
 	ac.spread_dirty_pages = false;
 
+	/*
+	 * Restore the original nodemask, which might have been replaced with
+	 * &cpuset_current_mems_allowed to optimize the fast-path attempt.
+	 */
+	ac.nodemask = nodemask;
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
 no_zone:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
