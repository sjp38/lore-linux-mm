Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 346006B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 02:49:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x127so126691142pgb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:49:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 65si7658472pgc.364.2017.03.16.23.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 23:49:42 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 2/5] mm, swap: Improve readability via make spin_lock/unlock balanced
Date: Fri, 17 Mar 2017 14:46:20 +0800
Message-Id: <20170317064635.12792-2-ying.huang@intel.com>
In-Reply-To: <20170317064635.12792-1-ying.huang@intel.com>
References: <20170317064635.12792-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Vegard Nossum <vegard.nossum@oracle.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

This is just a cleanup patch, no functionality change.  In
cluster_list_add_tail(), spin_lock_nested() is used to lock the
cluster, while unlock_cluster() is used to unlock the cluster.  To
improve the code readability.  Use spin_unlock() directly to unlock
the cluster.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6b6bb1bb6209..42fd620dcf4c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -335,7 +335,7 @@ static void cluster_list_add_tail(struct swap_cluster_list *list,
 		ci_tail = ci + tail;
 		spin_lock_nested(&ci_tail->lock, SINGLE_DEPTH_NESTING);
 		cluster_set_next(ci_tail, idx);
-		unlock_cluster(ci_tail);
+		spin_unlock(&ci_tail->lock);
 		cluster_set_next_flag(&list->tail, idx, 0);
 	}
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
