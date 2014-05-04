Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 87BE56B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 10:32:58 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so4460429eek.25
        for <linux-mm@kvack.org>; Sun, 04 May 2014 07:32:57 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w48si7482967eel.116.2014.05.04.07.32.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 07:32:56 -0700 (PDT)
Date: Sun, 4 May 2014 10:32:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: memcontrol: rewrite uncharge API
Message-ID: <20140504143251.GA1524@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 30, 2014 at 04:25:43PM -0400, Johannes Weiner wrote:
> The memcg uncharging code that is involved towards the end of a page's
> lifetime - truncation, reclaim, swapout, migration - is impressively
> complicated and fragile.
> 
> Because anonymous and file pages were always charged before they had
> their page->mapping established, uncharges had to happen when the page
> type could be known from the context, as in unmap for anonymous, page
> cache removal for file and shmem pages, and swap cache truncation for
> swap pages.  However, these operations also happen well before the
> page is actually freed, and so a lot of synchronization is necessary:
> 
> - On page migration, the old page might be unmapped but then reused,
>   so memcg code has to prevent an untimely uncharge in that case.
>   Because this code - which should be a simple charge transfer - is so
>   special-cased, it is not reusable for replace_page_cache().
> 
> - Swap cache truncation happens during both swap-in and swap-out, and
>   possibly repeatedly before the page is actually freed.  This means
>   that the memcg swapout code is called from many contexts that make
>   no sense and it has to figure out the direction from page state to
>   make sure memory and memory+swap are always correctly charged.
> 
> But now that charged pages always have a page->mapping, introduce
> mem_cgroup_uncharge(), which is called after the final put_page(),
> when we know for sure that nobody is looking at the page anymore.
> 
> For page migration, introduce mem_cgroup_migrate(), which is called
> after the migration is successful and the new page is fully rmapped.
> Because the old page is no longer uncharged after migration, prevent
> double charges by decoupling the page's memcg association (PCG_USED
> and pc->mem_cgroup) from the page holding an actual charge.  The new
> bits PCG_MEM and PCG_MEMSW represent the respective charges and are
> transferred to the new page during migration.
> 
> mem_cgroup_migrate() is suitable for replace_page_cache() as well.
> 
> Swap accounting is massively simplified: because the page is no longer
> uncharged as early as swap cache deletion, a new mem_cgroup_swapout()
> can transfer the page's memory+swap charge (PCG_MEMSW) to the swap
> entry before the final put_page() in page reclaim.
> 
> Finally, because pages are now charged under proper serialization
> (anon: exclusive; cache: page lock; swapin: page lock; migration: page
> lock), and uncharged under full exclusion, they can not race with
> themselves.  Because they are also off-LRU during charge/uncharge,
> charge migration can not race, with that, either.  Remove the crazily
> expensive the page_cgroup lock and set pc->flags non-atomically.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Follow-up fixlets to this change that fell out of more testing in
production and more auditing so far:

- Document mem_cgroup_move_account() exclusion
- Catch uncharged swapin readahead pages in mem_cgroup_swapout()
- Fix DEBUG_VM build after last-minute identifier rename
- Drop duplicate lru_cache_add_active_or_unevictable() in THP migration

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0add8b7b3a6c..f73df16b8115 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3387,6 +3387,12 @@ static int mem_cgroup_move_account(struct page *page,
 
 	mem_cgroup_charge_statistics(from, page, -nr_pages);
 
+	/*
+	 * It is safe to change pc->mem_cgroup here because the page
+	 * is referenced, charged, and isolated - we can't race with
+	 * uncharging, charging, migration, or LRU putback.
+	 */
+
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, page, nr_pages);
@@ -6234,6 +6240,12 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 
 	pc = lookup_page_cgroup(page);
 
+	/* Readahead page, never charged */
+	if (!PageCgroupUsed(pc))
+		return;
+
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
+
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
 	VM_BUG_ON_PAGE(oldid, page);
 
@@ -6723,8 +6735,8 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	if (!PageCgroupUsed(pc))
 		return;
 
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), page);
-	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
+	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), oldpage);
 	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
 
 	if (PageTransHuge(oldpage)) {
diff --git a/mm/migrate.c b/mm/migrate.c
index 80d33e62eb16..afe688021699 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1839,7 +1839,6 @@ fail_putback:
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_new_anon_rmap(new_page, vma, mmun_start);
-	lru_cache_add_active_or_unevictable(new_page, vma);
 	pmdp_clear_flush(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
