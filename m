From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:52:51 -0400
Message-Id: <20070625195251.21210.18354.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 4/11] Shared Policy: fix show_numa_maps()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Policy Infrstructure 4/11 fix show_numa_maps()

Against 2.6.22-rc4-mm2

This patch updates the procfs numa_maps display to handle multiple
shared policy ranges on a single vma.  numa_maps() still uses the
procfs task maps infrastructure, but provides wrappers around the
maps seq_file ops to handle shared policy "submaps", if any.

This fixes a problem with numa_maps for shared mappings:
Before this [mapped file policy] patch series, numa_maps could show
you different results for shared mappings depending on which task you
examined.  A task which has installed shared policies on sub-ranges
of the shared region will show the policies on the sub-ranges, as the
vmas for that task were split when the policies were installed.  
Another task that shares the region, but didn't install any policies,
or installed policies on a different region or set of regions will
show a different policy/range or set thereof, based on the VMAs
of that task.  By displaying the policies directly from the shared
policy structure, we now see the same info from each task that maps
the segment.

The patch expands the proc_maps_private struct [#ifdef CONFIG_NUMA]
to track the existence of and progress through a submap for the
"current" vma.  For vmas with shared policy submaps, a new 
function--get_numa_submap()--in mm/mempolicy.c allocates and
populates an array of the policy ranges in the shared policy.
To facilitate this, the shared policy struct tracks the number
of ranges [sp_nodes] in the tree.

The nm_* numa_map seq_file wrappers pass the range to be displayed
to show_numa_map() via the saddr and eaddr members added to the
proc_maps_private struct.  The patch modifies show_numa_map() to
use these members, where appropriate, instead of vm_start, vm_end.

As before, once the internal page size buffer is full, seq_read()
suspends the display, drops the mmap_sem and exits the read.
During this time the vma list can change.  However, even within a
single seq_read(), the shared_policy "submap" can be changed by
other mappers.  We could prevent this by holding the shared policy
spin_lock or otherwise holding off other mappers.  That would also
hold off other tasks faulting in pages, attempting to look up the
policy for that offset, unless we convert the lock to reader/writer.
It doesn't seem worth the effort, as the numa_map is only a snap_shot
in any case.  So, this patch makes a best effort [at least as good as
unpatched task map code, I think] to perform a single scan over the
address space, displaying the policies and page state/location
for policy ranges "snapped" under spin lock into the "submap"
array mentioned above.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/proc/task_mmu.c            |  191 ++++++++++++++++++++++++++++++++++++++++--
 include/linux/mempolicy.h     |    5 +
 include/linux/mm.h            |    6 +
 include/linux/proc_fs.h       |   12 ++
 include/linux/shared_policy.h |    3 
 mm/mempolicy.c                |   57 +++++++++++-
 6 files changed, 264 insertions(+), 10 deletions(-)

Index: Linux/include/linux/proc_fs.h
===================================================================
--- Linux.orig/include/linux/proc_fs.h	2007-06-22 13:07:48.000000000 -0400
+++ Linux/include/linux/proc_fs.h	2007-06-22 13:10:39.000000000 -0400
@@ -281,12 +281,24 @@ static inline struct proc_dir_entry *PDE
 	return PROC_I(inode)->pde;
 }
 
+struct mpol_range {
+	unsigned long saddr;
+	unsigned long eaddr;
+};
+
 struct proc_maps_private {
 	struct pid *pid;
 	struct task_struct *task;
 #ifdef CONFIG_MMU
 	struct vm_area_struct *tail_vma;
 #endif
+
+#ifdef CONFIG_NUMA
+	struct vm_area_struct *vma;	/* preserved over seq_reads */
+	unsigned long saddr;
+	unsigned long eaddr;		/* preserved over seq_reads */
+	struct mpol_range *range, *ranges; /* preserved ... */
+#endif
 };
 
 #endif /* _LINUX_PROC_FS_H */
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-06-22 13:10:35.000000000 -0400
+++ Linux/include/linux/mm.h	2007-06-22 13:10:39.000000000 -0400
@@ -1064,6 +1064,12 @@ static inline pgoff_t vma_addr_to_pgoff(
 {
 	return ((addr - vma->vm_start) >> shift) + vma->vm_pgoff;
 }
+
+static inline pgoff_t vma_pgoff_to_addr(struct vm_area_struct *vma,
+		pgoff_t pgoff)
+{
+	return ((pgoff - vma->vm_pgoff) << PAGE_SHIFT) + vma->vm_start;
+}
 #else
 static inline void setup_per_cpu_pageset(void) {}
 #endif
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-06-22 13:10:30.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-06-22 13:10:39.000000000 -0400
@@ -139,6 +139,11 @@ static inline void check_highest_zone(en
 int do_migrate_pages(struct mm_struct *mm,
 	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
 
+struct seq_file;
+extern int show_numa_map(struct seq_file *, void *);
+struct mpol_range;
+extern struct mpol_range *get_numa_submap(struct vm_area_struct *);
+
 #else
 
 struct mempolicy {};
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-22 13:10:35.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-22 13:11:15.000000000 -0400
@@ -1469,6 +1469,7 @@ static void sp_insert(struct shared_poli
 	}
 	rb_link_node(&new->nd, parent, p);
 	rb_insert_color(&new->nd, &sp->root);
+	++sp->nr_sp_nodes;
 	PDprintk("inserting %lx-%lx: %d\n", new->start, new->end,
 		 new->policy ? new->policy->policy : 0);
 }
@@ -1498,6 +1499,7 @@ static void sp_delete(struct shared_poli
 	rb_erase(&n->nd, &sp->root);
 	mpol_free(n->policy);
 	kmem_cache_free(sn_cache, n);
+	--sp->nr_sp_nodes;
 }
 
 struct sp_node *
@@ -1575,6 +1577,7 @@ struct shared_policy *mpol_shared_policy
 		return ERR_PTR(-ENOMEM);
 	sp->root = RB_ROOT;
 	spin_lock_init(&sp->lock);
+	sp->nr_sp_nodes = 0;
 
 	if (policy != MPOL_DEFAULT) {
 		struct mempolicy *newpol;
@@ -1989,9 +1992,9 @@ int show_numa_map(struct seq_file *m, vo
 		return 0;
 
 	mpol_to_str(buffer, sizeof(buffer),
-			    get_vma_policy(priv->task, vma, vma->vm_start));
+			    get_vma_policy(priv->task, vma, priv->saddr));
 
-	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
+	seq_printf(m, "%08lx %s", priv->saddr, buffer);
 
 	if (file) {
 		seq_printf(m, " file=");
@@ -2004,10 +2007,10 @@ int show_numa_map(struct seq_file *m, vo
 	}
 
 	if (is_vm_hugetlb_page(vma)) {
-		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
+		check_huge_range(vma, priv->saddr, priv->eaddr, md);
 		seq_printf(m, " huge");
 	} else {
-		check_pgd_range(vma, vma->vm_start, vma->vm_end,
+		check_pgd_range(vma, priv->saddr, priv->eaddr,
 				&node_online_map, MPOL_MF_STATS, md);
 	}
 
@@ -2046,3 +2049,49 @@ out:
 		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
 	return 0;
 }
+
+/*
+ * alloc/populate array of shared policy ranges for show_numa_map()
+ */
+struct mpol_range *get_numa_submap(struct vm_area_struct *vma)
+{
+	struct shared_policy *sp;
+	struct mpol_range *ranges, *range;
+	struct rb_node *rbn;
+	int nranges;
+
+	BUG_ON(!vma->vm_file);
+	sp = mapping_shared_policy(vma->vm_file->f_mapping);
+	if (!sp)
+		return NULL;
+
+	nranges = sp->nr_sp_nodes;
+	if (!nranges)
+		return NULL;
+
+	ranges = kzalloc((nranges + 1) * sizeof(*ranges), GFP_KERNEL);
+	if (!ranges)
+		return NULL;	/* pretend there are none */
+
+	range = ranges;
+	spin_lock(&sp->lock);
+	/*
+	 * # of ranges could have changes since we checked, but that is
+	 * unlikely, so this is close enough [as long as it's safe].
+	 */
+	rbn = rb_first(&sp->root);
+	/*
+	 * count nodes to ensure we leave one empty range struct
+	 * in case node added between check and alloc
+	 */
+	while (rbn && nranges--) {
+		struct sp_node *spn = rb_entry(rbn, struct sp_node, nd);
+		range->saddr = vma_pgoff_to_addr(vma, spn->start);
+		range->eaddr = vma_pgoff_to_addr(vma, spn->end);
+		++range;
+		rbn = rb_next(rbn);
+	}
+
+	spin_unlock(&sp->lock);
+	return ranges;
+}
Index: Linux/fs/proc/task_mmu.c
===================================================================
--- Linux.orig/fs/proc/task_mmu.c	2007-06-22 13:07:48.000000000 -0400
+++ Linux/fs/proc/task_mmu.c	2007-06-22 13:10:39.000000000 -0400
@@ -498,7 +498,188 @@ const struct file_operations proc_clear_
 #endif
 
 #ifdef CONFIG_NUMA
-extern int show_numa_map(struct seq_file *m, void *v);
+/*
+ * numa_maps uses procfs task maps file operations, with wrappers
+ * to handle mpol submaps--policy ranges within a vma
+ */
+
+/*
+ * start processing a new vma for show_numa_maps
+ */
+static void nm_vma_start(struct proc_maps_private *priv,
+			struct vm_area_struct *vma)
+{
+	if (!vma)
+		return;
+	priv->vma = vma;	/* saved across read()s */
+
+	priv->saddr = vma->vm_start;
+	if (!(vma->vm_flags & VM_SHARED) || !vma->vm_file ||
+		!vma->vm_file->f_mapping->spolicy) {
+		/*
+		 * usual case:  no submap
+		 */
+		priv->eaddr = vma->vm_end;
+		return;
+	}
+
+	priv->range = priv->ranges = get_numa_submap(vma);
+	if (!priv->range) {
+		priv->eaddr = vma->vm_end;	/* empty shared policy */
+		return;
+	}
+
+	/*
+	 * restart suspended submap where we left off
+	 */
+	while (priv->range->eaddr && priv->range->eaddr < priv->eaddr)
+		++priv->range;
+
+	if (!priv->range->eaddr)
+		priv->eaddr = vma->vm_end;
+	else if (priv->saddr < priv->range->saddr)
+		priv->eaddr = priv->range->saddr; /* show gap [default pol] */
+	else
+		priv->eaddr = priv->range->eaddr; /* show range */
+}
+
+/*
+ * done with numa_maps vma:  reset so we start a new
+ * vma on next seq_read.
+ */
+static void nm_vma_stop(struct proc_maps_private *priv)
+{
+	if (priv->ranges)
+		kfree(priv->ranges);
+	priv->ranges = priv->range = NULL;
+	priv->vma = NULL;
+}
+
+/*
+ * Advance to next vma in mm or next subrange in vma.
+ * mmap_sem held during a single seq_read(), but shared
+ * policy ranges can be modified at any time by other
+ * mappers.  We just continue to display the ranges we
+ * found when we started the vma.
+ */
+static void *nm_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	struct proc_maps_private *priv = m->private;
+	struct vm_area_struct *vma = v;
+
+	if (!priv->range || priv->eaddr >= vma->vm_end) {
+		/*
+		 * usual case:  no submap or end of vma
+		 * re: '>=' -- in case we got here from nm_start()
+		 * and vma @ pos truncated to < priv->eaddr
+		 */
+		nm_vma_stop(priv);
+		vma = m_next(m, v, pos);
+		nm_vma_start(priv, vma);
+		return vma;
+	}
+
+	/*
+	 * Advance to next range in submap
+	 */
+	priv->saddr = priv->eaddr;
+	if (priv->eaddr == priv->range->saddr) {
+		/*
+		 * just processed a gap in the submap
+		 */
+		priv->eaddr = min(priv->range->eaddr, vma->vm_end);
+		return vma;	/* show the range */
+	}
+
+	++priv->range;
+	if (!priv->range->eaddr)
+		priv->eaddr = vma->vm_end;	/* past end of ranges */
+	else if (priv->saddr < priv->range->saddr)
+		priv->eaddr = priv->range->saddr; /* gap in submap */
+	else
+		priv->eaddr = min(priv->range->eaddr, vma->vm_end);
+
+	return vma;
+}
+
+/*
+ * [Re]start scan for new seq_read().
+ * N.B., much could have changes in mm, as we dropped the mmap_sem
+ * between reads().  Need to call m_start() to find vma at pos.
+ */
+static void *nm_start(struct seq_file *m, loff_t *pos)
+{
+	struct proc_maps_private *priv = m->private;
+	struct vm_area_struct *vma;
+
+	if (!priv->range) {
+		/*
+		 * usual case:  1st after open, or finished prev vma
+		 */
+		vma = m_start(m, pos);
+		nm_vma_start(priv, vma);
+		return vma;
+	}
+
+	/*
+	 * Continue with submap of "current" vma.  However, vma could have
+	 * been unmapped, split, truncated, ... between read()s.
+	 * Reset "last_addr" to simulate seek;  find vma by 'pos'.
+	 */
+	m->version = 0;
+	--(*pos);		/* seq_read() incremented it */
+	vma = m_start(m, pos);
+	if (vma != priv->vma)
+		goto new_vma;
+	/*
+	 * Same vma address as where we left off, but could have different
+	 * ranges or could be entirely different vma.
+	 */
+	if (vma->vm_start > priv->eaddr)
+		goto new_vma;	/* starts past last range displayed */
+	if (priv->eaddr < vma->vm_end) {
+		/*
+		 * vma at pos still covers eaddr--where we left off.  Submap
+		 * could have changed, but we'll keep reporting ranges we found
+		 * earlier up to vm_end.
+		 * We hope it is very unlikely that submap changed.
+		 */
+		return nm_next(m, vma, pos);
+	}
+
+	/*
+	 * Already reported past end of vma; find next vma past eaddr
+	 */
+	while (vma && vma->vm_end < priv->eaddr)
+		vma = m_next(m, vma, pos);
+
+new_vma:
+	/*
+	 * new vma at pos;  continue from ~ last eaddr
+	 */
+	nm_vma_stop(priv);
+	nm_vma_start(priv, vma);
+	return vma;
+}
+
+/*
+ * Suspend display of numa_map--e.g., buffer full?
+ */
+static void nm_stop(struct seq_file *m, void *v)
+{
+	struct proc_maps_private *priv = m->private;
+	struct vm_area_struct *vma = v;
+
+	if (!vma || priv->eaddr >= vma->vm_end) {
+		nm_vma_stop(priv);
+	}
+	/*
+	 * leave state in priv for nm_start(); but drop the
+	 * mmap_sem and unref the mm
+	 */
+	m_stop(m, v);
+}
+
 
 static int show_numa_map_checked(struct seq_file *m, void *v)
 {
@@ -512,10 +693,10 @@ static int show_numa_map_checked(struct 
 }
 
 static struct seq_operations proc_pid_numa_maps_op = {
-        .start  = m_start,
-        .next   = m_next,
-        .stop   = m_stop,
-        .show   = show_numa_map_checked
+	.start  = nm_start,
+	.next   = nm_next,
+	.stop   = nm_stop,
+	.show   = show_numa_map_checked
 };
 
 static int numa_maps_open(struct inode *inode, struct file *file)
Index: Linux/include/linux/shared_policy.h
===================================================================
--- Linux.orig/include/linux/shared_policy.h	2007-06-22 13:10:35.000000000 -0400
+++ Linux/include/linux/shared_policy.h	2007-06-22 13:10:39.000000000 -0400
@@ -25,7 +25,8 @@ struct sp_node {
 
 struct shared_policy {
 	struct rb_root root;
-	spinlock_t lock;	/* protects rb tree */
+	spinlock_t     lock;		/* protects rb tree */
+	int            nr_sp_nodes;	/* for numa_maps */
 };
 
 extern struct shared_policy *mpol_shared_policy_new(struct address_space *,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
