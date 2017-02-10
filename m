Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D282C6B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 08:30:42 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u65so12490501wrc.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:30:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m72si1196432wmc.159.2017.02.10.05.30.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 05:30:41 -0800 (PST)
Date: Fri, 10 Feb 2017 14:30:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 6/7] proc: show MADV_FREE pages info in smaps
Message-ID: <20170210133040.GN10893@dhcp22.suse.cz>
References: <cover.1486163864.git.shli@fb.com>
 <1239fb2871c55d63e7e649ad14c6dabaef131d66.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1239fb2871c55d63e7e649ad14c6dabaef131d66.1486163864.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

$DESCRIPTION_OF_YOUR_USECASE_GOES_HERE

Moreover Documentation/filesystems/proc.txt should be updated as well.

Other than that, the patch looks good to me.

On Fri 03-02-17 15:33:22, Shaohua Li wrote:
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

after the description is added and documentation updated
Acked-by: Michal Hocko <mhocko@suse.com>

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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
