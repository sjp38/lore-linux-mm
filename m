Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E21AD8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 16:01:11 -0500 (EST)
Date: Thu, 10 Feb 2011 13:00:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: batch-free pcp list if possible
Message-Id: <20110210130037.24dbde41.akpm@linux-foundation.org>
In-Reply-To: <20110210093544.GA17873@csn.ul.ie>
References: <1297257677-12287-1-git-send-email-namhyung@gmail.com>
	<20110209123803.4bb6291c.akpm@linux-foundation.org>
	<20110210093544.GA17873@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 10 Feb 2011 09:35:44 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > What's the point in that?  What relationship does the number of
> > contiguous empty lists have with the number of pages to free from one
> > list?
> > 
> 
> The point is to avoid excessive checking of empty lists.

It seems pretty simple to me to skip the testing of empty lists
altogether.  I suggested one way, however I suspect a better approach
might be to maintain a count of the number of pages in each list and
then change free_pcppages_bulk() so that it calculates up-front the
number of pages to free from each list (equal proportion of each) then
sits in a tight loop freeing that number of pages.

It might be that the overhead of maintaining the per-list count makes
that not worthwhile.  It'll be hard to tell because the count
maintenance cost will be smeared all over the place.

I doubt if any of it matters much, compared to the cost of allocating,
populating and freeing a page.  I just want free_pcppages_bulk() to
stop hurting my brain ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
