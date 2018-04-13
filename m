Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3536B0030
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:35:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so1576066pgv.12
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:35:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j123sor1280778pgc.312.2018.04.13.06.35.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 06:35:26 -0700 (PDT)
Date: Fri, 13 Apr 2018 22:35:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305133743.12746-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Mar 05, 2018 at 01:37:43PM +0000, Roman Gushchin wrote:
> I was reported about suspicious growth of unreclaimable slabs
> on some machines. I've found that it happens on machines
> with low memory pressure, and these unreclaimable slabs
> are external names attached to dentries.
> 
> External names are allocated using generic kmalloc() function,
> so they are accounted as unreclaimable. But they are held
> by dentries, which are reclaimable, and they will be reclaimed
> under the memory pressure.
> 
> In particular, this breaks MemAvailable calculation, as it
> doesn't take unreclaimable slabs into account.
> This leads to a silly situation, when a machine is almost idle,
> has no memory pressure and therefore has a big dentry cache.
> And the resulting MemAvailable is too low to start a new workload.
> 
> To address the issue, the NR_INDIRECTLY_RECLAIMABLE_BYTES counter
> is used to track the amount of memory, consumed by external names.
> The counter is increased in the dentry allocation path, if an external
> name structure is allocated; and it's decreased in the dentry freeing
> path.
> 
> To reproduce the problem I've used the following Python script:
>   import os
> 
>   for iter in range (0, 10000000):
>       try:
>           name = ("/some_long_name_%d" % iter) + "_" * 220
>           os.stat(name)
>       except Exception:
>           pass
> 
> Without this patch:
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7811688 kB
>   $ python indirect.py
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    2753052 kB
> 
> With the patch:
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7809516 kB
>   $ python indirect.py
>   $ cat /proc/meminfo | grep MemAvailable
>   MemAvailable:    7749144 kB
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---
>  fs/dcache.c | 29 ++++++++++++++++++++++++-----
>  1 file changed, 24 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 5c7df1df81ff..a0312d73f575 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -273,8 +273,16 @@ static void __d_free(struct rcu_head *head)
>  static void __d_free_external(struct rcu_head *head)
>  {
>  	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
> -	kfree(external_name(dentry));
> -	kmem_cache_free(dentry_cache, dentry); 
> +	struct external_name *name = external_name(dentry);
> +	unsigned long bytes;
> +
> +	bytes = dentry->d_name.len + offsetof(struct external_name, name[1]);
> +	mod_node_page_state(page_pgdat(virt_to_page(name)),
> +			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
> +			    -kmalloc_size(kmalloc_index(bytes)));
> +
> +	kfree(name);
> +	kmem_cache_free(dentry_cache, dentry);
>  }
>  
>  static inline int dname_external(const struct dentry *dentry)
> @@ -1598,6 +1606,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>  	struct dentry *dentry;
>  	char *dname;
>  	int err;
> +	size_t reclaimable = 0;
>  
>  	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
>  	if (!dentry)
> @@ -1614,9 +1623,11 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>  		name = &slash_name;
>  		dname = dentry->d_iname;
>  	} else if (name->len > DNAME_INLINE_LEN-1) {
> -		size_t size = offsetof(struct external_name, name[1]);
> -		struct external_name *p = kmalloc(size + name->len,
> -						  GFP_KERNEL_ACCOUNT);
> +		struct external_name *p;
> +
> +		reclaimable = offsetof(struct external_name, name[1]) +
> +			name->len;
> +		p = kmalloc(reclaimable, GFP_KERNEL_ACCOUNT);

Can't we use kmem_cache_alloc with own cache created with SLAB_RECLAIM_ACCOUNT
if they are reclaimable? 
With that, it would help fragmentation problem with __GFP_RECLAIMABLE for
page allocation as well as counting problem, IMHO.


>  		if (!p) {
>  			kmem_cache_free(dentry_cache, dentry); 
>  			return NULL;
> @@ -1665,6 +1676,14 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>  		}
>  	}
>  
> +	if (unlikely(reclaimable)) {
> +		pg_data_t *pgdat;
> +
> +		pgdat = page_pgdat(virt_to_page(external_name(dentry)));
> +		mod_node_page_state(pgdat, NR_INDIRECTLY_RECLAIMABLE_BYTES,
> +				    kmalloc_size(kmalloc_index(reclaimable)));
> +	}
> +
>  	this_cpu_inc(nr_dentry);
>  
>  	return dentry;
> -- 
> 2.14.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
