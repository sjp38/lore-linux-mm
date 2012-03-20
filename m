Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9EFA26B00E8
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 15:01:24 -0400 (EDT)
Date: Tue, 20 Mar 2012 20:00:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
Message-ID: <20120320190055.GZ24602@redhat.com>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
 <20120223150034.2c757b3a@cuia.bos.redhat.com>
 <20120223135614.7c4e02db.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120223135614.7c4e02db.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, hughd@google.com

On Thu, Feb 23, 2012 at 01:56:14PM -0800, Andrew Morton wrote:
> We've been playing whack-a-mole with this search for many years.  What
> about developing a proper data structure with which to locate a
> suitable-sized hole in O(log(N)) time?

I intended to implement it a couple of years ago.

It takes a change to the rbtree code so that when rb_erase and
rb_insert_color are called, proper methods are called to notify the
caller that there's been a rotation (probably calling a new
rb_insert_color_with_metadata(&method(left_rot, right_rot)) ). So that
these methods can update the new status of the tree. So you can keep
the "max" hole information for the left and right side of the tree at
the top node, and if the left side of the tree from the top doesn't
have a big enough max hole you take the right immediately (if if fits)
skipping over everything that isn't interesting and you keep doing so
until the max hole on right or left fits the size of the allocation
request (and then you find what you were searching for in vma and
vma->vm_next). It's very tricky but it should be possible. Still it
would remain generic code in rbtree.c, not actually knowing it's the
max hole info we're collecting at the root node for left and right
nodes. Maybe only the left side of the tree max hole needs to be
collected, not having the right size only means a worst case O(log(N))
walk on the tree (taking ->right all the time 'till the leaf) so it'd
be perfectly ok and it may simplify things a lot having only the max
hole on the left.

I'm too busy optimizing AutoNUMA even further to delve into this but I
hope somebody implements it. I thought about exactly this when I've
seen these patches floating around, so I'm glad you mentioned it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
