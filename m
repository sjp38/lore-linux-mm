Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA736B037C
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:19:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z74so29718249pfi.8
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:19:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f8si6429674pgr.494.2017.07.23.22.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:19:04 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 09/12] memcg, THP, swap: Avoid to duplicated charge THP in swap cache
Date: Mon, 24 Jul 2017 13:18:37 +0800
Message-Id: <20170724051840.2309-10-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

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
index c2618bd8ebdd..a627b0fd67ea 100644
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
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
