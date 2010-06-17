Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 48C576B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:30:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H0U9J5024101
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Jun 2010 09:30:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01ADA45DE7E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 09:30:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8138E45DE70
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 09:30:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 045751DB8037
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 09:30:07 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89C881DB803E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 09:30:06 +0900 (JST)
Date: Thu, 17 Jun 2010 09:25:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100617092538.c712342b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100616050640.GA10687@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615135928.GK26788@csn.ul.ie>
	<4C178868.2010002@redhat.com>
	<20100615141601.GL26788@csn.ul.ie>
	<20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20100616050640.GA10687@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 01:06:40 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jun 16, 2010 at 09:17:55AM +0900, KAMEZAWA Hiroyuki wrote:
> > yes. It's only called from 
> > 	- page fault
> > 	- add_to_page_cache()
> > 
> > I think we'll see no stack problem. Now, memcg doesn't wakeup kswapd for
> > reclaiming memory, it needs direct writeback.
> 
> The page fault code should be fine, but add_to_page_cache can be called
> with quite deep stacks.  Two examples are grab_cache_page_write_begin
> which already was part of one of the stack overflows mentioned in this
> thread, or find_or_create_page which can be called via
> _xfs_buf_lookup_pages, which can be called from under the whole XFS
> allocator, or via grow_dev_page which might have a similarly deep
> stack for users of the normal buffer cache.  Although for the
> find_or_create_page we usually should not have __GFP_FS set in the
> gfp_mask.
> 

Hmm. ok, then, memory cgroup needs some care.

BTW, why xbf_buf_create() use GFP_KERNEL even if it can be blocked ?
memory cgroup just limits pages for users, then, doesn't intend to
limit kernel pages. If this buffer is not for user(visible page cache), but for
internal structure, I'll have to add a code for ignoreing memory cgroup check
when gfp_mask doesn't have GFP_MOVABLE.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
