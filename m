Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DA3A56B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 00:32:50 -0400 (EDT)
Date: Fri, 1 May 2009 13:33:17 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090501133317.9c372d38.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090430181246.GM4430@balbir.in.ibm.com>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430094252.GG4430@balbir.in.ibm.com>
	<20090430184738.752858ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430181246.GM4430@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 23:42:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:47:38]:
> 
> > On Thu, 30 Apr 2009 15:12:52 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:04:26]:
> > > 
> > > > On Thu, 30 Apr 2009 16:35:39 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > On Thu, 30 Apr 2009 16:16:27 +0900
> > > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > 
> > > > > > This is v5 but all codes are rewritten.
> > > > > > 
> > > > > > After this patch, when memcg is used,
> > > > > >  1. page's swapcount is checked after I/O (without locks). If the page is
> > > > > >     stale swap cache, freeing routine will be scheduled.
> > > > > >  2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.
> > > > > > 
> > > > > > Works well for me. no extra resources and no races.
> > > > > > 
> > > > > > Because my office will be closed until May/7, I'll not be able to make a
> > > > > > response. Posting this for showing what I think of now.
> > > > > > 
> > > > > I found a hole immediately after posted this...sorry. plz ignore this patch/
> > > > > see you again in the next month.
> > > > > 
> > > > I'm now wondering to disable "swapin readahed" completely when memcg is used...
> > > > Then, half of the problems will go away immediately.
> > > > And it's not so bad to try to free swapcache if swap writeback ends. Then, another
> > > > half will go away...
> > > >
> > > 
> > > Could you clarify? Will memcg not account for swapin readahead pages?
> > >  
> > swapin-readahead pages are _not_ accounted now. (And I think _never_)
> > But has race and leak swp_entry account until global LRU runs.
> > 
> > "Don't do swapin-readahead, at all" will remove following race completely.
> > ==
> >          CPU0                  CPU1
> >  free_swap_and_cache()
> >                         read_swapcache_async()
> > ==
> > swp_entry to be freed will not be read-in.
> > 
> > I think there will no performance regression in _usual_ case even if no readahead.
> > But has no number yet.
> >
> 
> Kamezawa, Daisuke,
> 
> Can't we just correct the accounting and leave the page on the global
> LRU?
> 
> Daisuke in the race conditions mentioned is (2) significant? Since the
> accounting is already fixed during mem_cgroup_uncharge_page()?
> 
Do you mean type-2 stale swap caches I described before ?

They doesn't pressure mem.usage nor memsw.usage as you say,
but consumes swp_entry(of cource, type-1 has this problem too).
As a result, all the swap space can be used up and causes OOM.

I've verified it long ago by:

- make swap space small(50MB).
- set mem.limit(32MB).
- run some programs(allocate, touch sometimes, exit) enough to
  exceed mem.limit repeatedly(I used page01 included in ltp and run
  5 instances 8MB per each in cpuset with 4cpus.).
- wait for a very long time :) (2,30 hours IIRC)
  You can see the usage of swap cache(grep SwapCached /proc/meminfo)
  increasing gradually.


BTW, I'm now testing a attached patch to fix type-2 with setting page-cluster
to 0 to aboid type-1, and seeing what happens in the usage of swap cache.
(I can't test it in large box though, because my office is closed till May 06.)

Thanks,
Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

memcg: free unused swapcache on swapout path

memcg cannot handle !PageCgroupUsed swapcache the owner process of which
has been exited.

This patch is for handling such swap caches created by a race like below:

    Assume processA is exiting and pte points to a page(!PageSwapCache).
    And processB is trying reclaim the page.

              processA                   |           processB
    -------------------------------------+-------------------------------------
      (page_remove_rmap())               |  (shrink_page_list())
         mem_cgroup_uncharge_page()      |
            ->uncharged because it's not |
              PageSwapCache yet.         |
              So, both mem/memsw.usage   |
              are decremented.           |
                                         |    add_to_swap() -> added to swap cache.

    If this page goes thorough without being freed for some reason, this page
    doesn't goes back to memcg's LRU because of !PageCgroupUsed.

These swap cache cannot be freed in memcg's LRU scanning, and swp_entry cannot
be freed properly as a result.
This patch adds a hook after add_to_swap() to check the page is mapped by a
process or not, and frees it if it has been unmapped already.

If a page has been on swap cache already when the owner process calls
page_remove_rmap() -> mem_cgroup_uncharge_page(), the page is not uncharged.
It goes back to memcg's LRU even if it goes through shrink_page_list()
without being freed, so this patch ignores these case.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |   12 ++++++++++++
 mm/memcontrol.c      |   14 ++++++++++++++
 mm/vmscan.c          |    8 ++++++++
 3 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index caf0767..8e75d7a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -336,11 +336,17 @@ static inline void disable_swap_token(void)
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern int memcg_free_unused_swapcache(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+static inline int
+memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
@@ -431,6 +437,12 @@ static inline swp_entry_t get_swap_page(void)
 #define has_swap_token(x) 0
 #define disable_swap_token() do { } while(0)
 
+static inline int
+memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 01c2d8f..4f7e5b6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1488,6 +1488,7 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+#ifdef CONFIG_SWAP
 /*
  * called from __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
@@ -1507,6 +1508,19 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 		css_put(&memcg->css);
 }
 
+int memcg_free_unused_swapcache(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	if (mem_cgroup_disabled())
+		return 0;
+	if (!PageAnon(page) || page_mapped(page))
+		return 0;
+	return try_to_free_swap(page);	/* checks page_swapcount */
+}
+#endif /* CONFIG_SWAP */
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /*
  * called from swap_entry_free(). remove record in swap_cgroup and
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..c1a7a6f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -656,6 +656,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
