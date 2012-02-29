Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 880446B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 17:05:01 -0500 (EST)
Date: Wed, 29 Feb 2012 14:04:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3.3] memcg: fix deadlock by inverting lrucare nesting
Message-Id: <20120229140458.c53352db.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Feb 2012 21:25:02 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> We have forgotten the rules of lock nesting: the irq-safe ones must be
> taken inside the non-irq-safe ones, otherwise we are open to deadlock:
> 
> CPU0                          CPU1
> ----                          ----
> lock(&(&pc->lock)->rlock);
>                               local_irq_disable();
>                               lock(&(&zone->lru_lock)->rlock);
>                               lock(&(&pc->lock)->rlock);
> <Interrupt>
> lock(&(&zone->lru_lock)->rlock);
> 
> To check a different locking issue, I happened to add a spin_lock to
> memcg's bit_spin_lock in lock_page_cgroup(), and lockdep very quickly
> complained about __mem_cgroup_commit_charge_lrucare() (on CPU1 above).
> 
> So delete __mem_cgroup_commit_charge_lrucare(), passing a bool lrucare
> to __mem_cgroup_commit_charge() instead, taking zone->lru_lock under
> lock_page_cgroup() in the lrucare case.
> 
> The original was using spin_lock_irqsave, but we'd be in more trouble
> if it were ever called at interrupt time: unconditional _irq is enough.
> And ClearPageLRU before del from lru, SetPageLRU before add to lru: no
> strong reason, but that is the ordering used consistently elsewhere.

This patch makes rather a mess of "memcg: remove PCG_CACHE page_cgroup
flag".

--- mm/memcontrol.c~memcg-remove-pcg_cache-page_cgroup-flag
+++ mm/memcontrol.c
@@ -2410,6 +2414,8 @@
 				       struct page_cgroup *pc,
 				       enum charge_type ctype)
 {
+	bool anon;
+
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
@@ -2429,21 +2435,14 @@
 	 * See mem_cgroup_add_lru_list(), etc.
  	 */
 	smp_wmb();
-	switch (ctype) {
-	case MEM_CGROUP_CHARGE_TYPE_CACHE:
-	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
-		SetPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
-		ClearPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	default:
-		break;
-	}
 
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
+	SetPageCgroupUsed(pc);
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		anon = true;
+	else
+		anon = false;
+
+	mem_cgroup_charge_statistics(memcg, anon, nr_pages);
 	unlock_page_cgroup(pc);
 	WARN_ON_ONCE(PageLRU(page));
 	/*

I did it this way:

static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
				       struct page *page,
				       unsigned int nr_pages,
				       struct page_cgroup *pc,
				       enum charge_type ctype,
				       bool lrucare)
{
	struct zone *uninitialized_var(zone);
	bool was_on_lru = false;
	bool anon;

	lock_page_cgroup(pc);
	if (unlikely(PageCgroupUsed(pc))) {
		unlock_page_cgroup(pc);
		__mem_cgroup_cancel_charge(memcg, nr_pages);
		return;
	}
	/*
	 * we don't need page_cgroup_lock about tail pages, becase they are not
	 * accessed by any other context at this point.
	 */

	/*
	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
	 * may already be on some other mem_cgroup's LRU.  Take care of it.
	 */
	if (lrucare) {
		zone = page_zone(page);
		spin_lock_irq(&zone->lru_lock);
		if (PageLRU(page)) {
			ClearPageLRU(page);
			del_page_from_lru_list(zone, page, page_lru(page));
			was_on_lru = true;
		}
	}

	pc->mem_cgroup = memcg;
	/*
	 * We access a page_cgroup asynchronously without lock_page_cgroup().
	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
	 * before USED bit, we need memory barrier here.
	 * See mem_cgroup_add_lru_list(), etc.
 	 */
	smp_wmb();
	SetPageCgroupUsed(pc);

	if (lrucare) {
		if (was_on_lru) {
			VM_BUG_ON(PageLRU(page));
			SetPageLRU(page);
			add_page_to_lru_list(zone, page, page_lru(page));
		}
		spin_unlock_irq(&zone->lru_lock);
	}

	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
		anon = true;
	else
		anon = false;

	mem_cgroup_charge_statistics(memcg, anon, nr_pages);
	unlock_page_cgroup(pc);

	/*
	 * "charge_statistics" updated event counter. Then, check it.
	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
	 * if they exceeds softlimit.
	 */
	memcg_check_events(memcg, page);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
