Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E35B6B0037
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:45:59 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so1976990pbc.24
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:45:59 -0700 (PDT)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id vs7si3428pbc.355.2013.10.30.14.45.58
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:45:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 02/11] pagewalk: add walk_page_vma()
Date: Wed, 30 Oct 2013 17:44:50 -0400
Message-Id: <1383169499-25144-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Introduces walk_page_vma(), which is useful for the callers which
want to walk over a given vma. It's used by later patches.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  1 +
 mm/pagewalk.c      | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/include/linux/mm.h v3.12-rc7-mmots-2013-10-29-16-24/include/linux/mm.h
index 5036d5b..f31f22f 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/include/linux/mm.h
+++ v3.12-rc7-mmots-2013-10-29-16-24/include/linux/mm.h
@@ -1063,6 +1063,7 @@ struct mm_walk {
 
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/pagewalk.c v3.12-rc7-mmots-2013-10-29-16-24/mm/pagewalk.c
index af93846..e837502 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/pagewalk.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/mm/pagewalk.c
@@ -326,3 +326,21 @@ int walk_page_range(unsigned long start, unsigned long end,
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
+	if (skip_check(walk))
+		return 0;
+	if (err)
+		return err;
+	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
