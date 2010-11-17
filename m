Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 557178D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 22:41:28 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oAH3fOKH029372
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:24 -0800
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by hpaq3.eem.corp.google.com with ESMTP id oAH3fMuR006981
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:23 -0800
Received: by gwj17 with SMTP id 17so1001635gwj.5
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:22 -0800 (PST)
Date: Tue, 16 Nov 2010 19:41:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/3] mm: remove gfp mask from pcpu_get_vm_areas
In-Reply-To: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011161937380.19230@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pcpu_get_vm_areas() only uses GFP_KERNEL allocations, so remove the gfp_t
formal and use the mask internally.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/vmalloc.h |    2 +-
 mm/percpu-vm.c          |    2 +-
 mm/vmalloc.c            |   21 +++++++++------------
 3 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -119,7 +119,7 @@ extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
 #ifdef CONFIG_SMP
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
-				     size_t align, gfp_t gfp_mask);
+				     size_t align);
 
 void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms);
 #endif
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -421,7 +421,7 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 		return NULL;
 
 	vms = pcpu_get_vm_areas(pcpu_group_offsets, pcpu_group_sizes,
-				pcpu_nr_groups, pcpu_atom_size, GFP_KERNEL);
+				pcpu_nr_groups, pcpu_atom_size);
 	if (!vms) {
 		pcpu_free_chunk(chunk);
 		return NULL;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2190,17 +2190,16 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
  * @sizes: array containing size of each area
  * @nr_vms: the number of areas to allocate
  * @align: alignment, all entries in @offsets and @sizes must be aligned to this
- * @gfp_mask: allocation mask
  *
  * Returns: kmalloc'd vm_struct pointer array pointing to allocated
  *	    vm_structs on success, %NULL on failure
  *
  * Percpu allocator wants to use congruent vm areas so that it can
  * maintain the offsets among percpu areas.  This function allocates
- * congruent vmalloc areas for it.  These areas tend to be scattered
- * pretty far, distance between two areas easily going up to
- * gigabytes.  To avoid interacting with regular vmallocs, these areas
- * are allocated from top.
+ * congruent vmalloc areas for it with GFP_KERNEL.  These areas tend to
+ * be scattered pretty far, distance between two areas easily going up
+ * to gigabytes.  To avoid interacting with regular vmallocs, these
+ * areas are allocated from top.
  *
  * Despite its complicated look, this allocator is rather simple.  It
  * does everything top-down and scans areas from the end looking for
@@ -2211,7 +2210,7 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
  */
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
-				     size_t align, gfp_t gfp_mask)
+				     size_t align)
 {
 	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
 	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
@@ -2221,8 +2220,6 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	unsigned long base, start, end, last_end;
 	bool purged = false;
 
-	gfp_mask &= GFP_RECLAIM_MASK;
-
 	/* verify parameters and allocate data structures */
 	BUG_ON(align & ~PAGE_MASK || !is_power_of_2(align));
 	for (last_area = 0, area = 0; area < nr_vms; area++) {
@@ -2255,14 +2252,14 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		return NULL;
 	}
 
-	vms = kzalloc(sizeof(vms[0]) * nr_vms, gfp_mask);
-	vas = kzalloc(sizeof(vas[0]) * nr_vms, gfp_mask);
+	vms = kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
+	vas = kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
 	if (!vas || !vms)
 		goto err_free;
 
 	for (area = 0; area < nr_vms; area++) {
-		vas[area] = kzalloc(sizeof(struct vmap_area), gfp_mask);
-		vms[area] = kzalloc(sizeof(struct vm_struct), gfp_mask);
+		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
+		vms[area] = kzalloc(sizeof(struct vm_struct), GFP_KERNEL);
 		if (!vas[area] || !vms[area])
 			goto err_free;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
