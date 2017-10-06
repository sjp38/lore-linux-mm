Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55A226B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 03:59:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14so8296360wre.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 00:59:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r65si880307wmr.160.2017.10.06.00.59.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 00:59:02 -0700 (PDT)
Date: Fri, 6 Oct 2017 09:59:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005222144.123797-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 15:21:44, Shakeel Butt wrote:
> The allocations from filp and names kmem caches can be directly
> triggered by user space applications. A buggy application can
> consume a significant amount of unaccounted system memory. Though
> we have not noticed such buggy applications in our production
> but upon close inspection, we found that a lot of machines spend
> very significant amount of memory on these caches. So, these
> caches should be accounted to kmemcg.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  fs/dcache.c     | 2 +-
>  fs/file_table.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index f90141387f01..fb3449161063 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -3642,7 +3642,7 @@ void __init vfs_caches_init_early(void)
>  void __init vfs_caches_init(void)
>  {
>  	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);

I might be wrong but isn't name cache only holding temporary objects
used for path resolution which are not stored anywhere?

>  
>  	dcache_init();
>  	inode_init();
> diff --git a/fs/file_table.c b/fs/file_table.c
> index 61517f57f8ef..567888cdf7d3 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -312,7 +312,7 @@ void put_filp(struct file *file)
>  void __init files_init(void)
>  {
>  	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
> -			SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> +			SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
>  	percpu_counter_init(&nr_files, 0, GFP_KERNEL);
>  }

Don't we have a limit for the maximum number of open files?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
