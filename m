Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67B176B0206
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 21:00:31 -0400 (EDT)
Date: Wed, 14 Apr 2010 09:54:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010 15:14:00 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Apr 2010 13:42:07 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > When I was testing page migration, I found underflow problem of "mapped_file" field
> > in memory.stat. This is a fix for the problem.
> > 
> > This patch is based on mmotm-2010-04-05-16-09, and IIUC it conflicts with Mel's
> > compaction patches, so I send it as RFC for now. After next mmotm, which will
> > include those patches, I'll update and resend this patch.
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > page_add_file_rmap(), which can be called from remove_migration_ptes(), is
> > assumed to increment memcg's stat of mapped file. But on success of page
> > migration, the newpage(mapped file) has not been charged yet, so the stat will
> > not be incremented. This behavior leads to underflow of memcg's stat because
> > when the newpage is unmapped afterwards, page_remove_rmap() decrements the stat.
> > This problem doesn't happen on failure path of page migration, because the old
> > page(mapped file) hasn't been uncharge at the point of remove_migration_ptes().
> > This patch fixes this problem by calling commit_charge(mem_cgroup_end_migration)
> > before remove_migration_ptes().
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Nice catch. but...I want to make all kind of complicated things under
> prepare/end migration. (And I want to avoid changes in migrate.c...)
> 
hmm, I want to call mem_cgroup_update_file_mapped() only where we update
NR_FILE_MAPPED, but, okey, I see your concern.

> Considering some racy condistions, I wonder memcg_update_file_mapped() itself
> still need fixes..
> 
> So, how about this ? We already added FILE_MAPPED flags, then, make use of it.
> ==
> 
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
> This patch fixes it by accounting file_mapped information at
> commiting charge.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> Index: mmotm-temp/mm/memcontrol.c
> ===================================================================
> --- mmotm-temp.orig/mm/memcontrol.c
> +++ mmotm-temp/mm/memcontrol.c
> @@ -1435,11 +1435,13 @@ void mem_cgroup_update_file_mapped(struc
>  
>  	/*
>  	 * Preemption is already disabled. We can use __this_cpu_xxx
> +	 * We have no lock per page at inc/dec mapcount of pages. We have to do
> +	 * check by ourselves under lock_page_cgroup().
>  	 */
> -	if (val > 0) {
> +	if (val > 0 && !PageCgroupFileMapped(pc)) {
>  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>  		SetPageCgroupFileMapped(pc);
> -	} else {
> +	} else if (PageCgroupFileMapped(pc)) {
>  		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>  		ClearPageCgroupFileMapped(pc);
>  	}
Adding likely() is better ? IIUC, these conditions are usually met except for
the case of page migration. And, can you add a comment about it ?

> @@ -2563,6 +2565,15 @@ void mem_cgroup_end_migration(struct mem
>  	 */
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
>  		mem_cgroup_uncharge_page(target);
> +	else {
> +		/*
> +		 * When a migrated file cache is remapped, it's not charged.
> +		 * Verify it. Because we're under lock_page(), there are
> +		 * no race with uncharge.
> +		 */
> +		if (page_mapped(target))
> +			mem_cgroup_update_file_mapped(mem, target, 1);
> +	}
We cannot rely on page lock, because when we succeeded in page migration,
"target" = "newpage" has already unlocked in move_to_new_page(). So the "target"
can be removed from the radix-tree theoretically(it's not related to this
underflow problem, though).
Shouldn't we call lock_page(target) and check "if (!target->mapping)" to handle
this case(maybe in another patch) ?

Thanks,
Daisuke Nishimura.

>  	/*
>  	 * At migration, we may charge account against cgroup which has no tasks
>  	 * So, rmdir()->pre_destroy() can be called while we do this charge.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
