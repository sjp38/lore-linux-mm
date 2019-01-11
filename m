Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA62D8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:12:34 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i2so8402477ywb.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:12:34 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m7si46489497ywe.146.2019.01.11.12.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 12:12:33 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH] mm: align anon mmap for THP
Date: Fri, 11 Jan 2019 12:10:03 -0800
Message-Id: <20190111201003.19755-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
to get an address returned by mmap() suitably aligned for THP.  It seems
that if mmap is asking for a mapping length greater than huge page
size, it should align the returned address to huge page size.

THP alignment has already been added for DAX, shm and tmpfs.  However,
simple anon mappings does not take THP alignment into account.

I could not determine if this was ever considered or discussed in the past.

There is a maze of arch specific and independent get_unmapped_area
routines.  The patch below just modifies the common vm_unmapped_area
routine.  It may be too simplistic, but I wanted to throw out some
code while asking if something like this has ever been considered.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/huge_mm.h |  6 ++++++
 include/linux/mm.h      |  3 +++
 mm/mmap.c               | 11 +++++++++++
 3 files changed, 20 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4663ee96cf59..dbff7ea7d2e7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -117,6 +117,10 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	return false;
 }
 
+#define thp_enabled_globally()						\
+	(transparent_hugepage_flags &					\
+	 ((1<<TRANSPARENT_HUGEPAGE_FLAG) |				\
+	  (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)))
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
@@ -262,6 +266,8 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	return false;
 }
 
+#define thp_enabled_globally() false
+
 static inline void prep_transhuge_page(struct page *page) {}
 
 #define transparent_hugepage_flags 0UL
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..131b0be0bbeb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2358,6 +2358,7 @@ struct vm_unmapped_area_info {
 	unsigned long align_offset;
 };
 
+extern void thp_vma_unmapped_align(struct vm_unmapped_area_info *info);
 extern unsigned long unmapped_area(struct vm_unmapped_area_info *info);
 extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
 
@@ -2373,6 +2374,8 @@ extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
 static inline unsigned long
 vm_unmapped_area(struct vm_unmapped_area_info *info)
 {
+	thp_vma_unmapped_align(info);
+
 	if (info->flags & VM_UNMAPPED_AREA_TOPDOWN)
 		return unmapped_area_topdown(info);
 	else
diff --git a/mm/mmap.c b/mm/mmap.c
index 6c04292e16a7..f9c111394052 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1864,6 +1864,17 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	return error;
 }
 
+void thp_vma_unmapped_align(struct vm_unmapped_area_info *info)
+{
+	if (!thp_enabled_globally())
+		return;
+
+	if (info->align_mask || info->length < HPAGE_PMD_SIZE)
+		return;
+
+	info->align_mask = PAGE_MASK & (HPAGE_PMD_SIZE - 1);
+}
+
 unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 {
 	/*
-- 
2.17.2
