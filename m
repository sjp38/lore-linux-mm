Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF7E6B0038
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 13:37:33 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so7684077pdi.33
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:37:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 02/11] pagewalk: add walk_page_vma()
Date: Mon, 14 Oct 2013 13:37:01 -0400
Message-Id: <1381772230-26878-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1381772230-26878-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org

Introduces walk_page_vma(), which is useful for the callers which
want to walk over a given vma. It's used by later patches.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h |  1 +
 mm/pagewalk.c      | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git v3.12-rc4.orig/include/linux/mm.h v3.12-rc4/include/linux/mm.h
index bd87065..6c138d7 100644
--- v3.12-rc4.orig/include/linux/mm.h
+++ v3.12-rc4/include/linux/mm.h
@@ -979,6 +979,7 @@ struct mm_walk {
 
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git v3.12-rc4.orig/mm/pagewalk.c v3.12-rc4/mm/pagewalk.c
index 9e95541..80b247b 100644
--- v3.12-rc4.orig/mm/pagewalk.c
+++ v3.12-rc4/mm/pagewalk.c
@@ -314,3 +314,23 @@ int walk_page_range(unsigned long start, unsigned long end,
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
+	if (walk->skip) {
+		walk->skip = 0;
+		return 0;
+	}
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
