Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 988706B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 15:05:46 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id r10so9159861pdi.22
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 12:05:46 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id o8si7284107pdr.159.2014.09.02.12.05.43
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 12:05:43 -0700 (PDT)
Message-ID: <54061505.8020500@sr71.net>
Date: Tue, 02 Sep 2014 12:05:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: regression caused by cgroups optimization in 3.17-rc2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

I'm seeing a pretty large regression in 3.17-rc2 vs 3.16 coming from the
memory cgroups code.  This is on a kernel with cgroups enabled at
compile time, but not _used_ for anything.  See the green lines in the
graph:

	https://www.sr71.net/~dave/intel/regression-from-05b843012.png

The workload is a little parallel microbenchmark doing page faults:

> https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault2.c

The hardware is an 8-socket Westmere box with 160 hardware threads.  For
some reason, this does not affect the version of the microbenchmark
which is doing completely anonymous page faults.

I bisected it down to this commit:

> commit 05b8430123359886ef6a4146fba384e30d771b3f
> Author: Johannes Weiner <hannes@cmpxchg.org>
> Date:   Wed Aug 6 16:05:59 2014 -0700
> 
>     mm: memcontrol: use root_mem_cgroup res_counter
>     
>     Due to an old optimization to keep expensive res_counter changes at a
>     minimum, the root_mem_cgroup res_counter is never charged; there is no
>     limit at that level anyway, and any statistics can be generated on
>     demand by summing up the counters of all other cgroups.
>     
>     However, with per-cpu charge caches, res_counter operations do not even
>     show up in profiles anymore, so this optimization is no longer
>     necessary.
>     
>     Remove it to simplify the code.

It does not revert cleanly because of the hunks below.  The code in
those hunks was removed, so I tried running without properly merging
them and it spews warnings because counter->usage is seen going negative.

So, it doesn't appear we can quickly revert this.

> --- mm/memcontrol.c
> +++ mm/memcontrol.c
> @@ -3943,7 +3947,7 @@
>          * replacement page, so leave it alone when phasing out the
>          * page that is unused after the migration.
>          */
> -       if (!end_migration)
> +       if (!end_migration && !mem_cgroup_is_root(memcg))
>                 mem_cgroup_do_uncharge(memcg, nr_pages, ctype);
>  
>         return memcg;
> @@ -4076,7 +4080,8 @@
>                  * We uncharge this because swap is freed.  This memcg can
>                  * be obsolete one. We avoid calling css_tryget_online().
>                  */
> -               res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +               if (!mem_cgroup_is_root(memcg))
> +                       res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>                 mem_cgroup_swap_statistics(memcg, false);
>                 css_put(&memcg->css);
>         }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
