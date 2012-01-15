Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 00A4D6B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 19:12:29 -0500 (EST)
Received: by iafj26 with SMTP id j26so8434653iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 16:12:29 -0800 (PST)
Date: Sat, 14 Jan 2012 16:12:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
In-Reply-To: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1201141610490.1261@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <20120109130259.GD3588@cmpxchg.org> <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
to obscure the LRU counts.  For easier searching?  So call it
lru_size rather than bare count (lru_length sounds better, but
would be wrong, since each huge page raises lru_size hugely).

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
KOSAKI-san felt neutral on this one.  Hannes said no objections.
Michal liked the namechange from count to lru_size, but wanted a
MEM_CGROUP_LRU_SIZE(mz, lru) macro to access it.  Whilst I prefer that
to MEM_CGROUP_ZSTAT(), I cannot see the point of an accessor for this.
So here's my original patch, for you to ignore or put in as you prefer,
then Michal can send something on top if he still feels strongly.

 mm/memcontrol.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-30 21:22:05.679339324 -0800
+++ mmotm/mm/memcontrol.c	2011-12-30 21:23:28.243341326 -0800
@@ -135,7 +135,7 @@ struct mem_cgroup_reclaim_iter {
  */
 struct mem_cgroup_per_zone {
 	struct lruvec		lruvec;
-	unsigned long		count[NR_LRU_LISTS];
+	unsigned long		lru_size[NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
@@ -147,8 +147,6 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
-/* Macro for accessing counter */
-#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
@@ -713,7 +711,7 @@ mem_cgroup_zone_nr_lru_pages(struct mem_
 
 	for_each_lru(l) {
 		if (BIT(l) & lru_mask)
-			ret += MEM_CGROUP_ZSTAT(mz, l);
+			ret += mz->lru_size[l];
 	}
 	return ret;
 }
@@ -1048,7 +1046,7 @@ struct lruvec *mem_cgroup_lru_add_list(s
 	memcg = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* compound_order() is stabilized through lru_lock */
-	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
+	mz->lru_size[lru] += 1 << compound_order(page);
 	return &mz->lruvec;
 }
 
@@ -1076,8 +1074,8 @@ void mem_cgroup_lru_del_list(struct page
 	VM_BUG_ON(!memcg);
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
-	VM_BUG_ON(MEM_CGROUP_ZSTAT(mz, lru) < (1 << compound_order(page)));
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
+	VM_BUG_ON(mz->lru_size[lru] < (1 << compound_order(page)));
+	mz->lru_size[lru] -= 1 << compound_order(page);
 }
 
 void mem_cgroup_lru_del(struct page *page)
@@ -3615,7 +3613,7 @@ static int mem_cgroup_force_empty_list(s
 	mz = mem_cgroup_zoneinfo(memcg, node, zid);
 	list = &mz->lruvec.lists[lru];
 
-	loop = MEM_CGROUP_ZSTAT(mz, lru);
+	loop = mz->lru_size[lru];
 	/* give some margin against EBUSY etc...*/
 	loop += 256;
 	busy = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
