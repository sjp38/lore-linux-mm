Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4076B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:12:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y5so12991881pgq.15
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:12:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a10si9702796pgf.48.2017.10.30.02.12.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 02:12:50 -0700 (PDT)
Subject: Re: [PATCH v2] mm: mlock: remove lru_add_drain_all()
References: <20171019222507.2894-1-shakeelb@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fce63066-1c01-26fd-e767-d72c6f8fb2bb@suse.cz>
Date: Mon, 30 Oct 2017 10:12:46 +0100
MIME-Version: 1.0
In-Reply-To: <20171019222507.2894-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/20/2017 12:25 AM, Shakeel Butt wrote:
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
> 
> On larger machines the overhead of lru_add_drain_all() in mlock() can
> be significant when mlocking data already in memory. We have observed
> high latency in mlock() due to lru_add_drain_all() when the users
> were mlocking in memory tmpfs files.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
