Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 1E5CB6B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 06:10:28 -0400 (EDT)
Date: Tue, 3 Jul 2012 11:10:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
Message-ID: <20120703101024.GG13141@csn.ul.ie>
References: <20120628135520.0c48b066@annuminas.surriel.com>
 <20120628135940.2c26ada9.akpm@linux-foundation.org>
 <4FECCB89.2050400@redhat.com>
 <20120628143546.d02d13f9.akpm@linux-foundation.org>
 <1341250950.16969.6.camel@lappy>
 <4FF2435F.2070302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FF2435F.2070302@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

On Mon, Jul 02, 2012 at 08:57:03PM -0400, Rik van Riel wrote:
> On 07/02/2012 01:42 PM, Sasha Levin wrote:
> >On Thu, 2012-06-28 at 14:35 -0700, Andrew Morton wrote:
> >>On Thu, 28 Jun 2012 17:24:25 -0400 Rik van Riel<riel@redhat.com>  wrote:
> >>>
> >>>>>@@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
> >>>>>             */
> >>>>>            if (isolated)
> >>>>>                    high_pfn = max(high_pfn, pfn);
> >>>>>+          if (cc->order>   0)
> >>>>>+                  zone->compact_cached_free_pfn = high_pfn;
> >>>>
> >>>>Is high_pfn guaranteed to be aligned to pageblock_nr_pages here?  I
> >>>>assume so, if lots of code in other places is correct but it's
> >>>>unobvious from reading this function.
> >>>
> >>>Reading the code a few more times, I believe that it is
> >>>indeed aligned to pageblock size.
> >>
> >>I'll slip this into -next for a while.
> >>
> >>--- a/mm/compaction.c~isolate_freepages-check-that-high_pfn-is-aligned-as-expected
> >>+++ a/mm/compaction.c
> >>@@ -456,6 +456,7 @@ static void isolate_freepages(struct zon
> >>                 }
> >>                 spin_unlock_irqrestore(&zone->lock, flags);
> >>
> >>+               WARN_ON_ONCE(high_pfn&  (pageblock_nr_pages - 1));
> >>                 /*
> >>                  * Record the highest PFN we isolated pages from. When next
> >>                  * looking for free pages, the search will restart here as
> >
> >I've triggered the following with today's -next:
> 
> I've been staring at the migrate code for most of the afternoon,
> and am not sure how this is triggered.
> 

That warning is placed in isolate_freepages(). When the migration
scanner and free scanner have almost met it is possible for high_pfn to
be

cc->migrate_pfn + pageblock_nr_pages

and that is not necessarily pageblock aligned. Forcing it to be aligned
raises the possibility that the free scanner moves to another zone. This
is very unlikely but could happen if a high zone was very small.

I should have caught this when the warning was proposed :( IMO it's
safe to just drop the warning.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
