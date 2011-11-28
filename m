Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D5EA76B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 05:15:41 -0500 (EST)
Received: by iaek3 with SMTP id k3so11689905iae.14
        for <linux-mm@kvack.org>; Mon, 28 Nov 2011 02:15:39 -0800 (PST)
Date: Mon, 28 Nov 2011 02:15:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, debug: test for online nid when allocating on single
 node
In-Reply-To: <20111124095205.GQ19415@suse.de>
Message-ID: <alpine.DEB.2.00.1111280211570.28069@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111221724550.18644@chino.kir.corp.google.com> <20111124095205.GQ19415@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, 24 Nov 2011, Mel Gorman wrote:

> > Calling alloc_pages_exact_node() means the allocation only passes the
> > zonelist of a single node into the page allocator.  If that node isn't
> > online, it's zonelist may never have been initialized causing a strange
> > oops that may not immediately be clear.
> > 
> > I recently debugged an issue where node 0 wasn't online and an allocator
> > was passing 0 to alloc_pages_exact_node() and it resulted in a NULL
> > pointer on zonelist->_zoneref.  If CONFIG_DEBUG_VM is enabled, though, it
> > would be nice to catch this a bit earlier.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Out of curiousity, who was passing in the ID of an offline node to
> alloc_pages_exact_node() ?
> 

It was the block layer in blk_throtl_init() because it passes the ->node 
field of request_queue to the slab layer which uses 
alloc_pages_exact_node() and requeue_queue is allocated with __GFP_ZERO 
and ->node isn't initialized until later.  At the same time, the machine 
only has a single node online, node 1, where the crashkernel was 
allocated.  My analysis is at 
http://marc.info/?l=linux-kernel&m=132195611123426

I've worked with kernels without a node 0 very successfully since about 
2.6.18 so the VM appears pretty stable in that regard, too, which is good 
news.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
