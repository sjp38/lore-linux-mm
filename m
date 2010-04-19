Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6DC6B01F1
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 23:44:58 -0400 (EDT)
Date: Mon, 19 Apr 2010 12:42:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH 2/2] memcg: fix file mapped underflow at
 migration (v3)
Message-Id: <20100419124225.91f3110b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100416193143.5807d114.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100415120652.c577846f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100416193143.5807d114.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hmm, before going further, will you explain why we need a new PCG_MIGRATION flag ?
What's the problem of v2 ?

Thanks,
Daisuke Nishimura.

On Fri, 16 Apr 2010 19:31:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This is still RFC. 
> I hope this will fix memcg v.s. page-migraion war finally ;(
> But we have to be careful...
> ==
> 
> At page migration, the new page is unlocked before calling end_migration().
> This is mis-understanding with page-migration code of memcg.
> (But it wasn't big problem..the real issue is mapcount handling.)
> 
> This has small race and we need to fix this race. By this,
> FILE_MAPPED of migrated file cache is not properly updated, now.
> 
> This patch is for fixing the race by changing algorithm.
> 
> At migrating mapped file, events happens in following sequence.
> 
>  1. allocate a new page.
>  2. get memcg of an old page.
>  3. charge ageinst a new page before migration. But at this point,
>     no changes to new page's page_cgroup, no commit-charge.
>  4. page migration replaces radix-tree, old-page and new-page.
>  5. page migration remaps the new page if the old page was mapped.
>  6. Here, the new page is unlocked.
>  7. memcg commits the charge for newpage, Mark page cgroup as USED.
> 
> Because "commit" happens after page-remap, we cannot count FILE_MAPPED
> at "5", we can lose file_mapped accounting information within this
> small race. FILE_MAPPED is updated only when mapcount changes 0->1.
> So, if we don't catch this 0->1 event, we can underflow FILE_MAPPED
> at 1->0 event.
> 
> We may be able to avoid underflow by some small technique or new hook but
> we should catch mapcount 0->1 event fundamentaly. To catch this, we have to
> make page_cgroup of new page as "USED".
> 
> BTW, historically, above implemntation comes from migration-failure
> of anonymous page. When we charge both of old page and new page
> with mapcount=0 before migration we can't catch
>   - the page is really freed before remap.
>   - migration fails but it's freed before remap
> .....corner cases.
> 
> For fixing all, this changes parepare/end migration with MIGRATION flag on
> page_cgroup.
> 
> New migration sequence with memcg is:
> 
>  1. allocate a new page.
>  2. mark PageCgroupMigration to the old page.
>  3. charge against a new page onto the old page's memcg. (here, new page's pc
>     is marked as PageCgroupUsed.)
>  4. mark PageCgroupMigration to the new page.
> 
> If a page_cgroup is marked as PageCgroupMigration, it's uncahrged until
> it's cleared.
> 
>  5. page migration replaces radix-tree, page table, etc...
>  6. At remapping, new page's page_cgroup is now marked as "USED"
>     We can catch 0->1 event and FILE_MAPPED will be properly updated.
>  7. Clear PageCgroupMigration of both of old page and new page.
>  8. uncharge unnecessary pages.
> 
> By this:
> At migration success of Anon:
>  - The new page is properly charged. If not-mapped after remap,
>    uncharge() will be called.
>  - The file cache is properly charged. FILE_MAPPED event can be caught.
> 
> At migration failure of Anon:
>  - The old page stays as charged. If not mapped after remap,
>    uncharge() will be called after clearing PageCgroupMigration.
>    If mapped, or on radix-tree(swapcache), it's not uncharged.
> 
> I hope this change will make memcg's page migration much simpler.
> Page migration has caused several troubles. Worth to add a flag
> for simplification.
> 
> Changelog: 2010/04/15
>  - updated against  mm-of-the-moment snapshot 2010-04-15-14-42
>    + Nishimura's fix. memcg-fix-prepare-migration-fix.patch
>  - fixed some typos.
>  - handle migration failure of anon page.
> 
> Changelog: 2010/04/14
>  - updated onto the latest mmotm + page-compaction, etc...
>  - fixed __try_charge() bypass case.
>  - use CHARGE_TYPE_FORCE for uncharging an unused page.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |    6 +-
>  include/linux/page_cgroup.h |    5 +
>  mm/memcontrol.c             |  115 +++++++++++++++++++++++++++++---------------
>  mm/migrate.c                |    2 
>  4 files changed, 87 insertions(+), 41 deletions(-)
> 
> Index: mmotm-Apr16/mm/memcontrol.c
> ===================================================================
> --- mmotm-Apr16.orig/mm/memcontrol.c
> +++ mmotm-Apr16/mm/memcontrol.c
> @@ -2275,6 +2275,9 @@ __mem_cgroup_uncharge_common(struct page
>  	if (!PageCgroupUsed(pc))
>  		goto unlock_out;
>  
> +	if (unlikely(PageAnon(page) && PageCgroupMigration(pc)))
> +		goto unlock_out;
> +
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
> @@ -2501,10 +2504,12 @@ static inline int mem_cgroup_move_swap_a
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
>   */
> -int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> +int mem_cgroup_prepare_migration(struct page *page,
> +	struct page *newpage, struct mem_cgroup **ptr)
>  {
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
> +	enum charge_type ctype;
>  	int ret = 0;
>  
>  	if (mem_cgroup_disabled())
> @@ -2515,69 +2520,103 @@ int mem_cgroup_prepare_migration(struct 
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
> +		/* disallow uncharge until the end of migration */
> +		SetPageCgroupMigration(pc);
>  	}
>  	unlock_page_cgroup(pc);
> +	/*
> +	 * If the page is uncharged before migration (removed from radix-tree)
> +	 * we return here.
> +	 */
> +	if (!mem)
> +		return 0;
>  
>  	*ptr = mem;
> -	if (mem) {
> -		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
> -		css_put(&mem->css);
> +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
> +	css_put(&mem->css);/* drop extra refcnt */
> +	if (ret || *ptr == NULL) {
> +		lock_page_cgroup(pc);
> +		ClearPageCgroupMigration(pc);
> +		unlock_page_cgroup(pc);
> +		/*
> +		 * The old page may be fully unmapped while we kept it.
> +		 * If file cache, we hold lock on this page and there
> +		 * is no race.
> +		 */
> +		if (PageAnon(page))
> +			mem_cgroup_uncharge_page(page);
> +		return -ENOMEM;
> +	}
> +	/*
> + 	 * The old page is under lock_page().
> + 	 * If the old_page is uncharged and freed while migration, page
> + 	 * migration will fail and newpage will properly uncharged.
> + 	 * Because we're only referer to this newpage, this commit_charge
> + 	 * against newpage never fails.
> +  	 */
> +	pc = lookup_page_cgroup(newpage);
> +	if (PageAnon(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +	else if (page_is_file_cache(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	else
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +	__mem_cgroup_commit_charge(mem, pc, ctype);
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED) {
> +		lock_page_cgroup(pc);
> +		SetPageCgroupMigration(pc);
> +		unlock_page_cgroup(pc);
>  	}
>  	return ret;
>  }
>  
>  /* remove redundant charge if migration failed*/
>  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -		struct page *oldpage, struct page *newpage)
> +	struct page *oldpage, struct page *newpage)
>  {
> -	struct page *target, *unused;
> +	struct page *used, *unused;
>  	struct page_cgroup *pc;
> -	enum charge_type ctype;
>  
>  	if (!mem)
>  		return;
> +	/* blocks rmdir() */
>  	cgroup_exclude_rmdir(&mem->css);
>  	/* at migration success, oldpage->mapping is NULL. */
>  	if (oldpage->mapping) {
> -		target = oldpage;
> -		unused = NULL;
> +		used = oldpage;
> +		unused = newpage;
>  	} else {
> -		target = newpage;
> +		used = newpage;
>  		unused = oldpage;
>  	}
> -
> -	if (PageAnon(target))
> -		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> -	else if (page_is_file_cache(target))
> -		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> -	else
> -		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> -
> -	/* unused page is not on radix-tree now. */
> -	if (unused)
> -		__mem_cgroup_uncharge_common(unused, ctype);
> -
> -	pc = lookup_page_cgroup(target);
>  	/*
> -	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> -	 * So, double-counting is effectively avoided.
> +	 * We disallowed uncharge of pages under migration because mapcount
> +	 * of the page goes down to zero, temporarly.
> +	 * Clear the flag and check the page should be charged.
>  	 */
> -	__mem_cgroup_commit_charge(mem, pc, ctype);
> +	pc = lookup_page_cgroup(unused);
> +	lock_page_cgroup(pc);
> +	ClearPageCgroupMigration(pc);
> +	unlock_page_cgroup(pc);
> +	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
>  
> +	pc = lookup_page_cgroup(used);
> +	lock_page_cgroup(pc);
> +	ClearPageCgroupMigration(pc);
> +	unlock_page_cgroup(pc);
>  	/*
> -	 * Both of oldpage and newpage are still under lock_page().
> -	 * Then, we don't have to care about race in radix-tree.
> -	 * But we have to be careful that this page is unmapped or not.
> -	 *
> -	 * There is a case for !page_mapped(). At the start of
> -	 * migration, oldpage was mapped. But now, it's zapped.
> -	 * But we know *target* page is not freed/reused under us.
> -	 * mem_cgroup_uncharge_page() does all necessary checks.
> -	 */
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -		mem_cgroup_uncharge_page(target);
> +	 * If the page is file cache, radix-tree replacement is very atomic
> + 	 * and we can skip this check. When it comes to Anon pages, it's
> + 	 * uncharged when mapcount goes down to 0. Because page migration
> + 	 * has to make mapcount goes down to 0, we may miss the caes as
> + 	 * migration-failure or really-unmapped-while-migration.
> + 	 * Check it out here.
> + 	 */
> +	if (PageAnon(used))
> +		mem_cgroup_uncharge_page(used);
>  	/*
> -	 * At migration, we may charge account against cgroup which has no tasks
> +	 * At migration, we may charge account against cgroup which has no
> +	 * tasks.
>  	 * So, rmdir()->pre_destroy() can be called while we do this charge.
>  	 * In that case, we need to call pre_destroy() again. check it here.
>  	 */
> Index: mmotm-Apr16/mm/migrate.c
> ===================================================================
> --- mmotm-Apr16.orig/mm/migrate.c
> +++ mmotm-Apr16/mm/migrate.c
> @@ -581,7 +581,7 @@ static int unmap_and_move(new_page_t get
>  	}
>  
>  	/* charge against new page */
> -	charge = mem_cgroup_prepare_migration(page, &mem);
> +	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
>  	if (charge == -ENOMEM) {
>  		rc = -ENOMEM;
>  		goto unlock;
> Index: mmotm-Apr16/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-Apr16.orig/include/linux/memcontrol.h
> +++ mmotm-Apr16/include/linux/memcontrol.h
> @@ -89,7 +89,8 @@ int mm_match_cgroup(const struct mm_stru
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
>  
>  extern int
> -mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
> +mem_cgroup_prepare_migration(struct page *page,
> +	struct page *newpage, struct mem_cgroup **ptr);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	struct page *oldpage, struct page *newpage);
>  
> @@ -228,7 +229,8 @@ static inline struct cgroup_subsys_state
>  }
>  
>  static inline int
> -mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> +mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
> +	struct mem_cgroup **ptr)
>  {
>  	return 0;
>  }
> Index: mmotm-Apr16/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-Apr16.orig/include/linux/page_cgroup.h
> +++ mmotm-Apr16/include/linux/page_cgroup.h
> @@ -40,6 +40,7 @@ enum {
>  	PCG_USED, /* this object is in use. */
>  	PCG_ACCT_LRU, /* page has been accounted for */
>  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> +	PCG_MIGRATION, /* under page migration */
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -79,6 +80,10 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
>  CLEARPCGFLAG(FileMapped, FILE_MAPPED)
>  TESTPCGFLAG(FileMapped, FILE_MAPPED)
>  
> +SETPCGFLAG(Migration, MIGRATION)
> +CLEARPCGFLAG(Migration, MIGRATION)
> +TESTPCGFLAG(Migration, MIGRATION)
> +
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
