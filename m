Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 005586B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 22:34:37 -0500 (EST)
Date: Tue, 25 Jan 2011 14:34:14 +1100
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/2] hugepage: Allow parallelization of the hugepage fault
 path
Message-ID: <20110125143414.1dbb150c@kryten>
In-Reply-To: <20110125143226.37532ea2@kryten>
References: <20110125143226.37532ea2@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: dwg@au1.ibm.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

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

- Always round num_fault_mutexes to a power of two to avoid an expensive
  modulus in the hash calculation.

I also tested this patch on a 64 thread POWER6 box using a simple parallel
fault testcase:

http://ozlabs.org/~anton/junkcode/parallel_fault.c

Command line options:

parallel_fault <nr_threads> <size in kB> <skip in kB>

First the time taken to fault 48GB of 16MB hugepages:
# time hugectl --heap ./parallel_fault 1 50331648 16384
11.1 seconds

Now the same test with 64 concurrent threads:
# time hugectl --heap ./parallel_fault 64 50331648 16384
8.8 seconds

Hardly any speedup. Finally the 64 concurrent threads test with this patch
applied:
# time hugectl --heap ./parallel_fault 64 50331648 16384
0.7 seconds

We go from 8.8 seconds to 0.7 seconds, an improvement of 12.6x.

Signed-off-by: David Gibson <dwg@au1.ibm.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: powerpc.git/mm/hugetlb.c
===================================================================
--- powerpc.git.orig/mm/hugetlb.c	2011-01-25 13:20:49.311405902 +1100
+++ powerpc.git/mm/hugetlb.c	2011-01-25 13:45:54.437235053 +1100
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
@@ -1764,6 +1772,8 @@ module_exit(hugetlb_exit);
 
 static int __init hugetlb_init(void)
 {
+	int i;
+
 	/* Some platform decide whether they support huge pages at boot
 	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
 	 * there is no such support
@@ -1790,6 +1800,12 @@ static int __init hugetlb_init(void)
 
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
@@ -2616,6 +2632,27 @@ backout_unlocked:
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
@@ -2624,8 +2661,10 @@ int hugetlb_fault(struct mm_struct *mm,
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
@@ -2642,12 +2681,16 @@ int hugetlb_fault(struct mm_struct *mm,
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
@@ -2716,7 +2759,7 @@ out_page_table_lock:
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
