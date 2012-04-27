Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 51F696B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 05:45:53 -0400 (EDT)
Date: Fri, 27 Apr 2012 10:45:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120427094548.GH15299@suse.de>
References: <201204261015.54449.b.zolnierkie@samsung.com>
 <20120426143620.GF15299@suse.de>
 <4F996F8B.1020207@redhat.com>
 <20120426164713.GG15299@suse.de>
 <4F999988.802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F999988.802@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, Apr 26, 2012 at 02:52:56PM -0400, Rik van Riel wrote:
> >Instead of COMPACT_ASYNC_PARTIAL and COMPACT_ASYNC_FULL should we have
> >COMPACT_ASYNC_MOVABLE and COMPACT_ASYNC_UNMOVABLE? The first pass from
> >the page allocator (COMPACT_ASYNC_MOVABLE) would only consider MOVABLE
> >blocks as migration targets. The second pass (COMPACT_ASYNC_UNMOVABLE)
> >would examine UNMOVABLE blocks, rescue them and use what blocks it
> >rescues as migration targets. The third pass (COMPACT_SYNC) would work
> >as it does currently. kswapd would only ever use COMPACT_ASYNC_MOVABLE.
> >
> >That would avoid rescanning the movable blocks uselessly on the second
> >pass but should still work for Bartlomiej's workload.
> >
> >What do you think?
> 
> This makes sense.
> 
> >>In other words, could it be better to always try to
> >>rescue the unmovable blocks?
> >
> >I do not think we should always scan within unmovable blocks on the
> >first pass. I strongly suspect it would lead to excessive amounts of CPU
> >time spent in mm/compaction.c.
> 
> Maybe my systems are not typical.  I have not seen
> more than about 10% of the memory blocks marked as
> unmovable in my system.

I see even less than 10% on my systems but I do not consider them to be
typical and there will be systems where there are more unmovable pageblocks
for whatever reason (lots of page table pages, anon_vmas and vmas for
example). Hence I'd rather not assume that the number is typically low.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
