Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C94E46B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so163698359pad.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n4si6083386pan.58.2016.09.01.08.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:07 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 01/10] swap: Change SWAPFILE_CLUSTER to 512
Date: Thu,  1 Sep 2016 08:16:54 -0700
Message-Id: <1472743023-4116-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

In this patch, the size of the swap cluster is changed to that of the
THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
the THP swap support on x86_64.  Where one swap cluster will be used to
hold the contents of each THP swapped out.  And some information of the
swapped out THP (such as compound map count) will be recorded in the
swap_cluster_info data structure.

In effect,  this will enlarge swap  cluster size by 2  times.  Which may
make  it harder  to find  a  free cluster  when the  swap space  becomes
fragmented.   So  that,  this  may  reduce  the  continuous  swap  space
allocation and sequential write in theory.  The performance test in 0day
show no regressions caused by this.

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8f1b97d..582912b 100644
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
