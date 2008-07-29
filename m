Date: Mon, 28 Jul 2008 20:31:08 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080728203108.256de0c4@cuia.bos.redhat.com>
In-Reply-To: <20080728171728.7d0452bc.akpm@linux-foundation.org>
References: <20080724222510.3bbbbedc@bree.surriel.com>
	<20080728105742.50d6514e@cuia.bos.redhat.com>
	<20080728164124.8240eabe.akpm@linux-foundation.org>
	<20080728195713.42cbceed@cuia.bos.redhat.com>
	<20080728200311.2218af4e@cuia.bos.redhat.com>
	<20080728171728.7d0452bc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 17:17:28 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

>         /*
> -        * Try to keep the active list 2/3 of the size of the cache.  And
> -        * make sure that refill_inactive is given a decent number of pages.
> -        *
> -        * The "scan_active + 1" here is important.  With pagecache-intensive
> -        * workloads the inactive list is huge, and `ratio' evaluates to zero
> -        * all the time.  Which pins the active list memory.  So we add one to

If the active list is so small that nr_active_file >> priority always
evaluates to 0, I suspect it won't hurt at all to keep it around.

After all, we now only scan once the (incrementing) scan number reaches
swap_cluster_max.

> -        * `scan_active' just to make sure that the kernel will slowly sift
> -        * through the active list.
> +        * Add one to `nr_to_scan' just to make sure that the kernel will
> +        * slowly sift through the active list.
>          */
> -       if (zone->nr_active >= 4*(zone->nr_inactive*2 + 1)) {
> -               /* Don't scan more than 4 times the inactive list scan size */
> -               scan_active = 4*scan_inactive;
> 
> (there was some regrettable information loss there).
> 
> Is the scenario which that fix addresses no longer possible?

I believe it is possible, but harmless.  Maybe even desired.

> On a different topic, I am staring in frustration at
> introduce-__get_user_pages.patch, which says:
> 
>   New munlock processing need to GUP_FLAGS_IGNORE_VMA_PERMISSIONS. 
>   because current get_user_pages() can't grab PROT_NONE pages theresore
>   it cause PROT_NONE pages can't munlock.
> 
> could someone please work out for me which of these patches:
> 
> vmscan-move-isolate_lru_page-to-vmscanc.patch
> vmscan-use-an-indexed-array-for-lru-variables.patch
> swap-use-an-array-for-the-lru-pagevecs.patch
> vmscan-free-swap-space-on-swap-in-activation.patch
> define-page_file_cache-function.patch
> vmscan-split-lru-lists-into-anon-file-sets.patch
> vmscan-second-chance-replacement-for-anonymous-pages.patch
> vmscan-fix-pagecache-reclaim-referenced-bit-check.patch
> vmscan-add-newly-swapped-in-pages-to-the-inactive-list.patch
> more-aggressively-use-lumpy-reclaim.patch
> pageflag-helpers-for-configed-out-flags.patch
> unevictable-lru-infrastructure.patch
> unevictable-lru-page-statistics.patch
> ramfs-and-ram-disk-pages-are-unevictable.patch
> shm_locked-pages-are-unevictable.patch
> mlock-mlocked-pages-are-unevictable.patch
> mlock-downgrade-mmap-sem-while-populating-mlocked-regions.patch
> mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> 
> that patch fixes?

I'll take a look later.  Time to drive home and eat dinner :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
