Message-ID: <466F66E3.8020200@yahoo.com.au>
Date: Wed, 13 Jun 2007 13:39:15 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au> <20070613033306.GA15169@linux-sh.org>
In-Reply-To: <20070613033306.GA15169@linux-sh.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Mundt wrote:
> On Wed, Jun 13, 2007 at 01:24:01PM +1000, Nick Piggin wrote:
> 
>>Paul Mundt wrote:
>>
>>>Here's an updated copy of the patch adding simple NUMA support to SLOB,
>>>against the current -mm version of SLOB this time.
>>>
>>>I've tried to address all of the comments on the initial version so far,
>>>but there's obviously still room for improvement.
>>>
>>>This approach is not terribly scalable in that we still end up using a
>>>global freelist (and a global spinlock!) across all nodes, making the
>>>partial free page lookup rather expensive. The next step after this will
>>>be moving towards split freelists with finer grained locking.
>>
>>I just think that this is not really a good intermediate step because
>>you only get NUMA awareness from the first allocation out of a page. I
>>guess that's an easy no-brainer for bigblock allocations, but for SLUB
>>proper, it seems not so good.
>>
>>For a lot of workloads you will have a steady state where allocation and
>>freeing rates match pretty well and there won't be much movement of pages
>>in and out of the allocator. In this case it will be back to random
>>allocations, won't it?
>>
> 
> That's why I tossed in the node id matching in slob_alloc() for the
> partial free page lookup. At the moment the logic obviously won't scale,
> since we end up scanning the entire freelist looking for a page that
> matches the node specifier. If we don't find one, we could rescan and
> just grab a block from another node, but at the moment it just continues
> on and tries to fetch a new page for the specified node.

Oh, I didn't notice that. OK, sorry that would work.

... but that goes against Matt's direction of wanting to improve basic
things like SMP scalability before NUMA awareness. I think once we had
per-CPU lists in place for SMP scalability, NUMA come much more naturally
and easily.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
