Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 299CE6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:35:52 -0400 (EDT)
Date: Thu, 28 Jun 2012 14:35:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
Message-Id: <20120628143546.d02d13f9.akpm@linux-foundation.org>
In-Reply-To: <4FECCB89.2050400@redhat.com>
References: <20120628135520.0c48b066@annuminas.surriel.com>
	<20120628135940.2c26ada9.akpm@linux-foundation.org>
	<4FECCB89.2050400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, jaschut@sandia.gov, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com

On Thu, 28 Jun 2012 17:24:25 -0400
Rik van Riel <riel@redhat.com> wrote:

> 
> >> @@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
> >>   		 */
> >>   		if (isolated)
> >>   			high_pfn = max(high_pfn, pfn);
> >> +		if (cc->order>  0)
> >> +			zone->compact_cached_free_pfn = high_pfn;
> >
> > Is high_pfn guaranteed to be aligned to pageblock_nr_pages here?  I
> > assume so, if lots of code in other places is correct but it's
> > unobvious from reading this function.
> 
> Reading the code a few more times, I believe that it is
> indeed aligned to pageblock size.

I'll slip this into -next for a while.

--- a/mm/compaction.c~isolate_freepages-check-that-high_pfn-is-aligned-as-expected
+++ a/mm/compaction.c
@@ -456,6 +456,7 @@ static void isolate_freepages(struct zon
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 
+		WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
 		/*
 		 * Record the highest PFN we isolated pages from. When next
 		 * looking for free pages, the search will restart here as
_

> >> --- a/mm/internal.h
> >> +++ b/mm/internal.h
> >> @@ -118,8 +118,10 @@ struct compact_control {
> >>   	unsigned long nr_freepages;	/* Number of isolated free pages */
> >>   	unsigned long nr_migratepages;	/* Number of pages to migrate */
> >>   	unsigned long free_pfn;		/* isolate_freepages search base */
> >> +	unsigned long start_free_pfn;	/* where we started the search */
> >>   	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> >>   	bool sync;			/* Synchronous migration */
> >> +	bool wrapped;			/* Last round for order>0 compaction */
> >
> > This comment is incomprehensible :(
> 
> Agreed.  I'm not sure how to properly describe that variable
> in 30 or so characters :)
> 
> It denotes whether the current invocation of compaction,
> called with order > 0, has had free_pfn and migrate_pfn
> meet, resulting in free_pfn being reset to the top of
> the zone.
> 
> Now, how to describe that briefly?

Use a multi-line comment above the definition ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
