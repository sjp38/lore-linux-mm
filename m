Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53D678E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:44:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o27-v6so123953pfj.6
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:44:54 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d12-v6si21574651pla.421.2018.09.11.17.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 17:44:53 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V5 RESEND 11/21] swap: Add sysfs interface to configure THP swapin
Date: Wed, 12 Sep 2018 08:44:04 +0800
Message-Id: <20180912004414.22583-12-ying.huang@intel.com>
In-Reply-To: <20180912004414.22583-1-ying.huang@intel.com>
References: <20180912004414.22583-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Swapin a THP as a whole isn't desirable in some situations.  For
example, for completely random access pattern, swapin a THP in one
piece will inflate the reading greatly.  So a sysfs interface:
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
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 Documentation/admin-guide/mm/transhuge.rst | 21 +++++++
 include/linux/huge_mm.h                    | 31 ++++++++++
 mm/huge_memory.c                           | 94 ++++++++++++++++++++++++------
 3 files changed, 127 insertions(+), 19 deletions(-)

diff --git a/Documentation/admin-guide/mm/transhuge.rst b/Documentation/admin-guide/mm/transhuge.rst
index 85e33f785fd7..23aefb17101c 100644
--- a/Documentation/admin-guide/mm/transhuge.rst
+++ b/Documentation/admin-guide/mm/transhuge.rst
@@ -160,6 +160,27 @@ Some userspace (such as a test program, or an optimized memory allocation
 
 	cat /sys/kernel/mm/transparent_hugepage/hpage_pmd_size
 
+Transparent hugepage may be swapout and swapin in one piece without
+splitting.  This will improve the utility of transparent hugepage but
+may inflate the read/write too.  So whether to enable swapin
+transparent hugepage in one piece can be configured as follow.
+
+	echo always >/sys/kernel/mm/transparent_hugepage/swapin_enabled
+	echo madvise >/sys/kernel/mm/transparent_hugepage/swapin_enabled
+	echo never >/sys/kernel/mm/transparent_hugepage/swapin_enabled
+
+always
+	Attempt to allocate a transparent huge page and read it from
+	swap space in one piece every time.
+
+never
+	Always split the swap space and PMD swap mapping and swapin
+	the fault normal page during swapin.
+
+madvise
+	Only swapin the transparent huge page in one piece for
+	MADV_HUGEPAGE madvise regions.
+
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c2b8ced6fc2b..9dedff974def 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -63,6 +63,8 @@ enum transparent_hugepage_flag {
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
+	TRANSPARENT_HUGEPAGE_SWAPIN_FLAG,
+	TRANSPARENT_HUGEPAGE_SWAPIN_REQ_MADV_FLAG,
 };
 
 struct kobject;
@@ -405,11 +407,40 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 
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
index 1232ade5deca..c4a766243a8f 100644
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
@@ -1653,6 +1704,9 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 retry:
 	page = lookup_swap_cache(entry, NULL, vmf->address);
 	if (!page) {
+		if (!transparent_hugepage_swapin_enabled(vma))
+			goto split;
+
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE, vma,
 					     haddr, false);
 		if (!page) {
@@ -1660,24 +1714,8 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 			 * Back out if somebody else faulted in this pmd
 			 * while we released the pmd lock.
 			 */
-			if (likely(pmd_same(*vmf->pmd, orig_pmd))) {
-				/*
-				 * Failed to allocate huge page, split huge swap
-				 * cluster, and fallback to swapin normal page
-				 */
-				ret = split_swap_cluster(entry, 0);
-				/* Somebody else swapin the swap entry, retry */
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
@@ -1790,6 +1828,24 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (page)
 		put_page(page);
 	return ret;
+split:
+	/*
+	 * Failed to allocate huge page, split huge swap cluster, and
+	 * fallback to swapin normal page
+	 */
+	ret = split_swap_cluster(entry, 0);
+	/* Somebody else swapin the swap entry, retry */
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
 #endif
 
-- 
2.16.4
