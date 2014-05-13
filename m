Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6AD6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 08:28:58 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so357810eei.14
        for <linux-mm@kvack.org>; Tue, 13 May 2014 05:28:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si5245217eew.131.2014.05.13.05.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 05:28:56 -0700 (PDT)
Date: Tue, 13 May 2014 13:28:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/19] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
Message-ID: <20140513122851.GP23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-5-git-send-email-mgorman@suse.de>
 <20140513105851.GA30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513105851.GA30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 12:58:51PM +0200, Peter Zijlstra wrote:
> On Tue, May 13, 2014 at 10:45:35AM +0100, Mel Gorman wrote:
> > +#ifdef HAVE_JUMP_LABEL
> > +extern struct static_key cpusets_enabled_key;
> > +static inline bool cpusets_enabled(void)
> > +{
> > +	return static_key_false(&cpusets_enabled_key);
> > +}
> > +
> > +/* jump label reference count + the top-level cpuset */
> > +#define number_of_cpusets (static_key_count(&cpusets_enabled_key) + 1)
> > +
> > +static inline void cpuset_inc(void)
> > +{
> > +	static_key_slow_inc(&cpusets_enabled_key);
> > +}
> > +
> > +static inline void cpuset_dec(void)
> > +{
> > +	static_key_slow_dec(&cpusets_enabled_key);
> > +}
> > +
> > +static inline void cpuset_init_count(void) { }
> > +
> > +#else
> >  extern int number_of_cpusets;	/* How many cpusets are defined in system? */
> >  
> > +static inline bool cpusets_enabled(void)
> > +{
> > +	return number_of_cpusets > 1;
> > +}
> > +
> > +static inline void cpuset_inc(void)
> > +{
> > +	number_of_cpusets++;
> > +}
> > +
> > +static inline void cpuset_dec(void)
> > +{
> > +	number_of_cpusets--;
> > +}
> > +
> > +static inline void cpuset_init_count(void)
> > +{
> > +	number_of_cpusets = 1;
> > +}
> > +#endif /* HAVE_JUMP_LABEL */
> 
> I'm still puzzled by the whole #else branch here, why not
> unconditionally use the jump-label one? Without HAVE_JUMP_LABEL we'll
> revert to a simple atomic_t counter, which should be perfectly fine, no?

No good reason -- the intent was to preserve the old behaviour if jump
labels were not available but there is no good reason for that. I'll delete
the alternative implementation, make number_of_cpusets an inline function
and move cpusets_enabled_key into the __read_mostly section. It's untested
but the patch now looks like

---8<---
mm: page_alloc: Use jump labels to avoid checking number_of_cpusets

If cpusets are not in use then we still check a global variable on every
page allocation. Use jump labels to avoid the overhead.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/cpuset.h | 28 +++++++++++++++++++++++++---
 kernel/cpuset.c        | 14 ++++----------
 mm/page_alloc.c        |  3 ++-
 3 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index b19d3dc..a94af76 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -15,7 +15,27 @@
 
 #ifdef CONFIG_CPUSETS
 
-extern int number_of_cpusets;	/* How many cpusets are defined in system? */
+extern struct static_key cpusets_enabled_key;
+static inline bool cpusets_enabled(void)
+{
+	return static_key_false(&cpusets_enabled_key);
+}
+
+static inline int nr_cpusets(void)
+{
+	/* jump label reference count + the top-level cpuset */
+	return static_key_count(&cpusets_enabled_key) + 1;
+}
+
+static inline void cpuset_inc(void)
+{
+	static_key_slow_inc(&cpusets_enabled_key);
+}
+
+static inline void cpuset_dec(void)
+{
+	static_key_slow_dec(&cpusets_enabled_key);
+}
 
 extern int cpuset_init(void);
 extern void cpuset_init_smp(void);
@@ -32,13 +52,13 @@ extern int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask);
 
 static inline int cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 {
-	return number_of_cpusets <= 1 ||
+	return nr_cpusets() <= 1 ||
 		__cpuset_node_allowed_softwall(node, gfp_mask);
 }
 
 static inline int cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
 {
-	return number_of_cpusets <= 1 ||
+	return nr_cpusets() <= 1 ||
 		__cpuset_node_allowed_hardwall(node, gfp_mask);
 }
 
@@ -124,6 +144,8 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 
 #else /* !CONFIG_CPUSETS */
 
+static inline bool cpusets_enabled(void) { return false; }
+
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3d54c41..1300178 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -61,12 +61,7 @@
 #include <linux/cgroup.h>
 #include <linux/wait.h>
 
-/*
- * Tracks how many cpusets are currently defined in system.
- * When there is only one cpuset (the root cpuset) we can
- * short circuit some hooks.
- */
-int number_of_cpusets __read_mostly;
+struct static_key cpusets_enabled_key __read_mostly = STATIC_KEY_INIT_FALSE;
 
 /* See "Frequency meter" comments, below. */
 
@@ -611,7 +606,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 		goto done;
 	}
 
-	csa = kmalloc(number_of_cpusets * sizeof(cp), GFP_KERNEL);
+	csa = kmalloc(nr_cpusets() * sizeof(cp), GFP_KERNEL);
 	if (!csa)
 		goto done;
 	csn = 0;
@@ -1888,7 +1883,7 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	if (is_spread_slab(parent))
 		set_bit(CS_SPREAD_SLAB, &cs->flags);
 
-	number_of_cpusets++;
+	cpuset_inc();
 
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags))
 		goto out_unlock;
@@ -1939,7 +1934,7 @@ static void cpuset_css_offline(struct cgroup_subsys_state *css)
 	if (is_sched_load_balance(cs))
 		update_flag(CS_SCHED_LOAD_BALANCE, cs, 0);
 
-	number_of_cpusets--;
+	cpuset_dec();
 	clear_bit(CS_ONLINE, &cs->flags);
 
 	mutex_unlock(&cpuset_mutex);
@@ -1992,7 +1987,6 @@ int __init cpuset_init(void)
 	if (!alloc_cpumask_var(&cpus_attach, GFP_KERNEL))
 		BUG();
 
-	number_of_cpusets = 1;
 	return 0;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c559e3..cb12b9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1930,7 +1930,8 @@ zonelist_scan:
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		if ((alloc_flags & ALLOC_CPUSET) &&
+		if (cpusets_enabled() &&
+			(alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
