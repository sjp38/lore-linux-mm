Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 817396B0088
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 12:40:25 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o8GGeJEO013668
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:40:20 -0700
Received: from gwj20 (gwj20.prod.google.com [10.200.10.20])
	by wpaz37.hot.corp.google.com with ESMTP id o8GGeCdM031790
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:40:18 -0700
Received: by gwj20 with SMTP id 20so773360gwj.25
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 09:40:18 -0700 (PDT)
Date: Thu, 16 Sep 2010 09:40:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Export amount of anonymous memory in a mapping via
 smaps
In-Reply-To: <201009160856.25923.knikanth@suse.de>
Message-ID: <alpine.DEB.2.00.1009160927110.24798@tigran.mtv.corp.google.com>
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com> <1284579969.21906.451.camel@calx> <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009160856.25923.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010, Nikanth Karthikesan wrote:

> Export the number of anonymous pages in a mapping via smaps.
> 
> Even the private pages in a mapping backed by a file, would be marked as
> anonymous, when they are modified. Export this information to user-space via
> smaps.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

Acked-by: Hugh Dickins <hughd@google.com>

but I'd prefer if we added a little more justification, such as:

Exporting this count will help gdb to make a better decision on which
areas need to be dumped in its coredump; and should be useful to others
studying the memory usage of a process.

> 
> ---
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 439fc1f..3c18fc8 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -326,6 +326,7 @@ struct mem_size_stats {
>  	unsigned long private_clean;
>  	unsigned long private_dirty;
>  	unsigned long referenced;
> +	unsigned long anonymous;
>  	unsigned long swap;
>  	u64 pss;
>  };
> @@ -356,6 +357,9 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  		if (!page)
>  			continue;
>  
> +		if (PageAnon(page))
> +			mss->anonymous += PAGE_SIZE;
> +
>  		mss->resident += PAGE_SIZE;
>  		/* Accumulate the size in pages that have been accessed. */
>  		if (pte_young(ptent) || PageReferenced(page))
> @@ -409,6 +413,7 @@ static int show_smap(struct seq_file *m, void *v)
>  		   "Private_Clean:  %8lu kB\n"
>  		   "Private_Dirty:  %8lu kB\n"
>  		   "Referenced:     %8lu kB\n"
> +		   "Anonymous:      %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
>  		   "MMUPageSize:    %8lu kB\n",
> @@ -420,6 +425,7 @@ static int show_smap(struct seq_file *m, void *v)
>  		   mss.private_clean >> 10,
>  		   mss.private_dirty >> 10,
>  		   mss.referenced >> 10,
> +		   mss.anonymous >> 10,
>  		   mss.swap >> 10,
>  		   vma_kernel_pagesize(vma) >> 10,
>  		   vma_mmu_pagesize(vma) >> 10);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
