Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 27E376B0055
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 21:26:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N2Lc6T006583
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 11:21:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E0E245DE56
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:21:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC0F945DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:21:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A7CF8E3800A
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:21:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 39066E38004
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:21:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU  lists
In-Reply-To: <28c262360903221744r6d275294gdc8ad3a12b8c5361@mail.gmail.com>
References: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org> <28c262360903221744r6d275294gdc8ad3a12b8c5361@mail.gmail.com>
Message-Id: <20090323111615.69F3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 11:21:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Hmm,,
> 
> This patch is another thing unlike previous series patches.
> Firstly, It looked good to me.
> 
> I think add_to_page_cache_lru have to become a fast path.
> But, how often would ramfs and shmem function be called ?
> 
> I have a concern for this patch to add another burden.
> so, we need any numbers for getting pros and cons.
> 
> Any thoughts ?

this is the just reason why current code don't call add_page_to_unevictable_list().
add_page_to_unevictable_list() don't use pagevec. it is needed for avoiding race.

then, if readahead path (i.e. add_to_page_cache_lru()) use add_page_to_unevictable_list(),
it can cause zone->lru_lock contention storm.

then, if nobody have good performance result, I don't ack this patch.


> On Mon, Mar 23, 2009 at 5:13 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Check if the mapping is evictable when initially adding page cache
> > pages to the LRU lists. ?If that is not the case, add them to the
> > unevictable list immediately instead of leaving it up to the reclaim
> > code to move them there.
> >
> > This is useful for ramfs and locked shmem which mark whole mappings as
> > unevictable and we know at fault time already that it is useless to
> > try reclaiming these pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
