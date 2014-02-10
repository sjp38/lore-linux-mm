Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 802A76B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 19:41:15 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so5408829pdj.2
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 16:41:15 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id q5si13272765pae.85.2014.02.09.16.41.13
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 16:41:14 -0800 (PST)
Date: Mon, 10 Feb 2014 09:41:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/5] mm/compaction: do not call
 suitable_migration_target() on every page
Message-ID: <20140210004122.GB12049@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391749726-28910-3-git-send-email-iamjoonsoo.kim@lge.com>
 <52F4A90D.20804@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F4A90D.20804@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 10:36:13AM +0100, Vlastimil Babka wrote:
> On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> > suitable_migration_target() checks that pageblock is suitable for
> > migration target. In isolate_freepages_block(), it is called on every
> > page and this is inefficient. So make it called once per pageblock.
> 
> Hmm but in sync compaction, compact_checklock_irqsave() may drop the zone->lock,
> reschedule and reacquire it and thus possibly invalidate your previous check. Async
> compaction is ok as that will quit immediately. So you could probably communicate that
> this happened and invalidate checked_pageblock in such case. Or maybe this would not
> happen too enough to worry about rare suboptimal migrations?

So, the result of previous check can be changed only if *this* pageblock's migratetype
is changed while we drop the lock. I guess that this is really rare event, and,
in this case, this pageblock already has mixed migratetype pages, so it has
no serious problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
