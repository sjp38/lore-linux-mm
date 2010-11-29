Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 90DC06B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:36:02 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT2ZxHT029692
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 29 Nov 2010 11:35:59 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CA6945DE61
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:35:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BA4845DE55
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:35:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B1B91DB803B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:35:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA1191DB803A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:35:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
In-Reply-To: <AANLkTikBvHn3Tc_RKTM8tGKjK1kgEZYsBCjXZSZ+Ri+-@mail.gmail.com>
References: <20101129090514.829C.A69D9226@jp.fujitsu.com> <AANLkTikBvHn3Tc_RKTM8tGKjK1kgEZYsBCjXZSZ+Ri+-@mail.gmail.com>
Message-Id: <20101129111900.82AB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 29 Nov 2010 11:35:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi

> > I don't like this change because fadvise(DONT_NEED) is rarely used
> > function and this PG_reclaim trick doesn't improve so much. In the
> > other hand, It increase VM state mess.
> 
> Chick-egg problem.
> Why fadvise(DONT_NEED) is rarely used is it's hard to use effective.
> mincore + fdatasync + fadvise series is very ugly.
> This patch's goal is to solve it.

Well, I haven't put opposition to your previous patch for this reason.
I think every one have agree mincore + fdatasync + fadvise mess is ugly.

However I doubt PG_reclaim trick is so effective. I mean, _if_ it's effective, our current
streaming io heristics doesn't work so effective. It's bad. and if so, we should fix
it generically. That's the reason why I prefer to use simple add_page_to_lru_list().

Please remember why do we made this one. rsync has special io access pattern
then our streaming io detection doesn't work so good. therefore we decided to
improve manual knob. But, why do we need to make completely different behavior
manual DONT_NEED suggestion and automatic DONT_NEED detection?

That's my point.


> PG_reclaim trick would prevent working set eviction.
> If you fadvise call and there are the invalidated page which are
> dirtying in middle of inactive LRU,
> reclaimer would evict working set of inactive LRU's tail even if we
> have a invalidated page in LRU.
> It's bad.
> 
> About VM state mess, PG_readahead already have done it.
> But I admit this patch could make it worse and that's why I Cced Wu Fengguang.
> 
> The problem it can make is readahead confusing and working set
> eviction after writeback.
> I can add ClearPageReclaim of mark_page_accessed for clear flag if the
> page is accessed during race.
> But I didn't add it in this version because I think it's very rare case.
> 
> I don't want to add new page flag due to this function or revert merge
> patch of (PG_readahead and PG_reclaim)
> 
> 
> >
> > However, I haven't found any fault and unworked reason in this patch.
> >
> Thanks for the good review, KOSAKI. :)
> 
> 
> -- 
> Kind regards,
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
