From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Date: Mon, 22 Sep 2008 02:38:11 +0100
Message-Id: <1222047492-27622-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is useful to verify that a hugepage-aware application is using the expected
pagesizes in each of its memory regions. This patch reports the pagesize
backing the VMA in /proc/pid/smaps. This should not break any sensible
parser as the file format is multi-line and it should skip information it
does not recognise.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/proc/task_mmu.c      |    6 ++++--
 include/linux/hugetlb.h |   13 +++++++++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 73d1891..81a3f91 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -394,7 +394,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   "Private_Clean:  %8lu kB\n"
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
-		   "Swap:           %8lu kB\n",
+		   "Swap:           %8lu kB\n"
+		   "PageSize:       %8lu kB\n",
 		   (vma->vm_end - vma->vm_start) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
@@ -403,7 +404,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   mss.private_clean >> 10,
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
-		   mss.swap >> 10);
+		   mss.swap >> 10,
+		   vma_page_size(vma) >> 10);
 
 	return ret;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 32e0ef0..0c83445 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -231,6 +231,19 @@ static inline unsigned long huge_page_size(struct hstate *h)
 	return (unsigned long)PAGE_SIZE << h->order;
 }
 
+static inline unsigned long vma_page_size(struct vm_area_struct *vma)
+{
+	struct hstate *hstate;
+
+	if (!is_vm_hugetlb_page(vma))
+		return PAGE_SIZE;
+
+	hstate = hstate_vma(vma);
+	VM_BUG_ON(!hstate);
+
+	return 1UL << (hstate->order + PAGE_SHIFT);
+}
+
 static inline unsigned long huge_page_mask(struct hstate *h)
 {
 	return h->mask;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
