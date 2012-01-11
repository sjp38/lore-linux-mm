Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id ECA766B006E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 05:11:17 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via IPI from page allocator context
Date: Wed, 11 Jan 2012 10:11:08 +0000
Message-Id: <1326276668-19932-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1326276668-19932-1-git-send-email-mgorman@suse.de>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>, Mel Gorman <mgorman@suse.de>

While running a CPU hotplug stress test under memory pressure, it
was observed that the machine would halt with no messages logged to
console. This is difficult to trigger and required a machine with 8
cores and plenty of memory.

Part of the problem is the page allocator is sending IPIs using
on_each_cpu() without calling get_online_cpus() to prevent changes
to the online cpumask. This allows IPIs to be send to CPUs that
are going offline or offline already. At least one bug report has
been seen on ppc64 against a 3.0 era kernel that looked like a bug
receiving interrupts on a CPU being offlined.

This patch starts by adding a call to get_online_cpus() to
drain_all_pages() to make it safe versis CPU hotplug.

In the context of the page allocator, this causes a problem. It is
possible that kthreadd blocks on cpu_hotplug mutex while another
process already holding the mutex is blocked waiting for kthreadd
to make forward progress leading to deadlock. Additionally, it is
important that cpu_hotplug mutex does not become a new hot lock while
under pressure. There is also the consideration that CPU hotplug
expects that get_online_cpus() is not called frequently as it can
lead to livelock in exceptional circumstances (see comment above
cpu_hotplug_begin()).

Rather than making it safe to call get_online_cpus() from the page
allocator, this patch simply removes the page allocator call to
drain_all_pages(). To avoid impacting high-order allocation success
rates, it still drains the local per-cpu lists for high-order
allocations that failed. As a side effect, this reduces the number
of IPIs sent during low memory situations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b8ba3a..b6df6fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1119,7 +1119,9 @@ void drain_local_pages(void *arg)
  */
 void drain_all_pages(void)
 {
+	get_online_cpus();
 	on_each_cpu(drain_local_pages, NULL, 1);
+	put_online_cpus();
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -1982,11 +1984,17 @@ retry:
 					migratetype);
 
 	/*
-	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 * If a high-order allocation failed after direct reclaim, there is a
+	 * possibility that it is because the necessary buddies have been
+	 * freed to the per-cpu list. Drain the local list and try again.
+	 * drain_all_pages is not used because it is unsafe to call
+	 * get_online_cpus from this context as it is possible that kthreadd
+	 * would block during thread creation and the cost of sending storms
+	 * of IPIs in low memory conditions is quite high.
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
