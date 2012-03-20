Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 194E36B0092
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 14:33:26 -0400 (EDT)
Message-ID: <4F68CD55.4040606@redhat.com>
Date: Tue, 20 Mar 2012 14:32:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
References: <20120223145417.261225fd@cuia.bos.redhat.com> <20120223150034.2c757b3a@cuia.bos.redhat.com> <20120223135614.7c4e02db.akpm@linux-foundation.org>
In-Reply-To: <20120223135614.7c4e02db.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

On 02/23/2012 04:56 PM, Andrew Morton wrote:

> We've been playing whack-a-mole with this search for many years.  What
> about developing a proper data structure with which to locate a
> suitable-sized hole in O(log(N)) time?

I got around to looking at this, and the more I look, the
worse things get.  The obvious (and probably highest
reasonable complexity) solution looks like this:

struct free_area {
	unsigned long address;
	struct rb_node rb_addr;
	unsigned long size;
	struct rb_node rb_size;
};

This works in a fairly obvious way for normal mmap
and munmap calls, inserting the free area into the tree
at the desired location, or expanding one that is already
there.

However, it totally falls apart when we need to get
aligned areas, for eg. hugetlb or cache coloring on
architectures with virtually indexed caches.

For those kinds of allocations, we are back to tree
walking just like today, giving us a fairly large amount
of additional complexity for no obvious gain.

Is this really the path we want to go down?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
