Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7F9476B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:15:58 -0400 (EDT)
Date: Mon, 9 Jul 2012 16:15:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/11] mm: memcg: fix compaction/migration failing due to
 memcg limits
Message-ID: <20120709141554.GD4627@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341449103-1986-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

[CCing Ingo for the memcg-devel vs tip/sched/numa inter tree dependency
 - see bellow]

On Thu 05-07-12 02:44:53, Johannes Weiner wrote:
> Compaction (and page migration in general) can currently be hindered
> through pages being owned by memory cgroups that are at their limits
> and unreclaimable.
> 
> The reason is that the replacement page is being charged against the
> limit while the page being replaced is also still charged.  But this
> seems unnecessary, given that only one of the two pages will still be
> in use after migration finishes.
> 
> This patch changes the memcg migration sequence so that the
> replacement page is not charged.  Whatever page is still in use after
> successful or failed migration gets to keep the charge of the page
> that was going to be replaced.

Could you mention the side effect on the stat vs charges discrepancy,
please?

> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

[...]
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 8137aea..aa06bf4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
[...]
> @@ -1519,10 +1512,9 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
>  {
>  	struct page *oldpage = page, *newpage;
>  	struct address_space *mapping = page_mapping(page);
> -	struct mem_cgroup *mcg;
> +	struct mem_cgroup *memcg;
>  	unsigned int gfp;
>  	int rc = 0;
> -	int charge = -ENOMEM;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(page_mapcount(page));
> @@ -1556,12 +1548,7 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
>  	if (!trylock_page(newpage))
>  		BUG();		/* new page should be unlocked!!! */
>  
> -	// XXX hnaz, is this right?
> -	charge = mem_cgroup_prepare_migration(page, newpage, &mcg, gfp);
> -	if (charge == -ENOMEM) {
> -		rc = charge;
> -		goto out;
> -	}
> +	mem_cgroup_prepare_migration(page, newpage, &memcg);
>  
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
> @@ -1581,11 +1568,9 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
>  		page = newpage;
>  	}
>  
> +	mem_cgroup_end_migration(memcg, oldpage, newpage, !rc);
>  out:
> -	if (!charge)
> -		mem_cgroup_end_migration(mcg, oldpage, newpage, !rc);
> -
> -       if (oldpage != page)
> +	if (oldpage != page)
>                 put_page(oldpage);
>  
>  	if (rc) {

Hmm, this depends on 4783af47 (mm: Migrate misplaced page) from
tip/sched/numa which adds an inter tree dependency which is quite
unfortunate from memcg-devel (aka mmotm git tree) tree POV. 
I can cherry-pick this patch into memcg-devel but I am not sure what
is the merging status of the patch (XXX sounds like it is going to be
updated later). Ingo?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
