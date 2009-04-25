Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BA8A6B003D
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 08:54:13 -0400 (EDT)
Date: Sat, 25 Apr 2009 21:54:59 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for memg v3.
Message-Id: <20090425215459.5cab7285.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090424152103.a5ee8d13.nishimura@mxp.nes.nec.co.jp>
	<20090424162840.2ad06d8a.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> +static void memcg_fixup_stale_swapcache(struct work_struct *work)
> +{
> +	int pos = 0;
> +	swp_entry_t entry;
> +	struct page *page;
> +	int forget, ret;
> +
> +	while (ssc.num) {
> +		spin_lock(&ssc.lock);
> +		pos = find_next_bit(ssc.usemap, STALE_ENTS, pos);
> +		spin_unlock(&ssc.lock);
> +
> +		if (pos >= STALE_ENTS)
> +			break;
> +
> +		entry = ssc.ents[pos];
> +
> +		forget = 1;
> +		page = lookup_swap_cache(entry);
> +		if (page) {
> +			lock_page(page);
> +			ret = try_to_free_swap(page);
> +			/* If it's still under I/O, don't forget it */
> +			if (!ret && PageWriteback(page))
> +				forget = 0;
> +			unlock_page(page);
I think we need page_cache_release().
lookup_swap_cache() gets the page.

> +		}
> +		if (forget) {
> +			spin_lock(&ssc.lock);
> +			clear_bit(pos, ssc.usemap);
> +			ssc.num--;
> +			if (ssc.num < STALE_ENTS/2)
> +				ssc.congestion = 0;
> +			spin_unlock(&ssc.lock);
> +		}
> +		pos++;
> +	}
> +	if (ssc.num) /* schedule me again */
> +		schedule_delayed_work(&ssc.gc_work, HZ/10);
"if (ssc.congestion)" would be better ?

> +	return;
> +}
> +

(snip)

> Index: mmotm-2.6.30-Apr21/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-Apr21.orig/mm/vmscan.c
> +++ mmotm-2.6.30-Apr21/mm/vmscan.c
> @@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
>  		if (PageAnon(page) && !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
> +			/* avoid making more stale swap caches */
> +			if (memcg_stale_swap_congestion())
> +				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
>  			may_enter_fs = 1;
> 
Hmm, I don't think this can avoid type-2 stale swap caches.
IIUC, this can only avoid add_to_swap() if the number of stale swap caches
exceeds some threshold, but type-2 swap caches(set !PageCgroupUsed by the
owner process via page_remove_rmap()->mem_cgroup_uncharge_page() before
beeing add to swap cache) is not handled as 'stale'.

In fact, I can see the usage of SwapCache increasing gradually.

Can you add a patch like bellow ?

Thanks,
Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Instead of checking memcg_stale_swap_congestion() before add_to_swap(),
free "unused" swap cache after add_to_swap().

IMHO, it would be better to let shrink_page_list() free as much pages
as possible, so free type-2 stale swap caches directly, instead of
handling them in lazy manner.
shrink_page_list() calls try_to_free_swap() already in some paths.
(e.g. pageout()->swap_writepage()->try_to_free_swap())
 
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1e6519c..51c6985 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -339,6 +339,7 @@ extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
 extern void memcg_mark_swapent_stale(swp_entry_t ent);
 extern void memcg_sanity_check_swapin(struct page *page, swp_entry_t ent);
 extern int memcg_stale_swap_congestion(void);
+extern int memcg_free_unused_swapcache(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
@@ -357,6 +358,11 @@ static inline int memcg_stale_swap_congestion(void)
 {
 	return 0;
 }
+
+static int memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ccc69b4..822a914 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1754,6 +1754,17 @@ static void setup_stale_swapcache_control(void)
 	INIT_DELAYED_WORK(&ssc.gc_work, memcg_fixup_stale_swapcache);
 }
 
+int memcg_free_unused_swapcache(struct page *page)
+{
+	VM_BUG_ON(!PageSwapCache(page));
+	VM_BUG_ON(!PageLocked(page));
+
+	if (mem_cgroup_disabled())
+		return 0;
+	if (!PageAnon(page) || page_mapped(page))
+		return 0;
+	return try_to_free_swap(page);	/* checks page_swapcount */
+}
 #else
 
 int memcg_stale_swap_congestion(void)
@@ -1765,6 +1776,10 @@ static void setup_stale_swapcache_control(void)
 {
 }
 
+int memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
 #endif /* CONFIG_SWAP */
 
 static DEFINE_MUTEX(set_limit_mutex);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 054ed38..5b9aa8e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -654,11 +654,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			/* avoid making more stale swap caches */
-			if (memcg_stale_swap_congestion())
-				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
+			/*
+			 * The owner process might have uncharged the page
+			 * (by page_remove_rmap()) before it has been added
+			 * to swap cache.
+			 * Check it here to avoid making it stale.
+			 */
+			if (memcg_free_unused_swapcache(page))
+				goto keep_locked;
 			may_enter_fs = 1;
 		}
 
===

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
