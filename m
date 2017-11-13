Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA0386B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:03:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g75so15205757pfg.4
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 08:03:40 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v85si13762329pgb.584.2017.11.13.08.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 08:03:39 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: show stats for non-default hugepage sizes in /proc/meminfo
Date: Mon, 13 Nov 2017 16:03:02 +0000
Message-ID: <20171113160302.14409-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

Currently we display some hugepage statistics (total, free, etc)
in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).

If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
/proc/meminfo output can be confusing, as non-default sized hugepages
are not reflected at all, and there are no signs that they are
existing and consuming system memory.

To solve this problem, let's display stats for all hugepage sizes.
To provide the backward compatibility let's save the existing format
for the default size, and add a prefix (e.g. 1G_) for non-default sizes.

For example (100 2Mb pages and 2 1Gb pages are pre-allocated):
  $ cat /proc/meminfo
  MemTotal:        8168976 kB
  MemFree:         5664792 kB
  <...>
  CmaFree:               0 kB
  HugePages_1G_Total:       2
  HugePages_1G_Free:        2
  HugePages_1G_Rsvd:        0
  HugePages_1G_Surp:        0
  Hugepagesize_1G:    1048576 kB
  HugePages_Total:     100
  HugePages_Free:      100
  HugePages_Rsvd:        0
  HugePages_Surp:        0
  Hugepagesize:       2048 kB
  DirectMap4k:       30584 kB
  DirectMap2M:     3115008 kB
  DirectMap1G:     7340032 kB

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/hugetlb.c | 49 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4b3bbd2980bb..abd37999f5da 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2973,20 +2973,45 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 void hugetlb_report_meminfo(struct seq_file *m)
 {
-	struct hstate *h = &default_hstate;
+	struct hstate *h;
+
 	if (!hugepages_supported())
 		return;
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
+
+	for_each_hstate(h) {
+		char prefix[16] = "";
+
+		if (h != &default_hstate) {
+			unsigned int order = huge_page_order(h) + PAGE_SHIFT;
+			char suffix = '_';
+
+			if (order >= 30) {
+				order -= 30;
+				suffix = 'G';
+			} else if (order >= 20) {
+				order -= 20;
+				suffix = 'M';
+			} else if (order >= 10) {
+				order -= 10;
+				suffix = 'k';
+			}
+
+			snprintf(prefix, sizeof(prefix), "_%lu%c",
+				 1UL << order, suffix);
+		}
+
+		seq_printf(m,
+			"HugePages%s_Total:   %5lu\n"
+			"HugePages%s_Free:    %5lu\n"
+			"HugePages%s_Rsvd:    %5lu\n"
+			"HugePages%s_Surp:    %5lu\n"
+			"Hugepagesize%s:   %8lu kB\n",
+			prefix, h->nr_huge_pages,
+			prefix, h->free_huge_pages,
+			prefix, h->resv_huge_pages,
+			prefix, h->surplus_huge_pages,
+			prefix, 1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+	}
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
