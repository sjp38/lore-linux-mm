Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C53456B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 10:30:45 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:30:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319143002.GQ24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332163591.18960.334.camel@twins>
 <20120319135745.GL24602@redhat.com>
 <4F673D73.90106@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F673D73.90106@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 04:06:43PM +0200, Avi Kivity wrote:
> I agree with Peter on this, but perhaps it's because my app will take
> all of 15 minutes to patch.  Up front knowledge is better than the
> kernel discovering it on its own.

I agree for qemu those soft bindings are fine.

But how you compute the statistical data is most difficult part, how
you collect them not so important after all.

The scheduler code Peter said is "that's not going to ever happen"
took several weeks of benchmarking and several rewrites to actual
materialize and be super happy about the core algorithm. If it's
simplified and just loops over the CPUs is because when you do
research and invent you can't waste time on actual implementation
details that just slow you down on the next rewrite of the algorithm
as you have to try again. So if my algorithms (abeit in a simplified
form compared to a real full implementation) works better, not having
the background scanning won't help Peter at all and you'll still be
better off with AutoNUMA.

When you focus only on the cost of collecting the information and no
actual discussion was spent yet on how to compute or react to it,
something's wrong... as that's the really interesting part of the code.

The fact the autonuma_balance() is simplified implementation is still
perfectly ok right now, as that's totally hidden kernel internal
thing, not even affecting kABI. Can be improved any time. Plus it's
not like it will backfire, it just won't be running as good as a full
more complex implementation that takes into account all the
runqueues. And implementating that won't be easy at all, there are
simpler things that are more urgent at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
