Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 883FE6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:51:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j16so16917415pgn.14
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:51:31 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g1si12045925pgo.705.2017.11.14.04.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 04:51:30 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: show total hugetlb memory consumption in /proc/meminfo
Date: Tue, 14 Nov 2017 12:50:26 +0000
Message-ID: <20171114125026.7055-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

Currently we display some hugepage statistics (total, free, etc)
in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).

If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
/proc/meminfo output can be confusing, as non-default sized hugepages
are not reflected at all, and there are no signs that they are
existing and consuming system memory.

To solve this problem, let's display the total amount of memory,
consumed by hugetlb pages of all sized (both free and used).
Let's call it "Hugetlb", and display size in kB to match generic
/proc/meminfo style.

For example, (1024 2Mb pages and 2 1Gb pages are pre-allocated):
  $ cat /proc/meminfo
  MemTotal:        8168984 kB
  MemFree:         3789276 kB
  <...>
  CmaFree:               0 kB
  HugePages_Total:    1024
  HugePages_Free:     1024
  HugePages_Rsvd:        0
  HugePages_Surp:        0
  Hugepagesize:       2048 kB
  Hugetlb:         4194304 kB
  DirectMap4k:       32632 kB
  DirectMap2M:     4161536 kB
  DirectMap1G:     6291456 kB

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/hugetlb.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4b3bbd2980bb..1a65f8482282 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2974,6 +2974,8 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 void hugetlb_report_meminfo(struct seq_file *m)
 {
 	struct hstate *h = &default_hstate;
+	unsigned long total = 0;
+
 	if (!hugepages_supported())
 		return;
 	seq_printf(m,
@@ -2987,6 +2989,11 @@ void hugetlb_report_meminfo(struct seq_file *m)
 			h->resv_huge_pages,
 			h->surplus_huge_pages,
 			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+
+	for_each_hstate(h)
+		total += (PAGE_SIZE << huge_page_order(h)) * h->nr_huge_pages;
+
+	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
