Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB72F6B0277
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:54:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l10so2425268wmg.5
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 00:54:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m30si1458725wrb.75.2017.10.12.00.54.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 00:54:52 -0700 (PDT)
Date: Thu, 12 Oct 2017 09:54:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] fs, mm: account filp cache to kmemcg
Message-ID: <20171012075451.3lfzctfusoctu3p2@dhcp22.suse.cz>
References: <20171011190359.34926-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011190359.34926-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 11-10-17 12:03:59, Shakeel Butt wrote:
> The allocations from filp cache can be directly triggered by user
> space applications. A buggy application can consume a significant
> amount of unaccounted system memory. Though we have not noticed
> such buggy applications in our production but upon close inspection,
> we found that a lot of machines spend very significant amount of
> memory on these caches.
> 
> One way to limit allocations from filp cache is to set system level
> limit of maximum number of open files. However this limit is shared
> between different users on the system and one user can hog this
> resource. To cater that, we can charge filp to kmemcg and set the
> maximum limit very high and let the memory limit of each user limit
> the number of files they can open and indirectly limiting their
> allocations from filp cache.
> 
> One side effect of this change is that it will allow _sysctl() to
> return ENOMEM and the man page of _sysctl() does not specify that.
> However the man page also discourages to use _sysctl() at all.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

OK, this makes more sense than the original patch. struct file is not
really large (248B on my system) so I am not sure how much this helps
though. Anyway, I have no objections to the patch but I do not feel
qualified to ack it either.

> ---
> 
> Changelog since v1:
> - removed names_cache charging to kmemcg
> 
>  fs/file_table.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
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
>  
> -- 
> 2.15.0.rc0.271.g36b669edcc-goog

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
