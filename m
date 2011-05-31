Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A9926B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 10:14:32 -0400 (EDT)
Date: Tue, 31 May 2011 16:14:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110531141402.GK19505@random.random>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
 <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110531133340.GB3490@barrios-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Tue, May 31, 2011 at 10:33:40PM +0900, Minchan Kim wrote:
> I checked them before sending patch but I got failed to find strange things. :(

My review also doesn't show other bugs in migrate_pages callers like
that one.

> Now I am checking the page's SwapBacked flag can be changed
> between before and after of migrate_pages so accounting of NR_ISOLATED_XX can
> make mistake. I am approaching the failure, too. Hmm.

When I checked that, I noticed the ClearPageSwapBacked in swapcache if
radix insertion fails, but that happens before adding the page in the
LRU so it shouldn't have a chance to be isolated.

So far I only noticed an unsafe page_count in
vmscan.c:isolate_lru_pages but that should at worst result in a
invalid pointer dereference as random result from that page_count is
not going to hurt and I think it's only a theoretical issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
