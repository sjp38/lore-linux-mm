Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF5B26B01AD
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 01:07:06 -0400 (EDT)
Date: Wed, 16 Jun 2010 01:06:40 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100616050640.GA10687@infradead.org>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
 <1276514273-27693-13-git-send-email-mel@csn.ul.ie>
 <4C16A567.4080000@redhat.com>
 <20100615114510.GE26788@csn.ul.ie>
 <4C17815A.8080402@redhat.com>
 <20100615135928.GK26788@csn.ul.ie>
 <4C178868.2010002@redhat.com>
 <20100615141601.GL26788@csn.ul.ie>
 <20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 09:17:55AM +0900, KAMEZAWA Hiroyuki wrote:
> yes. It's only called from 
> 	- page fault
> 	- add_to_page_cache()
> 
> I think we'll see no stack problem. Now, memcg doesn't wakeup kswapd for
> reclaiming memory, it needs direct writeback.

The page fault code should be fine, but add_to_page_cache can be called
with quite deep stacks.  Two examples are grab_cache_page_write_begin
which already was part of one of the stack overflows mentioned in this
thread, or find_or_create_page which can be called via
_xfs_buf_lookup_pages, which can be called from under the whole XFS
allocator, or via grow_dev_page which might have a similarly deep
stack for users of the normal buffer cache.  Although for the
find_or_create_page we usually should not have __GFP_FS set in the
gfp_mask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
