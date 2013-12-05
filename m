Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 549BB6B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 04:05:49 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so11282325ead.10
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 01:05:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s8si9981299eeh.59.2013.12.05.01.05.48
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 01:05:48 -0800 (PST)
Date: Thu, 5 Dec 2013 09:05:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Trace compaction begin and end
Message-ID: <20131205090544.GF11295@suse.de>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
 <20131204143045.GZ11295@suse.de>
 <529F418D.3070108@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <529F418D.3070108@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Wed, Dec 04, 2013 at 03:51:57PM +0100, Vlastimil Babka wrote:
> On 12/04/2013 03:30 PM, Mel Gorman wrote:
> >This patch adds two tracepoints for compaction begin and end of a zone. Using
> >this it is possible to calculate how much time a workload is spending
> >within compaction and potentially debug problems related to cached pfns
> >for scanning.
> 
> I guess for debugging pfns it would be also useful to print their
> values also in mm_compaction_end.
> 

What additional information would we get from it and what new
conclusions could we draw? We could guess how much work the
scanners did but the trace_mm_compaction_isolate_freepages and
trace_mm_compaction_isolate_migratepages tracepoints already accurately
tell us that. The scanner PFNs alone do not tell us if the cached pfns
were updated and even if it did, the information can be changed by
parallel resets so it would be hard to draw reasonable conclusions from
the information. We could guess where compaction hotspots might be but
without the skip information, we could not detect it accurately.  If we
wanted to detect that accurately, the mm_compaction_isolate* tracepoints
would be the one to update.

I was primarily concerned about compaction time so I might be looking
at this the wrong way but it feels like having the PFNs at the end of a
compaction cycle would be of marginal benefit.

> >In combination with the direct reclaim and slab trace points
> >it should be possible to estimate most allocation-related overhead for
> >a workload.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> >---
> >  include/trace/events/compaction.h | 42 +++++++++++++++++++++++++++++++++++++++
> >  mm/compaction.c                   |  4 ++++
> >  2 files changed, 46 insertions(+)
> >
> >diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> >index fde1b3e..f4e115a 100644
> >--- a/include/trace/events/compaction.h
> >+++ b/include/trace/events/compaction.h
> >@@ -67,6 +67,48 @@ TRACE_EVENT(mm_compaction_migratepages,
> >  		__entry->nr_failed)
> >  );
> >
> >+TRACE_EVENT(mm_compaction_begin,
> >+	TP_PROTO(unsigned long zone_start, unsigned long migrate_start,
> >+		unsigned long zone_end, unsigned long free_start),
> >+
> >+	TP_ARGS(zone_start, migrate_start, zone_end, free_start),
> 
> IMHO a better order would be:
>  zone_start, migrate_start, free_start, zone_end
> (well especially in the TP_printk part anyway).
> 

Ok, that would put them in PFN order which may be easier to visualise.
I'll post a V2 with that change at least.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
