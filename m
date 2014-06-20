Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 349B66B003D
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:12:10 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so4191818wgg.5
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:12:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vp1si12552516wjc.44.2014.06.20.13.12.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 13:12:08 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 03/13] pagewalk: add walk_page_vma()
Date: Fri, 20 Jun 2014 16:11:29 -0400
Message-Id: <1403295099-6407-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Introduces walk_page_vma(), which is useful for the callers which want to
walk over a given vma.  It's used by later patches.

ChangeLog:
- check walk_page_test's return value instead of walk->skip

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  1 +
 mm/pagewalk.c      | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git v3.16-rc1.orig/include/linux/mm.h v3.16-rc1/include/linux/mm.h
index 489a63a06a4a..7e9287750866 100644
--- v3.16-rc1.orig/include/linux/mm.h
+++ v3.16-rc1/include/linux/mm.h
@@ -1137,6 +1137,7 @@ struct mm_walk {
 
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git v3.16-rc1.orig/mm/pagewalk.c v3.16-rc1/mm/pagewalk.c
index 86d811202374..16865e5029f6 100644
--- v3.16-rc1.orig/mm/pagewalk.c
+++ v3.16-rc1/mm/pagewalk.c
@@ -271,3 +271,21 @@ int walk_page_range(unsigned long start, unsigned long end,
 	} while (start = next, start < end);
 	return err;
 }
+
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
+{
+	int err;
+
+	if (!walk->mm)
+		return -EINVAL;
+
+	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+	VM_BUG_ON(!vma);
+	walk->vma = vma;
+	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
+	if (err > 0)
+		return 0;
+	if (err < 0)
+		return err;
+	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
