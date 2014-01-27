Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 73A946B0031
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 23:17:52 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so7218788qcy.25
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 20:17:52 -0800 (PST)
Received: from g5t0006.atlanta.hp.com (g5t0006.atlanta.hp.com. [15.192.0.43])
        by mx.google.com with ESMTPS id b79si7527930qge.79.2014.01.26.20.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 20:17:51 -0800 (PST)
Message-ID: <1390796264.12245.1.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH v2 8/8] mm, hugetlb: improve page-fault scalability
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 26 Jan 2014 20:17:44 -0800
In-Reply-To: <1390794746-16755-9-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
	 <1390794746-16755-9-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The kernel can currently only handle a single hugetlb page fault at a time.
This is due to a single mutex that serializes the entire path. This lock
protects from spurious OOM errors under conditions of low of low availability
of free hugepages. This problem is specific to hugepages, because it is
normal to want to use every single hugepage in the system - with normal pages
we simply assume there will always be a few spare pages which can be used
temporarily until the race is resolved.

Address this problem by using a table of mutexes, allowing a better chance of
parallelization, where each hugepage is individually serialized. The hash key
is selected depending on the mapping type. For shared ones it consists of the
address space and file offset being faulted; while for private ones the mm and
virtual address are used. The size of the table is selected based on a compromise
of collisions and memory footprint of a series of database workloads.

Large database workloads that make heavy use of hugepages can be particularly
exposed to this issue, causing start-up times to be painfully slow. This patch
reduces the startup time of a 10 Gb Oracle DB (with ~5000 faults) from 37.5 secs
to 25.7 secs. Larger workloads will naturally benefit even more.

NOTE:
The only downside to this patch, detected by Joonsoo Kim, is that a small race
is possible in private mappings: A child process (with its own mm, after cow)
can instantiate a page that is already being handled by the parent in a cow
fault. When low on pages, can trigger spurious OOMs. I have not been able to
think of a efficient way of handling this... but do we really care about such
a tiny window? We already maintain another theoretical race with normal pages.
If not, one possible way to is to maintain the single hash for private mappings
-- any workloads that *really* suffer from this scaling problem should already
use shared mappings.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 85 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 72 insertions(+), 13 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f3efa5..cffd105 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -22,6 +22,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/page-isolation.h>
+#include <linux/jhash.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -53,6 +54,13 @@ static unsigned long __initdata default_hstate_size;
  */
 DEFINE_SPINLOCK(hugetlb_lock);
 
+/*
++ * Serializes faults on the same logical page.  This is used to
++ * prevent spurious OOMs when the hugepage pool is fully utilized.
++ */
+static int num_fault_mutexes;
+static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
+
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
 	bool free = (spool->count == 0) && (spool->used_hpages == 0);
@@ -1922,11 +1930,14 @@ static void __exit hugetlb_exit(void)
 	}
 
 	kobject_put(hugepages_kobj);
+	kfree(htlb_fault_mutex_table);
 }
 module_exit(hugetlb_exit);
 
 static int __init hugetlb_init(void)
 {
+	int i;
+
 	/* Some platform decide whether they support huge pages at boot
 	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
 	 * there is no such support
@@ -1951,6 +1962,18 @@ static int __init hugetlb_init(void)
 	hugetlb_register_all_nodes();
 	hugetlb_cgroup_file_init();
 
+#ifdef CONFIG_SMP
+	num_fault_mutexes = roundup_pow_of_two(8 * num_possible_cpus());
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
 	return 0;
 }
 module_init(hugetlb_init);
@@ -2733,15 +2756,14 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
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
 	spinlock_t *ptl;
 
@@ -2756,9 +2778,6 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return ret;
 	}
 
-	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
-
 	/*
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
@@ -2868,17 +2887,53 @@ backout_unlocked:
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
+		key[0] = (unsigned long) mapping;
+		key[1] = idx;
+	} else {
+		key[0] = (unsigned long) mm;
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
+	pte_t *ptep, entry;
 	spinlock_t *ptl;
 	int ret;
+	u32 hash;
+	pgoff_t idx;
 	struct page *page = NULL;
 	struct page *pagecache_page = NULL;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
+	struct address_space *mapping;
 
 	address &= huge_page_mask(h);
 
@@ -2897,15 +2952,20 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
@@ -2974,8 +3034,7 @@ out_ptl:
 	put_page(page);
 
 out_mutex:
-	mutex_unlock(&hugetlb_instantiation_mutex);
-
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
 	return ret;
 }
 
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
