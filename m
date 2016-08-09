Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 78DBF6B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:38:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so30851719pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:38:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r71si1655316pfb.169.2016.08.09.09.38.12
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:38:12 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC 02/11] swap: Change SWAPFILE_CLUSTER to 512
Date: Tue,  9 Aug 2016 09:37:44 -0700
Message-Id: <1470760673-12420-3-git-send-email-ying.huang@intel.com>
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

In this patch, the size of swap cluster is changed to that of THP on
x86_64 (512).  This is for THP (Transparent Huge Page) swap support on
x86_64.  Where one swap cluster will be used to hold the contents of
each THP swapped out.  And some information of the swapped out THP (such
as compound map count) will be recorded in the swap_cluster_info data
structure.

In effect, this will enlarge swap cluster size by 2 times.  Which may
make it harder to find a free cluster when swap space becomes
fragmented.  So that, this may reduce the continuous swap space
allocation and sequence write if that happens in theory.  The
performance test in 0day show no regressions caused by this.

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 09e3877..18f9292 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -196,7 +196,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 	}
 }
 
-#define SWAPFILE_CLUSTER	256
+#define SWAPFILE_CLUSTER	512
 #define LATENCY_LIMIT		256
 
 static inline void cluster_set_flag(struct swap_cluster_info *info,
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
