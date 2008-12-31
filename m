Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 535F26B00A7
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 17:38:11 -0500 (EST)
Date: Wed, 31 Dec 2008 16:37:44 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] cpuset,mm: fix allocating page cache/slab object on the
 unallowed node when memory spread is set
In-Reply-To: <200812311413.45127.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0812311633150.21130@quilx.com>
References: <49547B93.5090905@cn.fujitsu.com> <20081230142805.3c6f78e3.akpm@linux-foundation.org>
 <200812311413.45127.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, miaox@cn.fujitsu.com, menage@google.com, penberg@cs.helsinki.fi, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Dec 2008, Nick Piggin wrote:

> These paths are pretty performance critical. Why don't cpusets code do this
> work in the slowpath where the cpuset's mems_allowed gets changed rather
> than putting these calls all over the place with apparently no real rhyme or
> reason :( (this is not against your patch, but just this part of the cpusets
> design)

Right.

> > d) How does slub handle this problem?
>
> SLUB seems to do a "sloppy" kind of memory policy allocation, where it just
> relies on the page allocator to hand us the correct page and AFAIKS does not
> exactly obey this stuff all the time.

Slub avoids hanlding memory policy decisions and lets the page allocator
deal with it. That means that memory policies are not enforced on an
object basis but on a page basis. If you allocate a series of objects
under MPOL_INTERLEAVE then SLAB will give you one object from each node.
SLUB will give you objects from one page until the objects in a page are
exhausted. The next page will be acquired according to the current
memory policy. Meaning the page will come from the next node if
MPOL_INTERLEAVE is set. The following set of objects will be allocated
from that node. This allows a faster allocation for NUMA since the cachelines
for allocation can be kept hot. The page are still allocated from all
nodes.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
