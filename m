Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 115496B0047
	for <linux-mm@kvack.org>; Sat,  4 Sep 2010 04:00:28 -0400 (EDT)
Date: Sat, 4 Sep 2010 17:58:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100904075840.GE705@dastard>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
 <1283504926-2120-4-git-send-email-mel@csn.ul.ie>
 <20100903160026.564fdcc9.akpm@linux-foundation.org>
 <20100904022545.GD705@dastard>
 <20100903202101.f937b0bb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903202101.f937b0bb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 08:21:01PM -0700, Andrew Morton wrote:
> On Sat, 4 Sep 2010 12:25:45 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > Still, given the improvements in performance from this patchset,
> > I'd say inclusion is a no-braniner....
> 
> OK, thanks.
> 
> It'd be interesting to check the IPI frequency with and without -
> /proc/interrupts "CAL" field.  Presumably it went down a lot.

Maybe I suspected you would ask for this. I happened to dump
/proc/interrupts after the livelock run finished, so you're in
luck :)

The lines below are:

before: before running the single 50M inode create workload
after: the numbers after the run completes
livelock: the numbers after two runs with a livelock in the second

Vanilla 2.6.36-rc3:

before:      561   350   614   282   559   335   365   363
after:	   10472 10473 10544 10681  9818 10837 10187  9923

.36-rc3 With patchset:

before:      452   426   441   337   748   321   498   357
after:      9463  9112  8671  8830  9391  8684  9768  8971

The numbers aren't that different - roughly 10% lower on average
with the patchset. I will state that vanilla kernel runs I ijust did
had noticably more consistent performance than the previous results
I had acheived, so perhaps it wasn't triggering the livelock
conditions as effectively this time through.

And finally:

livelock:  59458 58367 58559 59493 59614 57970 59060 58207

So the livelock case tends to indicate roughly 40,000 more IPI
interrupts per CPU occurred.  The livelock occurred for close to 5
minutes, so that's roughly 130 IPIs per second per CPU....

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
