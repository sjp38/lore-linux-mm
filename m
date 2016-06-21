Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1182B828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 06:17:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g8so16500145itb.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 03:17:03 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0130.outbound.protection.outlook.com. [157.55.234.130])
        by mx.google.com with ESMTPS id e54si4522600otd.206.2016.06.21.03.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 03:17:02 -0700 (PDT)
Date: Tue, 21 Jun 2016 13:16:51 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/3] mm: memcontrol: fix cgroup creation failure after
 many small jobs
Message-ID: <20160621101650.GD15970@esperanza>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
 <20160617162516.GD19084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160617162516.GD19084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jun 17, 2016 at 12:25:16PM -0400, Johannes Weiner wrote:
> The memory controller has quite a bit of state that usually outlives
> the cgroup and pins its CSS until said state disappears. At the same
> time it imposes a 16-bit limit on the CSS ID space to economically
> store IDs in the wild. Consequently, when we use cgroups to contain
> frequent but small and short-lived jobs that leave behind some page
> cache, we quickly run into the 64k limitations of outstanding CSSs.
> Creating a new cgroup fails with -ENOSPC while there are only a few,
> or even no user-visible cgroups in existence.
> 
> Although pinning CSSs past cgroup removal is common, there are only
> two instances that actually need an ID after a cgroup is deleted:
> cache shadow entries and swapout records.
> 
> Cache shadow entries reference the ID weakly and can deal with the CSS
> having disappeared when it's looked up later. They pose no hurdle.
> 
> Swap-out records do need to pin the css to hierarchically attribute
> swapins after the cgroup has been deleted; though the only pages that
> remain swapped out after offlining are tmpfs/shmem pages. And those
> references are under the user's control, so they are manageable.
> 
> This patch introduces a private 16-bit memcg ID and switches swap and
> cache shadow entries over to using that. This ID can then be recycled
> after offlining when the CSS remains pinned only by objects that don't
> specifically need it.
> 
> This script demonstrates the problem by faulting one cache page in a
> new cgroup and deleting it again:
> 
> set -e
> mkdir -p pages
> for x in `seq 128000`; do
>   [ $((x % 1000)) -eq 0 ] && echo $x
>   mkdir /cgroup/foo
>   echo $$ >/cgroup/foo/cgroup.procs
>   echo trex >pages/$x
>   echo $$ >/cgroup/cgroup.procs
>   rmdir /cgroup/foo
> done
> 
> When run on an unpatched kernel, we eventually run out of possible IDs
> even though there are no visible cgroups:
> 
> [root@ham ~]# ./cssidstress.sh
> [...]
> 65000
> mkdir: cannot create directory '/cgroup/foo': No space left on device
> 
> After this patch, the IDs get released upon cgroup destruction and the
> cache and css objects get released once memory reclaim kicks in.

With 65K cgroups it will take the reclaimer a substantial amount of time
to iterate over all of them, which might result in latency spikes.
Probably, to avoid that, we could move pages from a dead cgroup's lru to
its parent's one on offline while still leaving dead cgroups pinned,
like we do in case of list_lru entries.

> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

One nit below.

...
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 75e74408cc8f..dc92b2df2585 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4057,6 +4057,60 @@ static struct cftype mem_cgroup_legacy_files[] = {
>  	{ },	/* terminate */
>  };
>  
> +/*
> + * Private memory cgroup IDR
> + *
> + * Swap-out records and page cache shadow entries need to store memcg
> + * references in constrained space, so we maintain an ID space that is
> + * limited to 16 bit (MEM_CGROUP_ID_MAX), limiting the total number of
> + * memory-controlled cgroups to 64k.
> + *
> + * However, there usually are many references to the oflline CSS after
> + * the cgroup has been destroyed, such as page cache or reclaimable
> + * slab objects, that don't need to hang on to the ID. We want to keep
> + * those dead CSS from occupying IDs, or we might quickly exhaust the
> + * relatively small ID space and prevent the creation of new cgroups
> + * even when there are much fewer than 64k cgroups - possibly none.
> + *
> + * Maintain a private 16-bit ID space for memcg, and allow the ID to
> + * be freed and recycled when it's no longer needed, which is usually
> + * when the CSS is offlined.
> + *
> + * The only exception to that are records of swapped out tmpfs/shmem
> + * pages that need to be attributed to live ancestors on swapin. But
> + * those references are manageable from userspace.
> + */
> +
> +static struct idr mem_cgroup_idr;

static DEFINE_IDR(mem_cgroup_idr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
