Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D858B6B01AD
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:48:50 -0400 (EDT)
Date: Wed, 16 Jun 2010 16:48:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/12] vmscan: Setup pagevec as late as possible in
 shrink_page_list()
Message-Id: <20100616164801.9d3c0d99.akpm@linux-foundation.org>
In-Reply-To: <1276514273-27693-10-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-10-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 12:17:50 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> shrink_page_list() sets up a pagevec to release pages as according as they
> are free. It uses significant amounts of stack on the pagevec. This
> patch adds pages to be freed via pagevec to a linked list which is then
> freed en-masse at the end. This avoids using stack in the main path that
> potentially calls writepage().
> 

hm, spose so.  I cen't see any trivial way to eliminate the local
pagevec there.

> +	if (pagevec_count(&freed_pvec))
> +		__pagevec_free(&freed_pvec);
> ...
> -	if (pagevec_count(&freed_pvec))
> -		__pagevec_free(&freed_pvec);

That's an open-coded pagevec_free().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
