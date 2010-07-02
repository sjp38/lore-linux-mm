Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7894D6B01D9
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 01:49:35 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/7] hugetlb: add hugepage check in mem_cgroup_{register,end}_migration()
Date: Fri,  2 Jul 2010 14:47:23 +0900
Message-Id: <1278049646-29769-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Currently memory cgroup doesn't charge hugepage,
so avoid calling these functions in hugepage migration context.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/memcontrol.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git v2.6.35-rc3-hwpoison/mm/memcontrol.c v2.6.35-rc3-hwpoison/mm/memcontrol.c
index c6ece0a..fed32de 100644
--- v2.6.35-rc3-hwpoison/mm/memcontrol.c
+++ v2.6.35-rc3-hwpoison/mm/memcontrol.c
@@ -2504,6 +2504,8 @@ int mem_cgroup_prepare_migration(struct page *page,
 
 	if (mem_cgroup_disabled())
 		return 0;
+	if (PageHuge(page))
+		return 0;
 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
@@ -2591,6 +2593,9 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 
 	if (!mem)
 		return;
+	if (PageHuge(oldpage))
+		return;
+
 	/* blocks rmdir() */
 	cgroup_exclude_rmdir(&mem->css);
 	/* at migration success, oldpage->mapping is NULL. */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
