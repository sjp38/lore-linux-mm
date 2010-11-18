Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E98C6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 04:28:29 -0500 (EST)
Date: Thu, 18 Nov 2010 09:28:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/8] mm: compaction: Use the LRU to get a hint on where
	compaction should start
Message-ID: <20101118092812.GF8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <1290010969-26721-8-git-send-email-mel@csn.ul.ie> <20101118181048.7bdfbb38.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101118181048.7bdfbb38.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 06:10:48PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Nov 2010 16:22:48 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The end of the LRU stores the oldest known page. Compaction on the other
> > hand always starts scanning from the start of the zone. This patch uses
> > the LRU to hint to compaction where it should start scanning from. This
> > means that compaction will at least start with some old pages reducing
> > the impact on running processes and reducing the amount of scanning. The
> > check it makes is racy as the LRU lock is not taken but it should be
> > harmless as we are not manipulating the lists without the lock.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Hmm, does this patch make a noticable difference ?

To scanning rates - yes.

> Isn't it better to start scan from the biggest free chunk in a zone ?
> 

Not necessarily. The biggest free chunk does not necessarily contain old
pages so one could stall a process by migrating a very active page. The same
applies for selecting the pageblock with the oldest LRU page of course but
it is less likely.

I prototyped a a patch that constantly used the buddy lists to select the
next pageblock to migrate from. The problem was that it was possible for it
to infinite loop because it could migrate from the same block more than once
in a migration cycle. To resolve that, I'd have to keep track of visited
pageblocks but I didn't want to require additional memory unless it was
absolutly necessary. I think the concept can be perfected and its impact
would be a reduction of scanning rates but it's not something that is
anywhere near merging yet.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
