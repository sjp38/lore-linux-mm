Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB9A56B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 08:34:32 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FDYTxN013557
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Jan 2009 22:34:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E3545DE61
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:34:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4470F45DD79
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:34:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D534E38003
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:34:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B24BF1DB803E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:34:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mark_page_accessed() in do_swap_page() move latter than memcg charge
In-Reply-To: <Pine.LNX.4.64.0901151145470.11108@blonde.anvils>
References: <20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <Pine.LNX.4.64.0901151145470.11108@blonde.anvils>
Message-Id: <20090115212030.EBE9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Jan 2009 22:34:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

(CC to Rik and Nick)

Hi

Thank you reviewing.

> > mark_page_accessed() update reclaim_stat statics.
> > but currently, memcg charge is called after mark_page_accessed().
> > 
> > then, mark_page_accessed() don't update memcg statics correctly.
> 
> Statics?  "Stats" is a good abbreviation for statistics,
> but statics are something else.

Doh! your are definitly right. thanks.

> > ---
> >  mm/memory.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > Index: b/mm/memory.c
> > ===================================================================
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
> >  		count_vm_event(PGMAJFAULT);
> >  	}
> >  
> > -	mark_page_accessed(page);
> > -
> >  	lock_page(page);
> >  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> >  
> > @@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
> >  		try_to_free_swap(page);
> >  	unlock_page(page);
> >  
> > +	mark_page_accessed(page);
> > +
> >  	if (write_access) {
> >  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> >  		if (ret & VM_FAULT_ERROR)
> 
> This catches my eye, because I'd discussed with Nick and was going to
> send in a patch which entirely _removes_ this mark_page_accessed call
> from do_swap_page (and replaces follow_page's mark_page_accessed call
> by a pte_mkyoung): they seem inconsistent to me, in the light of
> bf3f3bc5e734706730c12a323f9b2068052aa1f0 mm: don't mark_page_accessed
> in fault path.

Actually, bf3f3bc5e734706730c12a323f9b2068052aa1f0 only remove 
the mark_page_accessed() in filemap_fault().
current mmotm's do_swap_page() still have mark_page_accessed().

but your suggestion is very worth.
ok, I'm thinking and sorting out again.

Rik's commit 9ff473b9a72942c5ac0ad35607cae28d8d59ed7a vmscan: evict streaming IO first
does "reclaim stastics don't only update at reclaim, but also at fault and read/write.
it makes proper anon/file reclaim balancing stastics value before starting actual reclaim".
and it depend on fault path calling mark_page_accessed(). 

Then, we need following change. I think.

  - Remove calling mark_page_accessed() in do_swap_page().
    it makes consistency against filemap_fault().
  - Add calling update_page_reclaim_stat() into do_swap_page() and 
    filemap_fault().

Am I overlooking something?


> Though I need to give it another think through first: the situation
> is muddied by the way we (rightly) don't bother to do the mark_page_
> accessed on Anon in zap_pte_range anyway; and anon/swap has an
> independent lifecycle now with the separate swapbacked LRUs.
> 
> What do you think?  I didn't look further into your memcg situation,
> and what this patch is about: I'm unclear whether my patch to remove
> that mark_page_accessed would solve your problem, or mess you up.

===========================
Subject: [PATCH] mm: solve reclaim statistics confliction

commit 9ff473b9a72942c5ac0ad35607cae28d8d59ed7a "vmscan: evict streaming IO first"
require to update reclaim statistics in page fault and depend on that fault path call 
mark_page_accessed().

but commit bf3f3bc5e734706730c12a323f9b2068052aa1f0 "mm: don't mark_page_accessed
in fault path." require to remove mark_page_accessed() from fault path.

They have conflict requirement.


the solusion is,
  - Remove calling mark_page_accessed() in do_swap_page().
    it makes consistency against filemap_fault().
  - Add calling update_page_reclaim_stat() into do_swap_page() and 
    filemap_fault().


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/swap.h |    2 ++
 mm/filemap.c         |    1 +
 mm/memory.c          |    4 ++--
 mm/swap.c            |    4 ++--
 4 files changed, 7 insertions(+), 4 deletions(-)

Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -185,6 +185,8 @@ extern void rotate_reclaimable_page(stru
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
+extern void update_page_reclaim_stat(struct zone *zone, struct page *page,
+				     int file, int rotated);
 
 /**
  * lru_cache_add: add a page to the page lists
Index: b/mm/filemap.c
===================================================================
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1637,6 +1637,7 @@ retry_page_update:
 	/*
 	 * Found the page and have a reference on it.
 	 */
+	update_page_reclaim_stat(page_zone(page), page, 1, 1);
 	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
-	mark_page_accessed(page);
-
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
@@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
 		try_to_free_swap(page);
 	unlock_page(page);
 
+	update_page_reclaim_stat(page_zone(page), page, 0, 1);
+
 	if (write_access) {
 		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
 		if (ret & VM_FAULT_ERROR)
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -151,8 +151,8 @@ void  rotate_reclaimable_page(struct pag
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
-				     int file, int rotated)
+void update_page_reclaim_stat(struct zone *zone, struct page *page,
+			      int file, int rotated)
 {
 	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
 	struct zone_reclaim_stat *memcg_reclaim_stat;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
