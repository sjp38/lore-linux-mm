Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8B996B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:54:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so32463261wjc.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:54:59 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id v130si20067375wmd.161.2017.01.24.15.54.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 15:54:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 1B20B1DC025
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:54:58 +0000 (UTC)
Date: Tue, 24 Jan 2017 23:54:57 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170124235457.x7ssjun5ht2ycyac@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
 <20170123200412.mkesardc4mckk6df@techsingularity.net>
 <20170123205501.GA25944@htj.duckdns.org>
 <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
 <20170124160722.GC12281@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170124160722.GC12281@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On Tue, Jan 24, 2017 at 11:07:22AM -0500, Tejun Heo wrote:
> Hello, Mel.
> 
> On Mon, Jan 23, 2017 at 11:04:29PM +0000, Mel Gorman wrote:
> > On Mon, Jan 23, 2017 at 03:55:01PM -0500, Tejun Heo wrote:
> > > Hello, Mel.
> > > 
> > > On Mon, Jan 23, 2017 at 08:04:12PM +0000, Mel Gorman wrote:
> > > > What is the actual mechanism that does that? It's not something that
> > > > schedule_on_each_cpu does and one would expect that the core workqueue
> > > > implementation would get this sort of detail correct. Or is this a proposal
> > > > on how it should be done?
> > > 
> > > If you use schedule_on_each_cpu(), it's all fine as the thing pins
> > > cpus and waits for all the work items synchronously.  If you wanna do
> > > it asynchronously, right now, you'll have to manually synchronize work
> > > items against the offline callback manually.
> > > 
> > 
> > Is the current implementation and what it does wrong in some way? I ask
> > because synchronising against the offline callback sounds like it would
> > be a bit of a maintenance mess for relatively little gain.
> 
> As long as you wrap them with get/put_online_cpus(), the current
> implementation should be fine.  If it were up to me, I'd rather use
> static percpu work_structs and synchronize with a mutex tho.  The cost
> of synchronizing via mutex isn't high here compared to the overall
> operation, the whole thing is synchronous anyway and you won't have to
> worry about falling back.
> 

The synchronisation is not even required in all cases. Multiple direct
reclaimers synching to do the drain doesn't necessarily make sense for
example. How does the following look to you?

---8<---
mm, page_alloc: Use static global work_struct for draining per-cpu pages

As suggested by Vlastimil Babka and Tejun Heo, this patch uses a static
work_struct to co-ordinate the draining of per-cpu pages on the workqueue.
Only one task can drain at a time but this is better than the previous
scheme that allowed multiple tasks to send IPIs at a time.

One consideration is whether parallel requests should synchronise against
each other. This patch does not synchronise for a global drain. The common
case for such callers is expected to be multiple parallel direct reclaimers
competing for pages when the watermark is close to min. Draining the
per-cpu list is unlikely to make much progress and serialising the drain
is of dubious merit in that case. Drains are synchonrised for callers such
as memory hotplug and CMA that care about the drain being complete when
the function returns.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e87508ffa759..da6be2a5ff7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -92,6 +92,10 @@ EXPORT_PER_CPU_SYMBOL(_numa_mem_);
 int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
+/* work_structs for global per-cpu drains */
+DEFINE_MUTEX(pcpu_drain_mutex);
+DEFINE_PER_CPU(struct work_struct, pcpu_drain);
+
 #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
 volatile unsigned long latent_entropy __latent_entropy;
 EXPORT_SYMBOL(latent_entropy);
@@ -2351,7 +2355,6 @@ static void drain_local_pages_wq(struct work_struct *work)
  */
 void drain_all_pages(struct zone *zone)
 {
-	struct work_struct __percpu *works;
 	int cpu;
 
 	/*
@@ -2365,11 +2368,21 @@ void drain_all_pages(struct zone *zone)
 		return;
 
 	/*
+	 * Do not drain if one is already in progress unless it's specific to
+	 * a zone. Such callers are primarily CMA and memory hotplug and need
+	 * the drain to be complete when the call returns.
+	 */
+	if (unlikely(!mutex_trylock(&pcpu_drain_mutex))) {
+		if (!zone)
+			return;
+		mutex_lock(&pcpu_drain_mutex);
+	}
+
+	/*
 	 * As this can be called from reclaim context, do not reenter reclaim.
 	 * An allocation failure can be handled, it's simply slower
 	 */
 	get_online_cpus();
-	works = alloc_percpu_gfp(struct work_struct, GFP_ATOMIC);
 
 	/*
 	 * We don't care about racing with CPU hotplug event
@@ -2402,24 +2415,16 @@ void drain_all_pages(struct zone *zone)
 			cpumask_clear_cpu(cpu, &cpus_with_pcps);
 	}
 
-	if (works) {
-		for_each_cpu(cpu, &cpus_with_pcps) {
-			struct work_struct *work = per_cpu_ptr(works, cpu);
-			INIT_WORK(work, drain_local_pages_wq);
-			schedule_work_on(cpu, work);
-		}
-		for_each_cpu(cpu, &cpus_with_pcps)
-			flush_work(per_cpu_ptr(works, cpu));
-	} else {
-		for_each_cpu(cpu, &cpus_with_pcps) {
-			struct work_struct work;
-
-			INIT_WORK(&work, drain_local_pages_wq);
-			schedule_work_on(cpu, &work);
-			flush_work(&work);
-		}
+	for_each_cpu(cpu, &cpus_with_pcps) {
+		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
+		INIT_WORK(work, drain_local_pages_wq);
+		schedule_work_on(cpu, work);
 	}
+	for_each_cpu(cpu, &cpus_with_pcps)
+		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
+
 	put_online_cpus();
+	mutex_unlock(&pcpu_drain_mutex);
 }
 
 #ifdef CONFIG_HIBERNATION

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
