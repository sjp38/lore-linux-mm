Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBEA8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 00:04:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4C6CC3EE0C2
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:04:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D6E645DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:04:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1662145DE4E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:04:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06EFAE78002
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:04:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF4681DB803B
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:04:51 +0900 (JST)
Date: Mon, 7 Mar 2011 13:58:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Message-Id: <20110307135803.a7d718ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110304180157.133fdfd1.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
	<20110304000355.4f68bab1.akpm@linux-foundation.org>
	<20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
	<20110304180157.133fdfd1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Poelzleithner <poelzi@poelzi.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>

On Fri, 4 Mar 2011 18:01:57 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 4 Mar 2011 17:28:15 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This seems....
> > ==
> > static void mem_cgroup_start_move(struct mem_cgroup *mem)
> > {
> > .....
> > 	put_online_cpus();
> > 
> >         synchronize_rcu();   <---------(*)
> > }
> > ==
> > 
> 
> But this may scan LRU of memcg forever and SysRq+T just shows
> above stack.
> 
> I'll check a tree before THP and force_empty again

Hmm, one more conern is what kind of file system is used ?

Can I see 
 - /prco/mounts
and your .config ?

If you use FUSE, could you try this ?

I'll prepare one for mmotm.

==

fs/fuse/dev.c::fuse_try_move_page() does

   (1) remove a page by ->steal()
   (2) re-add the page to page cache 
   (3) link the page to LRU if it was not on LRU at (1)

This implies the page is _on_ LRU when it's added to radix-tree.
So, the page is added to  memory cgroup while it's on LRU.
because LRU is lazy and no one flushs it.

This is the same behavior as SwapCache and needs special care as
 - remove page from LRU before overwrite pc->mem_cgroup.
 - add page to LRU after overwrite pc->mem_cgroup.

So, reusing it with renaming.

Note: a page on pagevec(LRU).
If a page is not PageLRU(page) but on pagevec(LRU), it may be added to LRU
while we overwrite page->mapping. But in that case, PCG_USED bit of
the page_cgroup is not set and the page_cgroup will not be added to
wrong memcg's LRU. So, this patch's logic will work fine.
(It has been tested with SwapCache.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

Index: linux-2.6.37/mm/memcontrol.c
===================================================================
--- linux-2.6.37.orig/mm/memcontrol.c
+++ linux-2.6.37/mm/memcontrol.c
@@ -876,13 +876,12 @@ void mem_cgroup_add_lru_list(struct page
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
@@ -898,7 +897,7 @@ static void mem_cgroup_lru_del_before_co
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
+static void mem_cgroup_lru_add_after_commit(struct page *page)
 {
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
@@ -2299,7 +2298,7 @@ int mem_cgroup_newpage_charge(struct pag
 }
 
 static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype);
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -2339,18 +2338,28 @@ int mem_cgroup_cache_charge(struct page 
 	if (unlikely(!mm))
 		mm = &init_mm;
 
-	if (page_is_file_cache(page))
-		return mem_cgroup_charge_common(page, mm, gfp_mask,
+	/*
+	 * FUSE has a logic to reuse existing page-cache before free().
+	 * It means the 'page' may be on some LRU. SwapCache has the
+	 * same kind of handling.
+	 */
+	if (page_is_file_cache(page) && !PageLRU(page)) {
+		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE);
+	} else if (page_is_file_cache(page)) {
+		struct mem_cgroup *mem = NULL;
 
-	/* shmem */
-	if (PageSwapCache(page)) {
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
+		if (!ret)
+			__mem_cgroup_commit_charge_lrucare(page, mem,
+				MEM_CGROUP_CHARGE_TYPE_CACHE);
+	} else if (PageSwapCache(page)) {
 		struct mem_cgroup *mem = NULL;
 
 		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
 		if (!ret)
-			__mem_cgroup_commit_charge_swapin(page, mem,
-					MEM_CGROUP_CHARGE_TYPE_SHMEM);
+			__mem_cgroup_commit_charge_lrucare(page, mem,
+				MEM_CGROUP_CHARGE_TYPE_SHMEM);
 	} else
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
 					MEM_CGROUP_CHARGE_TYPE_SHMEM);
@@ -2398,7 +2407,7 @@ charge_cur_mm:
 }
 
 static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc;
@@ -2409,9 +2418,9 @@ __mem_cgroup_commit_charge_swapin(struct
 		return;
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
-	mem_cgroup_lru_del_before_commit_swapcache(page);
+	mem_cgroup_lru_del_before_commit(page);
 	__mem_cgroup_commit_charge(ptr, pc, ctype);
-	mem_cgroup_lru_add_after_commit_swapcache(page);
+	mem_cgroup_lru_add_after_commit(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
@@ -2449,7 +2458,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
-	__mem_cgroup_commit_charge_swapin(page, ptr,
+	__mem_cgroup_commit_charge_lrucare(page, ptr,
 					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
