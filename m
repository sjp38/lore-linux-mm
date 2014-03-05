Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0966B00B6
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 04:27:12 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so397043bkj.24
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 01:27:11 -0800 (PST)
Received: from zivm-wwu3.uni-muenster.de (ZIVM-WWU3-1.UNI-MUENSTER.DE. [128.176.192.17])
        by mx.google.com with ESMTP id zj7si1850469bkb.285.2014.03.05.01.27.09
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 01:27:10 -0800 (PST)
From: Markus Blank-Burian <burian@muenster.de>
Subject: Re: [PATCH 1/2] memcg: reparent charges of children before processing parent
Date: Wed, 05 Mar 2014 10:27:08 +0100
Message-ID: <1645786.OfqIDFbIrl@akheu22.uni-muenster.de>
In-Reply-To: <alpine.LSU.2.11.1402121500070.5029@eggly.anvils>
References: <alpine.LSU.2.11.1402121500070.5029@eggly.anvils>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I wanted to give you small feedback, that this patch successfully fixes the 
problem with reparent_charges on our cluster. Thank you very much for finding 
and fixing this one!


On Wednesday 12 February 2014 15:03:31 Hugh Dickins wrote:
> From: Filipe Brandenburger <filbranden@google.com>
> 
> Sometimes the cleanup after memcg hierarchy testing gets stuck in
> mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> 
> There may turn out to be several causes, but a major cause is this: the
> workitem to offline parent can get run before workitem to offline child;
> parent's mem_cgroup_reparent_charges() circles around waiting for the
> child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> which prevents the child from reaching its mem_cgroup_reparent_charges().
> 
> Further testing showed that an ordered workqueue for cgroup_destroy_wq
> is not always good enough: percpu_ref_kill_and_confirm's call_rcu_sched
> stage on the way can mess up the order before reaching the workqueue.
> 
> Instead, when offlining a memcg, call mem_cgroup_reparent_charges() on
> all its children (and grandchildren, in the correct order) to have their
> charges reparented first.
> 
> Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup
> destruction") Signed-off-by: Filipe Brandenburger <filbranden@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # v3.10+ (but will need extra care)
> ---
> Or, you may prefer my alternative cgroup.c approach in 2/2:
> there's no need for both.  Please note that neither of these patches
> attempts to handle the unlikely case of racy charges made to child
> after its offline, but parent's offline coming before child's free:
> mem_cgroup_css_free()'s backstop call to mem_cgroup_reparent_charges()
> cannot help in that case, with or without these patches.  Fixing that
> would have to be a separate effort - Michal's?
> 
>  mm/memcontrol.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> --- 3.14-rc2/mm/memcontrol.c	2014-02-02 18:49:07.897302115 -0800
> +++ linux/mm/memcontrol.c	2014-02-11 17:48:07.604582963 -0800
> @@ -6595,6 +6595,7 @@ static void mem_cgroup_css_offline(struc
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_event *event, *tmp;
> +	struct cgroup_subsys_state *iter;
> 
>  	/*
>  	 * Unregister events and notify userspace.
> @@ -6611,7 +6612,14 @@ static void mem_cgroup_css_offline(struc
>  	kmem_cgroup_css_offline(memcg);
> 
>  	mem_cgroup_invalidate_reclaim_iterators(memcg);
> -	mem_cgroup_reparent_charges(memcg);
> +
> +	/*
> +	 * This requires that offlining is serialized.  Right now that is
> +	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
> +	 */
> +	css_for_each_descendant_post(iter, css)
> +		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
> +
>  	mem_cgroup_destroy_all_caches(memcg);
>  	vmpressure_cleanup(&memcg->vmpressure);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
