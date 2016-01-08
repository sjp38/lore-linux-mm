Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 40A056B025B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 21:49:31 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id z14so48517532igp.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 18:49:31 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id 128si25797332ioe.88.2016.01.07.18.49.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 18:49:30 -0800 (PST)
Date: Fri, 8 Jan 2016 11:52:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when
 zone is contiguous
Message-ID: <20160108025219.GA14457@js1304-P5Q-DELUXE>
References: <1450678432-16593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1450678432-16593-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1512221410380.5172@chino.kir.corp.google.com>
 <567A3BBD.80408@suse.cz>
 <20151223065727.GA9691@js1304-P5Q-DELUXE>
 <568A67AA.3050603@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <568A67AA.3050603@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 04, 2016 at 01:38:02PM +0100, Vlastimil Babka wrote:
> On 12/23/2015 07:57 AM, Joonsoo Kim wrote:
> >>>What are the cases where pageblock_pfn_to_page() is used for a subset of
> >>>the pageblock and the result would be problematic for compaction?  I.e.,
> >>>do we actually care to use pageblocks that are not contiguous at all?
> >>
> >>The problematic pageblocks are those that have pages from more than one zone in
> >>them, so we just skip them. Supposedly that can only happen by switching once
> >>between two zones somewhere in the middle of the pageblock, so it's sufficient
> >>to check first and last pfn and compare their zones. So using
> >>pageblock_pfn_to_page() on a subset from compaction would be wrong. Holes (==no
> >>pages) within pageblock is a different thing checked by pfn_valid_within()
> >>(#defined out on archs where such holes cannot happen) when scanning the block.
> >>
> >>That's why I'm not entirely happy with how the patch conflates both the
> >>first/last pfn's zone checks and pfn_valid_within() checks. Yes, a fully
> >>contiguous zone does *imply* that pageblock_pfn_to_page() doesn't have to check
> >>first/last pfn for a matching zone. But it's not *equality*. And any (now just
> >>*potential*) user of pageblock_pfn_to_page() with pfn's different than
> >>first/last pfn of a pageblock is likely wrong.
> >
> >Now, I understand your concern. What makes me mislead is that
> >3 of 4 callers to pageblock_pfn_to_page() in compaction.c could call it with
> >non-pageblock boundary pfn.
> 
> Oh, I thought you were talking about potential new callers, now that
> the function was exported. So let's see about the existing callers:
> 
> isolate_migratepages() - first pfn can be non-boundary when
> restarting from a middle of pageblock, that's true. But it means the
> pageblock has already passed the check in previous call where it was
> boundary, so it's safe. Worst can happen that the restarting pfn
> will be in a intra-pageblock hole so pageblock will be falsely
> skipped over.

Yes, you are right.

> 
> isolate_freepages() - always boundary AFAICS?
> 
> isolate_migratepages_range() and isolate_freepages_range() - yeah
> the CMA parts say it doesn't have to be aligned, I don't know about
> actual users

CMA can call them with non-pageblock aligned pfn but checking
pageblock_pfn_to_page() with pageblock aligned pfn will be safe because
there is a constraint for CMA region that it is aligned with pageblock
and it should be in a single zone. Even, it has checked pfn_valid()
for all pfn during initialization step.

> >Maybe, they should be fixed first.
> 
> It would be probably best, even for isolate_migratepages() for
> consistency and less-surprisibility.

Yes. Without this fix, if only pageblock aligned pfn is checked for
cached hole information, optimized pageblock_pfn_to_page() would
cause error when meeting intra-pageblock hole in isolate_migratepages().

> >Then, yes. I can
> >separate first/last pfn's zone checks and pfn_valid_within() checks.
> >If then, would you be entirely happy? :)
> 
> Maybe, if the patch also made me a coffee :P

I hope so. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
