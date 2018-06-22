Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE9796B0271
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 23:55:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so2966518plc.1
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 20:55:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n61-v6si6160066plb.256.2018.06.21.20.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 20:55:37 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 10/21] mm, THP, swap: Support to count THP swapin and its fallback
Date: Fri, 22 Jun 2018 11:51:40 +0800
Message-Id: <20180622035151.6676-11-ying.huang@intel.com>
In-Reply-To: <20180622035151.6676-1-ying.huang@intel.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

From: Huang Ying <ying.huang@intel.com>

2 new /proc/vmstat fields are added, "thp_swapin" and
"thp_swapin_fallback" to count swapin a THP from swap device as a
whole and fallback to normal page swapin.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 Documentation/admin-guide/mm/transhuge.rst |  8 ++++++++
 include/linux/vm_event_item.h              |  2 ++
 mm/huge_memory.c                           |  4 +++-
 mm/page_io.c                               | 15 ++++++++++++---
 mm/vmstat.c                                |  2 ++
 5 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/Documentation/admin-guide/mm/transhuge.rst b/Documentation/admin-guide/mm/transhuge.rst
index 7ab93a8404b9..85e33f785fd7 100644
--- a/Documentation/admin-guide/mm/transhuge.rst
+++ b/Documentation/admin-guide/mm/transhuge.rst
@@ -364,6 +364,14 @@ thp_swpout_fallback
 	Usually because failed to allocate some continuous swap space
 	for the huge page.
 
+thp_swpin
+	is incremented every time a huge page is swapin in one piece
+	without splitting.
+
+thp_swpin_fallback
+	is incremented if a huge page has to be split during swapin.
+	Usually because failed to allocate a huge page.
+
 As the system ages, allocating huge pages may be expensive as the
 system uses memory compaction to copy data around memory to free a
 huge page for use. There are some counters in ``/proc/vmstat`` to help
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 5c7f010676a7..7b438548a78e 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -88,6 +88,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 		THP_SWPOUT,
 		THP_SWPOUT_FALLBACK,
+		THP_SWPIN,
+		THP_SWPIN_FALLBACK,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ac79ae2ab257..8d49a11e83ee 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1664,8 +1664,10 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 				/* swapoff occurs under us */
 				} else if (ret == -EINVAL)
 					ret = 0;
-				else
+				else {
+					count_vm_event(THP_SWPIN_FALLBACK);
 					goto fallback;
+				}
 			}
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto out;
diff --git a/mm/page_io.c b/mm/page_io.c
index b41cf9644585..96277058681e 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -347,6 +347,15 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	return ret;
 }
 
+static inline void count_swpin_vm_event(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (unlikely(PageTransHuge(page)))
+		count_vm_event(THP_SWPIN);
+#endif
+	count_vm_events(PSWPIN, hpage_nr_pages(page));
+}
+
 int swap_readpage(struct page *page, bool synchronous)
 {
 	struct bio *bio;
@@ -370,7 +379,7 @@ int swap_readpage(struct page *page, bool synchronous)
 
 		ret = mapping->a_ops->readpage(swap_file, page);
 		if (!ret)
-			count_vm_event(PSWPIN);
+			count_swpin_vm_event(page);
 		return ret;
 	}
 
@@ -381,7 +390,7 @@ int swap_readpage(struct page *page, bool synchronous)
 			unlock_page(page);
 		}
 
-		count_vm_event(PSWPIN);
+		count_swpin_vm_event(page);
 		return 0;
 	}
 
@@ -400,7 +409,7 @@ int swap_readpage(struct page *page, bool synchronous)
 	get_task_struct(current);
 	bio->bi_private = current;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
-	count_vm_event(PSWPIN);
+	count_swpin_vm_event(page);
 	bio_get(bio);
 	qc = submit_bio(bio);
 	while (synchronous) {
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 75eda9c2b260..259c7bddbb6e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1263,6 +1263,8 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc_failed",
 	"thp_swpout",
 	"thp_swpout_fallback",
+	"thp_swpin",
+	"thp_swpin_fallback",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.16.4
