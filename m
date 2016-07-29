Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC8F6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 23:24:59 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n69so103653255ion.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:24:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 15si1418072itx.100.2016.07.28.20.24.57
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 20:24:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: move swap-in anonymous page into active list
Date: Fri, 29 Jul 2016 12:25:40 +0900
Message-Id: <1469762740-17860-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Every swap-in anonymous page starts from inactive lru list's head.
It should be activated unconditionally when VM decide to reclaim
because page table entry for the page always usually has marked
accessed bit. Thus, their window size for getting a new referece
is 2 * NR_inactive + NR_active while others is NR_active + NR_active.

It's not fair that it has more chance to be referenced compared
to other newly allocated page which starts from active lru list's
head.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index 4425b6059339..3a730b920242 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2642,6 +2642,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true, false);
+		activate_page(page);
 	} else { /* ksm created a completely new copy */
 		page_add_new_anon_rmap(page, vma, fe->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
