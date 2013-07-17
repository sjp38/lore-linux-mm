Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1DDFE6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 15:50:31 -0400 (EDT)
Message-ID: <1374090625.15271.2.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] hugepage: allow parallelization of the hugepage fault path
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Wed, 17 Jul 2013 12:50:25 -0700
In-Reply-To: <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
	 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
	 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
	 <20130715072432.GA28053@voom.fritz.box>
	 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric B Munson <emunson@mgebm.net>, Anton Blanchard <anton@samba.org>

From: David Gibson <david@gibson.dropbear.id.au>

At present, the page fault path for hugepages is serialized by a
single mutex. This is used to avoid spurious out-of-memory conditions
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
table of mutexes, selected based on a hash, which allows us to know
which page in the file we're instantiating. For shared mappings, the
hash key is selected based on the address space and file offset being faulted.
Similarly, for private mappings, the mm and virtual address are used.

From: Anton Blanchard <anton@samba.org>
[https://lkml.org/lkml/2011/7/15/31]
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

40.68 seconds

Now the same test with 64 concurrent threads:
39.34 seconds

Hardly any speedup. Finally the 64 concurrent threads test with
this patch applied:
0.85 seconds

We go from 40.68 seconds to 0.85 seconds, an improvement of 47.9x

This was tested with the libhugetlbfs test suite, and the PASS/FAIL
count was the same before and after this patch.

From: Davidlohr Bueso <davidlohr.bueso@hp.com>

- Cleaned up and forward ported to Linus' latest.
- Cache aligned mutexes.
- Keep non SMP systems using a single mutex.

It was found that this mutex can become quite contended
during the early phases of large databases which make use of huge pages - for instance
startup and initial runs. One clear example is a 1.5Gb Oracle database, where lockstat
reports that this mutex can be one of the top 5 most contended locks in the kernel during
the first few minutes:

    	     hugetlb_instantiation_mutex:   10678     10678
             ---------------------------
             hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
             ---------------------------
             hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340

contentions:          10678
acquisitions:         99476
waittime-total: 76888911.01 us

With this patch we see a much less contention and wait time:

              &htlb_fault_mutex_table[i]:   383
              --------------------------
              &htlb_fault_mutex_table[i]    383   [<ffffffff8115e27b>] hugetlb_fault+0x1eb/0x440
              --------------------------
              &htlb_fault_mutex_table[i]    383   [<ffffffff8115e27b>] hugetlb_fault+0x1eb/0x440

contentions:        383
acquisitions:    120546
waittime-total: 1381.72 us

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Signed-off-by: Anton Blanchard <anton@samba.org>
Tested-by: Eric B Munson <emunson@mgebm.net>
Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 mm/hugetlb.c | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 14 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 83aff0a..1f6e564 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -21,6 +21,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/jhash.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -52,6 +53,13 @@ static unsigned long __initdata default_hstate_size;
  */
 DEFINE_SPINLOCK(hugetlb_lock);
 
+/*
+ * Serializes faults on the same logical page.  This is used to
+ * prevent spurious OOMs when the hugepage pool is fully utilized.
+ */
+static int num_fault_mutexes;
+static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
+
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
 	bool free = (spool->count == 0) && (spool->used_hpages == 0);
@@ -1896,13 +1904,15 @@ static void __exit hugetlb_exit(void)
 	for_each_hstate(h) {
 		kobject_put(hstate_kobjs[hstate_index(h)]);
 	}
-
+	kfree(htlb_fault_mutex_table);
 	kobject_put(hugepages_kobj);
 }
 module_exit(hugetlb_exit);
 
 static int __init hugetlb_init(void)
 {
+	int i;
+
 	/* Some platform decide whether they support huge pages at boot
 	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
 	 * there is no such support
@@ -1927,6 +1937,19 @@ static int __init hugetlb_init(void)
 	hugetlb_register_all_nodes();
 	hugetlb_cgroup_file_init();
 
+#ifdef CONFIG_SMP
+	num_fault_mutexes = roundup_pow_of_two(2 * num_possible_cpus());
+#else
+	num_fault_mutexes = 1;
+#endif
+	htlb_fault_mutex_table =
+		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
+	if (!htlb_fault_mutex_table)
+		return -ENOMEM;
+
+	for (i = 0; i < num_fault_mutexes; i++)
+		mutex_init(&htlb_fault_mutex_table[i]);
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -2709,15 +2732,14 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
 }
 
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, unsigned int flags)
+			   struct address_space *mapping, pgoff_t idx,
+			   unsigned long address, pte_t *ptep, unsigned int flags)
 {
 	struct hstate *h = hstate_vma(vma);
 	int ret = VM_FAULT_SIGBUS;
 	int anon_rmap = 0;
-	pgoff_t idx;
 	unsigned long size;
 	struct page *page;
-	struct address_space *mapping;
 	pte_t new_pte;
 
 	/*
@@ -2731,9 +2753,6 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 
-	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
-
 	/*
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
@@ -2839,15 +2858,51 @@ backout_unlocked:
 	goto out;
 }
 
+#ifdef CONFIG_SMP
+static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    struct address_space *mapping,
+			    pgoff_t idx, unsigned long address)
+{
+	unsigned long key[2];
+	u32 hash;
+
+	if (vma->vm_flags & VM_SHARED) {
+		key[0] = (unsigned long)mapping;
+		key[1] = idx;
+	} else {
+		key[0] = (unsigned long)mm;
+		key[1] = address >> huge_page_shift(h);
+	}
+
+	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
+
+	return hash & (num_fault_mutexes - 1);
+}
+#else
+/*
+ * For uniprocesor systems we always use a single mutex, so just
+ * return 0 and avoid the hashing overhead.
+ */
+static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    struct address_space *mapping,
+			    pgoff_t idx, unsigned long address)
+{
+	return 0;
+}
+#endif
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
-	pte_t *ptep;
-	pte_t entry;
+	pgoff_t idx;
 	int ret;
+	u32 hash;
+	pte_t *ptep, entry;
 	struct page *page = NULL;
+	struct address_space *mapping;
 	struct page *pagecache_page = NULL;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
 
 	address &= huge_page_mask(h);
@@ -2867,15 +2922,20 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
+		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags);
 		goto out_mutex;
 	}
 
@@ -2943,8 +3003,7 @@ out_page_table_lock:
 	put_page(page);
 
 out_mutex:
-	mutex_unlock(&hugetlb_instantiation_mutex);
-
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
 	return ret;
 }
 
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
