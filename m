Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4F1896B0092
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:57:09 -0500 (EST)
Received: by bkty12 with SMTP id y12so1373402bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:57:07 -0800 (PST)
Message-ID: <4F4645B0.5040702@openvz.org>
Date: Thu, 23 Feb 2012 17:57:04 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: fix page_referencies cgroup filter on global
 reclaim
References: <20120215162830.13902.60256.stgit@zurg> <20120221104622.GB1676@cmpxchg.org> <4F43821C.7080001@openvz.org> <20120221131122.GC1676@cmpxchg.org>
In-Reply-To: <20120221131122.GC1676@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Johannes Weiner wrote:
> On Tue, Feb 21, 2012 at 03:38:04PM +0400, Konstantin Khlebnikov wrote:
>> Johannes Weiner wrote:
>>> On Wed, Feb 15, 2012 at 08:28:30PM +0400, Konstantin Khlebnikov wrote:
>>>> Global memory reclaimer should't skip referencies for any pages,
>>>> even if they are shared between different cgroups.
>>>
>>> Agreed: if we reclaim from one memcg because of its limit, we want to
>>> reclaim those pages that this group is not using.  If it's used by
>>> someone else, it should be evicted and refaulted by the group that
>>> needs it.
>>>
>>> If we reclaim globally, all references are "true" because we want to
>>> evict those pages that are not used by any cgroup.
>>>
>>> But if we reclaim a hierarchical subgroup, we don't want to evict
>>> pages that are shared among this hierarchy, either, even if the memcg
>>> that has the page charged to it is not using it.  Bouncing the page
>>> around the hierarchy is not sensible, because it does not solve the
>>> problem of the parent hitting its limit when the sibling group will
>>> refault it in a blink of an eye.  It should only be evicted if the
>>> memcg that's not using it nears its own limit, because only in that
>>> case would reclaiming the page remedy the situation.
>>>
>>>> This patch adds scan_control->current_mem_cgroup, which points to currently
>>>> shrinking sub-cgroup in hierarchy, at global reclaim it always NULL.
>>>
>>> So to be consistent, I'm wondering if we should pass
>>> sc->target_mem_cgroup - the limit-hitting hierarchy root - to
>>> page_referenced() and then have mm_match_cgroup() do a
>>> mem_cgroup_same_or_subtree() check to see if the vma is in the
>>> hierarchy rooted at sc->target_mem_cgroup.
>>>
>>> Global reclaim is handled automatically, because mm_match_cgroup() is
>>> not checked when the passed memcg is NULL, which sc->target_mem_cgroup
>>> is for global reclaim.
>>
>> Also we can try to recharge page to other cgroup, if we found in rmap another its user
>> outsize of currently shrinking hierarchy, page there is isolated, so at the end we will
>> insert page directly to its lru.
>
> Not sure if it's worth the trouble, but that could work.
>
>> But the main purpose of this patch for me is killing mz->mem_cgroup dereference,
>> because I plan to replace mz with direct reference to lruvec, which will be memcg-free object.
>
> I like that plan.  How about this patch then?

I sent my version. See patch "[PATCH v3 02/21] memcg: make mm_match_cgroup() hirarchical"

one note below

>
> ---
> From: Johannes Weiner<hannes@cmpxchg.org>
> Subject: mm: memcg: count pte references from every member of the reclaimed hierarchy
>
> The rmap walker checking page table references has historically
> ignored references from VMAs that were not part of the memcg that was
> being reclaimed during memcg hard limit reclaim.
>
> When transitioning global reclaim to memcg hierarchy reclaim, I missed
> that bit and now references from outside a memcg are ignored even
> during global reclaim.
>
> Reverting back to traditional behaviour - count all references during
> global reclaim and only mind references of the memcg being reclaimed
> during limit reclaim would be one option.
>
> However, the more generic idea is to ignore references exactly then
> when they are outside the hierarchy that is currently under reclaim;
> because only then will their reclamation be of any use to help the
> pressure situation.  It makes no sense to ignore references from a
> sibling memcg and then evict a page that will be immediately refaulted
> by that sibling which contributes to the same usage of the common
> ancestor under reclaim.
>
> The solution: make the rmap walker ignore references from VMAs that
> are not part of the hierarchy that is being reclaimed.
>
> Flat limit reclaim will stay the same, hierarchical limit reclaim will
> mind the references only to pages that the hierarchy owns.  Global
> reclaim, since it reclaims from all memcgs, will be fixed to regard
> all references.
>
> Reported-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> ---
>   include/linux/memcontrol.h |    3 ++-
>   mm/memcontrol.c            |    2 +-
>   mm/vmscan.c                |    6 ++++--
>   3 files changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8537c5d..ba9455d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -78,6 +78,7 @@ extern void mem_cgroup_uncharge_page(struct page *page);
>   extern void mem_cgroup_uncharge_cache_page(struct page *page);
>
>   extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
> +bool mem_cgroup_same_or_subtree(const struct mem_cgroup *, struct mem_cgroup *);
>   int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
>
>   extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> @@ -91,7 +92,7 @@ int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
>   	rcu_read_lock();
>   	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
>   	rcu_read_unlock();
> -	return cgroup == memcg;
> +	return mem_cgroup_same_or_subtree(cgroup, memcg);
>   }

seems like this memcg pointer is rcu-protected, so it seems broken.

>
>   extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e4be95a..f91d762 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1044,7 +1044,7 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
>    * Checks whether given mem is same or in the root_mem_cgroup's
>    * hierarchy subtree
>    */
> -static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> +bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>   		struct mem_cgroup *memcg)
>   {
>   	if (root_memcg != memcg) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c631234..120646e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -708,7 +708,8 @@ static enum page_references page_check_references(struct page *page,
>   	int referenced_ptes, referenced_page;
>   	unsigned long vm_flags;
>
> -	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup,&vm_flags);
> +	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
> +					&vm_flags);
>   	referenced_page = TestClearPageReferenced(page);
>
>   	/* Lumpy reclaim - ignore references */
> @@ -1710,7 +1711,8 @@ static void shrink_active_list(unsigned long nr_pages,
>   			continue;
>   		}
>
> -		if (page_referenced(page, 0, mz->mem_cgroup,&vm_flags)) {
> +		if (page_referenced(page, 0, sc->target_mem_cgroup,
> +				&vm_flags)) {
>   			nr_rotated += hpage_nr_pages(page);
>   			/*
>   			 * Identify referenced, file-backed active pages and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
