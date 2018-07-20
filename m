Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E10246B0005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:19:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e19-v6so5341730pgv.11
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:19:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q90-v6si1235046pfa.272.2018.07.20.00.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:19:56 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v4 1/8] swap: Add comments to lock_cluster_or_swap_info()
Date: Fri, 20 Jul 2018 15:18:38 +0800
Message-Id: <20180720071845.17920-2-ying.huang@intel.com>
In-Reply-To: <20180720071845.17920-1-ying.huang@intel.com>
References: <20180720071845.17920-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

To improve the code readability.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-and-acked-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d8fddfb000ec..d101e044efbf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -297,13 +297,18 @@ static inline void unlock_cluster(struct swap_cluster_info *ci)
 		spin_unlock(&ci->lock);
 }
 
+/*
+ * Determine the locking method in use for this device.  Return
+ * swap_cluster_info if SSD-style cluster-based locking is in place.
+ */
 static inline struct swap_cluster_info *lock_cluster_or_swap_info(
-	struct swap_info_struct *si,
-	unsigned long offset)
+		struct swap_info_struct *si, unsigned long offset)
 {
 	struct swap_cluster_info *ci;
 
+	/* Try to use fine-grained SSD-style locking if available: */
 	ci = lock_cluster(si, offset);
+	/* Otherwise, fall back to traditional, coarse locking: */
 	if (!ci)
 		spin_lock(&si->lock);
 
-- 
2.16.4
