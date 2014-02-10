Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 460286B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:45:13 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3276886eae.19
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f45si28390648eep.236.2014.02.10.13.45.10
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 13:45:11 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 02/11] pagewalk: add walk_page_vma()
Date: Mon, 10 Feb 2014 16:44:27 -0500
Message-Id: <1392068676-30627-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Introduces walk_page_vma(), which is useful for the callers which
want to walk over a given vma. It's used by later patches.

ChangeLog v4:
- rename skip_check to skip_lower_level_walking

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  1 +
 mm/pagewalk.c      | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git v3.14-rc2.orig/include/linux/mm.h v3.14-rc2/include/linux/mm.h
index 4d0bc01de43c..144b08617957 100644
--- v3.14-rc2.orig/include/linux/mm.h
+++ v3.14-rc2/include/linux/mm.h
@@ -1104,6 +1104,7 @@ struct mm_walk {
 
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git v3.14-rc2.orig/mm/pagewalk.c v3.14-rc2/mm/pagewalk.c
index 4770558feea8..2a88dfa58af6 100644
--- v3.14-rc2.orig/mm/pagewalk.c
+++ v3.14-rc2/mm/pagewalk.c
@@ -334,3 +334,21 @@ int walk_page_range(unsigned long start, unsigned long end,
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
+	if (skip_lower_level_walking(walk))
+		return 0;
+	if (err)
+		return err;
+	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+}
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
