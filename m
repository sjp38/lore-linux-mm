Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1392E6B0088
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 21:49:39 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 1/2] Add hugetlb_report_nodemask_meminfo()
Date: Thu,  9 Dec 2010 18:49:04 -0800
Message-Id: <1291949345-13892-2-git-send-email-yinghan@google.com>
In-Reply-To: <1291949345-13892-1-git-send-email-yinghan@google.com>
References: <1291949345-13892-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is useful to accumulate hugetlb statistics on nodemask. This
is used on the following patch also which exporting per-cpuset
meminfo.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/hugetlb.h |    3 +++
 mm/hugetlb.c            |   21 +++++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 943c76b..5e95672 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -10,6 +10,7 @@ struct user_struct;
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
+#include <linux/nodemask.h>
 #include <linux/shm.h>
 #include <asm/tlbflush.h>
 
@@ -36,6 +37,7 @@ void __unmap_hugepage_range(struct vm_area_struct *,
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 void hugetlb_report_meminfo(struct seq_file *);
 int hugetlb_report_node_meminfo(int, char *);
+void hugetlb_report_nodemask_meminfo(const nodemask_t *mask, struct seq_file *);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
@@ -93,6 +95,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 {
 }
 #define hugetlb_report_node_meminfo(n, buf)	0
+#define hugetlb_report_nodemask_meminfo(mask, seq_file)
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define follow_huge_pud(mm, addr, pud, write)	NULL
 #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c4a3558..27961eb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2029,6 +2029,27 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 		nid, h->surplus_huge_pages_node[nid]);
 }
 
+void hugetlb_report_nodemask_meminfo(const nodemask_t *mask, struct seq_file *m)
+{
+	unsigned long total = 0;
+	unsigned long free = 0;
+	unsigned long surp = 0;
+	struct hstate *h = &default_hstate;
+	int nid;
+
+	for_each_node_mask(nid, *mask) {
+		total += h->nr_huge_pages_node[nid];
+		free += h->free_huge_pages_node[nid];
+		surp += h->surplus_huge_pages_node[nid];
+	}
+
+	seq_printf(m,
+		"HugePages_Total: %5lu\n"
+		"HugePages_Free:  %5lu\n"
+		"HugePages_Surp:  %5lu\n",
+		total, free, surp);
+}
+
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
