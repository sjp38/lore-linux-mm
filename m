Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7574F6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 03:40:40 -0400 (EDT)
Date: Wed, 4 Jul 2012 00:42:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
Message-Id: <20120704004219.47d0508d.akpm@linux-foundation.org>
In-Reply-To: <4FF3ABA1.3070808@kernel.org>
References: <20120628135520.0c48b066@annuminas.surriel.com>
	<20120628135940.2c26ada9.akpm@linux-foundation.org>
	<4FECCB89.2050400@redhat.com>
	<20120628143546.d02d13f9.akpm@linux-foundation.org>
	<1341250950.16969.6.camel@lappy>
	<4FF2435F.2070302@redhat.com>
	<20120703101024.GG13141@csn.ul.ie>
	<20120703144808.4daa4244.akpm@linux-foundation.org>
	<4FF3ABA1.3070808@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

On Wed, 04 Jul 2012 11:34:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > The rest of this patch takes care to ensure that
> > ->compact_cached_free_pfn is aligned to pageblock_nr_pages.  But it now
> > appears that this particular site will violate that.
> > 
> > What's up?  Do we need to fix this site, or do we remove all that
> > make-compact_cached_free_pfn-aligned code?
> 
> 
> I vote removing the warning because it doesn't related to Rik's incremental compaction.
> Let's see. 
> 
> high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages.
> In here, cc->migrate_pfn isn't necessarily pageblock aligined.
> So if we don't consider compact_cached_free_pfn, it can hit.
> 
> static void isolate_freepages()
> {
> 	high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages;
> 	for (..) {
> 		...
> 		 WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
> 		
> 	}
> }

Please, look at the patch.  In numerous places it is aligning
compact_cached_free_pfn to a multiple of pageblock_nr_pages.  But in
one place it doesn't do that.  So are all those alignment operations
necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
