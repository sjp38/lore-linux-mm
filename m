Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7C3066B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 17:37:33 -0400 (EDT)
Date: Thu, 26 Apr 2012 14:37:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] mm: memcg: count pte references from every member
 of the reclaimed hierarchy
Message-Id: <20120426143729.10f672ae.akpm@linux-foundation.org>
In-Reply-To: <1335296144-29381-2-git-send-email-hannes@cmpxchg.org>
References: <1335296144-29381-1-git-send-email-hannes@cmpxchg.org>
	<1335296144-29381-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 24 Apr 2012 21:35:44 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

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
> ...
>
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -78,6 +78,7 @@ extern void mem_cgroup_uncharge_cache_page(struct page *page);
>  
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				     int order);
> +bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *, struct mem_cgroup *);

I dunno about you guys, but this practice of omitting the names of the
arguments in the declaration drives me bats.  It really does throw away
a *lot* of information.  It looks OK when one is initially reading the
code, but when I actually go in there and do some work on the code, it
makes things significantly harder.

>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> @@ -91,10 +92,13 @@ static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
>  {
>  	struct mem_cgroup *memcg;
> +	int match;
> +
>  	rcu_read_lock();
>  	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> +	match = memcg && __mem_cgroup_same_or_subtree(cgroup, memcg);
>  	rcu_read_unlock();
> -	return cgroup == memcg;
> +	return match;
>  }

mm_match_cgroup() really wants to return a bool type, no?

> +bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> +				  struct mem_cgroup *memcg)

Like him.

> +static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> +				       struct mem_cgroup *memcg)

And him.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
