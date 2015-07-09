Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9356B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 07:22:43 -0400 (EDT)
Received: by wgov12 with SMTP id v12so36013806wgo.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 04:22:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd7si8566057wic.106.2015.07.09.04.22.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jul 2015 04:22:41 -0700 (PDT)
Date: Thu, 9 Jul 2015 13:22:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/8] memcg: export struct mem_cgroup
Message-ID: <20150709112239.GE13872@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-2-git-send-email-mhocko@kernel.org>
 <20150708153925.GA2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708153925.GA2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 18:39:26, Vladimir Davydov wrote:
> Hi Michal,
> 
> On Wed, Jul 08, 2015 at 02:27:45PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 73b02b0a8f60..f5a8d0bbef8d 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -23,8 +23,11 @@
> >  #include <linux/vm_event_item.h>
> >  #include <linux/hardirq.h>
> >  #include <linux/jump_label.h>
> > +#include <linux/page_counter.h>
> > +#include <linux/vmpressure.h>
> > +#include <linux/mmzone.h>
> > +#include <linux/writeback.h>
> >  
> > -struct mem_cgroup;
> 
> I think we still need this forward declaration e.g. for defining
> reclaim_iter.

Yes, this was just an omission and I haven't noticed it because the
compilation haven't complained. I do agree that we shouldn't rely on
fwd. declarations from other header files. Fixed.

[...]
> > +struct mem_cgroup_stat_cpu {
> > +	long count[MEM_CGROUP_STAT_NSTATS];
> > +	unsigned long events[MEMCG_NR_EVENTS];
> > +	unsigned long nr_page_events;
> > +	unsigned long targets[MEM_CGROUP_NTARGETS];
> > +};
> > +
> > +struct reclaim_iter {
> 
> I think we'd better rename it to mem_cgroup_reclaim_iter.

The name is awfully long but it is used only at the single place so it
shouldn't matter much and we will be more consistent in naming and won't
pollute the namespace. Changed...

> 
> > +	struct mem_cgroup *position;
> > +	/* scan generation, increased every round-trip */
> > +	unsigned int generation;
> > +};
> > +
> > +/*
> > + * per-zone information in memory controller.
> > + */
> > +struct mem_cgroup_per_zone {
> > +	struct lruvec		lruvec;
> > +	unsigned long		lru_size[NR_LRU_LISTS];
> > +
> > +	struct reclaim_iter	iter[DEF_PRIORITY + 1];
> > +
> > +	struct rb_node		tree_node;	/* RB tree node */
> > +	unsigned long		usage_in_excess;/* Set to the value by which */
> > +						/* the soft limit is exceeded*/
> > +	bool			on_tree;
> > +	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
> > +						/* use container_of	   */
> > +};
> > +
> > +struct mem_cgroup_per_node {
> > +	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
> > +};
> > +
> > +struct mem_cgroup_threshold {
> > +	struct eventfd_ctx *eventfd;
> > +	unsigned long threshold;
> > +};
> > +
> > +/* For threshold */
> > +struct mem_cgroup_threshold_ary {
> > +	/* An array index points to threshold just below or equal to usage. */
> > +	int current_threshold;
> > +	/* Size of entries[] */
> > +	unsigned int size;
> > +	/* Array of thresholds */
> > +	struct mem_cgroup_threshold entries[0];
> > +};
> > +
> > +struct mem_cgroup_thresholds {
> > +	/* Primary thresholds array */
> > +	struct mem_cgroup_threshold_ary *primary;
> > +	/*
> > +	 * Spare threshold array.
> > +	 * This is needed to make mem_cgroup_unregister_event() "never fail".
> > +	 * It must be able to store at least primary->size - 1 entries.
> > +	 */
> > +	struct mem_cgroup_threshold_ary *spare;
> > +};
> 
> I think we'd better define these structures inside CONFIG_MEMCG section,
> just like struct mem_cgroup.

OK. I just wanted to make the code compilable but I can move the ifdef
up which would be cleaner. We only need enums and cg_proto stuff to be
compilable. Will do that.

> > +
> > +/*
> > + * Bits in struct cg_proto.flags
> > + */
> > +enum cg_proto_flags {
> > +	/* Currently active and new sockets should be assigned to cgroups */
> > +	MEMCG_SOCK_ACTIVE,
> > +	/* It was ever activated; we must disarm static keys on destruction */
> > +	MEMCG_SOCK_ACTIVATED,
> > +};
> > +
> > +struct cg_proto {
> > +	struct page_counter	memory_allocated;	/* Current allocated memory. */
> > +	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> > +	int			memory_pressure;
> > +	long			sysctl_mem[3];
> > +	unsigned long		flags;
> > +	/*
> > +	 * memcg field is used to find which memcg we belong directly
> > +	 * Each memcg struct can hold more than one cg_proto, so container_of
> > +	 * won't really cut.
> > +	 *
> > +	 * The elegant solution would be having an inverse function to
> > +	 * proto_cgroup in struct proto, but that means polluting the structure
> > +	 * for everybody, instead of just for memcg users.
> > +	 */
> > +	struct mem_cgroup	*memcg;
> > +};
> 
> I'd prefer to leave it where it is now. I don't see any reason why we
> have to embed it into mem_cgroup, so may be we'd better keep a pointer
> to it in struct mem_cgroup instead?

This patch is supposed to be minimal without any functional changes.
Changing tcp_mem to pointer would require allocation and freeing and that
is out of scope of this patch. Besides that I do not see any stong
advantage doing that.

[...]
> >  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
> 
> It's a trivial one line function, so why not inline it too?

Yes it is trivial but according to my notes it increased the code size
by ~100B.
 
[...]
> > -void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> >  static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> >  					     enum vm_event_item idx)
> >  {
> > +	struct mem_cgroup *memcg;
> > +
> >  	if (mem_cgroup_disabled())
> >  		return;
> > -	__mem_cgroup_count_vm_event(mm, idx);
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > +	if (unlikely(!memcg))
> > +		goto out;
> > +
> > +	switch (idx) {
> > +	case PGFAULT:
> > +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
> > +		break;
> > +	case PGMAJFAULT:
> > +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
> > +		break;
> > +	default:
> > +		BUG();
> 
> This switch-case looks bulky and weird. Let's make this function accept
> MEM_CGROUP_EVENTS_PGFAULT/PGMAJFAULT directly instead.

Yes it looks ugly but I didn't intend to change it in this particular
patch. I wouldn't mind a follow up cleanup patch.

[...]
> > -int memcg_cache_id(struct mem_cgroup *memcg);
> > +/*
> > + * helper for acessing a memcg's index. It will be used as an index in the
> > + * child cache array in kmem_cache, and also to derive its name. This function
> > + * will return -1 when this is not a kmem-limited memcg.
> > + */
> > +static inline int memcg_cache_id(struct mem_cgroup *memcg)
> > +{
> > +	return memcg ? memcg->kmemcg_id : -1;
> > +}
> 
> We can inline memcg_kmem_is_active too.

I do not have this one in my notes so I haven't tried to inline it.
Let's see.

   text    data     bss     dec     hex filename
12355346        1823792 1089536 15268674         e8fb42 vmlinux.before
12354970        1823792 1089536 15268298         e8f9ca vmlinux.after
12354970        1823792 1089536 15268298         e8f9ca vmlinux.memcg_kmem_is_active

Interesting. The code size hasn't changed. This is quite surprising but
I guess it has changed just the aligning of the code. Anyway, I will
inline it.

Thanks for the review Vladimir!

The current diff against the patch is:
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f5a8d0bbef8d..42f118ae04cf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -28,6 +28,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 
+struct mem_cgroup;
 struct page;
 struct mm_struct;
 struct kmem_cache;
@@ -83,6 +84,35 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_NTARGETS,
 };
 
+/*
+ * Bits in struct cg_proto.flags
+ */
+enum cg_proto_flags {
+	/* Currently active and new sockets should be assigned to cgroups */
+	MEMCG_SOCK_ACTIVE,
+	/* It was ever activated; we must disarm static keys on destruction */
+	MEMCG_SOCK_ACTIVATED,
+};
+
+struct cg_proto {
+	struct page_counter	memory_allocated;	/* Current allocated memory. */
+	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
+	int			memory_pressure;
+	long			sysctl_mem[3];
+	unsigned long		flags;
+	/*
+	 * memcg field is used to find which memcg we belong directly
+	 * Each memcg struct can hold more than one cg_proto, so container_of
+	 * won't really cut.
+	 *
+	 * The elegant solution would be having an inverse function to
+	 * proto_cgroup in struct proto, but that means polluting the structure
+	 * for everybody, instead of just for memcg users.
+	 */
+	struct mem_cgroup	*memcg;
+};
+
+#ifdef CONFIG_MEMCG
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
 	unsigned long events[MEMCG_NR_EVENTS];
@@ -90,7 +120,7 @@ struct mem_cgroup_stat_cpu {
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
 
-struct reclaim_iter {
+struct mem_cgroup_reclaim_iter {
 	struct mem_cgroup *position;
 	/* scan generation, increased every round-trip */
 	unsigned int generation;
@@ -103,7 +133,7 @@ struct mem_cgroup_per_zone {
 	struct lruvec		lruvec;
 	unsigned long		lru_size[NR_LRU_LISTS];
 
-	struct reclaim_iter	iter[DEF_PRIORITY + 1];
+	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
 
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
@@ -144,35 +174,6 @@ struct mem_cgroup_thresholds {
 };
 
 /*
- * Bits in struct cg_proto.flags
- */
-enum cg_proto_flags {
-	/* Currently active and new sockets should be assigned to cgroups */
-	MEMCG_SOCK_ACTIVE,
-	/* It was ever activated; we must disarm static keys on destruction */
-	MEMCG_SOCK_ACTIVATED,
-};
-
-struct cg_proto {
-	struct page_counter	memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
-	int			memory_pressure;
-	long			sysctl_mem[3];
-	unsigned long		flags;
-	/*
-	 * memcg field is used to find which memcg we belong directly
-	 * Each memcg struct can hold more than one cg_proto, so container_of
-	 * won't really cut.
-	 *
-	 * The elegant solution would be having an inverse function to
-	 * proto_cgroup in struct proto, but that means polluting the structure
-	 * for everybody, instead of just for memcg users.
-	 */
-	struct mem_cgroup	*memcg;
-};
-
-#ifdef CONFIG_MEMCG
-/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -735,7 +736,10 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
-bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+{
+	return memcg->kmem_acct_active;
+}
 
 /*
  * In general, we'll do everything in our power to not incur in any overhead
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 759ec413e72c..a3543dedc153 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -184,13 +184,6 @@ struct mem_cgroup_event {
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
-#ifdef CONFIG_MEMCG_KMEM
-bool memcg_kmem_is_active(struct mem_cgroup *memcg)
-{
-	return memcg->kmem_acct_active;
-}
-#endif
-
 /* Stuffs for move charges at task migration. */
 /*
  * Types of charges to be moved.
@@ -841,7 +834,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
-	struct reclaim_iter *uninitialized_var(iter);
+	struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
 	struct cgroup_subsys_state *css = NULL;
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *pos = NULL;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
