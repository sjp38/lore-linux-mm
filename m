Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9969E6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 12:28:14 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t24so4267558pfe.20
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 09:28:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s10si5205183pfi.143.2018.03.02.09.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Mar 2018 09:28:13 -0800 (PST)
Date: Fri, 2 Mar 2018 09:28:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd fails
Message-ID: <20180302172807.GD31400@bombadil.infradead.org>
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com>
 <672ebefc-483d-2932-37b5-4ffe58156f0f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <672ebefc-483d-2932-37b5-4ffe58156f0f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 01, 2018 at 01:23:34PM +0100, Vlastimil Babka wrote:
> On 03/01/2018 12:42 PM, David Rientjes wrote:
> > It's possible for buddy pages to become stranded on pcps that, if drained,
> > could be merged with other buddy pages on the zone's free area to form
> > large order pages, including up to MAX_ORDER.
> 
> BTW I wonder if we could be smarter and quicker about the drains. Let a
> pcp struct page be easily recognized as such, and store the cpu number
> in there. Migration scanner could then maintain a cpumask, and recognize
> if the only missing pages for coalescing a cc->order block are on the
> pcplists, and then do a targeted drain.
> But that only makes sense to implement if it can make a noticeable
> difference to offset the additional overhead, of course.

Perhaps we should turn this around ... rather than waiting for the
coalescer to come along, when we're about to put a page on the pcp list,
check whether its buddy is PageBuddy().  If so, send it to the buddy
allocator so it can get merged instead of putting it on the pcp list.

I can see the negatives of that; if you're in a situation where you've
got a 2^12 block free and allocate one page, that's 12 splits.  Then you
free the page and it does 12 joins.  Then you allocate again and do 12
splits ...

That seems like a relatively rare scenario; we're generally going to
have a lot of pages in motion on any workload we care about, and there's
always going to be pages on the pcp list.

It's not an alternative to David's patch; having page A and page A+1 on
the pcp list will prevent the pages from getting merged.  But it should
delay the time until his bigger hammer kicks in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
