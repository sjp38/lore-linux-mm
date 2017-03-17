Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71FED6B038D
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 02:49:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so90514854pgh.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:49:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r185si5466249pfr.34.2017.03.16.23.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 23:49:54 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 3/5] mm, swap: Avoid lock swap_avail_lock when held cluster lock
Date: Fri, 17 Mar 2017 14:46:21 +0800
Message-Id: <20170317064635.12792-3-ying.huang@intel.com>
In-Reply-To: <20170317064635.12792-1-ying.huang@intel.com>
References: <20170317064635.12792-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

Cluster lock is used to protect the swap_cluster_info and
corresponding elements in swap_info_struct->swap_map[].  But it is
found that now in scan_swap_map_slots(), swap_avail_lock may be
acquired when cluster lock is held.  This does no good except making
the locking more complex and improving the potential locking
contention, because the swap_info_struct->lock is used to protect the
data structure operated in the code already.  Fix this via moving the
corresponding operations in scan_swap_map_slots() out of cluster lock.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Tim Chen <tim.c.chen@intel.com>
---
 mm/swapfile.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42fd620dcf4c..53b5881ee0d6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -672,6 +672,9 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 		else
 			goto done;
 	}
+	si->swap_map[offset] = usage;
+	inc_cluster_info_page(si, si->cluster_info, offset);
+	unlock_cluster(ci);
 
 	if (offset == si->lowest_bit)
 		si->lowest_bit++;
@@ -685,9 +688,6 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 		plist_del(&si->avail_list, &swap_avail_head);
 		spin_unlock(&swap_avail_lock);
 	}
-	si->swap_map[offset] = usage;
-	inc_cluster_info_page(si, si->cluster_info, offset);
-	unlock_cluster(ci);
 	si->cluster_next = offset + 1;
 	slots[n_ret++] = swp_entry(si->type, offset);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
