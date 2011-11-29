Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF436B005A
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:52:44 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/7] mm: memcg: remove unneeded checks from newpage_charge()
Date: Tue, 29 Nov 2011 11:52:04 +0100
Message-Id: <1322563925-1667-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
References: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

All callsites pass in freshly allocated pages and a valid mm.  As a
result, all checks pertaining the page's mapcount, page->mapping or
the fallback to init_mm are unneeded.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8ccb342..f5aa1b8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2679,19 +2679,11 @@ int mem_cgroup_newpage_charge(struct page *page,
 {
 	if (mem_cgroup_disabled())
 		return 0;
-	/*
-	 * If already mapped, we don't have to account.
-	 * If page cache, page->mapping has address_space.
-	 * But page->mapping may have out-of-use anon_vma pointer,
-	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
-	 * is NULL.
-  	 */
-	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
-		return 0;
-	if (unlikely(!mm))
-		mm = &init_mm;
+	VM_BUG_ON(page_mapped(page));
+	VM_BUG_ON(page->mapping && !PageAnon(page));
+	VM_BUG_ON(!mm);
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED);
+					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
 static void
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
