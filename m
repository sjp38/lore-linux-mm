Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63D826B038A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 21:47:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v63so107137386pgv.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 18:47:28 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x17si23830323pfk.215.2017.02.21.18.47.26
        for <linux-mm@kvack.org>;
        Tue, 21 Feb 2017 18:47:27 -0800 (PST)
Date: Wed, 22 Feb 2017 11:47:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 6/7] proc: show MADV_FREE pages info in smaps
Message-ID: <20170222024721.GA17580@blaptop>
References: <cover.1486163864.git.shli@fb.com>
 <1239fb2871c55d63e7e649ad14c6dabaef131d66.1486163864.git.shli@fb.com>
MIME-Version: 1.0
In-Reply-To: <1239fb2871c55d63e7e649ad14c6dabaef131d66.1486163864.git.shli@fb.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 03, 2017 at 03:33:22PM -0800, Shaohua Li wrote:
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  fs/proc/task_mmu.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ee3efb2..8f2423f 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -440,6 +440,7 @@ struct mem_size_stats {
>  	unsigned long private_dirty;
>  	unsigned long referenced;
>  	unsigned long anonymous;
> +	unsigned long lazyfree;
>  	unsigned long anonymous_thp;
>  	unsigned long shmem_thp;
>  	unsigned long swap;
> @@ -456,8 +457,11 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  	int i, nr = compound ? 1 << compound_order(page) : 1;
>  	unsigned long size = nr * PAGE_SIZE;
>  
> -	if (PageAnon(page))
> +	if (PageAnon(page)) {
>  		mss->anonymous += size;
> +		if (!PageSwapBacked(page))

How about this?

		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))

> +			mss->lazyfree += size;
> +	}
>  
>  	mss->resident += size;
>  	/* Accumulate the size in pages that have been accessed. */
> @@ -770,6 +774,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   "Private_Dirty:  %8lu kB\n"
>  		   "Referenced:     %8lu kB\n"
>  		   "Anonymous:      %8lu kB\n"
> +		   "LazyFree:       %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
>  		   "ShmemPmdMapped: %8lu kB\n"
>  		   "Shared_Hugetlb: %8lu kB\n"
> @@ -788,6 +793,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   mss.private_dirty >> 10,
>  		   mss.referenced >> 10,
>  		   mss.anonymous >> 10,
> +		   mss.lazyfree >> 10,
>  		   mss.anonymous_thp >> 10,
>  		   mss.shmem_thp >> 10,
>  		   mss.shared_hugetlb >> 10,
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
