Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 59EE36B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 02:36:22 -0500 (EST)
Received: by igvg19 with SMTP id g19so73389481igv.1
        for <linux-mm@kvack.org>; Sun, 06 Dec 2015 23:36:22 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id q8si20001104ige.33.2015.12.06.23.36.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 06 Dec 2015 23:36:21 -0800 (PST)
Date: Mon, 7 Dec 2015 16:37:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 1/7] mm/compaction: skip useless pfn when updating
 cached pfn
Message-ID: <20151207073730.GB27292@js1304-P5Q-DELUXE>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-2-git-send-email-iamjoonsoo.kim@lge.com>
 <56601B44.609@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56601B44.609@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 03, 2015 at 11:36:52AM +0100, Vlastimil Babka wrote:
> On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> > Cached pfn is used to determine the start position of scanner
> > at next compaction run. Current cached pfn points the skipped pageblock
> > so we uselessly checks whether pageblock is valid for compaction and
> > skip-bit is set or not. If we set scanner's cached pfn to next pfn of
> > skipped pageblock, we don't need to do this check.
> > 
> > This patch moved update_pageblock_skip() to
> > isolate_(freepages|migratepages). Updating pageblock skip information
> > isn't relevant to CMA so they are more appropriate place
> > to update this information.
> 
> That's step in a good direction, yeah. But why not go as far as some variant of
> my (not resubmitted) patch "mm, compaction: decouple updating pageblock_skip and
> cached pfn" [1]. Now the overloading of update_pageblock_skip() is just too much
> - a struct page pointer for the skip bits, and a pfn of different page for the
> cached pfn update, that's just more complex than it should be.
> 
> (I also suspect the pageblock_flags manipulation functions could be simpler if
> they accepted zone pointer and pfn instead of struct page)

Okay.

> Also recently in Aaron's report we found a possible scenario where pageblocks
> are being skipped without entering the isolate_*_block() functions, and it would
> make sense to update the cached pfn's in that case, independently of updating
> pageblock skip bits.
> 
> But this might be too out of scope of your series, so if you want I can
> separately look at reviving some useful parts of [1] and the simpler
> pageblock_flags manipulations.

I will cherry-pick some useful parts of that with your authorship and
respin this series after you finish to review all patches.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
