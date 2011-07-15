Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 338F06B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 02:10:34 -0400 (EDT)
Date: Fri, 15 Jul 2011 16:10:28 +1000
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/2] hugepage: Allow parallelization of the hugepage fault
 path
Message-ID: <20110715161028.2869d307@kryten>
In-Reply-To: <20110715160650.48d61245@kryten>
References: <20110125143226.37532ea2@kryten>
	<20110125143414.1dbb150c@kryten>
	<20110126092428.GR18984@csn.ul.ie>
	<20110715160650.48d61245@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Gibson <dwg@au1.ibm.com>

At present, the page fault path for hugepages is serialized by a
single mutex.  This is used to avoid spurious out-of-memory conditions
when the hugepage pool is fully utilized (two processes or threads can
race to instantiate the same mapping with the last hugepage from the
pool, the race loser returning VM_FAULT_OOM).  This problem is
specific to hugepages, because it is normal to want to use every
single hugepage in the system - with normal pages we simply assume
there will always be a few spare pages which can be used temporarily
until the race is resolved.

Unfortunately this serialization also means that clearing of hugepages
cannot be parallelized across multiple CPUs, which can lead to very
long process startup times when using large numbers of hugepages.

This patch improves the situation by replacing the single mutex with a
table of mutexes, selected based on a hash of the address_space and
file offset being faulted (or mm and virtual address for MAP_PRIVATE
mappings).

From: Anton Blanchard <anton@samba.org>

Forward ported and made a few changes:

- Use the Jenkins hash to scatter the hash, better than using just the
  low bits.

- Always round num_fault_mutexes to a power of two to avoid an
  expensive modulus in the hash calculation.

I also tested this patch on a large POWER7 box using a simple parallel
fault testcase:

http://ozlabs.org/~anton/junkcode/parallel_fault.c

Command line options:

parallel_fault <nr_threads> <size in kB> <skip in kB>


First the time taken to fault 128GB of 16MB hugepages:

# time hugectl --heap ./parallel_fault 1 134217728 16384
40.68 seconds

Now the same test with 64 concurrent threads:
# time hugectl --heap ./parallel_fault 64 134217728 16384
39.34 seconds

Hardly any speedup. Finally the 64 concurrent threads test with
this patch applied:
# time hugectl --heap ./parallel_fault 64 134217728 16384
0.85 seconds

We go from 40.68 seconds to 0.85 seconds, an improvement of 47.9x

This was tested with the libhugetlbfs test suite, and the PASS/FAIL
count was the same before and after this patch.


Signed-off-by: David Gibson <dwg@au1.ibm.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6-work/mm/hugetlb.c
===================================================================
--- linux-2.6-work.orig/mm/hugetlb.c	2011-07-15 09:17:23.724410080 +1000
+++ linux-2.6-work/mm/hugetlb.c	2011-07-15 09:17:24.584425505 +1000
@@ -21,6 +21,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/jhash.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -54,6 +55,13 @@ static unsigned long __initdata default_
 static DEFINE_SPINLOCK(hugetlb_lock);
 
 /*
+ * Serializes faults on the same logical page.  This is used to
+ * prevent spurious OOMs when the hugepage pool is fully utilized.
+ */
+static unsigned int num_fault_mutexes;
+static struct mutex *htlb_fault_mutex_table;
+
+/*
  * Region tracking -- allows tracking of reservations and instantiated pages
  *                    across the pages in a mapping.
  */
@@ -1772,6 +1780,8 @@ module_exit(hugetlb_exit);
 
 static int __init hugetlb_init(void)
 {
+	int i;
+
 	/* Some platform decide whether they support huge pages at boot
 	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
 	 * there is no such support
@@ -1798,6 +1808,12 @@ static int __init hugetlb_init(void)
 
 	hugetlb_register_all_nodes();
 
+	num_fault_mutexes = roundup_pow_of_two(2 * num_possible_cpus());
+	htlb_fault_mutex_table =
+		kmalloc(num_fault_mutexes * sizeof(struct mutex), GFP_KERNEL);
+	for (i = 0; i < num_fault_mutexes; i++)
+		mutex_init(&htlb_fault_mutex_table[i]);
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -2622,6 +2638,27 @@ backout_unlocked:
 	goto out;
 }
 
+static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    struct address_space *mapping,
+			    unsigned long pagenum, unsigned long address)
+{
+	unsigned long key[2];
+	u32 hash;
+
+	if ((vma->vm_flags & VM_SHARED)) {
+		key[0] = (unsigned long)mapping;
+		key[1] = pagenum;
+	} else {
+		key[0] = (unsigned long)mm;
+		key[1] = address >> huge_page_shift(h);
+	}
+
+	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
+
+	return hash & (num_fault_mutexes - 1);
+}
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
@@ -2630,8 +2667,10 @@ int hugetlb_fault(struct mm_struct *mm,
 	int ret;
 	struct page *page = NULL;
 	struct page *pagecache_page = NULL;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
+	struct address_space *mapping;
+	unsigned long idx;
+	u32 hash;
 
 	ptep = huge_pte_offset(mm, address);
 	if (ptep) {
@@ -2648,12 +2687,16 @@ int hugetlb_fault(struct mm_struct *mm,
 	if (!ptep)
 		return VM_FAULT_OOM;
 
+	mapping = vma->vm_file->f_mapping;
+	idx = vma_hugecache_offset(h, vma, address);
+
 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	mutex_lock(&hugetlb_instantiation_mutex);
+	hash = fault_mutex_hash(h, mm, vma, mapping, idx, address);
+	mutex_lock(&htlb_fault_mutex_table[hash]);
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
 		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
@@ -2722,7 +2765,7 @@ out_page_table_lock:
 		unlock_page(page);
 
 out_mutex:
-	mutex_unlock(&hugetlb_instantiation_mutex);
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
