Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04C9C6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 22:49:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so33947996pfc.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 19:49:33 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id y2si54992442pfa.52.2016.06.01.19.49.31
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 19:49:32 -0700 (PDT)
Date: Thu, 2 Jun 2016 11:50:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160602025050.GC9133@js1304-P5Q-DELUXE>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160531063740.GC30967@js1304-P5Q-DELUXE>
 <276c5490-c5e3-2ba5-68d8-df02922f6122@suse.cz>
 <8c3efbf0-6c05-273d-5d35-bd0b386a20ec@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c3efbf0-6c05-273d-5d35-bd0b386a20ec@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, May 31, 2016 at 02:29:24PM +0200, Vlastimil Babka wrote:
> On 05/31/2016 02:07 PM, Vlastimil Babka wrote:
> >On 05/31/2016 08:37 AM, Joonsoo Kim wrote:
> >>>@@ -3695,22 +3695,22 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >>> 	else
> >>> 		no_progress_loops++;
> >>>
> >>>-	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> >>>-				 did_some_progress > 0, no_progress_loops))
> >>>-		goto retry;
> >>>-
> >>>+	should_retry = should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> >>>+				 did_some_progress > 0, no_progress_loops);
> >>> 	/*
> >>> 	 * It doesn't make any sense to retry for the compaction if the order-0
> >>> 	 * reclaim is not able to make any progress because the current
> >>> 	 * implementation of the compaction depends on the sufficient amount
> >>> 	 * of free memory (see __compaction_suitable)
> >>> 	 */
> >>>-	if (did_some_progress > 0 &&
> >>>-			should_compact_retry(ac, order, alloc_flags,
> >>>+	if (did_some_progress > 0)
> >>>+		should_retry |= should_compact_retry(ac, order, alloc_flags,
> >>> 				compact_result, &compact_priority,
> >>>-				compaction_retries))
> >>>+				compaction_retries);
> >>>+	if (should_retry)
> >>> 		goto retry;
> >>
> >>Hmm... it looks odd that we check should_compact_retry() when
> >>did_some_progress > 0. If system is full of anonymous memory and we
> >>don't have swap, we can't reclaim anything but we can compact.
> >
> >Right, thanks.
> 
> Hmm on the other hand, should_compact_retry will assume (in
> compaction_zonelist_suitable()) that reclaimable memory is actually
> reclaimable. If there's nothing to tell us that it actually isn't,
> if we drop the reclaim progress requirement. That's risking an
> infinite loop?

You are right. I hope this retry logic will be robust to cover all
the theoretical situations but it looks not easy. Sigh...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
