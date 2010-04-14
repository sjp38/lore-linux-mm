Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C00C6B020B
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:40:09 -0400 (EDT)
Date: Wed, 14 Apr 2010 14:31:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414143132.179edc6e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100414120622.0a5c2983.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
	<20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414105608.d40c70ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414120622.0a5c2983.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 12:06:22 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> At page migration, the new page is unlocked before calling end_migration().
> This is mis-understanding with page-migration code of memcg.
> And FILE_MAPPED of migrated file cache is not properly updated, now.
> 
> At migrating mapped file, events happens in following sequence.
> 
>  1. allocate a new page.
>  2. get memcg of an old page.
>  3. charge ageinst new page, before migration. But at this point
>     no changes to page_cgroup, no commit-charge.
>  4. page migration replaces radix-tree, old-page and new-page.
>  5. page migration remaps the new page if the old page was mapped.
>  6. memcg commits the charge for newpage.
> 
> Because "commit" happens after page-remap, we lose file_mapped
> accounting information at migration.
> 
> For fixing all, this changes parepare/end migration.
> New migration sequence with memcg is:
> 
>  1. allocate a new page.
>  2. charge against a new page onto old page's memcg. (here, the new page
>     is marked as PageCgroupUsed.)
>  3. page migration replaces radix-tree, page table, etc...
>  4. At remapping, FILE_MAPPED will be properly updated. (because newpage is marked as
>     USED, already)
>  5. If anonymous page is freed before remap, check it and fixup accounting.
>  
> 
Great! I like this change very much.

Some comments are inlined.

> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    6 +-
>  mm/memcontrol.c            |   95 ++++++++++++++++++++++++---------------------
>  mm/migrate.c               |    2 
>  3 files changed, 56 insertions(+), 47 deletions(-)
> 
> Index: mmotm-temp/mm/memcontrol.c
> ===================================================================
> --- mmotm-temp.orig/mm/memcontrol.c
> +++ mmotm-temp/mm/memcontrol.c
> @@ -2501,10 +2501,12 @@ static inline int mem_cgroup_move_swap_a
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
> @@ -2517,65 +2519,70 @@ int mem_cgroup_prepare_migration(struct 
>  		css_get(&mem->css);
>  	}
>  	unlock_page_cgroup(pc);
> -
> -	if (mem) {
> -		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> -		css_put(&mem->css);
> -	}
> -	*ptr = mem;
> +	/*
> +	 * If the page is uncharged before migration (removed from radix-tree)
> +	 * we return here.
> +	 */
> +	if (!mem)
> +		return 0;
> +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> +	css_put(&mem->css); /* drop extra refcnt */
it should be:

	*ptr = mem;
	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
	css_put(&mem->css);

as Andrea has fixed already.

> +	if (ret)
> +		return ret;
> +	/*
> + 	 * The old page is under lock_page().
> + 	 * If the old_page is uncharged and freed while migration, page migration
> + 	 * will fail and newpage will properly uncharged by end_migration.
> + 	 * And commit_charge against newpage never fails.
> +  	 */
> +	pc = lookup_page_cgroup(newpage);
> +	if (PageAnon(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +	else if (!PageSwapBacked(page))
I think using page_is_file_cache() would be better.

> +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	else
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +	__mem_cgroup_commit_charge(mem, pc, ctype);
> +	/* FILE_MAPPED of this page will be updated at remap routine */
>  	return ret;
>  }
>  
>  /* remove redundant charge if migration failed*/
>  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -		struct page *oldpage, struct page *newpage)
> +	struct page *oldpage, struct page *newpage)
>  {
> -	struct page *target, *unused;
> -	struct page_cgroup *pc;
> -	enum charge_type ctype;
> +	struct page *used, *unused;
>  
>  	if (!mem)
>  		return;
>  	cgroup_exclude_rmdir(&mem->css);
> +
> +
unnecessary extra line :)

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
> -	/*
> -	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
> -	 * So, double-counting is effectively avoided.
> -	 */
> -	__mem_cgroup_commit_charge(mem, pc, ctype);
> -
> +	/* PageCgroupUsed() flag check will do all we want */
> +	mem_cgroup_uncharge_page(unused);
hmm... using mem_cgroup_uncharge_page() would be enough, but I think it doesn't
show what we want: we must uncharge "unused" by all means in PageCgroupUsed case,
and I feel it strange a bit to uncharge "unused" by mem_cgroup_uncharge_page(),
if it *was* a cache page.
So I think __mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE)
would be better, otherwise we need more comments to explain why
mem_cgroup_uncharge_page() is enough.

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
> + 	 * If old page was file cache, and removed from radix-tree
> + 	 * before lock_page(), perepare_migration doesn't charge and we never
> + 	 * reach here.
> + 	 *
And if newpage was removed from radix-tree after unlock_page(),
the context which removed it from radix-tree uncharges it properly, because
it is charged at prepare_migration.

right?

> + 	 * Considering ANON pages, we can't depend on lock_page.
> + 	 * If a page may be unmapped before it's remapped, new page's
> + 	 * mapcount will not increase. (case that mapcount 0->1 never occur.)
> + 	 * PageCgroupUsed() and SwapCache checks will be done.
> + 	 *
> + 	 * Once mapcount goes to 1, our hook to page_remove_rmap will do
> + 	 * enough jobs.
> + 	 */
> +	if (PageAnon(used) && !page_mapped(used))
> +		mem_cgroup_uncharge_page(used);
mem_cgroup_uncharge_page() does the same check :)


Thanks,
Daisuke Nishimura.

>  	/*
>  	 * At migration, we may charge account against cgroup which has no tasks
>  	 * So, rmdir()->pre_destroy() can be called while we do this charge.
> Index: mmotm-temp/mm/migrate.c
> ===================================================================
> --- mmotm-temp.orig/mm/migrate.c
> +++ mmotm-temp/mm/migrate.c
> @@ -576,7 +576,7 @@ static int unmap_and_move(new_page_t get
>  	}
>  
>  	/* charge against new page */
> -	charge = mem_cgroup_prepare_migration(page, &mem);
> +	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
>  	if (charge == -ENOMEM) {
>  		rc = -ENOMEM;
>  		goto unlock;
> Index: mmotm-temp/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-temp.orig/include/linux/memcontrol.h
> +++ mmotm-temp/include/linux/memcontrol.h
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
