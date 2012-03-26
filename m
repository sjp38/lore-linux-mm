Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4C0596B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 15:45:06 -0400 (EDT)
Date: Mon, 26 Mar 2012 21:44:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
Message-ID: <20120326194435.GW5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
 <1332786353.16159.173.camel@twins>
 <4F70C365.8020009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F70C365.8020009@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Mar 26, 2012 at 03:28:37PM -0400, Rik van Riel wrote:
> Agreed, it looks O(N), but because every CPU will be calling
> it its behaviour will be O(N^2) and has the potential to
> completely break systems with a large number of CPUs.

As I wrote in the comment before the function, math speaking, this
looks like O(N) but it is O(1), not O(N) nor O(N^2). This is because N
= NR_CPUS = 1.

As I also wrote in the comment before the function, this is called at
every schedule in the short term primarily because I want to see a
flood if this algorithm does something wrong after I do.

echo 1 >/sys/kernel/mm/autonuma/debug

 * This has O(N) complexity but N isn't the number of running
 * processes, but the number of CPUs, so if you assume a constant
 * number of CPUs (capped at NR_CPUS) it is O(1). O(1) misleading math
 * aside, the number of cachelines touched with thousands of CPU might
 * make it measurable. Calling this at every schedule may also be
 * overkill and it may be enough to call it with a frequency similar
 * to the load balancing, but by doing so we're also verifying the
 * algorithm is a converging one in all workloads if performance is
 * improved and there's no frequent CPU migration, so it's good in the
 * short term for stressing the algorithm.

Over time (not urgent) this can be called at a regular interval like
load_balance() or be more integrated within CFS so it doesn't need to
be called at all.

For the short term it shall be called at every schedule for debug
reasons so I wouldn't suggest to make an effort to call it at lower
frequency right now. If somebody wants to make an effort to make it
more integrated in CFS that's welcome though, but I would still like a
tweak to force the algorithm synchronously during every schedule
decision like now so I can verify it converges at the scheduler level
and there is not a flood of worthless bounces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
