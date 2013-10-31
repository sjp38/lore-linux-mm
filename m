Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 94A996B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 05:07:20 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so2085411pdj.39
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 02:07:20 -0700 (PDT)
Received: from psmtp.com ([74.125.245.144])
        by mx.google.com with SMTP id dj3si1212285pbc.340.2013.10.31.02.07.17
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 02:07:18 -0700 (PDT)
Date: Thu, 31 Oct 2013 10:07:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memcg-fix-test-for-child-groups.patch added to -mm tree
Message-ID: <20131031090714.GD13144@dhcp22.suse.cz>
References: <527191b6.zSpIEdNWLZ9XUQtM%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <527191b6.zSpIEdNWLZ9XUQtM%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 30-10-13 16:09:42, Andrew Morton wrote:
> Subject: + mm-memcg-fix-test-for-child-groups.patch added to -mm tree
> To: hannes@cmpxchg.org,mhocko@suse.cz
> From: akpm@linux-foundation.org
> Date: Wed, 30 Oct 2013 16:09:42 -0700
> 
> 
> The patch titled
>      Subject: mm: memcg: fix test for child groups
> has been added to the -mm tree.  Its filename is
>      mm-memcg-fix-test-for-child-groups.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-fix-test-for-child-groups.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-memcg-fix-test-for-child-groups.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: memcg: fix test for child groups
> 
> When memcg code needs to know whether any given memcg has children, it
> uses the cgroup child iteration primitives and returns true/false
> depending on whether the iteration loop is executed at least once or not.
> 
> Because a cgroup's list of children is RCU protected, these primitives
> require the RCU read-lock to be held, which is not the case for all memcg
> callers.  This results in the following splat when e.g.  enabling
> hierarchy mode:
> 
> [    3.683974] WARNING: CPU: 3 PID: 1 at /home/hannes/src/linux/linux/kernel/cgroup.c:3043 css_next_child+0xa3/0x160()
> [    3.686266] CPU: 3 PID: 1 Comm: systemd Not tainted 3.12.0-rc5-00117-g83f11a9-dirty #18
> [    3.688616] Hardware name: LENOVO 3680B56/3680B56, BIOS 6QET69WW (1.39 ) 04/26/2012
> [    3.690900]  0000000000000009 ffff88013227bdc8 ffffffff8173602f 0000000000000000
> [    3.693225]  ffff88013227be00 ffffffff81090af8 0000000000000000 ffff88013220d000
> [    3.695606]  ffff8800b6c50028 ffff88013220d000 0000000000000000 ffff88013227be10
> [    3.697950] Call Trace:
> [    3.700233]  [<ffffffff8173602f>] dump_stack+0x54/0x74
> [    3.702503]  [<ffffffff81090af8>] warn_slowpath_common+0x78/0xa0
> [    3.704764]  [<ffffffff81090c0a>] warn_slowpath_null+0x1a/0x20
> [    3.707009]  [<ffffffff81101173>] css_next_child+0xa3/0x160
> [    3.709255]  [<ffffffff8118ae7b>] mem_cgroup_hierarchy_write+0x5b/0xa0
> [    3.711497]  [<ffffffff810fe428>] cgroup_file_write+0x108/0x2a0
> [    3.713721]  [<ffffffff8119b90d>] ? __sb_start_write+0xed/0x1b0
> [    3.715936]  [<ffffffff811980fb>] ? vfs_write+0x1bb/0x1e0
> [    3.718155]  [<ffffffff810b8d3f>] ? up_write+0x1f/0x40
> [    3.720356]  [<ffffffff81197ffd>] vfs_write+0xbd/0x1e0
> [    3.722539]  [<ffffffff8119820c>] SyS_write+0x4c/0xa0
> [    3.724685]  [<ffffffff817400d2>] system_call_fastpath+0x16/0x1b
> [    3.726809] ---[ end trace ec33c7d4de043d06 ]---
> 
> In the memcg case, we only care about children when we are attempting to
> modify inheritable attributes interactively.  Racing with deletion could
> mean a spurious -EBUSY, no problem.  Racing with addition is handled just
> fine as well through the memcg_create_mutex: if the child group is not on
> the list after the mutex is acquired, it won't be initialized from the
> parent's attributes until after the unlock.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Yes, I liked the original list_empty check much more than playing cgroup
iteration game. The argument at the time was that we shouldn't rely on
cgroups internals so much. I do not think that the children list will
ever change to something else and if yes let's deal with it when it
matters.

That being said
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/memcontrol.c |   35 +++++++++++------------------------
>  1 file changed, 11 insertions(+), 24 deletions(-)
> 
> diff -puN mm/memcontrol.c~mm-memcg-fix-test-for-child-groups mm/memcontrol.c
> --- a/mm/memcontrol.c~mm-memcg-fix-test-for-child-groups
> +++ a/mm/memcontrol.c
> @@ -4959,31 +4959,18 @@ static void mem_cgroup_reparent_charges(
>  	} while (usage > 0);
>  }
>  
> -/*
> - * This mainly exists for tests during the setting of set of use_hierarchy.
> - * Since this is the very setting we are changing, the current hierarchy value
> - * is meaningless
> - */
> -static inline bool __memcg_has_children(struct mem_cgroup *memcg)
> -{
> -	struct cgroup_subsys_state *pos;
> -
> -	/* bounce at first found */
> -	css_for_each_child(pos, &memcg->css)
> -		return true;
> -	return false;
> -}
> -
> -/*
> - * Must be called with memcg_create_mutex held, unless the cgroup is guaranteed
> - * to be already dead (as in mem_cgroup_force_empty, for instance).  This is
> - * from mem_cgroup_count_children(), in the sense that we don't really care how
> - * many children we have; we only need to know if we have any.  It also counts
> - * any memcg without hierarchy as infertile.
> - */
>  static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  {
> -	return memcg->use_hierarchy && __memcg_has_children(memcg);
> +	lockdep_assert_held(&memcg_create_mutex);
> +	/*
> +	 * The lock does not prevent addition or deletion to the list
> +	 * of children, but it prevents a new child from being
> +	 * initialized based on this parent in css_online(), so it's
> +	 * enough to decide whether hierarchically inherited
> +	 * attributes can still be changed or not.
> +	 */
> +	return memcg->use_hierarchy &&
> +		!list_empty(&memcg->css.cgroup->children);
>  }
>  
>  /*
> @@ -5063,7 +5050,7 @@ static int mem_cgroup_hierarchy_write(st
>  	 */
>  	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
>  				(val == 1 || val == 0)) {
> -		if (!__memcg_has_children(memcg))
> +		if (list_empty(&memcg->css.cgroup->children))
>  			memcg->use_hierarchy = val;
>  		else
>  			retval = -EBUSY;
> _
> 
> Patches currently in -mm which might be from hannes@cmpxchg.org are
> 
> percpu-fix-this_cpu_sub-subtrahend-casting-for-unsigneds.patch
> memcg-use-__this_cpu_sub-to-dec-stats-to-avoid-incorrect-subtrahend-casting.patch
> mm-memcg-use-proper-memcg-in-limit-bypass.patch
> mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> mm-memcg-fix-test-for-child-groups.patch
> mm-nobootmemc-have-__free_pages_memory-free-in-larger-chunks.patch
> memcg-refactor-mem_control_numa_stat_show.patch
> memcg-support-hierarchical-memorynuma_stats.patch
> memblock-factor-out-of-top-down-allocation.patch
> memblock-introduce-bottom-up-allocation-mode.patch
> x86-mm-factor-out-of-top-down-direct-mapping-setup.patch
> x86-mem-hotplug-support-initialize-page-tables-in-bottom-up.patch
> x86-acpi-crash-kdump-do-reserve_crashkernel-after-srat-is-parsed.patch
> mem-hotplug-introduce-movable_node-boot-option.patch
> swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
> percpu-add-test-module-for-various-percpu-operations.patch
> linux-next.patch
> mm-avoid-increase-sizeofstruct-page-due-to-split-page-table-lock.patch
> mm-rename-use_split_ptlocks-to-use_split_pte_ptlocks.patch
> mm-convert-mm-nr_ptes-to-atomic_long_t.patch
> mm-introduce-api-for-split-page-table-lock-for-pmd-level.patch
> mm-thp-change-pmd_trans_huge_lock-to-return-taken-lock.patch
> mm-thp-move-ptl-taking-inside-page_check_address_pmd.patch
> mm-thp-do-not-access-mm-pmd_huge_pte-directly.patch
> mm-hugetlb-convert-hugetlbfs-to-use-split-pmd-lock.patch
> mm-convert-the-rest-to-new-page-table-lock-api.patch
> mm-implement-split-page-table-lock-for-pmd-level.patch
> x86-mm-enable-split-page-table-lock-for-pmd-level.patch
> debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
