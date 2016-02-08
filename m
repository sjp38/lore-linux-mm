Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA328309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 03:43:36 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id c200so4439914wme.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 00:43:36 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id w76si15180290wmw.53.2016.02.08.00.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 00:43:34 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id g62so14439863wme.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 00:43:34 -0800 (PST)
Date: Mon, 8 Feb 2016 10:43:32 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: Some arch may want to use HPAGE_PMD related
 values as variables
Message-ID: <20160208084332.GD9075@node.shutemov.name>
References: <1454913660-27031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454913660-27031-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454913660-27031-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 08, 2016 at 12:11:00PM +0530, Aneesh Kumar K.V wrote:
> With next generation power processor, we are having a new mmu model
> [1] that require us to maintain a different linux page table format.
> 
> Inorder to support both current and future ppc64 systems with a single
> kernel we need to make sure kernel can select between different page
> table format at runtime. With the new MMU (radix MMU) added, we will
> have two different pmd hugepage size 16MB for hash model and 2MB for
> Radix model. Hence make HPAGE_PMD related values as a variable.
> 
> [1] http://ibm.biz/power-isa3 (Needs registration).
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/arm/include/asm/pgtable-3level.h | 8 ++++++++
>  arch/arm64/include/asm/pgtable.h      | 7 +++++++
>  arch/mips/include/asm/pgtable.h       | 8 ++++++++
>  arch/powerpc/mm/pgtable_64.c          | 7 +++++++
>  arch/s390/include/asm/pgtable.h       | 8 ++++++++
>  arch/sparc/include/asm/pgtable_64.h   | 7 +++++++
>  arch/tile/include/asm/pgtable.h       | 9 +++++++++
>  arch/x86/include/asm/pgtable.h        | 8 ++++++++
>  include/linux/huge_mm.h               | 3 ---
>  mm/huge_memory.c                      | 8 +++++---
>  10 files changed, 67 insertions(+), 6 deletions(-)

That is ugly. What about this:

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 459fd25b378e..f12513a20a06 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -111,9 +111,6 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
                        __split_huge_pmd(__vma, __pmd, __address);      \
        }  while (0)
 
-#if HPAGE_PMD_ORDER >= MAX_ORDER
-#error "hugepages can't be allocated by the buddy allocator"
-#endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
                            unsigned long *vm_flags, int advice);
 extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 08fc0ba2207e..bc33330b5547 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -83,7 +83,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
        (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
-static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
+static unsigned int khugepaged_pages_to_scan __read_mostly;
 static unsigned int khugepaged_pages_collapsed;
 static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
@@ -98,7 +98,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  * it would have happened if the vma was large enough during page
  * fault.
  */
-static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
+static unsigned int khugepaged_max_ptes_none __read_mostly;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -650,16 +650,36 @@ static inline void hugepage_exit_sysfs(struct kobject *hugepage_kobj)
 }
 #endif /* CONFIG_SYSFS */
 
+#define MAYBE_BUILD_BUG_ON(cond)               \
+({                                             \
+       if (__builtin_constant_p((cond)))       \
+               BUILD_BUG_ON(cond);             \
+       else                                    \
+               BUG_ON(cond);                   \
+})
+
 static int __init hugepage_init(void)
 {
        int err;
        struct kobject *hugepage_kobj;
 
+       khugepaged_pages_to_scan = HPAGE_PMD_NR*8;
+       khugepaged_max_ptes_none = HPAGE_PMD_NR-1;
+
        if (!has_transparent_hugepage()) {
                transparent_hugepage_flags = 0;
                return -EINVAL;
        }
 
+       /* hugepages can't be allocated by the buddy allocator */
+       MAYBE_BUILD_BUG_ON(HPAGE_PMD_ORDER >= MAX_ORDER);
+
+       /*
+        * we use page->mapping and page->index in second tail page
+        * as list_head: assuming THP order >= 2
+        */
+       MAYBE_BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
+
        err = hugepage_init_sysfs(&hugepage_kobj);
        if (err)
                goto err_sysfs;
@@ -760,12 +780,6 @@ static inline struct list_head *page_deferred_list(struct page *page)
 
 void prep_transhuge_page(struct page *page)
 {
-       /*
-        * we use page->mapping and page->indexlru in second tail page
-        * as list_head: assuming THP order >= 2
-        */
-       BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
-
        INIT_LIST_HEAD(page_deferred_list(page));
        set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
