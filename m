Message-ID: <4702E49D.2030206@google.com>
Date: Tue, 02 Oct 2007 17:38:53 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] cpuset write throttle
References: <469D3342.3080405@google.com>	<46E741B1.4030100@google.com>	<46E7434F.9040506@google.com> <20070914161517.5ea3847f.akpm@linux-foundation.org>
In-Reply-To: <20070914161517.5ea3847f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, a.p.zijlstra@chello.nl, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 11 Sep 2007 18:39:27 -0700
> Ethan Solomita <solo@google.com> wrote:
> 
>> Make page writeback obey cpuset constraints
> 
> akpm:/usr/src/25> pushpatch 
> patching file mm/page-writeback.c
> Hunk #1 FAILED at 103.
> Hunk #2 FAILED at 129.
> Hunk #3 FAILED at 166.
> Hunk #4 FAILED at 252.
> Hunk #5 FAILED at 267.
> Hunk #6 FAILED at 282.
> Hunk #7 FAILED at 301.
> Hunk #8 FAILED at 313.
> Hunk #9 FAILED at 329.
> Hunk #10 succeeded at 563 (offset 175 lines).
> Hunk #11 FAILED at 575.
> Hunk #12 FAILED at 607.
> 11 out of 12 hunks FAILED -- saving rejects to file mm/page-writeback.c.rej
> Failed to apply cpuset-write-throttle
> 
> :(
> 
> 
> Huge number of rejects against Peter's stuff.  Please redo for next -mm.

	I've been looking at how to merge my cpuset write throttling changes
with Peter's per-BDI write throttling changes that have just been taken
by akpm. (Quick simplifying summary: my proposed patchset will only
throttle a process based upon dirty pages in the nodes to which the
process has access, as limited by cpuset's mems_allowed, thus protecting
one cpuset from the dirtying tendencies of other cpusets)

	This is essential if cpusets are to isolate tasks from each other, so
we need to find a way to make it work with per-BDI. Theoretically we
could track of the per-BDI information within per-node structures
instead of globally, but that could lead to a scary increase in code
complexity and CPU time spent in get_dirty_limits. We don't want the
disk to finish flushing all its pages to disk before we calculate the
dirty limit. 8)

	We could keep my changes and Peter's changes completely independent
calculations, and make it an "or", i.e. the caller of get_dirty_limits
will decide to throttle if either the per-BDI stats signal a throttling
or if the per-cpuset stats signal a throttling.

	Unfortunately this eliminates one of the main reasons for the
per-cpuset throttling. If one cpuset is responsible for pushing one
disk/BDI to its dirty limit, someone in another cpuset can get throttled.

	If we used "and" instead of "or", i.e. the caller is only throttled if
get_dirty_limits would throttle because of both per-BDI stats and
per-cpuset stats we make my cpusets case happy, but in the above
scenario the other cpuset can continue to dirty an overly-dirtied BDI
until they hit their own cpuset limits.

	I'm hoping to get some input from Christoph, Peter, and anyone else who
can think of a good way to bring this all together.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
