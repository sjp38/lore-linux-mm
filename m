Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5C58F6B0012
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 01:11:27 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] nommu: reimplement remap_pfn_range() to simply return 0
Date: Mon, 20 Jun 2011 13:22:13 +0800
Message-ID: <1308547333-27413-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, uclinux-dist-devel@blackfin.uclinux.org, geert@linux-m68k.org, Bob Liu <lliubbo@gmail.com>

Function remap_pfn_range() means map physical address pfn<<PAGE_SHIFT to
user addr.

For nommu arch it's implemented by vma->vm_start = pfn << PAGE_SHIFT which is
wrong acroding the original meaning of this function.

Some driver developer using remap_pfn_range() with correct parameter will get
unexpected result because vm_start is changed.

It should be implementd just like addr = pfn << PAGE_SHIFT which is meanless
on nommu arch, so this patch just make it simply return 0.

Reported-by: Scott Jiang <scott.jiang.linux@gmail.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 include/linux/mm.h |   10 ++++++++++
 mm/nommu.c         |    8 --------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..017c32f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1526,8 +1526,18 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 #endif
 
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
+
+#ifdef CONFIG_MMU
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
+#else
+static inline int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
+		unsigned long pfn, unsigned long size, pgprot_t prot)
+{
+	return 0;
+}
+#endif
+
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
diff --git a/mm/nommu.c b/mm/nommu.c
index 1fd0c51..01cf6e0 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1813,14 +1813,6 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	return NULL;
 }
 
-int remap_pfn_range(struct vm_area_struct *vma, unsigned long from,
-		unsigned long to, unsigned long size, pgprot_t prot)
-{
-	vma->vm_start = vma->vm_pgoff << PAGE_SHIFT;
-	return 0;
-}
-EXPORT_SYMBOL(remap_pfn_range);
-
 int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 			unsigned long pgoff)
 {
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
