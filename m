Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CAF0B6B01B8
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 02:28:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H6S0Gl019287
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Jun 2010 15:28:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6CCB45DE7B
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 15:27:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E82C45DE6F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 15:27:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0ED4E38009
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 15:27:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9C51DB8042
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 15:27:58 +0900 (JST)
Date: Thu, 17 Jun 2010 15:23:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100617152312.43e84eb0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100617061647.GA21277@infradead.org>
References: <1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615135928.GK26788@csn.ul.ie>
	<4C178868.2010002@redhat.com>
	<20100615141601.GL26788@csn.ul.ie>
	<20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20100616050640.GA10687@infradead.org>
	<20100617092538.c712342b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100617061647.GA21277@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010 02:16:47 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 17, 2010 at 09:25:38AM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > BTW, why xbf_buf_create() use GFP_KERNEL even if it can be blocked ?
> > memory cgroup just limits pages for users, then, doesn't intend to
> > limit kernel pages.
> 
> You mean xfs_buf_allocate?  It doesn't in the end.  It goes through the
> xfs_kmem helper which clear __GFP_FS if we're currently inside a
> filesystem transaction (PF_FSTRANS is set) or a caller specificly
> requested it to be disabled even without that by passig the
> XBF_DONT_BLOCK flag.
> 
Ah, sorry. My question was wrong.

If xfs_buf_allocate() is not for pages on LRU but for kernel memory,
memory cgroup has no reason to charge against it because we can't reclaim
memory which is not on LRU.

Then, I wonder I may have to add following check 

	if (!(gfp_mask & __GFP_RECLAIMABLE)) {
		/* ignore this. we just charge against reclaimable memory on LRU. */
		return 0;
	}

to mem_cgroup_charge_cache() which is a hook for accounting page-cache.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
