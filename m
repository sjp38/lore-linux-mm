Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68B796B03A7
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 20:55:37 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id e21so2254137ywa.14
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 17:55:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 204si7942083ywy.150.2017.06.02.17.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 17:55:36 -0700 (PDT)
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due to hugepages
Date: Fri,  2 Jun 2017 20:54:13 -0400
Message-Id: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mike.kravetz@Oracle.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com--dry-run

When the user specifies too many hugepages or an invalid
default_hugepagesz the communication to the user is implicit in the
allocation message.  This patch adds a warning when the desired page
count is not allocated and prints an error when the default_hugepagesz
is invalid on boot.

Signed-off-by: Liam R. Howlett <Liam.Howlett@Oracle.com>
---
 mm/hugetlb.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..6de30bbac23e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -70,6 +70,7 @@ struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
 /* Forward declaration */
 static int hugetlb_acct_memory(struct hstate *h, long delta);
+static char * __init memfmt(char *buf, unsigned long n);
 
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
@@ -2189,7 +2190,14 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 					 &node_states[N_MEMORY]))
 			break;
 	}
-	h->max_huge_pages = i;
+	if (i < h->max_huge_pages) {
+		char buf[32];
+
+		memfmt(buf, huge_page_size(h)),
+		pr_warn("HugeTLB: allocating %lu of page size %s failed.  Only allocated %lu hugepages.\n",
+			h->max_huge_pages, buf, i);
+		h->max_huge_pages = i;
+	}
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -2785,6 +2793,11 @@ static int __init hugetlb_init(void)
 		return 0;
 
 	if (!size_to_hstate(default_hstate_size)) {
+		if (default_hstate_size != 0) {
+			pr_err("HugeTLB: unsupported default_hugepagesz %lu. Reverting to %lu\n",
+			       default_hstate_size, HPAGE_SIZE);
+		}
+
 		default_hstate_size = HPAGE_SIZE;
 		if (!size_to_hstate(default_hstate_size))
 			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
-- 
2.13.0.92.gcd65a7235

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
