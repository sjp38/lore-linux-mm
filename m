Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A584B8D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 19:01:55 -0500 (EST)
Date: Thu, 10 Mar 2011 16:01:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] memcg: fix leak on wrong LRU with FUSE
Message-Id: <20110310160116.289b378f.akpm@linux-foundation.org>
In-Reply-To: <20110311084551.883c8aeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110308135612.e971e1f3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308181832.6386da5f.nishimura@mxp.nes.nec.co.jp>
	<20110309150750.d570798c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309164801.3a4c8d10.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309100020.GD30778@cmpxchg.org>
	<20110310083659.fd8b1c3f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110310144752.289483d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110310150428.f175758c.nishimura@mxp.nes.nec.co.jp>
	<20110310142029.5d108e37.akpm@linux-foundation.org>
	<20110311084551.883c8aeb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daniel Poelzleithner <poelzi@poelzi.org>

On Fri, 11 Mar 2011 08:45:51 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 10 Mar 2011 14:20:29 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 10 Mar 2011 15:04:28 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > > Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > I hope this can fix the original BZ case.
> > 
> > Do you recall the buzilla bug number?
> > 
> 
> Bug 30432

OK, well please let's not lose track of these things.  It's useful for
maintaining the bug database and it helps with the rather important
step of crediting the bug reporters who help us.

> The patch works only when the user use FUSE.
> We need to confirm that.

Daniel, are you able to test the proposed fix?



From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

fs/fuse/dev.c::fuse_try_move_page() does

   (1) remove a page by ->steal()
   (2) re-add the page to page cache
   (3) link the page to LRU if it was not on LRU at (1)

This implies the page is _on_ LRU when it's added to radix-tree.  So, the
page is added to memory cgroup while it's on LRU.  because LRU is lazy and
no one flushs it.

This is the same behavior as SwapCache and needs special care as
 - remove page from LRU before overwrite pc->mem_cgroup.
 - add page to LRU after overwrite pc->mem_cgroup.

And we need to taking care of pagevec.

If PageLRU(page) is set before we add PCG_USED bit, the page will not be
added to memcg's LRU (in short period).  So, regardlress of PageLRU(page)
value before commit_charge(), we need to check PageLRU(page) after
commit_charge().

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=30432

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: Balbir Singh <balbir@in.ibm.com>
Reported-by: Daniel Poelzleithner <poelzi@poelzi.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   70 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 52 insertions(+), 18 deletions(-)

diff -puN mm/memcontrol.c~memcg-fix-leak-on-wrong-lru-with-fuse mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-fix-leak-on-wrong-lru-with-fuse
+++ a/mm/memcontrol.c
@@ -926,18 +926,28 @@ void mem_cgroup_add_lru_list(struct page
 }
 
 /*
- * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
- * lru because the page may.be reused after it's fully uncharged (because of
- * SwapCache behavior).To handle that, unlink page_cgroup from LRU when charge
- * it again. This function is only used to charge SwapCache. It's done under
- * lock_page and expected that zone->lru_lock is never held.
+ * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
+ * while it's linked to lru because the page may be reused after it's fully
+ * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
+ * It's done under lock_page and expected that zone->lru_lock isnever held.
  */
-static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
+static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
+	/*
+	 * Doing this check without taking ->lru_lock seems wrong but this
+	 * is safe. Because if page_cgroup's USED bit is unset, the page
+	 * will not be added to any memcg's LRU. If page_cgroup's USED bit is
+	 * set, the commit after this will fail, anyway.
+	 * This all charge/uncharge is done under some mutual execustion.
+	 * So, we don't need to taking care of changes in USED bit.
+	 */
+	if (likely(!PageLRU(page)))
+		return;
+
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	/*
 	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
@@ -948,12 +958,15 @@ static void mem_cgroup_lru_del_before_co
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
+static void mem_cgroup_lru_add_after_commit(struct page *page)
 {
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
+	/* taking care of that the page is added to LRU while we commit it */
+	if (likely(!PageLRU(page)))
+		return;
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	/* link when the page is linked to LRU but page_cgroup isn't */
 	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
@@ -2431,9 +2444,26 @@ static void
 __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype);
 
+static void
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *mem,
+					enum charge_type ctype)
+{
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+	/*
+	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
+	 * is already on LRU. It means the page may on some other page_cgroup's
+	 * LRU. Take care of it.
+	 */
+	mem_cgroup_lru_del_before_commit(page);
+	__mem_cgroup_commit_charge(mem, page, 1, pc, ctype);
+	mem_cgroup_lru_add_after_commit(page);
+	return;
+}
+
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
+	struct mem_cgroup *mem = NULL;
 	int ret;
 
 	if (mem_cgroup_disabled())
@@ -2468,14 +2498,22 @@ int mem_cgroup_cache_charge(struct page 
 	if (unlikely(!mm))
 		mm = &init_mm;
 
-	if (page_is_file_cache(page))
-		return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
+	if (page_is_file_cache(page)) {
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &mem, true);
+		if (ret || !mem)
+			return ret;
 
+		/*
+		 * FUSE reuses pages without going through the final
+		 * put that would remove them from the LRU list, make
+		 * sure that they get relinked properly.
+		 */
+		__mem_cgroup_commit_charge_lrucare(page, mem,
+					MEM_CGROUP_CHARGE_TYPE_CACHE);
+		return ret;
+	}
 	/* shmem */
 	if (PageSwapCache(page)) {
-		struct mem_cgroup *mem;
-
 		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
 		if (!ret)
 			__mem_cgroup_commit_charge_swapin(page, mem,
@@ -2532,17 +2570,13 @@ static void
 __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype)
 {
-	struct page_cgroup *pc;
-
 	if (mem_cgroup_disabled())
 		return;
 	if (!ptr)
 		return;
 	cgroup_exclude_rmdir(&ptr->css);
-	pc = lookup_page_cgroup(page);
-	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, page, 1, pc, ctype);
-	mem_cgroup_lru_add_after_commit_swapcache(page);
+
+	__mem_cgroup_commit_charge_lrucare(page, ptr, ctype);
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
