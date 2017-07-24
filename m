Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D96C56B03A1
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:19:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so120468868pfe.11
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:19:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f8si6429674pgr.494.2017.07.23.22.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:19:11 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 12/12] mm, THP, swap: Add THP swapping out fallback counting
Date: Mon, 24 Jul 2017 13:18:40 +0800
Message-Id: <20170724051840.2309-13-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

From: Huang Ying <ying.huang@intel.com>

When swapping out THP (Transparent Huge Page), instead of swapping out
the THP as a whole, sometimes we have to fallback to split the THP
into normal pages before swapping, because no free swap clusters are
available, or cgroup limit is exceeded, etc.  To count the number of
the fallback, a new VM event THP_SWPOUT_FALLBACK is added, and counted
when we fallback to split the THP.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 include/linux/vm_event_item.h | 1 +
 mm/vmscan.c                   | 3 +++
 mm/vmstat.c                   | 1 +
 3 files changed, 5 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index c75024e80eed..e02820fc2861 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -86,6 +86,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 		THP_SWPOUT,
+		THP_SWPOUT_FALLBACK,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7472ddafc14a..4f7212f8ca00 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1153,6 +1153,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					if (split_huge_page_to_list(page,
 								    page_list))
 						goto activate_locked;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+					count_vm_event(THP_SWPOUT_FALLBACK);
+#endif
 					if (!add_to_swap(page))
 						goto activate_locked;
 				}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index bccf426453cd..e131b51654c7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1072,6 +1072,7 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 	"thp_swpout",
+	"thp_swpout_fallback",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
