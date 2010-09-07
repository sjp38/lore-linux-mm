Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82C096B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:23:53 -0400 (EDT)
Date: Tue, 7 Sep 2010 09:23:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct
 reclaim allocation fails
In-Reply-To: <20100906040243.GA7362@dastard>
Message-ID: <alpine.DEB.2.00.1009070918030.14634@router.home>
References: <20100903160026.564fdcc9.akpm@linux-foundation.org> <20100904022545.GD705@dastard> <20100903202101.f937b0bb.akpm@linux-foundation.org> <20100904075840.GE705@dastard> <20100904081414.GF705@dastard> <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard> <20100905060539.GA17450@localhost> <20100905131447.GJ705@dastard> <20100905134554.GA7083@localhost> <20100906040243.GA7362@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010, Dave Chinner wrote:

> [  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
> [  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
> [  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
> [  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240

fallback_alloc() showing up here means that one page allocator call from
SLAB has already failed. SLAB then did an expensive search through all
object caches on all nodes to find some available object. There were no
objects in queues at all therefore SLAB called the page allocator again
(kmem_getpages()).

As soon as memory is available (on any node or any cpu, they are all
empty) SLAB will repopulate its queues(!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
