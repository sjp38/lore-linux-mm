Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC27D6B0089
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 02:18:36 -0400 (EDT)
Date: Fri, 10 Sep 2010 16:17:46 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100910061746.GE705@dastard>
References: <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
 <20100906040243.GA7362@dastard>
 <20100906084015.GJ8384@csn.ul.ie>
 <20100906215023.GC7362@dastard>
 <20100908084923.GW705@dastard>
 <20100909123910.GP29263@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100909123910.GP29263@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 09, 2010 at 01:39:10PM +0100,  wrote:
> It has been pointed out that the fix potentially increases the number of
> IPIs sent. On larger machines, I worry that these delays could be severe
> and we'll see other problems down the line. Hence, I'd like to reduce
> the number of calls to drain_all_pages() without eliminating them
> entirely. I'm currently in the process of testing the following patch
> but can you try it as well please?
> 
> In particular, I am curious to see if the performance of fs_mark
> improves any and if the interrupt counts drop as a result of the patch.

The interrupt counts have definitely dropped - this is after
creating 200M inodes and then removing them all:

CAL:      11154 10596 11804 15366 10048 12916 13049 9864

That's in the same ballpark as a single 50M inode create run without
the patch.

Performance seems a bit lower, though (2-3% maybe less), and CPU
usage seems a bit higher (stays much closer to 800% than 700-750%
without the patch). Those are subjective observations from watching
graphs and counters, so take them with a grain of salt.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
