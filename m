Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 93CC36B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 09:01:58 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 0/3] retry slab allocation after first failure
Date: Wed, 19 Dec 2012 18:01:39 +0400
Message-Id: <1355925702-7537-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

Hi everybody,

First, an introduction: I am doing this work as part of a larger work to have a
good support for memcg targetted shrinkers. The winning approch so far is to
try reuse the generic LRU mechanism proposed by Dave Shrinnker (The Australian
xfs guy, in case you are wondering). But we still don't know that yet. As
usual, I am trying to flush work that seems independent of the main work per
se.  I would love to see them merged if they have merit on their own, but I
will also be happy to carry them in my personal tree if needed.

I used private patches to generate the results in here, that actually shrink
per-memcg.  It will take me some time to post them - but I hope not much.
However, it is trivial to functionally describe them: they shrink objects
belonging to a memcg instead of globally. Also, they only make the scenario I
am describing here more likely: they don't *create* those problems.

In a nutshell: When reclaim kicks in, we will first go through LRU and/or
page-cache pages. If we manage to free them, we can be sure at least one page
is free. After that, we go scan the object shrinkers.

With the shrinkers, however, the story is different. We shrink objects that
lives in pages, but that doesn't mean we will be able to free a whole page.
That heavily depends on the temporal characteristics of the workload being run.

When the kmem allocators find no space left in the existing pages, they will
resort to allocate a new page. Despite the architectural differences in the
multiple allocators they all work like this. What we can conclude from this
is that if an object allocation failed, we can be absolutely sure that a page
allocation also failed. However, it is very likely that the page allocator will
not give up before conducting reclaim.

The reclaim round, despite not being able to free a whole page, may very well
have been able to free objects spread around multiple pages. Which means that
at this point, a new object allocation would likely succeed.

I conducted a simple experiment to easily trigger this, described as follows.

1) I have a somewhat fresh Fedora installation (it is Fedora + a linux git tree
   + some random small stuff). I then run find, sitting in a kmem-limited memcg.

2) I bisect the values of memory.kmem.limit_in_bytes, until I find an amount of
   memory that is enough to run the workload without no memory allocation
   failures three times in a row (to account for random noise).

3) I do the same, using my still not posted targetted shrinking patches. At this
   point, we are more or less simulating a physical box with global reclaim
   under very high pressure. We're only tweaking the odds in favour of failure.

4) I do the same, using the patches I am now posting in here. Meaning: after
   direct reclaim failed and a page could not be freed, we try it again if our
   flags allow us.

The result of 2), is that this whole workload fits in ~65M. Since we don't ever
reclaim, this is a very good approximation of our working set size.

In 3), because direct reclaim triggers and sometimes manages to free some pages,
this fits in ~28M.

In 4), retrying once after failure, the workload fits in ~14M.

So I believe this introduces a more resilient behavior, and is good on its own.
While I agree that this is not a *likely* scenario upstream (it will be for
containers), if we honestly believed kernel allocations would not fail, we would
not be testing their return value =)

P.S.1: I know it is merge window and everything, so no need to rush.
P.S.2: I compiled it locally with slab, slub and slob. But I haven't passed it
through any thorough randconfig bomb yet.

Any comments appreciated.

Glauber Costa (3):
  slab: single entry-point for slab allocation
  slub: remove slab_alloc wrapper
  sl[auo]b: retry allocation once in case of failure.

 mm/slab.c | 90 ++++++++++++++++-----------------------------------------------
 mm/slab.h | 42 +++++++++++++++++++++++++++++
 mm/slob.c | 27 ++++++++++++++++---
 mm/slub.c | 34 +++++++++++++++---------
 4 files changed, 109 insertions(+), 84 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
