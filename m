Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 667766B0073
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 06:18:28 -0400 (EDT)
Date: Wed, 8 Aug 2012 11:18:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] mm: have order > 0 compaction start near a pageblock
 with free pages
Message-ID: <20120808101822.GM29814@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
 <1344342677-5845-7-git-send-email-mgorman@suse.de>
 <20120808043600.GD4247@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120808043600.GD4247@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2012 at 01:36:00PM +0900, Minchan Kim wrote:
> > 
> > Second, it updates compact_cached_free_pfn in a more limited set of
> > circumstances.
> > 
> > If a scanner has wrapped, it updates compact_cached_free_pfn to the end
> > 	of the zone. Each time a wrapped scanner isoaltes a page, it
> > 	updates compact_cached_free_pfn. The intention is that after
> > 	wrapping, the compact_cached_free_pfn will be at the highest
> > 	pageblock with free pages when compaction completes.
> 
> Okay.
> 
> > 
> > If a scanner has not wrapped when compaction completes and
> 
> Compaction complete?
> Your code seem to do it in isolate_freepages.
> Isn't it compaction complete?
> 

s/compaction/free page isolation/

> > 	compact_cached_free_pfn is set the end of the the zone, initialise
> > 	it once.
> 

> I can't understad this part.
> Could you elaborate a bit more?
> 

Is this better?

If a scanner has wrapped, it updates compact_cached_free_pfn to the end
        of the zone. When a wrapped scanner isolates a page, it updates
        compact_cached_free_pfn to point to the highest pageblock it
        can isolate pages from. 

If a scanner has not wrapped when it has finished isolated pages it 
        checks if compact_cached_free_pfn is pointing to the end of the
        zone. If so, the value is updated to point to the highest 
        pageblock that pages were isolated from. This value will not
        be updated again until a free page scanner wraps and resets
        compact_cached_free_pfn.

This is not optimal and it can still race but the compact_cached_free_pfn
will be pointing to or very near a pageblock with free pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
