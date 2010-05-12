Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C89106B020C
	for <linux-mm@kvack.org>; Wed, 12 May 2010 03:53:02 -0400 (EDT)
Date: Wed, 12 May 2010 16:45:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH -mm] memcg fix mis-accounting of file mapped
 racy with migration
Message-Id: <20100512164529.7819031e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100512163014.4d17b6d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100512163014.4d17b6d0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Thank you for your effort.

I'll review and test it.

Thanks,
Daisuke Nishimura.

On Wed, 12 May 2010 16:30:14 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This was reported April but I waited for the fix of migration+compaction.
> 
> Tested with m-of-the-moment snapshot 2010-05-11-18-20. seems to work well.
> 
> 
> ==
> FILE_MAPPED per memcg of migrated file cache is not properly updated, 
> because our hook in page_add_file_rmap() can't know to which memcg
> FILE_MAPPED should be counted.
> 	
> Basically, this patch is for fixing the bug but includes some big changes
> to fix up other messes.
> 
> Now, at migrating mapped file, events happen in following sequence.
> 
>  1. allocate a new page.
>  2. get memcg of an old page.
>  3. charge ageinst a new page before migration. But at this point,
>     no changes to new page's page_cgroup, no commit for the charge.
>     (IOW, PCG_USED bit is not set.)
>  4. page migration replaces radix-tree, old-page and new-page.
>  5. page migration remaps the new page if the old page was mapped.
>  6. Here, the new page is unlocked.
>  7. memcg commits the charge for newpage, Mark the new page's page_cgroup
>     as PCG_USED.
> 
> Because "commit" happens after page-remap, we can count FILE_MAPPED
> at "5", because we should avoid to trust page_cgroup->mem_cgroup.
> if PCG_USED bit is unset.
> (Note: memcg's LRU removal code does that but LRU-isolation logic is used
>  for helpint it. When we overwrite page_cgroup->mem_cgroup, page_cgroup is
>  not on LRU or page_cgroup->mem_cgroup is NULL.)
> 
> We can lose file_mapped accounting information at 5 because FILE_MAPPED
> is updated only when mapcount changes 0->1. So we should catch it.
> 
> BTW, historically, above implemntation comes from migration-failure
> of anonymous page. Because we charge both of old page and new page
> with mapcount=0, we can't catch
>   - the page is really freed before remap.
>   - migration fails but it's freed before remap
> or .....corner cases.
> 
> New migration sequence with memcg is:
> 
>  1. allocate a new page.
>  2. mark PageCgroupMigration to the old page.
>  3. charge against a new page onto the old page's memcg. (here, new page's pc
>     is marked as PageCgroupUsed.)
>  4. mark PageCgroupMigration to the old page.
>  5. page migration replaces radix-tree, page table, etc...
>  6. At remapping, new page's page_cgroup is now makrked as "USED"
>     We can catch 0->1 event and FILE_MAPPED will be properly updated.
> 
>     And we can catch SWAPOUT event after unlock this and freeing this
>     page by unmap() can be caught.
> 
>  7. Clear PageCgroupMigration of the old page.
> 
> So, FILE_MAPPED will be correctly updated.
> 
> Then, for what MIGRATION flag is ?
>   Without it, at migration failure, we may have to charge old page again
>   because it may be fully unmapped. "charge" means that we have to dive into
>   memory reclaim or something complated. So, it's better to avoid
>   charge it again. Before this patch, __commit_charge() was working for
>   both of the old/new page and fixed up all. But this technique has some
>   racy condtion around FILE_MAPPED and SWAPOUT etc...
>   Now, the kernel use MIGRATION flag and don't uncharge old page until
>   the end of migration.
> 
> I hope this change will make memcg's page migration much simpler.
> This page migration has caused several troubles. Worth to add
> a flag for simplification.
> 
> Changelog: 2010/05/12
>  - adjusted onto mm-of-the-moment snapshot 2010-05-11-18-20
> 
> Changelog: 2010/04/20
>  - fixed SWAPOUT case.
>  - added texts for explanation.
>  - removed MIGRAION flag onto new page.
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
>  include/linux/memcontrol.h  |    6 +
>  include/linux/page_cgroup.h |    5 +
>  mm/memcontrol.c             |  137 +++++++++++++++++++++++++++++++-------------
>  mm/migrate.c                |    2 
>  4 files changed, 108 insertions(+), 42 deletions(-)
> 
> Index: mmotm-2.6.34-rc7-mm1/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-rc7-mm1.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-rc7-mm1/mm/memcontrol.c
> @@ -2281,7 +2281,8 @@ __mem_cgroup_uncharge_common(struct page
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
> -		if (page_mapped(page))
> +		/* See mem_cgroup_prepare_migration() */
> +		if (page_mapped(page) || PageCgroupMigration(pc))
>  			goto unlock_out;
>  		break;
>  	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
> @@ -2504,10 +2505,12 @@ static inline int mem_cgroup_move_swap_a
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
> @@ -2518,69 +2521,125 @@ int mem_cgroup_prepare_migration(struct 
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
> +		/*
> +		 * At migrating an anonymous page, its mapcount goes down
> +		 * to 0 and uncharge() will be called. But, even if it's fully
> +		 * unmapped, migration may fail and this page has to be
> +		 * charged again. We set MIGRATION flag here and delay uncharge
> +		 * until end_migration() is called
> +		 *
> +		 * Corner Case Thinking
> +		 * A)
> +		 * When the old page was mapped as Anon and it's unmap-and-freed
> +		 * while migration was ongoing.
> +		 * If unmap finds the old page, uncharge() of it will be delayed
> +		 * until end_migration(). If unmap finds a new page, it's
> +		 * uncharged when it make mapcount to be 1->0. If unmap code
> +		 * finds swap_migration_entry, the new page will not be mapped
> +		 * and end_migration() will find it(mapcount==0).
> +		 *
> +		 * B)
> +		 * When the old page was mapped but migraion fails, the kernel
> +		 * remaps it. A charge for it is kept by MIGRATION flag even
> +		 * if mapcount goes down to 0. We can do remap successfully
> +		 * without charging it again.
> +		 *
> +		 * C)
> +		 * The "old" page is under lock_page() until the end of
> +		 * migration, so, the old page itself will not be swapped-out.
> +		 * If the new page is swapped out before end_migraton, our
> +		 * hook to usual swap-out path will catch the event.
> +		 */
> +		if (PageAnon(page))
> +			SetPageCgroupMigration(pc);
>  	}
>  	unlock_page_cgroup(pc);
> +	/*
> +	 * If the page is not charged at this point,
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
> +		if (PageAnon(page)) {
> +			lock_page_cgroup(pc);
> +			ClearPageCgroupMigration(pc);
> +			unlock_page_cgroup(pc);
> +			/*
> +		 	 * The old page may be fully unmapped while we kept it.
> +		 	 */
> +			mem_cgroup_uncharge_page(page);
> +		}
> +		return -ENOMEM;
>  	}
> +	/*
> + 	 * We charge new page before it's used/mapped. So, even if unlock_page()
> + 	 * is called before end_migration, we can catch all events on this new
> + 	 * page. In the case new page is migrated but not remapped, new page's
> + 	 * mapcount will be finally 0 and we call uncharge in end_migration().
> +  	 */
> +	pc = lookup_page_cgroup(newpage);
> +	if (PageAnon(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +	else if (page_is_file_cache(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	else
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +	__mem_cgroup_commit_charge(mem, pc, ctype);
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
> +	pc = lookup_page_cgroup(oldpage);
> +	lock_page_cgroup(pc);
> +	ClearPageCgroupMigration(pc);
> +	unlock_page_cgroup(pc);
>  
> +	if (unused != oldpage)
> +		pc = lookup_page_cgroup(unused);
> +	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
> +
> +	pc = lookup_page_cgroup(used);
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
> +	 * If a page is a file cache, radix-tree replacement is very atomic
> + 	 * and we can skip this check. When it was an Anon page, its mapcount
> + 	 * goes down to 0. But because we added MIGRATION flage, it's not
> + 	 * uncharged yet. There are several case but page->mapcount check
> + 	 * and USED bit check in mem_cgroup_uncharge_page() will do enough
> + 	 * check. (see prepare_charge() also)
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
> Index: mmotm-2.6.34-rc7-mm1/mm/migrate.c
> ===================================================================
> --- mmotm-2.6.34-rc7-mm1.orig/mm/migrate.c
> +++ mmotm-2.6.34-rc7-mm1/mm/migrate.c
> @@ -590,7 +590,7 @@ static int unmap_and_move(new_page_t get
>  	}
>  
>  	/* charge against new page */
> -	charge = mem_cgroup_prepare_migration(page, &mem);
> +	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
>  	if (charge == -ENOMEM) {
>  		rc = -ENOMEM;
>  		goto unlock;
> Index: mmotm-2.6.34-rc7-mm1/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-2.6.34-rc7-mm1.orig/include/linux/memcontrol.h
> +++ mmotm-2.6.34-rc7-mm1/include/linux/memcontrol.h
> @@ -90,7 +90,8 @@ int mm_match_cgroup(const struct mm_stru
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
>  
>  extern int
> -mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
> +mem_cgroup_prepare_migration(struct page *page,
> +	struct page *newpage, struct mem_cgroup **ptr);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	struct page *oldpage, struct page *newpage);
>  
> @@ -229,7 +230,8 @@ static inline struct cgroup_subsys_state
>  }
>  
>  static inline int
> -mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> +mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
> +	struct mem_cgroup **ptr)
>  {
>  	return 0;
>  }
> Index: mmotm-2.6.34-rc7-mm1/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.34-rc7-mm1.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.34-rc7-mm1/include/linux/page_cgroup.h
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
