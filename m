Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 412326B02C8
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 02:52:36 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C33C93EE0C3
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:34 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EBF145DEB8
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 763A545DEB2
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62672E08002
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 004521DB803C
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:34 +0900 (JST)
Date: Wed, 14 Dec 2011 16:51:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4] memcg: clear pc->mem_cgorup if necessary.
Message-Id: <20111214165124.4d2cf723.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is a preparation before removing a flag PCG_ACCT_LRU in page_cgroup
and reducing atomic ops/complexity in memcg LRU handling.

In some cases, pages are added to lru before charge to memcg and pages
are not classfied to memory cgroup at lru addtion. Now, the lru where
the page should be added is determined a bit in page_cgroup->flags and
pc->mem_cgroup. I'd like to remove the check of flag.

To handle the case pc->mem_cgroup may contain stale pointers if pages are
added to LRU before classification. This patch resets pc->mem_cgroup to
root_mem_cgroup before lru additions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    5 +++++
 mm/ksm.c                   |    1 +
 mm/memcontrol.c            |   14 ++++++++++++++
 mm/swap_state.c            |    1 +
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bd3b102..7428409 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -126,6 +126,7 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
+extern void mem_cgroup_reset_owner(struct page *page);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -388,6 +389,10 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
 }
+
+static inline void mem_cgroup_reset_owner(struct page *page);
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/ksm.c b/mm/ksm.c
index a6d3fb7..480983d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1571,6 +1571,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (new_page) {
+		mem_cgroup_reset_owner(new_page);
 		copy_user_highpage(new_page, page, address, vma);
 
 		SetPageDirty(new_page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7a857e8..2ae973d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3024,6 +3024,20 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 	rcu_read_unlock();
 }
 
+/*
+ * A function for resetting pc->mem_cgroup for newly allocated pages.
+ * This function should be called if the newpage will be added to LRU
+ * before start accounting.
+ */
+void mem_cgroup_reset_owner(struct page *newpage)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(newpage);
+	VM_BUG_ON(PageCgroupUsed(pc));
+	pc->mem_cgroup = root_mem_cgroup;
+}
+
 /**
  * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
  * @entry: swap entry to be moved
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 78cc4d1..747539e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -301,6 +301,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			new_page = alloc_page_vma(gfp_mask, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
+			mem_cgroup_reset_owner(new_page);
 		}
 
 		/*
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
