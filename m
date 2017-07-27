Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01972802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:03:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w51so74184933qtc.12
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:03:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l1si16392780qtf.280.2017.07.27.11.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 11:03:53 -0700 (PDT)
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for reclaiming hugepages on OOM events.
Date: Thu, 27 Jul 2017 14:02:36 -0400
Message-Id: <20170727180236.6175-2-Liam.Howlett@Oracle.com>
In-Reply-To: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
References: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

When a system runs out of memory it may be desirable to reclaim
unreserved hugepages.  This situation arises when a correctly configured
system has a memory failure and takes corrective action of rebooting and
removing the memory from the memory pool results in a system failing to
boot.  With this change, the out of memory handler is able to reclaim
any pages that are free and not reserved.

Signed-off-by: Liam R. Howlett <Liam.Howlett@Oracle.com>
---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 35 +++++++++++++++++++++++++++++++++++
 mm/oom_kill.c           |  8 ++++++++
 3 files changed, 44 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8d9fe131a240..20e5729b9e9a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -470,6 +470,7 @@ static inline pgoff_t basepage_index(struct page *page)
 }
 
 extern int dissolve_free_huge_page(struct page *page);
+extern unsigned long decrease_free_hugepages(nodemask_t *nodes);
 extern int dissolve_free_huge_pages(unsigned long start_pfn,
 				    unsigned long end_pfn);
 static inline bool hugepage_migration_supported(struct hstate *h)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee783dd9..00a0e08b96c5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1454,6 +1454,41 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 /*
+ * Decrement free hugepages.  Used by oom kill to avoid killing a task if
+ * there is free huge pages that can be used instead.
+ * Returns the number of bytes reclaimed from hugepages
+ */
+#define CONFIG_HUGETLB_PAGE_OOM
+unsigned long decrease_free_hugepages(nodemask_t *nodes)
+{
+#ifdef CONFIG_HUGETLB_PAGE_OOM
+	struct hstate *h;
+	unsigned long ret = 0;
+
+	spin_lock(&hugetlb_lock);
+	for_each_hstate(h) {
+		if (h->free_huge_pages > h->resv_huge_pages) {
+			char buf[32];
+
+			memfmt(buf, huge_page_size(h));
+			ret = free_pool_huge_page(h, nodes ?
+						  nodes : &node_online_map, 0);
+			pr_warn("HugeTLB: Reclaiming %lu hugepage(s) of page size %s\n",
+				ret, buf);
+			ret *= huge_page_size(h);
+			goto found;
+		}
+	}
+
+found:
+	spin_unlock(&hugetlb_lock);
+	return ret;
+#else
+	return 0;
+#endif /* CONFIG_HUGETLB_PAGE_OOM */
+}
+
+/*
  * Dissolve a given free hugepage into free buddy pages. This function does
  * nothing for in-use (including surplus) hugepages. Returns -EBUSY if the
  * number of free hugepages would be reduced below the number of reserved
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..0a42f6d7d253 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -40,6 +40,7 @@
 #include <linux/ratelimit.h>
 #include <linux/kthread.h>
 #include <linux/init.h>
+#include <linux/hugetlb.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -1044,6 +1045,13 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	/* Reclaim a free, unreserved hugepage. */
+	freed = decrease_free_hugepages(oc->nodemask);
+	if (freed != 0) {
+		pr_err("Out of memory: Reclaimed %lu from HugeTLB\n", freed);
+		return true;
+	}
+
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-- 
2.13.0.90.g1eb437020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
