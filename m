Date: Mon, 4 Feb 2008 22:20:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Support for statistics to help analyze allocator behavior
Message-ID: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The statistics provided here allow the monitoring of allocator behavior
at the cost of some (minimal) loss of performance. Counters are placed in
SLUB's per cpu data structure that is already written to by other code.
 
The per cpu structure may be extended by the statistics to be more than 
one cacheline which will increase the cache footprint of SLUB.

That is why there is a compile option to enable/disable the inclusion of
the statistics module.

The slabinfo tool is enhanced to support these statistics via two options:

-D 	Switches the line of information displayed for a slab from size
	mode to activity mode.

-A	Sorts the slabs displayed by activity. This allows the display of
	the slabs most important to the performance of a certain load.

-r	Report option will report detailed statistics on

Example (tbench load):

slabinfo -AD		->Shows the most active slabs

Name                   Objects    Alloc     Free   %Fast
skbuff_fclone_cache         33 111953835 111953835  99  99
:0000192                  2666  5283688  5281047  99  99
:0001024                   849  5247230  5246389  83  83
vm_area_struct            1349   119642   118355  91  22
:0004096                    15    66753    66751  98  98
:0000064                  2067    25297    23383  98  78
dentry                   10259    28635    18464  91  45
:0000080                 11004    18950     8089  98  98
:0000096                  1703    12358    10784  99  98
:0000128                   762    10582     9875  94  18
:0000512                   184     9807     9647  95  81
:0002048                   479     9669     9195  83  65
anon_vma                   777     9461     9002  99  71
kmalloc-8                 6492     9981     5624  99  97
:0000768                   258     7174     6931  58  15

So the skbuff_fclone_cache is of highest importance for the tbench load.
Pretty high load on the 192 sized slab. Look for the aliases

slabinfo -a | grep 000192
:0000192     <- xfs_btree_cur filp kmalloc-192 uid_cache tw_sock_TCP request_sock_TCPv6 tw_sock_TCPv6 skbuff_head_cache xfs_ili

Likely skbuff_head_cache.


Looking into the statistics of the skbuff_fclone_cache is possible through

slabinfo skbuff_fclone_cache	->-r option implied if cache name is mentioned


.... Usual output ...

Slab Perf Counter       Alloc     Free %Al %Fr
--------------------------------------------------
Fastpath             111953360 111946981  99  99
Slowpath                 1044     7423   0   0
Page Alloc                272      264   0   0
Add partial                25      325   0   0
Remove partial             86      264   0   0
RemoteObj/SlabFrozen      350     4832   0   0
Total                111954404 111954404

Flushes       49 Refill        0
Deactivate Full=325(92%) Empty=0(0%) ToHead=24(6%) ToTail=1(0%)

Looks good because the fastpath is overwhelmingly taken.


skbuff_head_cache:

Slab Perf Counter       Alloc     Free %Al %Fr
--------------------------------------------------
Fastpath              5297262  5259882  99  99
Slowpath                 4477    39586   0   0
Page Alloc                937      824   0   0
Add partial                 0     2515   0   0
Remove partial           1691      824   0   0
RemoteObj/SlabFrozen     2621     9684   0   0
Total                 5301739  5299468

Deactivate Full=2620(100%) Empty=0(0%) ToHead=0(0%) ToTail=0(0%)

Less good because the proportion of slowpath is a bit higher here.



Descriptions of the output:

Total:		The total number of allocation and frees that occurred for a
		slab

Fastpath:	The number of allocations/frees that used the fastpath.

Slowpath:	Other allocations

Page Alloc:	Number of calls to the page allocator as a result of slowpath
		processing

Add Partial:	Number of slabs added to the partial list through free or
		alloc (occurs during cpuslab flushes)

Remove Partial:	Number of slabs removed from the partial list as a result of
		allocations retrieving a partial slab or by a free freeing
		the last object of a slab.

RemoteObj/Froz:	How many times were remotely freed object encountered when a
		slab was about to be deactivated. Frozen: How many times was
		free able to skip list processing because the slab was in use
		as the cpuslab of another processor.

Flushes:	Number of times the cpuslab was flushed on request
		(kmem_cache_shrink, may result from races in __slab_alloc)

Refill:		Number of times we were able to refill the cpuslab from
		remotely freed objects for the same slab.

Deactivate:	Statistics how slabs were deactivated. Shows how they were
		put onto the partial list.


Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |  149 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/slub_def.h    |   23 ++++++
 lib/Kconfig.debug           |   11 +++
 mm/slub.c                   |  100 +++++++++++++++++++++++++++--
 4 files changed, 266 insertions(+), 17 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-04 14:37:14.399727258 -0800
+++ linux-2.6/include/linux/slub_def.h	2008-02-04 15:37:42.872467791 -0800
@@ -11,12 +11,35 @@
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
 
+enum stat_item {
+	ALLOC_FASTPATH,		/* Allocation from cpu slab */
+	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
+	FREE_FASTPATH,		/* Free to cpu slub */
+	FREE_SLOWPATH,		/* Freeing not to cpu slab */
+	FREE_FROZEN,		/* Freeing to frozen slab */
+	FREE_ADD_PARTIAL,	/* Freeing moves slab to partial list */
+	FREE_REMOVE_PARTIAL,	/* Freeing removes last object */
+	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from partial list */
+	ALLOC_SLAB,		/* Cpu slab acquired from page allocator */
+	ALLOC_REFILL,		/* Refill cpu slab from slab freelist */
+	FREE_SLAB,		/* Slab freed to the page allocator */
+	CPUSLAB_FLUSH,		/* Abandoning of the cpu slab */
+	DEACTIVATE_FULL,	/* Cpu slab was full when deactivated */
+	DEACTIVATE_EMPTY,	/* Cpu slab was empty when deactivated */
+	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
+	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
+	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
+	NR_SLUB_STAT_ITEMS };
+
 struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to first free per cpu object */
 	struct page *page;	/* The slab from which we are allocating */
 	int node;		/* The node of the page (or -1 for debug) */
 	unsigned int offset;	/* Freepointer offset (in word units) */
 	unsigned int objsize;	/* Size of an object (from kmem_cache) */
+#ifdef CONFIG_SLUB_STATS
+	unsigned stat[NR_SLUB_STAT_ITEMS];
+#endif
 };
 
 struct kmem_cache_node {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-04 14:40:27.390320615 -0800
+++ linux-2.6/mm/slub.c	2008-02-04 16:41:10.255931037 -0800
@@ -243,6 +243,7 @@ enum track_item { TRACK_ALLOC, TRACK_FRE
 static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
+
 #else
 static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
 static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
@@ -251,8 +252,16 @@ static inline void sysfs_slab_remove(str
 {
 	kfree(s);
 }
+
 #endif
 
+static inline void stat(struct kmem_cache_cpu *c, enum stat_item si)
+{
+#ifdef CONFIG_SLUB_STATS
+	c->stat[si]++;
+#endif
+}
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -1357,17 +1366,22 @@ static struct page *get_partial(struct k
 static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	struct kmem_cache_cpu *c = get_cpu_slab(s, smp_processor_id());
 
 	ClearSlabFrozen(page);
 	if (page->inuse) {
 
-		if (page->freelist != page->end)
+		if (page->freelist != page->end) {
 			add_partial(n, page, tail);
-		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
+			stat(c, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
+		} else {
+			stat(c, DEACTIVATE_FULL);
+			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
 			add_full(n, page);
+		}
 		slab_unlock(page);
-
 	} else {
+		stat(c, DEACTIVATE_EMPTY);
 		if (n->nr_partial < MIN_PARTIAL) {
 			/*
 			 * Adding an empty slab to the partial slabs in order
@@ -1393,6 +1407,9 @@ static void deactivate_slab(struct kmem_
 {
 	struct page *page = c->page;
 	int tail = 1;
+
+	if (c->freelist)
+		stat(c, DEACTIVATE_REMOTE_FREES);
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
@@ -1422,6 +1439,7 @@ static void deactivate_slab(struct kmem_
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
+	stat(c, CPUSLAB_FLUSH);
 	slab_lock(c->page);
 	deactivate_slab(s, c);
 }
@@ -1505,6 +1523,7 @@ static void *__slab_alloc(struct kmem_ca
 	slab_lock(c->page);
 	if (unlikely(!node_match(c, node)))
 		goto another_slab;
+	stat(c, ALLOC_REFILL);
 load_freelist:
 	object = c->page->freelist;
 	if (unlikely(object == c->page->end))
@@ -1519,6 +1538,7 @@ load_freelist:
 	c->node = page_to_nid(c->page);
 unlock_out:
 	slab_unlock(c->page);
+	stat(c, ALLOC_SLOWPATH);
 out:
 #ifdef CONFIG_FAST_CMPXCHG_LOCAL
 	preempt_disable();
@@ -1533,6 +1553,7 @@ new_slab:
 	new = get_partial(s, gfpflags, node);
 	if (new) {
 		c->page = new;
+		stat(c, ALLOC_FROM_PARTIAL);
 		goto load_freelist;
 	}
 
@@ -1548,6 +1569,7 @@ new_slab:
 		c = get_cpu_slab(s, smp_processor_id());
 		if (c->page)
 			flush_slab(s, c);
+		stat(c, ALLOC_SLAB);
 		slab_lock(new);
 		SetSlabFrozen(new);
 		c->page = new;
@@ -1606,6 +1628,7 @@ static __always_inline void *slab_alloc(
 			}
 			break;
 		}
+		stat(c, ALLOC_FASTPATH);
 	} while (cmpxchg_local(&c->freelist, object, object[c->offset])
 								!= object);
 	put_cpu();
@@ -1621,6 +1644,7 @@ static __always_inline void *slab_alloc(
 	else {
 		object = c->freelist;
 		c->freelist = object[c->offset];
+		stat(c, ALLOC_FASTPATH);
 	}
 	local_irq_restore(flags);
 #endif
@@ -1658,12 +1682,14 @@ static void __slab_free(struct kmem_cach
 {
 	void *prior;
 	void **object = (void *)x;
+	struct kmem_cache_cpu *c = get_cpu_slab(s, raw_smp_processor_id());
 
 #ifdef CONFIG_FAST_CMPXCHG_LOCAL
 	unsigned long flags;
 
 	local_irq_save(flags);
 #endif
+	stat(c, FREE_SLOWPATH);
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
@@ -1673,8 +1699,10 @@ checks_ok:
 	page->freelist = object;
 	page->inuse--;
 
-	if (unlikely(SlabFrozen(page)))
+	if (unlikely(SlabFrozen(page))) {
+		stat(c, FREE_FROZEN);
 		goto out_unlock;
+	}
 
 	if (unlikely(!page->inuse))
 		goto slab_empty;
@@ -1684,8 +1712,10 @@ checks_ok:
 	 * was not on the partial list before
 	 * then add it.
 	 */
-	if (unlikely(prior == page->end))
+	if (unlikely(prior == page->end)) {
 		add_partial(get_node(s, page_to_nid(page)), page, 1);
+		stat(c, FREE_ADD_PARTIAL);
+	}
 
 out_unlock:
 	slab_unlock(page);
@@ -1695,13 +1725,16 @@ out_unlock:
 	return;
 
 slab_empty:
-	if (prior != page->end)
+	if (prior != page->end) {
 		/*
 		 * Slab still on the partial list.
 		 */
 		remove_partial(s, page);
+		stat(c, FREE_REMOVE_PARTIAL);
+	}
 
 	slab_unlock(page);
+	stat(c, FREE_SLAB);
 #ifdef CONFIG_FAST_CMPXCHG_LOCAL
 	local_irq_restore(flags);
 #endif
@@ -1755,6 +1788,7 @@ static __always_inline void slab_free(st
 			break;
 		}
 		object[c->offset] = freelist;
+		stat(c, FREE_FASTPATH);
 	} while (cmpxchg_local(&c->freelist, freelist, object) != freelist);
 	put_cpu();
 #else
@@ -1766,6 +1800,7 @@ static __always_inline void slab_free(st
 	if (likely(page == c->page && c->node >= 0)) {
 		object[c->offset] = c->freelist;
 		c->freelist = object;
+		stat(c, FREE_FASTPATH);
 	} else
 		__slab_free(s, page, x, addr, c->offset);
 
@@ -3977,6 +4012,40 @@ static ssize_t remote_node_defrag_ratio_
 SLAB_ATTR(remote_node_defrag_ratio);
 #endif
 
+#ifdef CONFIG_SLUB_STATS
+
+#define STAT_ATTR(si, text) 					\
+static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
+{								\
+	unsigned long sum  = 0;					\
+	int cpu;						\
+								\
+	for_each_online_cpu(cpu)				\
+		sum += get_cpu_slab(s, cpu)->stat[si];		\
+	return sprintf(buf, "%lu\n", sum);			\
+}								\
+SLAB_ATTR_RO(text);						\
+
+STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
+STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
+STAT_ATTR(FREE_FASTPATH, free_fastpath);
+STAT_ATTR(FREE_SLOWPATH, free_slowpath);
+STAT_ATTR(FREE_FROZEN, free_frozen);
+STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
+STAT_ATTR(FREE_REMOVE_PARTIAL, free_remove_partial);
+STAT_ATTR(ALLOC_FROM_PARTIAL, alloc_from_partial);
+STAT_ATTR(ALLOC_SLAB, alloc_slab);
+STAT_ATTR(ALLOC_REFILL, alloc_refill);
+STAT_ATTR(FREE_SLAB, free_slab);
+STAT_ATTR(CPUSLAB_FLUSH, cpuslab_flush);
+STAT_ATTR(DEACTIVATE_FULL, deactivate_full);
+STAT_ATTR(DEACTIVATE_EMPTY, deactivate_empty);
+STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
+STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
+STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
+
+#endif
+
 static struct attribute *slab_attrs[] = {
 	&slab_size_attr.attr,
 	&object_size_attr.attr,
@@ -4007,6 +4076,25 @@ static struct attribute *slab_attrs[] = 
 #ifdef CONFIG_NUMA
 	&remote_node_defrag_ratio_attr.attr,
 #endif
+#ifdef CONFIG_SLUB_STATS
+	&alloc_fastpath_attr.attr,
+	&alloc_slowpath_attr.attr,
+	&free_fastpath_attr.attr,
+	&free_slowpath_attr.attr,
+	&free_frozen_attr.attr,
+	&free_add_partial_attr.attr,
+	&free_remove_partial_attr.attr,
+	&alloc_from_partial_attr.attr,
+	&alloc_slab_attr.attr,
+	&alloc_refill_attr.attr,
+	&free_slab_attr.attr,
+	&cpuslab_flush_attr.attr,
+	&deactivate_full_attr.attr,
+	&deactivate_empty_attr.attr,
+	&deactivate_to_head_attr.attr,
+	&deactivate_to_tail_attr.attr,
+	&deactivate_remote_frees_attr.attr,
+#endif
 	NULL
 };
 
Index: linux-2.6/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.orig/Documentation/vm/slabinfo.c	2008-02-04 14:37:14.451726859 -0800
+++ linux-2.6/Documentation/vm/slabinfo.c	2008-02-04 15:36:26.596093238 -0800
@@ -32,6 +32,13 @@ struct slabinfo {
 	int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	unsigned long partial, objects, slabs;
+	unsigned long alloc_fastpath, alloc_slowpath;
+	unsigned long free_fastpath, free_slowpath;
+	unsigned long free_frozen, free_add_partial, free_remove_partial;
+	unsigned long alloc_from_partial, alloc_slab, free_slab, alloc_refill;
+	unsigned long cpuslab_flush, deactivate_full, deactivate_empty;
+	unsigned long deactivate_to_head, deactivate_to_tail;
+	unsigned long deactivate_remote_frees;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
 } slabinfo[MAX_SLABS];
@@ -64,8 +71,10 @@ int show_inverted = 0;
 int show_single_ref = 0;
 int show_totals = 0;
 int sort_size = 0;
+int sort_active = 0;
 int set_debug = 0;
 int show_ops = 0;
+int show_activity = 0;
 
 /* Debug options */
 int sanity = 0;
@@ -93,8 +102,10 @@ void usage(void)
 	printf("slabinfo 5/7/2007. (c) 2007 sgi. clameter@sgi.com\n\n"
 		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
+		"-A|--activity          Most active slabs first\n"
 		"-d<options>|--debug=<options> Set/Clear Debug options\n"
-		"-e|--empty		Show empty slabs\n"
+		"-D|--display-active    Switch line format to activity\n"
+		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
@@ -281,8 +292,11 @@ int line = 0;
 
 void first_line(void)
 {
-	printf("Name                   Objects Objsize    Space "
-		"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
+	if (show_activity)
+		printf("Name                   Objects    Alloc     Free   %%Fast\n");
+	else
+		printf("Name                   Objects Objsize    Space "
+			"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
 }
 
 /*
@@ -309,6 +323,12 @@ unsigned long slab_size(struct slabinfo 
 	return 	s->slabs * (page_size << s->order);
 }
 
+unsigned long slab_activity(struct slabinfo *s)
+{
+	return 	s->alloc_fastpath + s->free_fastpath +
+		s->alloc_slowpath + s->free_slowpath;
+}
+
 void slab_numa(struct slabinfo *s, int mode)
 {
 	int node;
@@ -392,6 +412,71 @@ const char *onoff(int x)
 	return "Off";
 }
 
+void slab_stats(struct slabinfo *s)
+{
+	unsigned long total_alloc;
+	unsigned long total_free;
+	unsigned long total;
+
+	if (!s->alloc_slab)
+		return;
+
+	total_alloc = s->alloc_fastpath + s->alloc_slowpath;
+	total_free = s->free_fastpath + s->free_slowpath;
+
+	if (!total_alloc)
+		return;
+
+	printf("\n");
+	printf("Slab Perf Counter       Alloc     Free %%Al %%Fr\n");
+	printf("--------------------------------------------------\n");
+	printf("Fastpath             %8lu %8lu %3lu %3lu\n",
+		s->alloc_fastpath, s->free_fastpath,
+		s->alloc_fastpath * 100 / total_alloc,
+		s->free_fastpath * 100 / total_free);
+	printf("Slowpath             %8lu %8lu %3lu %3lu\n",
+		total_alloc - s->alloc_fastpath, s->free_slowpath,
+		(total_alloc - s->alloc_fastpath) * 100 / total_alloc,
+		s->free_slowpath * 100 / total_free);
+	printf("Page Alloc           %8lu %8lu %3lu %3lu\n",
+		s->alloc_slab, s->free_slab,
+		s->alloc_slab * 100 / total_alloc,
+		s->free_slab * 100 / total_free);
+	printf("Add partial          %8lu %8lu %3lu %3lu\n",
+		s->deactivate_to_head + s->deactivate_to_tail,
+		s->free_add_partial,
+		(s->deactivate_to_head + s->deactivate_to_tail) * 100 / total_alloc,
+		s->free_add_partial * 100 / total_free);
+	printf("Remove partial       %8lu %8lu %3lu %3lu\n",
+		s->alloc_from_partial, s->free_remove_partial,
+		s->alloc_from_partial * 100 / total_alloc,
+		s->free_remove_partial * 100 / total_free);
+
+	printf("RemoteObj/SlabFrozen %8lu %8lu %3lu %3lu\n",
+		s->deactivate_remote_frees, s->free_frozen,
+		s->deactivate_remote_frees * 100 / total_alloc,
+		s->free_frozen * 100 / total_free);
+
+	printf("Total                %8lu %8lu\n\n", total_alloc, total_free);
+
+	if (s->cpuslab_flush)
+		printf("Flushes %8lu\n", s->cpuslab_flush);
+
+	if (s->alloc_refill)
+		printf("Refill %8lu\n", s->alloc_refill);
+
+	total = s->deactivate_full + s->deactivate_empty +
+			s->deactivate_to_head + s->deactivate_to_tail;
+
+	if (total)
+		printf("Deactivate Full=%lu(%lu%%) Empty=%lu(%lu%%) "
+			"ToHead=%lu(%lu%%) ToTail=%lu(%lu%%)\n",
+			s->deactivate_full, (s->deactivate_full * 100) / total,
+			s->deactivate_empty, (s->deactivate_empty * 100) / total,
+			s->deactivate_to_head, (s->deactivate_to_head * 100) / total,
+			s->deactivate_to_tail, (s->deactivate_to_tail * 100) / total);
+}
+
 void report(struct slabinfo *s)
 {
 	if (strcmp(s->name, "*") == 0)
@@ -430,6 +515,7 @@ void report(struct slabinfo *s)
 	ops(s);
 	show_tracking(s);
 	slab_numa(s, 1);
+	slab_stats(s);
 }
 
 void slabcache(struct slabinfo *s)
@@ -479,13 +565,27 @@ void slabcache(struct slabinfo *s)
 		*p++ = 'T';
 
 	*p = 0;
-	printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
-		s->name, s->objects, s->object_size, size_str, dist_str,
-		s->objs_per_slab, s->order,
-		s->slabs ? (s->partial * 100) / s->slabs : 100,
-		s->slabs ? (s->objects * s->object_size * 100) /
-			(s->slabs * (page_size << s->order)) : 100,
-		flags);
+	if (show_activity) {
+		unsigned long total_alloc;
+		unsigned long total_free;
+
+		total_alloc = s->alloc_fastpath + s->alloc_slowpath;
+		total_free = s->free_fastpath + s->free_slowpath;
+
+		printf("%-21s %8ld %8ld %8ld %3ld %3ld \n",
+			s->name, s->objects,
+			total_alloc, total_free,
+			total_alloc ? (s->alloc_fastpath * 100 / total_alloc) : 0,
+			total_free ? (s->free_fastpath * 100 / total_free) : 0);
+	}
+	else
+		printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
+			s->name, s->objects, s->object_size, size_str, dist_str,
+			s->objs_per_slab, s->order,
+			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->objects * s->object_size * 100) /
+				(s->slabs * (page_size << s->order)) : 100,
+			flags);
 }
 
 /*
@@ -892,6 +992,8 @@ void sort_slabs(void)
 
 			if (sort_size)
 				result = slab_size(s1) < slab_size(s2);
+			else if (sort_active)
+				result = slab_activity(s1) < slab_activity(s2);
 			else
 				result = strcasecmp(s1->name, s2->name);
 
@@ -1074,6 +1176,23 @@ void read_slab_dir(void)
 			free(t);
 			slab->store_user = get_obj("store_user");
 			slab->trace = get_obj("trace");
+			slab->alloc_fastpath = get_obj("alloc_fastpath");
+			slab->alloc_slowpath = get_obj("alloc_slowpath");
+			slab->free_fastpath = get_obj("free_fastpath");
+			slab->free_slowpath = get_obj("free_slowpath");
+			slab->free_frozen= get_obj("free_frozen");
+			slab->free_add_partial = get_obj("free_add_partial");
+			slab->free_remove_partial = get_obj("free_remove_partial");
+			slab->alloc_from_partial = get_obj("alloc_from_partial");
+			slab->alloc_slab = get_obj("alloc_slab");
+			slab->alloc_refill = get_obj("alloc_refill");
+			slab->free_slab = get_obj("free_slab");
+			slab->cpuslab_flush = get_obj("cpuslab_flush");
+			slab->deactivate_full = get_obj("deactivate_full");
+			slab->deactivate_empty = get_obj("deactivate_empty");
+			slab->deactivate_to_head = get_obj("deactivate_to_head");
+			slab->deactivate_to_tail = get_obj("deactivate_to_tail");
+			slab->deactivate_remote_frees = get_obj("deactivate_remote_frees");
 			chdir("..");
 			if (slab->name[0] == ':')
 				alias_targets++;
@@ -1124,7 +1243,9 @@ void output_slabs(void)
 
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
+	{ "activity", 0, NULL, 'A' },
 	{ "debug", 2, NULL, 'd' },
+	{ "display-activity", 0, NULL, 'D' },
 	{ "empty", 0, NULL, 'e' },
 	{ "first-alias", 0, NULL, 'f' },
 	{ "help", 0, NULL, 'h' },
@@ -1149,7 +1270,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzTS",
+	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTS",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1158,11 +1279,17 @@ int main(int argc, char *argv[])
 		case 'a':
 			show_alias = 1;
 			break;
+		case 'A':
+			sort_active = 1;
+			break;
 		case 'd':
 			set_debug = 1;
 			if (!debug_opt_scan(optarg))
 				fatal("Invalid debug option '%s'\n", optarg);
 			break;
+		case 'D':
+			show_activity = 1;
+			break;
 		case 'e':
 			show_empty = 1;
 			break;
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2008-02-04 14:37:14.459726937 -0800
+++ linux-2.6/lib/Kconfig.debug	2008-02-04 14:40:30.062303158 -0800
@@ -205,6 +205,17 @@ config SLUB_DEBUG_ON
 	  off in a kernel built with CONFIG_SLUB_DEBUG_ON by specifying
 	  "slub_debug=-".
 
+config SLUB_STATS
+	default n
+	bool "Enable SLUB performance statistics"
+	depends on SLUB
+	help
+	  SLUB statistics are useful to debug SLUBs allocation behavior in
+	  order find ways to optimize the allocator. This should never be
+	  enabled for production use since keeping statistics slows down
+	  the allocator by 5 to 10%. The slabinfo command supports
+	  determination of the most active slabs. Try running: slabinfo -DA
+
 config DEBUG_PREEMPT
 	bool "Debug preemptible kernel"
 	depends on DEBUG_KERNEL && PREEMPT && (TRACE_IRQFLAGS_SUPPORT || PPC64)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
