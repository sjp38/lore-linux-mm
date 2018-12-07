Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1F3D6B7EA2
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:41:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so1812594pgv.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:41:57 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.41.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:41:56 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 10/21] swap: Support to count THP swapin and its fallback
Date: Fri,  7 Dec 2018 13:41:10 +0800
Message-Id: <20181207054122.27822-11-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

2 new /proc/vmstat fields are added, "thp_swapin" and
"thp_swapin_fallback" to count swapin a THP from swap device in one
piece and fallback to normal page swapin.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
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
index 7661abe5236e..24867b771ae0 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -89,6 +89,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 		THP_SWPOUT,
 		THP_SWPOUT_FALLBACK,
+		THP_SWPIN,
+		THP_SWPIN_FALLBACK,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3bb2df7f5f84..c674deb643d6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1723,8 +1723,10 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
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
index 5bdfd21c1bd9..4da5e2083893 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -348,6 +348,15 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
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
@@ -371,7 +380,7 @@ int swap_readpage(struct page *page, bool synchronous)
 
 		ret = mapping->a_ops->readpage(swap_file, page);
 		if (!ret)
-			count_vm_event(PSWPIN);
+			count_swpin_vm_event(page);
 		return ret;
 	}
 
@@ -382,7 +391,7 @@ int swap_readpage(struct page *page, bool synchronous)
 			unlock_page(page);
 		}
 
-		count_vm_event(PSWPIN);
+		count_swpin_vm_event(page);
 		return 0;
 	}
 
@@ -401,7 +410,7 @@ int swap_readpage(struct page *page, bool synchronous)
 	get_task_struct(current);
 	bio->bi_private = current;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
-	count_vm_event(PSWPIN);
+	count_swpin_vm_event(page);
 	bio_get(bio);
 	qc = submit_bio(bio);
 	while (synchronous) {
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 18de2ca87533..37638638b9bb 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1266,6 +1266,8 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc_failed",
 	"thp_swpout",
 	"thp_swpout_fallback",
+	"thp_swpin",
+	"thp_swpin_fallback",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.18.1
