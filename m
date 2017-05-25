Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41E126B0315
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:47:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so217607354pfh.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:47:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si26530689pgb.168.2017.05.24.23.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 23:47:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 09/13] memcg, THP, swap: Support move mem cgroup charge for THP swapped out
Date: Thu, 25 May 2017 14:46:31 +0800
Message-Id: <20170525064635.2832-10-ying.huang@intel.com>
In-Reply-To: <20170525064635.2832-1-ying.huang@intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

PTE mapped THP (Transparent Huge Page) will be ignored when moving
memory cgroup charge.  But for THP which is in the swap cache, the
memory cgroup charge for the swap of a tail-page may be moved in
current implementation.  That isn't correct, because the swap charge
for all sub-pages of a THP should be moved together.  Following the
processing of the PTE mapped THP, the mem cgroup charge moving for the
swap entry for a tail-page of a THP is ignored too.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/memcontrol.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c131f7e5ecd1..1f36bb61a6de 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4606,8 +4606,11 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		if (!ret || !target)
 			put_page(page);
 	}
-	/* There is a swap entry and a page doesn't exist or isn't charged */
-	if (ent.val && !ret &&
+	/*
+	 * There is a swap entry and a page doesn't exist or isn't charged.
+	 * But we cannot move a tail-page in a THP.
+	 */
+	if (ent.val && !ret && (!page || !PageTransCompound(page)) &&
 	    mem_cgroup_id(mc.from) == lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
