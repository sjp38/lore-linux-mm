Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 386696B0343
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:14:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 132so36011398pgb.6
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:14:55 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m29si3124833pli.455.2017.06.23.00.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 00:14:54 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2 09/12] memcg, THP, swap: Avoid to duplicated charge THP in swap cache
Date: Fri, 23 Jun 2017 15:13:00 +0800
Message-Id: <20170623071303.13469-10-ying.huang@intel.com>
In-Reply-To: <20170623071303.13469-1-ying.huang@intel.com>
References: <20170623071303.13469-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

For a THP (Transparent Huge Page), tail_page->mem_cgroup is NULL.  So
to check whether the page is charged already, we need to check the
head page.  This is not an issue before because it is impossible for a
THP to be in the swap cache before.  But after we add delaying
splitting THP after swapped out support, it is possible now.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 99e96ae59cd3..123564bcdd77 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5407,7 +5407,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		 * in turn serializes uncharging.
 		 */
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
-		if (page->mem_cgroup)
+		if (compound_head(page)->mem_cgroup)
 			goto out;
 
 		if (do_swap_account) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
