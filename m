Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D53FC6B041C
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:31:39 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n136so14021948lfn.13
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:31:39 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id r75si1285767lfi.366.2017.06.21.09.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 09:31:38 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l200so10895034lfg.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:31:37 -0700 (PDT)
Date: Wed, 21 Jun 2017 19:31:34 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] fs/dcache.c: fix spin lockup issue on nlru->lock
Message-ID: <20170621163134.GA3273@esperanza>
References: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
 <1498027155-4456-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498027155-4456-1-git-send-email-stummala@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Jun 21, 2017 at 12:09:15PM +0530, Sahitya Tummala wrote:
> __list_lru_walk_one() acquires nlru spin lock (nlru->lock) for
> longer duration if there are more number of items in the lru list.
> As per the current code, it can hold the spin lock for upto maximum
> UINT_MAX entries at a time. So if there are more number of items in
> the lru list, then "BUG: spinlock lockup suspected" is observed in
> the below path -
> 
> [<ffffff8eca0fb0bc>] spin_bug+0x90
> [<ffffff8eca0fb220>] do_raw_spin_lock+0xfc
> [<ffffff8ecafb7798>] _raw_spin_lock+0x28
> [<ffffff8eca1ae884>] list_lru_add+0x28
> [<ffffff8eca1f5dac>] dput+0x1c8
> [<ffffff8eca1eb46c>] path_put+0x20
> [<ffffff8eca1eb73c>] terminate_walk+0x3c
> [<ffffff8eca1eee58>] path_lookupat+0x100
> [<ffffff8eca1f00fc>] filename_lookup+0x6c
> [<ffffff8eca1f0264>] user_path_at_empty+0x54
> [<ffffff8eca1e066c>] SyS_faccessat+0xd0
> [<ffffff8eca084e30>] el0_svc_naked+0x24
> 
> This nlru->lock is acquired by another CPU in this path -
> 
> [<ffffff8eca1f5fd0>] d_lru_shrink_move+0x34
> [<ffffff8eca1f6180>] dentry_lru_isolate_shrink+0x48
> [<ffffff8eca1aeafc>] __list_lru_walk_one.isra.10+0x94
> [<ffffff8eca1aec34>] list_lru_walk_node+0x40
> [<ffffff8eca1f6620>] shrink_dcache_sb+0x60
> [<ffffff8eca1e56a8>] do_remount_sb+0xbc
> [<ffffff8eca1e583c>] do_emergency_remount+0xb0
> [<ffffff8eca0ba510>] process_one_work+0x228
> [<ffffff8eca0bb158>] worker_thread+0x2e0
> [<ffffff8eca0c040c>] kthread+0xf4
> [<ffffff8eca084dd0>] ret_from_fork+0x10
> 
> Fix this lockup by reducing the number of entries to be shrinked
> from the lru list to 1024 at once. Also, add cond_resched() before
> processing the lru list again.
> 
> Link: http://marc.info/?t=149722864900001&r=1&w=2
> Fix-suggested-by: Jan kara <jack@suse.cz>
> Fix-suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>
> ---
> v2: patch shrink_dcache_sb() instead of list_lru_walk()
> ---
>  fs/dcache.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index cddf397..c8ca150 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1133,10 +1133,11 @@ void shrink_dcache_sb(struct super_block *sb)
>  		LIST_HEAD(dispose);
>  
>  		freed = list_lru_walk(&sb->s_dentry_lru,
> -			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
> +			dentry_lru_isolate_shrink, &dispose, 1024);
>  
>  		this_cpu_sub(nr_dentry_unused, freed);
>  		shrink_dentry_list(&dispose);
> +		cond_resched();
>  	} while (freed > 0);

In an extreme case, a single invocation of list_lru_walk() can skip all
1024 dentries, in which case 'freed' will be 0 forcing us to break the
loop prematurely. I think we should loop until there's at least one
dentry left on the LRU, i.e.

	while (list_lru_count(&sb->s_dentry_lru) > 0)

However, even that wouldn't be quite correct, because list_lru_count()
iterates over all memory cgroups to sum list_lru_one->nr_items, which
can race with memcg offlining code migrating dentries off a dead cgroup
(see memcg_drain_all_list_lrus()). So it looks like to make this check
race-free, we need to account the number of entries on the LRU not only
per memcg, but also per node, i.e. add list_lru_node->nr_items.
Fortunately, list_lru entries can't be migrated between NUMA nodes.

>  }
>  EXPORT_SYMBOL(shrink_dcache_sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
