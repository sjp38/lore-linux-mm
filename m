Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 692BB8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 08:06:37 -0500 (EST)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of hugepages
Date: Mon,  7 Mar 2011 14:05:55 +0100
Message-Id: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: emunson@mgebm.net, anton@redhat.com, Petr Holasek <pholasek@redhat.com>, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

/proc/meminfo file shows data for all used sizes of hugepages
on system, not only for default hugepage size.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 mm/hugetlb.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bb0b7c1..7919849 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1963,18 +1963,20 @@ out:
 
 void hugetlb_report_meminfo(struct seq_file *m)
 {
-	struct hstate *h = &default_hstate;
-	seq_printf(m,
-			"HugePages_Total:   %5lu\n"
-			"HugePages_Free:    %5lu\n"
-			"HugePages_Rsvd:    %5lu\n"
-			"HugePages_Surp:    %5lu\n"
-			"Hugepagesize:   %8lu kB\n",
-			h->nr_huge_pages,
-			h->free_huge_pages,
-			h->resv_huge_pages,
-			h->surplus_huge_pages,
-			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+	struct hstate *h;
+
+	for_each_hstate(h)
+		seq_printf(m,
+				"HugePages_Total:   %5lu\n"
+				"HugePages_Free:    %5lu\n"
+				"HugePages_Rsvd:    %5lu\n"
+				"HugePages_Surp:    %5lu\n"
+				"Hugepagesize:   %8lu kB\n",
+				h->nr_huge_pages,
+				h->free_huge_pages,
+				h->resv_huge_pages,
+				h->surplus_huge_pages,
+				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
