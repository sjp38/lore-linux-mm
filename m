Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA2B6B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:06:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w67so6900275wmd.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 07:06:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si5182596wra.71.2017.02.27.07.06.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 07:06:53 -0800 (PST)
Date: Mon, 27 Feb 2017 16:06:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170227150649.GI26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 24-02-17 13:31:49, Shaohua Li wrote:
> show MADV_FREE pages info of each vma in smaps. The interface is for
> diganose or monitoring purpose, userspace could use it to understand
> what happens in the application. Since userspace could dirty MADV_FREE
> pages without notice from kernel, this interface is the only place we
> can get accurate accounting info about MADV_FREE pages.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  Documentation/filesystems/proc.txt | 4 ++++
>  fs/proc/task_mmu.c                 | 8 +++++++-
>  2 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index c94b467..45853e1 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -412,6 +412,7 @@ Private_Clean:         0 kB
>  Private_Dirty:         0 kB
>  Referenced:          892 kB
>  Anonymous:             0 kB
> +LazyFree:              0 kB
>  AnonHugePages:         0 kB
>  ShmemPmdMapped:        0 kB
>  Shared_Hugetlb:        0 kB
> @@ -441,6 +442,9 @@ accessed.
>  "Anonymous" shows the amount of memory that does not belong to any file.  Even
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
> +"LazyFree" shows the amount of memory which is marked by madvise(MADV_FREE).
> +The memory isn't freed immediately with madvise(). It's freed in memory
> +pressure if the memory is clean.
>  "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
>  "ShmemPmdMapped" shows the ammount of shared (shmem/tmpfs) memory backed by
>  huge pages.
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ee3efb2..8a5ec00 100644
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
> +		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
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
