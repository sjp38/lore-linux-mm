Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 5E3676B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 11:17:43 -0500 (EST)
Date: Thu, 5 Jan 2012 16:17:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120105161739.GD27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120105144011.GU11810@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 02:40:11PM +0000, Russell King - ARM Linux wrote:
> On Thu, Jan 05, 2012 at 02:20:17PM +0000, Mel Gorman wrote:
> > On Tue, Jan 03, 2012 at 12:45:45PM -0500, KOSAKI Motohiro wrote:
> > > >   void drain_all_pages(void)
> > > >   {
> > > > -	on_each_cpu(drain_local_pages, NULL, 1);
> > > > +	int cpu;
> > > > +	struct per_cpu_pageset *pcp;
> > > > +	struct zone *zone;
> > > > +
> > > 
> > > get_online_cpu() ?
> > > 
> > 
> > Just a separate note;
> > 
> > I'm looking at some mysterious CPU hotplug problems that only happen
> > under heavy load. My strongest suspicion at the moment that the problem
> > is related to on_each_cpu() being used without get_online_cpu() but you
> > cannot simply call get_online_cpu() in this path without causing
> > deadlock.
> 
> Mel,
> 
> That's a known hotplug problems.  PeterZ has a patch which (probably)
> solves it, but there seems to be very little traction of any kind to
> merge it. 

Link please? I'm including a patch below under development that is
intended to only cope with the page allocator case under heavy memory
pressure. Currently it does not pass testing because eventually RCU
gets stalled with the following trace

[ 1817.176001]  [<ffffffff810214d7>] arch_trigger_all_cpu_backtrace+0x87/0xa0
[ 1817.176001]  [<ffffffff810c4779>] __rcu_pending+0x149/0x260
[ 1817.176001]  [<ffffffff810c48ef>] rcu_check_callbacks+0x5f/0x110
[ 1817.176001]  [<ffffffff81068d7f>] update_process_times+0x3f/0x80
[ 1817.176001]  [<ffffffff8108c4eb>] tick_sched_timer+0x5b/0xc0
[ 1817.176001]  [<ffffffff8107f28e>] __run_hrtimer+0xbe/0x1a0
[ 1817.176001]  [<ffffffff8107f581>] hrtimer_interrupt+0xc1/0x1e0
[ 1817.176001]  [<ffffffff81020ef3>] smp_apic_timer_interrupt+0x63/0xa0
[ 1817.176001]  [<ffffffff81449073>] apic_timer_interrupt+0x13/0x20
[ 1817.176001]  [<ffffffff8116c135>] vfsmount_lock_local_lock+0x25/0x30
[ 1817.176001]  [<ffffffff8115c855>] path_init+0x2d5/0x370
[ 1817.176001]  [<ffffffff8115eecd>] path_lookupat+0x2d/0x620
[ 1817.176001]  [<ffffffff8115f4ef>] do_path_lookup+0x2f/0xd0
[ 1817.176001]  [<ffffffff811602af>] user_path_at_empty+0x9f/0xd0
[ 1817.176001]  [<ffffffff81154e7b>] vfs_fstatat+0x4b/0x90
[ 1817.176001]  [<ffffffff81154f4f>] sys_newlstat+0x1f/0x50
[ 1817.176001]  [<ffffffff81448692>] system_call_fastpath+0x16/0x1b

It might be a separate bug, don't know for sure.

> I've been chasing that patch and getting no replies what so
> ever from folk like Peter, Thomas and Ingo.
> 
> The problem affects all IPI-raising functions, which mask with
> cpu_online_mask directly.
> 

Actually, in one sense I'm glad to hear it because from my brief
poking around, I was having trouble understanding why we were always
safe from sending IPIs to CPUs in the process of being offlined.

> I'm not sure that smp_call_function() can use get_online_cpu() as it
> looks like it's not permitted to sleep (it spins in csd_lock_wait if
> it is to wait for the called function to complete on all CPUs,
> rather than using a sleepable completion.)  get_online_cpu() solves
> the online mask problem by sleeping until it's safe to access it.
> 

Yeah, although from the context of the page allocator calling
get_online_cpu() is not safe because it can deadlock kthreadd.

In the interest of comparing with PeterZ's patch, here is the patch I'm
currently looking at. It has not passed testing yet. I suspect it'll be
met with hatred but it will at least highlight some of the problems I've
seen recently (which apparently are not new)

Gilad, I expect this patch to collide with yours but I also expect
yours could be based on top of it if necessary. There is also the
side-effect that this patch should reduce the number of IPIs sent by the
page allocator under memory pressure.

==== CUT HERE ====
mm: page allocator: Guard against CPUs going offline while draining per-cpu page lists

While running a CPU hotplug stress test under memory pressure, I
saw cases where under enough stress the machine would halt although
it required a machine with 8 cores and plenty memory. I think the
problems may be related.

Part of the problem is the page allocator is sending IPIs using
on_each_cpu() without calling get_online_cpus() to prevent changes
to the online cpumask. This allows IPIs to be send to CPUs that
are going offline or offline already.

Adding just a call to get_online_cpus() is not enough as kthreadd
could block on cpu_hotplug mutex while another process is blocked with
the mutex held waiting for kthreadd to make forward progress leading
to deadlock. Additionally, it is important that cpu_hotplug mutex
does not become a new hot lock while under pressure.  This is also
the consideration that CPU hotplug expects that get_online_cpus()
is not called frequently as it can lead to livelock in exceptional
circumstances (see comment above cpu_hotplug_begin()).

Hence, this patch adds a try_get_online_cpus() function used
by the page allocator to only acquire the mutex and elevate the
hotplug reference count when uncontended. This ensures the CPU mask
is valid when sending an IPI to drain all pages while avoiding
hammering cpu_hotplug mutex or potentially deadlocking kthreadd.
As a side-effect the number of IPIs sent while under memory pressure
is reduced.

Not-signed-off
--- 
 include/linux/cpu.h |    2 ++
 kernel/cpu.c        |   26 ++++++++++++++++++++++++++
 mm/page_alloc.c     |   22 ++++++++++++++++++----
 3 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 5f09323..9ac5c27 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -133,6 +133,7 @@ extern struct sysdev_class cpu_sysdev_class;
 /* Stop CPUs going up and down. */
 
 extern void get_online_cpus(void);
+extern bool try_get_online_cpus(void);
 extern void put_online_cpus(void);
 #define hotcpu_notifier(fn, pri)	cpu_notifier(fn, pri)
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
@@ -156,6 +157,7 @@ static inline void cpu_hotplug_driver_unlock(void)
 
 #define get_online_cpus()	do { } while (0)
 #define put_online_cpus()	do { } while (0)
+#define try_put_online_cpus()	true
 #define hotcpu_notifier(fn, pri)	do { (void)(fn); } while (0)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
diff --git a/kernel/cpu.c b/kernel/cpu.c
index aa39dd7..a90422f 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -70,6 +70,32 @@ void get_online_cpus(void)
 }
 EXPORT_SYMBOL_GPL(get_online_cpus);
 
+/*
+ * This differs from get_online_cpus() in that it tries to get uncontended
+ * access to the online CPU mask. Principally this is used by the page
+ * allocator to avoid hammering on the cpu_hotplug mutex and to limit the
+ * number of IPIs it is sending.
+ */
+bool try_get_online_cpus(void)
+{
+	bool contention_free = false;
+	might_sleep();
+	if (cpu_hotplug.refcount)
+		return false;
+
+	if (cpu_hotplug.active_writer == current)
+		return true;
+
+	mutex_lock(&cpu_hotplug.lock);
+	if (!cpu_hotplug.refcount) {
+		contention_free = true;
+		cpu_hotplug.refcount++;
+	}
+	mutex_unlock(&cpu_hotplug.lock);
+
+	return contention_free;
+}
+
 void put_online_cpus(void)
 {
 	if (cpu_hotplug.active_writer == current)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e684e6b..7f75cab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,6 +57,7 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/kthread.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1129,7 +1130,18 @@ void drain_local_pages(void *arg)
  */
 void drain_all_pages(void)
 {
+	get_online_cpus();
 	on_each_cpu(drain_local_pages, NULL, 1);
+	put_online_cpus();
+}
+
+static bool try_drain_all_pages(void)
+{
+	if (!try_get_online_cpus())
+		return false;
+	on_each_cpu(drain_local_pages, NULL, 1);
+	put_online_cpus();
+	return true;
 }
 
 #ifdef CONFIG_HIBERNATION
@@ -2026,11 +2038,13 @@ retry:
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
+	 * pages are pinned on the per-cpu lists. Drain them and try again.
+	 * kthreadd cannot drain all pages as the current holder of the
+	 * cpu_hotplug mutex could be waiting for kthreadd to make forward
+	 * progress.
 	 */
-	if (!page && !drained) {
-		drain_all_pages();
-		drained = true;
+	if (!page && !drained && current != kthreadd_task) {
+		drained = try_drain_all_pages();
 		goto retry;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
