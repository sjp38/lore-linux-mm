Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBF8F9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:41:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 602D33EE0C3
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:32 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48F0C45DE4E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30C1245DE4D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 227A1E78002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95FC9E78004
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:41:31 +0900 (JST)
Date: Wed, 27 Apr 2011 17:34:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 6/8] In order putback lru core
Message-Id: <20110427173450.82cef21e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 27 Apr 2011 01:25:23 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> This patch defines new APIs to putback the page into previous position of LRU.
> The idea is simple.
> 
> When we try to putback the page into lru list and if friends(prev, next) of the pages
> still is nearest neighbor, we can insert isolated page into prev's next instead of
> head of LRU list. So it keeps LRU history without losing the LRU information.
> 
> Before :
> 	LRU POV : H - P1 - P2 - P3 - P4 -T
> 
> Isolate P3 :
> 	LRU POV : H - P1 - P2 - P4 - T
> 
> Putback P3 :
> 	if (P2->next == P4)
> 		putback(P3, P2);
> 	So,
> 	LRU POV : H - P1 - P2 - P3 - P4 -T
> 
> For implement, we defines new structure pages_lru which remebers
> both lru friend pages of isolated one and handling functions.
> 
> But this approach has a problem on contiguous pages.
> In this case, my idea can not work since friend pages are isolated, too.
> It means prev_page->next == next_page always is false and both pages are not
> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
> So for solving the problem, I can change the idea.
> I think we don't need both friend(prev, next) pages relation but
> just consider either prev or next page that it is still same LRU.
> Worset case in this approach, prev or next page is free and allocate new
> so it's in head of LRU and our isolated page is located on next of head.
> But it's almost same situation with current problem. So it doesn't make worse
> than now and it would be rare. But in this version, I implement based on idea
> discussed at LSF/MM. If my new idea makes sense, I will change it.
> 

I think using only 'next'(prev?) pointer will be enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
