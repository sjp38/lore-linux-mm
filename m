Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 979AF6B1F33
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:55:02 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so849967pgb.6
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:55:02 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b15si24149550plm.431.2018.11.20.00.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:55:01 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V7 RESEND 02/21] swap: Add __swap_duplicate_locked()
Date: Tue, 20 Nov 2018 16:54:30 +0800
Message-Id: <20181120085449.5542-3-ying.huang@intel.com>
In-Reply-To: <20181120085449.5542-1-ying.huang@intel.com>
References: <20181120085449.5542-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

The part of __swap_duplicate() with lock held is separated into a new
function __swap_duplicate_locked().  Because we will add more logic
about the PMD swap mapping into __swap_duplicate() and keep the most
PTE swap mapping related logic in __swap_duplicate_locked().

Just mechanical code refactoring, there is no any functional change in
this patch.

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
 mm/swapfile.c | 63 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 35 insertions(+), 28 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index ec210be02c3b..f3c175d830b1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3441,32 +3441,12 @@ void si_swapinfo(struct sysinfo *val)
 	spin_unlock(&swap_lock);
 }
 
-/*
- * Verify that a swap entry is valid and increment its swap map count.
- *
- * Returns error code in following case.
- * - success -> 0
- * - swp_entry is invalid -> EINVAL
- * - swp_entry is migration entry -> EINVAL
- * - swap-cache reference is requested but there is already one. -> EEXIST
- * - swap-cache reference is requested but the entry is not used. -> ENOENT
- * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
- */
-static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
+static int __swap_duplicate_locked(struct swap_info_struct *p,
+				   unsigned long offset, unsigned char usage)
 {
-	struct swap_info_struct *p;
-	struct swap_cluster_info *ci;
-	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
-	int err = -EINVAL;
-
-	p = get_swap_device(entry);
-	if (!p)
-		goto out;
-
-	offset = swp_offset(entry);
-	ci = lock_cluster_or_swap_info(p, offset);
+	int err = 0;
 
 	count = p->swap_map[offset];
 
@@ -3476,12 +3456,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	 */
 	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
 		err = -ENOENT;
-		goto unlock_out;
+		goto out;
 	}
 
 	has_cache = count & SWAP_HAS_CACHE;
 	count &= ~SWAP_HAS_CACHE;
-	err = 0;
 
 	if (usage == SWAP_HAS_CACHE) {
 
@@ -3508,11 +3487,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 
 	p->swap_map[offset] = count | has_cache;
 
-unlock_out:
+out:
+	return err;
+}
+
+/*
+ * Verify that a swap entry is valid and increment its swap map count.
+ *
+ * Returns error code in following case.
+ * - success -> 0
+ * - swp_entry is invalid -> EINVAL
+ * - swp_entry is migration entry -> EINVAL
+ * - swap-cache reference is requested but there is already one. -> EEXIST
+ * - swap-cache reference is requested but the entry is not used. -> ENOENT
+ * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
+ */
+static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
+{
+	struct swap_info_struct *p;
+	struct swap_cluster_info *ci;
+	unsigned long offset;
+	int err = -EINVAL;
+
+	p = get_swap_device(entry);
+	if (!p)
+		goto out;
+
+	offset = swp_offset(entry);
+	ci = lock_cluster_or_swap_info(p, offset);
+	err = __swap_duplicate_locked(p, offset, usage);
 	unlock_cluster_or_swap_info(p, ci);
+
+	put_swap_device(p);
 out:
-	if (p)
-		put_swap_device(p);
 	return err;
 }
 
-- 
2.18.1
