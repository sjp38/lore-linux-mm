Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8C89B6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 04:28:20 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ9URiL012831
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Dec 2008 18:30:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EED9845DE55
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:30:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FA4D45DE4F
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:30:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A3241DB801F
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:30:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FAEA1DB801A
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 18:30:26 +0900 (JST)
Date: Fri, 19 Dec 2008 18:29:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [bug][mmtom] memcg: MEM_CGROUP_ZSTAT underflow
Message-Id: <20081219182929.428380df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081219172903.7ca9b123.nishimura@mxp.nes.nec.co.jp>
References: <20081219172903.7ca9b123.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Hugh Dickins <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Dec 2008 17:29:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> Current(I'm testing 2008-12-16-15-50 with some patches, though) memcg have
> MEM_CGROUP_ZSTAT underflow problem.
> 
> How to reproduce:
> - make a directory, set mem.limit.
> - run some programs exceeding mem.limit.
> - make another directory, and all the tasks in old directory to new one.
> - New directory's "inactive_anon" in memory.stat underflows.
> 
> From my investigation:
> - This problem seems to happen only when swapping anonymous pages. It seems
>   not to happen about shmem.
> - After removing memcg-fix-swap-accounting-leak-v3.patch(and of course
>   memcg-fix-swap-accounting-leak-doc-fix.patch), this problem doesn't happen.
> 
> Thoughts?
> 

Thanks, then we need v4 ...but it just because my memcg-synchronized-lru.patch's
assumption about SwapCache was broken or not sane.

It assumes pc->page_cgroup is not changed after added to LRU, but now, it changes
because it can be dropped from SwapCache and new pc->mem_cgroup can be assigned.
Maybe mem_cgroup_lru_fixup() isn't enough, now.

Then..could you try this ? I can't do test right now, sorry.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

As memcg-fix-swap-accounting-leak-v3.patch pointed out, SwapCache
can be not SwapCache before commit.

In this case, 
	- the page is completely uncharged.
	- but still on Old LRU.
	- pc->mem_cgroup is changed before it's removed from LRU.

For avoiding race, remove page_cgroup from old LRU before we call commit.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

Index: mmotm-Dec-17/mm/memcontrol.c
===================================================================
--- mmotm-Dec-17.orig/mm/memcontrol.c
+++ mmotm-Dec-17/mm/memcontrol.c
@@ -1152,12 +1152,27 @@ int mem_cgroup_cache_charge_swapin(struc
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
+	struct zone *zone;
 
 	if (mem_cgroup_disabled())
 		return;
 	if (!ptr)
 		return;
+
 	pc = lookup_page_cgroup(page);
+
+	zone = page_zone(page);
+	spin_lock(&zone->lru_lock);
+	if (!PageSwapCache(page) && !list_empty(&pc->lru)) {
+		/*
+ 		 * We need to forget old LRU before modifying pc->mem_cgroup.
+ 		 * This is necessary only when the page is already uncharged
+ 		 * by delete_from_swap_cache().
+ 		 * (Nothing happens when pc->mem_cgroup is NULL.)
+  		 */
+		mem_cgroup_del_lru(page);
+	}
+	spin_unlock(&zone->lru_lock);
 	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -1246,6 +1261,12 @@ __mem_cgroup_uncharge_common(struct page
 
 	mem_cgroup_charge_statistics(mem, pc, false);
 	ClearPageCgroupUsed(pc);
+	/*
+ 	 * Don't clear pc->mem_cgroup because del_from_lru() will see this.
+ 	 * The fully unchaged page is assumed to be freed after us, so it's
+ 	 * safe. When this page is reused before free, we have to be careful.
+ 	 * (In SwapCache case...it can happen.)
+  	 */
 
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);







> 
> Thanks,
> Daisuke Nishimura.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
