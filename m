Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id F075B6B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 17:37:20 -0500 (EST)
Date: Wed, 18 Jan 2012 14:37:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] SHM_UNLOCK: fix long unpreemptible section
Message-Id: <20120118143718.663b8cf5.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1201141615440.1338@eggly.anvils>
References: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils>
	<alpine.LSU.2.00.1201141615440.1338@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Sat, 14 Jan 2012 16:18:43 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
> evictable again once the shared memory is unlocked.  It does this with
> pagevec_lookup()s across the whole object (which might occupy most of
> memory), and takes 300ms to unlock 7GB here.  A cond_resched() every
> PAGEVEC_SIZE pages would be good.
> 
> However, KOSAKI-san points out that this is called under shmem.c's
> info->lock, and it's also under shm.c's shm_lock(), both spinlocks.
> There is no strong reason for that: we need to take these pages off
> the unevictable list soonish, but those locks are not required for it.
> 
> So move the call to scan_mapping_unevictable_pages() from shmem.c's
> unlock handling up to shm.c's unlock handling.  Remove the recently
> added barrier, not needed now we have spin_unlock() before the scan.
> 
> Use get_file(), with subsequent fput(), to make sure we have a
> reference to mapping throughout scan_mapping_unevictable_pages():
> that's something that was previously guaranteed by the shm_lock().
> 
> Remove shmctl's lru_add_drain_all(): we don't fault in pages at
> SHM_LOCK time, and we lazily discover them to be Unevictable later,
> so it serves no purpose for SHM_LOCK; and serves no purpose for
> SHM_UNLOCK, since pages still on pagevec are not marked Unevictable.
> 
> The original code avoided redundant rescans by checking VM_LOCKED
> flag at its level: now avoid them by checking shp's SHM_LOCKED.
> 
> The original code called scan_mapping_unevictable_pages() on a
> locked area at shm_destroy() time: perhaps we once had accounting
> cross-checks which required that, but not now, so skip the overhead
> and just let inode eviction deal with them.
> 
> Put check_move_unevictable_page() and scan_mapping_unevictable_pages()
> under CONFIG_SHMEM (with stub for the TINY case when ramfs is used),
> more as comment than to save space; comment them used for SHM_UNLOCK.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: stable@vger.kernel.org [back to 2.6.32 but will need respins]

Is -stable backporting really warranted?  AFAICT the only thing we're
fixing here is a long latency glitch during a rare operation on large
machines.  Usually it will be on only one CPU, too.

"[PATCH 2/2] SHM_UNLOCK: fix Unevictable pages stranded after swap"
does loko like -stable material, so omitting 1/1 will probably screw
things up :(


> Resend in the hope that it can get into 3.3.

That we can do ;)

>
> ...
>
> --- mmotm.orig/mm/vmscan.c	2012-01-06 10:04:54.000000000 -0800
> +++ mmotm/mm/vmscan.c	2012-01-06 10:06:13.941943604 -0800
> @@ -3499,6 +3499,7 @@ int page_evictable(struct page *page, st
>  	return 1;
>  }
>  
> +#ifdef CONFIG_SHMEM
>  /**
>   * check_move_unevictable_page - check page for evictability and move to appropriate zone lru list
>   * @page: page to check evictability and move to appropriate lru list
> @@ -3509,6 +3510,8 @@ int page_evictable(struct page *page, st
>   *
>   * Restrictions: zone->lru_lock must be held, page must be on LRU and must
>   * have PageUnevictable set.
> + *
> + * This function is only used for SysV IPC SHM_UNLOCK.
>   */
>  static void check_move_unevictable_page(struct page *page, struct zone *zone)
>  {
> @@ -3545,6 +3548,8 @@ retry:
>   *
>   * Scan all pages in mapping.  Check unevictable pages for
>   * evictability and move them to the appropriate zone lru list.
> + *
> + * This function is only used for SysV IPC SHM_UNLOCK.
>   */
>  void scan_mapping_unevictable_pages(struct address_space *mapping)
>  {
> @@ -3590,9 +3595,14 @@ void scan_mapping_unevictable_pages(stru
>  		pagevec_release(&pvec);
>  
>  		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
> +		cond_resched();
>  	}
> -
>  }
> +#else
> +void scan_mapping_unevictable_pages(struct address_space *mapping)
> +{
> +}
> +#endif /* CONFIG_SHMEM */

Inlining the CONFIG_SHMEM=n stub would have been mroe efficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
