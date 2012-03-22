Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E7BF46B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:49:58 -0400 (EDT)
Date: Thu, 22 Mar 2012 19:49:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120322184925.GT24602@redhat.com>
References: <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
 <20120321124937.GX24602@redhat.com>
 <87limtboet.fsf@danplanet.com>
 <20120321225242.GL24602@redhat.com>
 <20120322001722.GQ24602@redhat.com>
 <873990buuy.fsf@danplanet.com>
 <20120322142735.GE24602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322142735.GE24602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dan,

On Thu, Mar 22, 2012 at 03:27:35PM +0100, Andrea Arcangeli wrote:
> current code would optimally perform, if all nodes are busy and there
> aren't idle cores (or only idle siblings). I guess I'll leave the HT
> optimizations for later. I probably shall measure this again with HT off.

I added the latest virt measurement with KVM for kernel build and
memhog. I also measured how much I'd save by increasing the
knuma_scand pass frequency (scan_sleep_pass_millisecs) from 10sec
default (5000 value) to 30sec. I also tried 1min but it was within
error range of 30sec. 10sec -> 30sec is also almost within error range
showing the cost is really tiny. Luckily the numbers were totally
stable by running a -j16 loop on both VM (each VM had 12 vcpus on a
host with 24 CPUs) and the error was less than 1sec for each kernel
build (on tmpfs obviously and totally stripped down userland in both
guest and host).

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120322.pdf

slide 11 and 12.

This is with THP on, with THP off things would be different likely but
hey THP off is like 20% slower or more on a kernel build in guest in
the first place.

I'm satisfied with the benchmarks results so far and more will come
soon, but now it's time to go back coding and add THP native
migration. That will benefit everyone, from cpuset in userland to
numa/sched.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
