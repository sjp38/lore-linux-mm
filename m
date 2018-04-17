Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15D856B0022
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y129so1423968pgb.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b7si2783831pfh.257.2018.04.16.19.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:08 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 11/21] mm, THP, swap: Add sysfs interface to configure THP swapin
Date: Tue, 17 Apr 2018 10:02:20 +0800
Message-Id: <20180417020230.26412-12-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Swapin a THP as a whole isn't desirable at some situations.  For
example, for random access pattern, swapin a THP as a whole will
inflate the reading greatly.  So a sysfs interface:
/sys/kernel/mm/transparent_hugepage/swapin_enabled is added to
configure it.  Three options as follow are provided,

- always: THP swapin will be enabled always

- madvise: THP swapin will be enabled only for VMA with VM_HUGEPAGE
  flag set.

- never: THP swapin will be disabled always

The default configuration is: madvise.

During page fault, if a PMD swap mapping is found and THP swapin is
disabled, the huge swap cluster and the PMD swap mapping will be split
and fallback to normal page swapin.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/huge_mm.h | 31 ++++++++++++++
 mm/huge_memory.c        | 89 ++++++++++++++++++++++++++++++++---------
 2 files changed, 102 insertions(+), 18 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f5348d072351..1cfd43047f0d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -62,6 +62,8 @@ enum transparent_hugepage_flag {
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
+	TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+	TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
 };
 
 struct kobject;
@@ -404,11 +406,40 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 
 #ifdef CONFIG_THP_SWAP
 extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
+
+static inline bool transparent_hugepage_swapin_enabled(
+	struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_NOHUGEPAGE)
+		return false;
+
+	if (is_vma_temporary_stack(vma))
+		return false;
+
+	if (test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
+		return false;
+
+	if (transparent_hugepage_flags &
+			(1 << TRANSPARENT_HUGEPAGE_SWAPIN_FLAG))
+		return true;
+
+	if (transparent_hugepage_flags &
+			(1 << TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG))
+		return !!(vma->vm_flags & VM_HUGEPAGE);
+
+	return false;
+}
 #else /* CONFIG_THP_SWAP */
 static inline int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	return 0;
 }
+
+static inline bool transparent_hugepage_swapin_enabled(
+	struct vm_area_struct *vma)
+{
+	return false;
+}
 #endif /* CONFIG_THP_SWAP */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e4d32384e10b..0538fe48918b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -57,7 +57,8 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
-	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
+	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG)|
+	(1<<TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG);
 
 static struct shrinker deferred_split_shrinker;
 
@@ -316,6 +317,53 @@ static struct kobj_attribute debug_cow_attr =
 	__ATTR(debug_cow, 0644, debug_cow_show, debug_cow_store);
 #endif /* CONFIG_DEBUG_VM */
 
+#ifdef CONFIG_THP_SWAP
+static ssize_t swapin_enabled_show(struct kobject *kobj,
+				   struct kobj_attribute *attr, char *buf)
+{
+	if (test_bit(TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+		     &transparent_hugepage_flags))
+		return sprintf(buf, "[always] madvise never\n");
+	else if (test_bit(TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
+			  &transparent_hugepage_flags))
+		return sprintf(buf, "always [madvise] never\n");
+	else
+		return sprintf(buf, "always madvise [never]\n");
+}
+
+static ssize_t swapin_enabled_store(struct kobject *kobj,
+				    struct kobj_attribute *attr,
+				    const char *buf, size_t count)
+{
+	ssize_t ret = count;
+
+	if (!memcmp("always", buf,
+		    min(sizeof("always")-1, count))) {
+		clear_bit(TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
+			  &transparent_hugepage_flags);
+		set_bit(TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+			&transparent_hugepage_flags);
+	} else if (!memcmp("madvise", buf,
+			   min(sizeof("madvise")-1, count))) {
+		clear_bit(TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+			  &transparent_hugepage_flags);
+		set_bit(TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
+			&transparent_hugepage_flags);
+	} else if (!memcmp("never", buf,
+			   min(sizeof("never")-1, count))) {
+		clear_bit(TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+			  &transparent_hugepage_flags);
+		clear_bit(TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
+			  &transparent_hugepage_flags);
+	} else
+		ret = -EINVAL;
+
+	return ret;
+}
+static struct kobj_attribute swapin_enabled_attr =
+	__ATTR(swapin_enabled, 0644, swapin_enabled_show, swapin_enabled_store);
+#endif /* CONFIG_THP_SWAP */
+
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
@@ -326,6 +374,9 @@ static struct attribute *hugepage_attr[] = {
 #endif
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
+#endif
+#ifdef CONFIG_THP_SWAP
+	&swapin_enabled_attr.attr,
 #endif
 	NULL,
 };
@@ -1648,6 +1699,9 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 retry:
 	page = lookup_swap_cache(entry, NULL, vmf->address);
 	if (!page) {
+		if (!transparent_hugepage_swapin_enabled(vma))
+			goto split;
+
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE, vma,
 					     haddr, false);
 		if (!page) {
@@ -1655,23 +1709,8 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 			 * Back out if somebody else faulted in this pmd
 			 * while we released the pmd lock.
 			 */
-			if (likely(pmd_same(*vmf->pmd, orig_pmd))) {
-				ret = split_swap_cluster(entry, false);
-				/*
-				 * Retry if somebody else swap in the swap
-				 * entry
-				 */
-				if (ret == -EEXIST) {
-					ret = 0;
-					goto retry;
-				/* swapoff occurs under us */
-				} else if (ret == -EINVAL)
-					ret = 0;
-				else {
-					count_vm_event(THP_SWPIN_FALLBACK);
-					goto fallback;
-				}
-			}
+			if (likely(pmd_same(*vmf->pmd, orig_pmd)))
+				goto split;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto out;
 		}
@@ -1784,6 +1823,20 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (page)
 		put_page(page);
 	return ret;
+split:
+	ret = split_swap_cluster(entry, false);
+	/* Retry if somebody else swap in the swap entry */
+	if (ret == -EEXIST) {
+		ret = 0;
+		goto retry;
+	}
+	/* swapoff occurs under us */
+	if (ret == -EINVAL) {
+		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+		return 0;
+	}
+	count_vm_event(THP_SWPIN_FALLBACK);
+	goto fallback;
 }
 #else
 static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
-- 
2.17.0
