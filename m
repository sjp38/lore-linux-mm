Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D43E8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:16:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 70F9F3EE0C0
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:16:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51DAB45DE5B
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:16:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3708B45DE59
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:16:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B25E08003
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:16:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D143E1DB8038
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:16:51 +0900 (JST)
Date: Tue, 18 Jan 2011 11:10:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/4] memcg: fixe USED bit handling at uncharge with THP
Message-Id: <20110118111055.1be29ad0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118110604.e2528324.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110118110604.e2528324.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, under THP:

at charge:
  - PageCgroupUsed bit is set to all page_cgroup on a hugepage.
    ....set to 512 pages.
at uncharge
  - PageCgroupUsed bit is unset on the head page.

So, some pages will remain with "Used" bit.

This patch fixes that Used bit is set only to the head page.
Used bits for tail pages will be set at splitting if necessary.

This patch adds this lock order:
   zone->lru_lock-> compound_lock() -> page_cgroup_move_lock().

Changelog:
 - fixed some styles.
 - removed BUG_ON()
 - fixed mem_cgroup_update_page_stat() v.s. splitting races.
   To avoid races, PCG_MOVE_LOCK is used.
 - copy all required flags at splitting.
 - add a dummy function for compile.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    8 +++
 mm/huge_memory.c           |    2 
 mm/memcontrol.c            |   91 +++++++++++++++++++++++++--------------------
 3 files changed, 61 insertions(+), 40 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -1614,7 +1614,7 @@ void mem_cgroup_update_page_stat(struct 
 	if (unlikely(!mem || !PageCgroupUsed(pc)))
 		goto out;
 	/* pc->mem_cgroup is unstable ? */
-	if (unlikely(mem_cgroup_stealed(mem))) {
+	if (unlikely(mem_cgroup_stealed(mem)) || PageTransHuge(page)) {
 		/* take a lock against to access pc->mem_cgroup */
 		move_lock_page_cgroup(pc, &flags);
 		need_unlock = true;
@@ -2083,14 +2083,27 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 	return mem;
 }
 
-/*
- * commit a charge got by __mem_cgroup_try_charge() and makes page_cgroup to be
- * USED state. If already USED, uncharge and return.
- */
-static void ____mem_cgroup_commit_charge(struct mem_cgroup *mem,
-					 struct page_cgroup *pc,
-					 enum charge_type ctype)
+static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
+				       struct page_cgroup *pc,
+				       enum charge_type ctype,
+				       int page_size)
 {
+	int nr_pages = page_size >> PAGE_SHIFT;
+
+	/* try_charge() can return NULL to *memcg, taking care of it. */
+	if (!mem)
+		return;
+
+	lock_page_cgroup(pc);
+	if (unlikely(PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		mem_cgroup_cancel_charge(mem, page_size);
+		return;
+	}
+	/*
+	 * we don't need page_cgroup_lock about tail pages, becase they are not
+	 * accessed by any other context at this point.
+	 */
 	pc->mem_cgroup = mem;
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
@@ -2114,35 +2127,7 @@ static void ____mem_cgroup_commit_charge
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), 1);
-}
-
-static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
-				       struct page_cgroup *pc,
-				       enum charge_type ctype,
-				       int page_size)
-{
-	int i;
-	int count = page_size >> PAGE_SHIFT;
-
-	/* try_charge() can return NULL to *memcg, taking care of it. */
-	if (!mem)
-		return;
-
-	lock_page_cgroup(pc);
-	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem, page_size);
-		return;
-	}
-
-	/*
-	 * we don't need page_cgroup_lock about tail pages, becase they are not
-	 * accessed by any other context at this point.
-	 */
-	for (i = 0; i < count; i++)
-		____mem_cgroup_commit_charge(mem, pc + i, ctype);
-
+	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), nr_pages);
 	unlock_page_cgroup(pc);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
@@ -2152,6 +2137,34 @@ static void __mem_cgroup_commit_charge(s
 	memcg_check_events(mem, pc->page);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
+			(1 << PCG_MIGRATION))
+/*
+ * Because tail pages are not marked as "used", set it. We're under
+ * 'splitting' and compund_lock. 'splitting' ensures that the pages
+ */
+void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
+{
+	struct page_cgroup *head_pc = lookup_page_cgroup(head);
+	struct page_cgroup *tail_pc = lookup_page_cgroup(tail);
+	unsigned long flags;
+
+	/*
+	 * We have no races witch charge/uncharge but will have races with
+	 * page state accounting.
+	 */
+	move_lock_page_cgroup(head_pc, &flags);
+
+	tail_pc->mem_cgroup = head_pc->mem_cgroup;
+	smp_wmb(); /* see __commit_charge() */
+	/* we don't need to copy all flags...*/
+	tail_pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+	move_unlock_page_cgroup(head_pc, &flags);
+}
+#endif
+
 /**
  * __mem_cgroup_move_account - move account of the page
  * @pc:	page_cgroup of the page.
@@ -2545,7 +2558,6 @@ direct_uncharge:
 static struct mem_cgroup *
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
-	int i;
 	int count;
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
@@ -2595,8 +2607,7 @@ __mem_cgroup_uncharge_common(struct page
 		break;
 	}
 
-	for (i = 0; i < count; i++)
-		mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -1);
+	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -count);
 
 	ClearPageCgroupUsed(pc);
 	/*
Index: mmotm-0107/include/linux/memcontrol.h
===================================================================
--- mmotm-0107.orig/include/linux/memcontrol.h
+++ mmotm-0107/include/linux/memcontrol.h
@@ -146,6 +146,10 @@ unsigned long mem_cgroup_soft_limit_recl
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
+#endif
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -335,6 +339,10 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 	return 0;
 }
 
+static inline mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-0107/mm/huge_memory.c
===================================================================
--- mmotm-0107.orig/mm/huge_memory.c
+++ mmotm-0107/mm/huge_memory.c
@@ -1203,6 +1203,8 @@ static void __split_huge_page_refcount(s
 		BUG_ON(!PageDirty(page_tail));
 		BUG_ON(!PageSwapBacked(page_tail));
 
+		mem_cgroup_split_huge_fixup(page, page_tail);
+
 		lru_add_page_tail(zone, page, page_tail);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
