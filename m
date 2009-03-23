Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 489ED6B00BE
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:59:41 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N91A1N015909
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 18:01:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B164845DE54
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:01:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 891F845DE50
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:01:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69F0AE08003
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:01:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C1DE1DB8037
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:01:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU  lists
In-Reply-To: <20090323084254.GA1685@cmpxchg.org>
References: <20090323111615.69F3.A69D9226@jp.fujitsu.com> <20090323084254.GA1685@cmpxchg.org>
Message-Id: <20090323175507.6A18.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 18:01:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 23, 2009 at 11:21:36AM +0900, KOSAKI Motohiro wrote:
> > > Hmm,,
> > > 
> > > This patch is another thing unlike previous series patches.
> > > Firstly, It looked good to me.
> > > 
> > > I think add_to_page_cache_lru have to become a fast path.
> > > But, how often would ramfs and shmem function be called ?
> > > 
> > > I have a concern for this patch to add another burden.
> > > so, we need any numbers for getting pros and cons.
> > > 
> > > Any thoughts ?
> > 
> > this is the just reason why current code don't call add_page_to_unevictable_list().
> > add_page_to_unevictable_list() don't use pagevec. it is needed for avoiding race.
> > 
> > then, if readahead path (i.e. add_to_page_cache_lru()) use add_page_to_unevictable_list(),
> > it can cause zone->lru_lock contention storm.
> 
> How is it different then shrink_page_list()?  If readahead put a
> contiguous chunk of unevictable pages to the file lru, then
> shrink_page_list() will as well call add_page_to_unevictable_list() in
> a loop.

it's probability issue.

readahead: we need to concern
	(1) readahead vs readahead
	(2) readahead vs reclaim

vmscan: we need to concern
	(3) background reclaim vs foreground reclaim

So, (3) is rarely event than (1) and (2).
Am I missing anything?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
