Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 271746B0261
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:32:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a32so3959184wrc.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:32:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b200si983744wme.254.2017.10.19.05.32.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:32:09 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:32:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171019123206.3etacullgnarbnad@dhcp22.suse.cz>
References: <20171018231730.42754-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018231730.42754-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-10-17 16:17:30, Shakeel Butt wrote:
> Recently we have observed high latency in mlock() in our generic
> library and noticed that users have started using tmpfs files even
> without swap and the latency was due to expensive remote LRU cache
> draining.

some numbers would be really nice
 
> Is lru_add_drain_all() required by mlock()? The answer is no and the
> reason it is still in mlock() is to rapidly move mlocked pages to
> unevictable LRU.

Is this really true? lru_add_drain_all will flush the previously cached
LRU pages. We are not flushing after the pages have been faulted in so
this might not do anything wrt. mlocked pages, right?

> Without lru_add_drain_all() the mlocked pages which
> were on pagevec at mlock() time will be moved to evictable LRUs but
> will eventually be moved back to unevictable LRU by reclaim. So, we
> can safely remove lru_add_drain_all() from mlock(). Also there is no
> need for local lru_add_drain() as it will be called deep inside
> __mm_populate() (in follow_page_pte()).

Anyway, I do agree that lru_add_drain_all here is pointless. Either we
should drain after the memory has been faulted in and mlocked or not at
all. So the patch looks good to me I am just not sure about the
changelog.
 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/mlock.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index dfc6f1912176..3ceb2935d1e0 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -669,8 +669,6 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
>  	if (!can_do_mlock())
>  		return -EPERM;
>  
> -	lru_add_drain_all();	/* flush pagevec */
> -
>  	len = PAGE_ALIGN(len + (offset_in_page(start)));
>  	start &= PAGE_MASK;
>  
> @@ -797,9 +795,6 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (!can_do_mlock())
>  		return -EPERM;
>  
> -	if (flags & MCL_CURRENT)
> -		lru_add_drain_all();	/* flush pagevec */
> -
>  	lock_limit = rlimit(RLIMIT_MEMLOCK);
>  	lock_limit >>= PAGE_SHIFT;
>  
> -- 
> 2.15.0.rc1.287.g2b38de12cc-goog
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
