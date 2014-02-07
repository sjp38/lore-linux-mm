Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id ADCC06B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 08:45:35 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id q58so2325716wes.35
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 05:45:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk7si2321125wjb.30.2014.02.07.05.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 05:45:33 -0800 (PST)
Date: Fri, 7 Feb 2014 14:45:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140207134533.GC5121@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 06-02-14 15:56:01, Hugh Dickins wrote:
> Sometimes the cleanup after memcg hierarchy testing gets stuck in
> mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> 
> There may turn out to be several causes, but a major cause is this: the
> workitem to offline parent can get run before workitem to offline child;
> parent's mem_cgroup_reparent_charges() circles around waiting for the
> child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> which prevents the child from reaching its mem_cgroup_reparent_charges().
> 
> Just use an ordered workqueue for cgroup_destroy_wq.

Hmm, interesting. Markus has seen hangs even with mem_cgroup_css_offline
and the referenced cgroup fixes, maybe this is the the right one
finally.

> Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
> Suggested-by: Filipe Brandenburger <filbranden@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # 3.10+

Reviewed-by: Michal Hocko <mhocko@suse.cz>

e5fca243abae was marked for 3.9 stable but I do not see it in the Greg's
3.9 stable branch so 3.10+ seems to be sufficient.

> ---
> 
>  kernel/cgroup.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- 3.14-rc1/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
> +++ linux/kernel/cgroup.c	2014-02-06 15:20:35.548904965 -0800
> @@ -4845,12 +4845,12 @@ static int __init cgroup_wq_init(void)
>  	/*
>  	 * There isn't much point in executing destruction path in
>  	 * parallel.  Good chunk is serialized with cgroup_mutex anyway.
> -	 * Use 1 for @max_active.
> +	 * Must be ordered to make sure parent is offlined after children.
>  	 *
>  	 * We would prefer to do this in cgroup_init() above, but that
>  	 * is called before init_workqueues(): so leave this until after.
>  	 */
> -	cgroup_destroy_wq = alloc_workqueue("cgroup_destroy", 0, 1);
> +	cgroup_destroy_wq = alloc_ordered_workqueue("cgroup_destroy", 0);
>  	BUG_ON(!cgroup_destroy_wq);
>  
>  	/*

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
