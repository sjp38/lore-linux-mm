Date: Fri, 26 Sep 2008 19:43:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926194309.845d661b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926142455.5b0e239e.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
	<20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120408.39187294.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926120019.33d58ca4.nishimura@mxp.nes.nec.co.jp>
	<20080926130534.e16c9317.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926142455.5b0e239e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 14:24:55 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> Unfortunately, there remains some bugs yet...
> 

Thank you for your patient good test!

I'm now testing following (and will do over-night test.)
In this an hour, this seems to work good. 
(under your test which usually panics in 10-20min on my box.)

==
page_cgroup is not valid until pc->mem_cgroup is set to appropriate value.
There is a small race between Set-Used-Bit and Set-Proper-pc->mem_cgroup.
This patch tries to fix that by adding PCG_VALID bit

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/page_cgroup.h |    3 +++
 mm/memcontrol.c             |   22 ++++++++++++++--------
 2 files changed, 17 insertions(+), 8 deletions(-)

Index: mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
@@ -21,6 +21,7 @@ struct page_cgroup *lookup_page_cgroup(s
 
 enum {
 	/* flags for mem_cgroup */
+	PCG_VALID, /* you can access this page cgroup */
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
@@ -50,6 +51,10 @@ static inline int TestSetPageCgroup##una
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 
+TESTPCGFLAG(Valid, VALID)
+SETPCGFLAG(Valid, VALID)
+CLEARPCGFLAG(Valid, VALID)
+
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 TESTSETPCGFLAG(Used, USED)
Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -340,7 +340,7 @@ void mem_cgroup_move_lists(struct page *
 	if (!trylock_page_cgroup(pc))
 		return;
 
-	if (PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
+	if (PageCgroupValid(pc) && PageCgroupLRU(pc)) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
@@ -434,7 +434,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
-		if (unlikely(!PageCgroupUsed(pc)))
+		if (unlikely(!PageCgroupValid(pc)))
 			continue;
 		page = pc->page;
 
@@ -511,7 +511,7 @@ int mem_cgroup_move_account(struct page 
 		return ret;
 	}
 
-	if (!PageCgroupUsed(pc)) {
+	if (!PageCgroupValid(pc)) {
 		res_counter_uncharge(&to->res, PAGE_SIZE);
 		goto out;
 	}
@@ -580,6 +580,7 @@ __set_page_cgroup_lru(struct memcg_percp
 	unsigned long flags;
 	struct mem_cgroup_per_zone *mz, *prev_mz;
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
 	int i, nr;
 
 	local_irq_save(flags);
@@ -589,6 +590,7 @@ __set_page_cgroup_lru(struct memcg_percp
 
 	for (i = nr - 1; i >= 0; i--) {
 		pc = mpv->vec[i];
+		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		if (prev_mz != mz) {
 			if (prev_mz)
@@ -596,9 +598,11 @@ __set_page_cgroup_lru(struct memcg_percp
 			prev_mz = mz;
 			spin_lock(&mz->lru_lock);
 		}
-		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
-			SetPageCgroupLRU(pc);
-			__mem_cgroup_add_list(mz, pc);
+		if (PageCgroupValid(pc) && !PageCgroupLRU(pc)) {
+			if (mem == pc->mem_cgroup) {
+				SetPageCgroupLRU(pc);
+				__mem_cgroup_add_list(mz, pc);
+			}
 		}
 	}
 
@@ -790,6 +794,7 @@ void mem_cgroup_commit_charge(struct pag
 	}
 
 	pc->mem_cgroup = mem;
+	SetPageCgroupValid(pc);
 	set_page_cgroup_lru(pc);
 	css_put(&mem->css);
 	preempt_enable();
@@ -928,6 +933,7 @@ __mem_cgroup_uncharge_common(struct page
 		return;
 	preempt_disable();
 	lock_page_cgroup(pc);
+	ClearPageCgroupValid(pc);
 	ClearPageCgroupUsed(pc);
 	mem = pc->mem_cgroup;
 	unlock_page_cgroup(pc);
@@ -970,7 +976,7 @@ int mem_cgroup_prepare_migration(struct 
 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc)) {
+	if (PageCgroupValid(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (PageCgroupCache(pc)) {
@@ -1086,7 +1092,7 @@ static void mem_cgroup_force_empty_list(
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	list_for_each_entry_safe(pc, tmp, list, lru) {
 		page = pc->page;
-		if (!PageCgroupUsed(pc))
+		if (!PageCgroupValid(pc))
 			continue;
 		/* For avoiding race with speculative page cache handling. */
 		if (!PageLRU(page) || !get_page_unless_zero(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
