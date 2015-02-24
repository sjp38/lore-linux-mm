Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id B84466B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:50:22 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so35564741iec.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:50:22 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id d8si2086246icw.60.2015.02.24.12.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 12:50:22 -0800 (PST)
Received: by iecvy18 with SMTP id vy18so35400954iec.13
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:50:22 -0800 (PST)
Date: Tue, 24 Feb 2015 12:50:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
In-Reply-To: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
Message-ID: <alpine.DEB.2.10.1502241245530.3855@chino.kir.corp.google.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, jweiner@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, loberman@redhat.com, lwoodman@redhat.com, raghavendra.kt@linux.vnet.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 24 Feb 2015, Rafael Aquini wrote:

> commit 6d2be915e589 ("mm/readahead.c: fix readahead failure for memoryless NUMA
> nodes and limit readahead pages")[1] imposed 2 mB hard limits to readahead by 
> changing max_sane_readahead() to sort out a corner case where a thread runs on 
> amemoryless NUMA node and it would have its readahead capability disabled.
> 
> The aforementioned change, despite fixing that corner case, is detrimental to
> other ordinary workloads that memory map big files and rely on readahead() or
> posix_fadvise(WILLNEED) syscalls to get most of the file populating system's cache.
> 
> Laurence Oberman reports, via https://bugzilla.redhat.com/show_bug.cgi?id=1187940,
> slowdowns up to 3-4 times when changes for mentioned commit [1] got introduced in
> RHEL kenrel. We also have an upstream bugzilla opened for similar complaint:
> https://bugzilla.kernel.org/show_bug.cgi?id=79111
> 
> This patch brings back the old behavior of max_sane_readahead() where we used to
> consider NR_INACTIVE_FILE and NR_FREE_PAGES pages to derive a sensible / adujstable
> readahead upper limit. This patch also keeps the 2 mB ceiling scheme introduced by
> commit [1] to avoid regressions on CONFIG_HAVE_MEMORYLESS_NODES systems,
> where numa_mem_id(), by any buggy reason, might end up not returning
> the 'local memory' for a memoryless node CPU.
> 
> Reported-by: Laurence Oberman <loberman@redhat.com>
> Tested-by: Laurence Oberman <loberman@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  mm/readahead.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 9356758..73f934d 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -203,6 +203,7 @@ out:
>  	return ret;
>  }
>  
> +#define MAX_READAHEAD   ((512 * 4096) / PAGE_CACHE_SIZE)
>  /*
>   * Chunk the readahead into 2 megabyte units, so that we don't pin too much
>   * memory at once.
> @@ -217,7 +218,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	while (nr_to_read) {
>  		int err;
>  
> -		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
> +		unsigned long this_chunk = MAX_READAHEAD;
>  
>  		if (this_chunk > nr_to_read)
>  			this_chunk = nr_to_read;
> @@ -232,14 +233,15 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	return 0;
>  }
>  
> -#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
>  /*
>   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
>   * sensible upper limit.
>   */
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
> -	return min(nr, MAX_READAHEAD);
> +	return min(nr, max(MAX_READAHEAD,
> +			  (node_page_state(numa_mem_id(), NR_INACTIVE_FILE) +
> +			   node_page_state(numa_mem_id(), NR_FREE_PAGES)) / 2));
>  }
>  
>  /*

I think Linus suggested avoiding the complexity here regarding any 
heuristics involving the per-node memory state, specifically in 
http://www.kernelhub.org/?msg=413344&p=2, and suggested the MAX_READAHEAD 
size.

If we are to go forward with this revert, then I believe the change to 
numa_mem_id() will fix the memoryless node issue as pointed out in that 
thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
