Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6344F900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:48:21 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so133346pdj.26
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:48:21 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id az17si555108pdb.198.2014.10.28.00.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 00:48:20 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so134044pab.36
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:48:20 -0700 (PDT)
Date: Tue, 28 Oct 2014 23:44:50 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same as
 normal zero page.
Message-ID: <20141028154416.GB13840@gmail.com>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
 <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon, Oct 27, 2014 at 03:17:48PM -0700, Andrew Morton wrote:
> On Mon, 27 Oct 2014 23:02:13 +0800 Fengwei Yin <yfw.kernel@gmail.com> wrote:
> 
> > We could see following memory info in /proc/xxxx/smaps with THP enabled.
> >   7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
> >   Size:           4294967296 kB
> >   Rss:            10612736 kB
> >   Pss:            10612736 kB
> >   Shared_Clean:          0 kB
> >   Shared_Dirty:          0 kB
> >   Private_Clean:  10612736 kB
> >   Private_Dirty:         0 kB
> >   Referenced:     10612736 kB
> >   Anonymous:             0 kB
> >   AnonHugePages:  10612736 kB
> >   Swap:                  0 kB
> >   KernelPageSize:        4 kB
> >   MMUPageSize:           4 kB
> >   Locked:                0 kB
> >   VmFlags: rd mr mw me
> > which is wrong becuase just huge_zero_page/normal_zero_page is used for
> > /dev/zero. Most of the value should be 0.
> > 
> > This patch detects huge_zero_page (original implementation just detect
> > normal_zero_page) and avoids to update the wrong value for huge_zero_page.
> > 
> > ...
> >
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -41,6 +41,7 @@
> >  #include <linux/kernel_stat.h>
> >  #include <linux/mm.h>
> >  #include <linux/hugetlb.h>
> > +#include <linux/huge_mm.h>
> >  #include <linux/mman.h>
> >  #include <linux/swap.h>
> >  #include <linux/highmem.h>
> > @@ -787,6 +788,9 @@ check_pfn:
> >  		return NULL;
> >  	}
> >  
> > +	if (is_huge_zero_pfn(pfn))
> > +		return NULL;
> > +
> 
> Why this change?
> 
> What effect does it have upon vm_normal_page()'s many existing callers?

Subject: [PATCH v3] smaps should deal with huge zero page exactly same as
 normal zero page.

We could see following memory info in /proc/xxxx/smaps with THP enabled.
  7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
  Size:           4294967296 kB
  Rss:            10612736 kB
  Pss:            10612736 kB
  Shared_Clean:          0 kB
  Shared_Dirty:          0 kB
  Private_Clean:  10612736 kB
  Private_Dirty:         0 kB
  Referenced:     10612736 kB
  Anonymous:             0 kB
  AnonHugePages:  10612736 kB
  Swap:                  0 kB
  KernelPageSize:        4 kB
  MMUPageSize:           4 kB
  Locked:                0 kB
  VmFlags: rd mr mw me
which is wrong becuase just huge_zero_page/normal_zero_page is used for
/dev/zero. Most of the value should be 0.

This patch detects huge_zero_page (original implementation just detect
normal_zero_page) and avoids to update the wrong value for huge_zero_page.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Fengwei Yin <yfw.kernel@gmail.com>
---

Hi Andrew,
Please try this patch.
It passed build with/without CONFIG_TRANSPARENT_HUGEPAGE. Thanks.

Regards
Yin, Fengwei


 fs/proc/task_mmu.c      | 6 ++++--
 include/linux/huge_mm.h | 7 +++++++
 mm/huge_memory.c        | 5 +++++
 mm/memory.c             | 4 ++++
 4 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4e0388c..735b389 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -474,8 +474,11 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	if (!page)
 		return;
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
 		mss->anonymous += ptent_size;
+		if (PageTransHuge(page))
+			mss->anonymous_thp += HPAGE_PMD_SIZE;
+	}
 
 	if (page->index != pgoff)
 		mss->nonlinear += ptent_size;
@@ -511,7 +514,6 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
 		spin_unlock(ptl);
-		mss->anonymous_thp += HPAGE_PMD_SIZE;
 		return 0;
 	}
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad9051b..b594c53 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -157,6 +157,8 @@ static inline int hpage_nr_pages(struct page *page)
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
+extern bool is_huge_zero_pfn(unsigned long pfn);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -206,6 +208,11 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 	return 0;
 }
 
+static inline bool is_huge_zero_pfn(unsigned long pfn)
+{
+	return 0;
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74c78aa..7e7880c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -183,6 +183,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
+bool is_huge_zero_pfn(unsigned long pfn)
+{
+	return is_huge_zero_page(pfn_to_page(pfn));
+}
+
 static struct page *get_huge_zero_page(void)
 {
 	struct page *zero_page;
diff --git a/mm/memory.c b/mm/memory.c
index 1cc6bfb..eebb6c5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -41,6 +41,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
+#include <linux/huge_mm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/highmem.h>
@@ -787,6 +788,9 @@ check_pfn:
 		return NULL;
 	}
 
+	if (is_huge_zero_pfn(pfn))
+		return NULL;
+
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
