Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5B36B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:19:05 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l8so694398wre.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:19:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l140si393984wmb.43.2017.10.19.23.19.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 23:19:04 -0700 (PDT)
Date: Fri, 20 Oct 2017 08:19:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171020061902.sqz5vklhtqrawelf@dhcp22.suse.cz>
References: <20171019222507.2894-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019222507.2894-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 19-10-17 15:25:07, Shakeel Butt wrote:
> lru_add_drain_all() is not required by mlock() and it will drain
> everything that has been cached at the time mlock is called. And
> that is not really related to the memory which will be faulted in
> (and cached) and mlocked by the syscall itself.
> 
> Without lru_add_drain_all() the mlocked pages can remain on pagevecs
> and be moved to evictable LRUs. However they will eventually be moved
> back to unevictable LRU by reclaim. So, we can safely remove
> lru_add_drain_all() from mlock syscall. Also there is no need for
> local lru_add_drain() as it will be called deep inside __mm_populate()
> (in follow_page_pte()).

This paragraph can be still a bit confusing. I suspect you meant to say
something like: "If anything lru_add_drain_all" should be called _after_
pages have been mlocked and faulted in but even that is not strictly
needed because those pages would get to the appropriate LRUs lazily
during the reclaim path. Moreover follow_page_pte (gup) will drain the
local pcp LRU cache."

> On larger machines the overhead of lru_add_drain_all() in mlock() can
> be significant when mlocking data already in memory. We have observed
> high latency in mlock() due to lru_add_drain_all() when the users
> were mlocking in memory tmpfs files.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Anyway, this patch makes a lot of sense to me. Feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changelog since v1:
> - updated commit message
> 
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
> 2.15.0.rc0.271.g36b669edcc-goog
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
