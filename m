Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88BE1828E1
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 10:07:58 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h144so111946405ita.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 07:07:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xb3si26850898pab.132.2016.06.06.07.07.31
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 07:07:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 30/32] thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE
Date: Mon,  6 Jun 2016 17:07:07 +0300
Message-Id: <1465222029-45942-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>

For file mappings, we don't deposit page tables on THP allocation
because it's not strictly required to implement split_huge_pmd(): we
can just clear pmd and let following page faults to reconstruct the
page table.

But Power makes use of deposited page table to address MMU quirk.

Let's hide THP page cache, including huge tmpfs, under separate config
option, so it can be forbidden on Power.

We can revert the patch later once solution for Power found.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/shmem_fs.h | 10 +++++++++-
 mm/Kconfig               |  8 ++++++++
 mm/huge_memory.c         |  2 +-
 mm/khugepaged.c          | 11 +++++++----
 mm/memory.c              |  5 +++--
 mm/shmem.c               | 26 +++++++++++++-------------
 6 files changed, 41 insertions(+), 21 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 0890f700a546..54fa28dfbd89 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -54,7 +54,6 @@ extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
-extern bool shmem_huge_enabled(struct vm_area_struct *vma);
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
@@ -112,4 +111,13 @@ static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
 
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+extern bool shmem_huge_enabled(struct vm_area_struct *vma);
+#else
+static inline bool shmem_huge_enabled(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 3e2daef3c946..3c81803b00a3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -440,6 +440,14 @@ choice
 endchoice
 
 #
+# We don't deposit page tables on file THP mapping,
+# but Power makes use of them to address MMU quirk.
+#
+config	TRANSPARENT_HUGE_PAGECACHE
+	def_bool y
+	depends on TRANSPARENT_HUGEPAGE && !PPC
+
+#
 # UP and nommu archs use km based percpu allocator
 #
 config NEED_PER_CPU_KM
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9a3316afc6ff..114e9caead2a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -292,7 +292,7 @@ static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
 	&use_zero_page_attr.attr,
-#ifdef CONFIG_SHMEM
+#if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
 	&shmem_enabled_attr.attr,
 #endif
 #ifdef CONFIG_DEBUG_VM
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 13ce29dda107..b4337cfe41cb 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -820,6 +820,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
 	if (shmem_file(vma->vm_file)) {
+		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+			return false;
 		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
 				HPAGE_PMD_NR);
 	}
@@ -1198,7 +1200,7 @@ out:
 	return ret;
 }
 
-#ifdef CONFIG_SHMEM
+#if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
 static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 {
 	struct vm_area_struct *vma;
@@ -1680,8 +1682,6 @@ skip:
 		if (khugepaged_scan.address < hstart)
 			khugepaged_scan.address = hstart;
 		VM_BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
-		if (shmem_file(vma->vm_file) && !shmem_huge_enabled(vma))
-			goto skip;
 
 		while (khugepaged_scan.address < hend) {
 			int ret;
@@ -1693,9 +1693,12 @@ skip:
 				  khugepaged_scan.address + HPAGE_PMD_SIZE >
 				  hend);
 			if (shmem_file(vma->vm_file)) {
-				struct file *file = get_file(vma->vm_file);
+				struct file *file;
 				pgoff_t pgoff = linear_page_index(vma,
 						khugepaged_scan.address);
+				if (!shmem_huge_enabled(vma))
+					goto skip;
+				file = get_file(vma->vm_file);
 				up_read(&mm->mmap_sem);
 				ret = 1;
 				khugepaged_scan_shmem(mm, file->f_mapping,
diff --git a/mm/memory.c b/mm/memory.c
index 2be64ed7776a..2b95d7f2676f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2906,7 +2906,7 @@ map_pte:
 	return 0;
 }
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 
 #define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
 static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
@@ -2988,7 +2988,8 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 	pte_t entry;
 	int ret;
 
-	if (pmd_none(*fe->pmd) && PageTransCompound(page)) {
+	if (pmd_none(*fe->pmd) && PageTransCompound(page) &&
+			IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
 		/* THP on COW? */
 		VM_BUG_ON_PAGE(memcg, page);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index a63bc49903e8..71d9b2cd5cfb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -363,7 +363,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 #define SHMEM_HUGE_DENY		(-1)
 #define SHMEM_HUGE_FORCE	(-2)
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
 int shmem_huge __read_mostly;
@@ -406,11 +406,11 @@ static const char *shmem_format_huge(int huge)
 	}
 }
 
-#else /* !CONFIG_TRANSPARENT_HUGEPAGE */
+#else /* !CONFIG_TRANSPARENT_HUGE_PAGECACHE */
 
 #define shmem_huge SHMEM_HUGE_DENY
 
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
 
 /*
  * Like add_to_page_cache_locked, but error if expected item has gone.
@@ -1229,7 +1229,7 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 	void __rcu **results;
 	struct page *page;
 
-	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		return NULL;
 
 	rcu_read_lock();
@@ -1270,7 +1270,7 @@ static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
 	int nr;
 	int err = -ENOSPC;
 
-	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		huge = false;
 	nr = huge ? HPAGE_PMD_NR : 1;
 
@@ -1773,7 +1773,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 	get_area = current->mm->get_unmapped_area;
 	addr = get_area(file, uaddr, len, pgoff, flags);
 
-	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		return addr;
 	if (IS_ERR_VALUE(addr))
 		return addr;
@@ -1890,7 +1890,7 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
-	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
 			((vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK) <
 			(vma->vm_end & HPAGE_PMD_MASK)) {
 		khugepaged_enter(vma, vma->vm_flags);
@@ -3285,7 +3285,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			sbinfo->gid = make_kgid(current_user_ns(), gid);
 			if (!gid_valid(sbinfo->gid))
 				goto bad_val;
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 		} else if (!strcmp(this_char, "huge")) {
 			int huge;
 			huge = shmem_parse_huge(value);
@@ -3382,7 +3382,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
 		seq_printf(seq, ",gid=%u",
 				from_kgid_munged(&init_user_ns, sbinfo->gid));
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 	/* Rightly or wrongly, show huge mount option unmasked by shmem_huge */
 	if (sbinfo->huge)
 		seq_printf(seq, ",huge=%s", shmem_format_huge(sbinfo->huge));
@@ -3728,7 +3728,7 @@ int __init shmem_init(void)
 		goto out1;
 	}
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 	if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY)
 		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
 	else
@@ -3745,7 +3745,7 @@ out3:
 	return error;
 }
 
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SYSFS)
+#if defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE) && defined(CONFIG_SYSFS)
 static ssize_t shmem_enabled_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
@@ -3828,7 +3828,7 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 			return false;
 	}
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SYSFS */
+#endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE && CONFIG_SYSFS */
 
 #else /* !CONFIG_SHMEM */
 
@@ -4008,7 +4008,7 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
 
-	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
 			((vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK) <
 			(vma->vm_end & HPAGE_PMD_MASK)) {
 		khugepaged_enter(vma, vma->vm_flags);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
