Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4716B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 12:46:14 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so1086304lbv.10
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 09:46:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si7299864laa.104.2014.11.05.09.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 09:46:11 -0800 (PST)
Date: Wed, 5 Nov 2014 18:46:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105174609.GE28226@dhcp22.suse.cz>
References: <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105165428.GF14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 11:54:28, Tejun Heo wrote:
> On Wed, Nov 05, 2014 at 05:39:56PM +0100, Michal Hocko wrote:
> > On Wed 05-11-14 11:29:29, Tejun Heo wrote:
> > > Hello, Michal.
> > > 
> > > On Wed, Nov 05, 2014 at 05:01:15PM +0100, Michal Hocko wrote:
> > > > I am not sure I am following. With the latest patch OOM path is no
> > > > longer blocked by the PM (aka oom_killer_disable()). Allocations simply
> > > > fail if the read_trylock fails.
> > > > oom_killer_disable is moved before tasks are frozen and it will wait for
> > > > all on-going OOM killers on the write lock. OOM killer is enabled again
> > > > on the resume path.
> > > 
> > > Sure, but why are we exposing new interfaces?  Can't we just make
> > > oom_killer_disable() first set the disable flag and wait for the
> > > on-going ones to finish (and make the function fail if it gets chosen
> > > as an OOM victim)?
> > 
> > Still not following. How do you want to detect an on-going OOM without
> > any interface around out_of_memory?
> 
> I thought you were using oom_killer_allowed_start() outside OOM path.
> Ugh.... why is everything weirdly structured?  oom_killer_disabled
> implies that oom killer may fail, right?  Why is
> __alloc_pages_slowpath() checking it directly?

Because out_of_memory can be called from mutliple paths. And
the only interesting one should be the page allocation path.
pagefault_out_of_memory is not interesting because it cannot happen for
the frozen task.

Now that I am looking maybe even sysrq OOM trigger should as well.

> If whether oom killing failed or not is relevant to its users, make
> out_of_memory() return an error code.  There's no reason for the
> exclusion detail to leak out of the oom killer proper.  The only
> interface should be disable/enable and whether oom killing failed or
> not.

Got your point. I can reshuffle the code and make the trylock thingy
inside oom_kill.c. I am not sure it is so much better because the OOM
knowledge is already spread (e.g. check oom_zonelist_trylock outside of
out_of_memory or even oom_gfp_allowed before we
enter__alloc_pages_may_oom). Anyway, I do not care much and I am OK with
your return code convention as the only other way how OOM might fail is
when there is no victim and we panic then.

Something like (even not compile tested)
---
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 42bad18c66c9..14f3d7fd961f 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -355,8 +355,10 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL), GFP_KERNEL,
-		      0, NULL, true);
+	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
+			   GFP_KERNEL, 0, NULL, true)) {
+		printk(KERN_INFO "OOM killer disabled\n");
+	}
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 850f7f653eb7..4af99a9b543b 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -68,7 +68,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
 
-extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
@@ -85,21 +85,6 @@ extern void oom_killer_disable(void);
  */
 extern void oom_killer_enable(void);
 
-/**
- * oom_killer_allowed_start - start OOM killer section
- *
- * Synchronise with oom_killer_{disable,enable} sections.
- * Returns 1 if oom_killer is allowed.
- */
-extern int oom_killer_allowed_start(void);
-
-/**
- * oom_killer_allowed_end - end OOM killer section
- *
- * previously started by oom_killer_allowed_end.
- */
-extern void oom_killer_allowed_end(void);
-
 static inline bool oom_gfp_allowed(gfp_t gfp_mask)
 {
 	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 126e7da17cf9..3e136a2c0b1f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -610,18 +610,8 @@ void oom_killer_enable(void)
 	up_write(&oom_sem);
 }
 
-int oom_killer_allowed_start(void)
-{
-	return down_read_trylock(&oom_sem);
-}
-
-void oom_killer_allowed_end(void)
-{
-	up_read(&oom_sem);
-}
-
 /**
- * out_of_memory - kill the "best" process when we run out of memory
+ * __out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
@@ -633,7 +623,7 @@ void oom_killer_allowed_end(void)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask, bool force_kill)
 {
 	const nodemask_t *mpol_mask;
@@ -698,6 +688,27 @@ out:
 		schedule_timeout_killable(1);
 }
 
+/** out_of_memory -  tries to invoke OOM killer.
+ * @zonelist: zonelist pointer
+ * @gfp_mask: memory allocation flags
+ * @order: amount of memory being requested as a power of 2
+ * @nodemask: nodemask passed to page allocator
+ * @force_kill: true if a task must be killed, even if others are exiting
+ *
+ * invokes __out_of_memory if the OOM is not disabled by oom_killer_disable()
+ * when it returns false. Otherwise returns true.
+ */
+bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
+		int order, nodemask_t *nodemask, bool force_kill)
+{
+	if (!down_read_trylock(&oom_sem))
+		return false;
+	__out_of_memory(zonlist, gfp_mask, order, nodemask, force_kill);
+	up_read(&oom_sem);
+
+	return true;
+}
+
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
  * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
@@ -712,7 +723,7 @@ void pagefault_out_of_memory(void)
 
 	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
 	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
-		out_of_memory(NULL, 0, 0, NULL, false);
+		__out_of_memory(NULL, 0, 0, NULL, false);
 		oom_zonelist_unlock(zonelist, GFP_KERNEL);
 	}
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 206ce46ce975..fdbcdd9cd1a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2239,10 +2239,11 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int classzone_idx, int migratetype)
+	int classzone_idx, int migratetype, bool *oom_failed)
 {
 	struct page *page;
 
+	*oom_failed = false;
 	/* Acquire the per-zone oom lock for each zone */
 	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
@@ -2279,8 +2280,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
-
+	if (!out_of_memory(zonelist, gfp_mask, order, nodemask, false))
+		*oom_failed = true;
 out:
 	oom_zonelist_unlock(zonelist, gfp_mask);
 	return page;
@@ -2706,26 +2707,28 @@ rebalance:
 	 */
 	if (!did_some_progress) {
 		if (oom_gfp_allowed(gfp_mask)) {
+			bool oom_failed;
+
 			/* Coredumps can quickly deplete all memory reserves */
 			if ((current->flags & PF_DUMPCORE) &&
 			    !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
-			/*
-			 * Just make sure that we cannot race with oom_killer
-			 * disabling e.g. PM freezer needs to make sure that
-			 * no OOM happens after all tasks are frozen.
-			 */
-			if (!oom_killer_allowed_start())
-				goto nopage;
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,
-					classzone_idx, migratetype);
-			oom_killer_allowed_end();
+					classzone_idx, migratetype,
+					&oom_failed);
 
 			if (page)
 				goto got_pg;
 
+			/*
+			 * OOM killer might be disabled and then we have to
+			 * fail the allocation
+			 */
+			if (oom_failed)
+				goto no_page;
+
 			if (!(gfp_mask & __GFP_NOFAIL)) {
 				/*
 				 * The oom killer is not called for high-order
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
