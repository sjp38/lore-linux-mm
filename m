Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 593D86B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:18:54 -0500 (EST)
Date: Thu, 12 Jan 2012 17:18:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
Message-ID: <20120112171847.GN4118@suse.de>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
 <1326276668-19932-3-git-send-email-mgorman@suse.de>
 <1326381492.2442.188.camel@twins>
 <20120112153712.GL4118@suse.de>
 <1326383551.2442.203.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1326383551.2442.203.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E.   McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

On Thu, Jan 12, 2012 at 04:52:31PM +0100, Peter Zijlstra wrote:
> On Thu, 2012-01-12 at 15:37 +0000, Mel Gorman wrote:
> > On Thu, Jan 12, 2012 at 04:18:12PM +0100, Peter Zijlstra wrote:
> > > On Wed, 2012-01-11 at 10:11 +0000, Mel Gorman wrote:
> > > > At least one bug report has
> > > > been seen on ppc64 against a 3.0 era kernel that looked like a bug
> > > > receiving interrupts on a CPU being offlined. 
> > > 
> > > Got details on that Mel? The preempt_disable() in on_each_cpu() should
> > > serialize against the stop_machine() crap in unplug.
> > 
> > I might have added 2 and 2 together and got 5.
> > 
> > The stack trace clearly was while sending IPIs in on_each_cpu() and
> > always when under memory pressure and stuck in direct reclaim. This was
> > on !PREEMPT kernels where preempt_disable() is a no-op. That is why I
> > thought get_online_cpu() would be necessary.
> 
> For non-preempt the required scheduling of stop_machine() will have to
> wait even longer. Still there might be something funny, some of the
> hotplug notifiers are ran before the stop_machine thing does its thing
> so there might be some fun interaction.

Ok, how about this as a replacement patch?

---8<---
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page allocator: Do not drain per-cpu lists via IPI from page allocator context

While running a CPU hotplug stress test under memory pressure, it
was observed that the machine would halt with no messages logged
to console. This is difficult to trigger and required a machine
with 8 cores and plenty of memory. In at least one case on ppc64,
the warning in include/linux/cpumask.h:107 triggered implying that
IPIs are being sent to offline CPUs in some cases.

A suspicious part of the problem is that the page allocator is sending
IPIs using on_each_cpu() without calling get_online_cpus() to prevent
changes to the online cpumask. It is depending on preemption being
disabled to protect it which is a no-op on !PREEMPT kernels. This means
that a thread can be reading the mask in smp_call_function_many() when
an attempt is made to take a CPU offline. The expectation is that this
is not a problem as the stop_machine() used during CPU hotplug should
be able to prevent any problems as the reader of the online mask will
prevent stop_machine making forward progress but it's unhelpful.

On the other side, the mask can also be read while the CPU is being
brought online. In this case it is the responsibility of the
architecture that the CPU is able to receive and handle interrupts
before being marked active but that does not mean they always get it
right.

Sending excessive IPIs from the page allocator is a bad idea. In low
memory situations, a large number of processes can drain the per-cpu
lists at the same time, in quick succession and on many CPUs which is
pointless. In light of this and the unspecific CPU hotplug concerns,
this patch removes the call drain_all_pages() after failing direct
reclaim. To avoid impacting high-order allocation success rates,
it still drains the local per-cpu lists for high-order allocations
that failed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b8ba3a..63ea182 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1982,11 +1982,13 @@ retry:
 					migratetype);
 
 	/*
-	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 * If a high-order allocation failed after direct reclaim, there is a
+	 * possibility that it is because the necessary buddies have been
+	 * freed to the per-cpu list. Drain the local list and try again.
 	 */
-	if (!page && !drained) {
-		drain_all_pages();
+	if (!page && order && !drained) {
+		drain_pages(get_cpu());
+		put_cpu();
 		drained = true;
 		goto retry;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
