Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 758606B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:41:09 -0400 (EDT)
Date: Thu, 2 Jun 2011 23:40:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110602214041.GF2802@random.random>
References: <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110531143734.GB13418@barrios-laptop>
 <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602202156.GA23486@barrios-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Minchan,

On Fri, Jun 03, 2011 at 05:21:56AM +0900, Minchan Kim wrote:
> Isn't it rather aggressive?
> I think cursor page is likely to be PageTail rather than PageHead.
> Could we handle it simply with below code?

It's not so likely, there is small percentage of compound pages that
aren't THP compared to the rest that is either regular pagecache or
anon regular or anon THP or regular shm. If it's THP chances are we
isolated the head and it's useless to insist on more tail pages (at
least for large page size like on x86). Plus we've compaction so
insisting and screwing lru ordering isn't worth it, better to be
permissive and abort... in fact I wouldn't dislike to remove the
entire lumpy logic when COMPACTION_BUILD is true, but that alters the
trace too...

> get_page(cursor_page)
> /* The page is freed already */
> if (1 == page_count(cursor_page)) {
> 	put_page(cursor_page)
> 	continue;
> }
> put_page(cursor_page);

We can't call get_page on an tail page or we break split_huge_page,
only an isolated lru can be boosted, if we take the lru_lock and we
check the page is in lru, then we can isolate and pin it safely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
