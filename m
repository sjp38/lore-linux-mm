Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A35206B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 13:18:20 -0400 (EDT)
Date: Wed, 19 Sep 2012 13:18:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm: clear_page_mlock in page_remove_rmap
Message-ID: <20120919171811.GR1560@cmpxchg.org>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
 <alpine.LSU.2.00.1209182053520.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209182053520.11632@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 18, 2012 at 08:55:21PM -0700, Hugh Dickins wrote:
> We had thought that pages could no longer get freed while still marked
> as mlocked; but Johannes Weiner posted this program to demonstrate that
> truncating an mlocked private file mapping containing COWed pages is
> still mishandled:
> 
> #include <sys/types.h>
> #include <sys/mman.h>
> #include <sys/stat.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <stdio.h>
> 
> int main(void)
> {
> 	char *map;
> 	int fd;
> 
> 	system("grep mlockfreed /proc/vmstat");
> 	fd = open("chigurh", O_CREAT|O_EXCL|O_RDWR);
> 	unlink("chigurh");
> 	ftruncate(fd, 4096);
> 	map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
> 	map[0] = 11;
> 	mlock(map, sizeof(fd));
> 	ftruncate(fd, 0);
> 	close(fd);
> 	munlock(map, sizeof(fd));
> 	munmap(map, 4096);
> 	system("grep mlockfreed /proc/vmstat");
> 	return 0;
> }
> 
> The anon COWed pages are not caught by truncation's clear_page_mlock()
> of the pagecache pages; but unmap_mapping_range() unmaps them, so we
> ought to look out for them there in page_remove_rmap().  Indeed, why
> should truncation or invalidation be doing the clear_page_mlock() when
> removing from pagecache?  mlock is a property of mapping in userspace,
> not a propertly of pagecache: an mlocked unmapped page is nonsensical.

property?

> --- 3.6-rc6.orig/mm/memory.c	2012-09-18 15:38:08.000000000 -0700
> +++ 3.6-rc6/mm/memory.c	2012-09-18 17:51:02.871288773 -0700
> @@ -1576,12 +1576,12 @@ split_fallthrough:
>  		if (page->mapping && trylock_page(page)) {
>  			lru_add_drain();  /* push cached pages to LRU */
>  			/*
> -			 * Because we lock page here and migration is
> -			 * blocked by the pte's page reference, we need
> -			 * only check for file-cache page truncation.
> +			 * Because we lock page here, and migration is
> +			 * blocked by the pte's page reference, and we
> +			 * know the page is still mapped, we don't even
> +			 * need to check for file-cache page truncation.
>  			 */
> -			if (page->mapping)
> -				mlock_vma_page(page);
> +			mlock_vma_page(page);
>  			unlock_page(page);

So I don't see a reason for checking for truncation in current code,
but I also had a hard time figuring out from git history and list
archives when this was ever "needed" (flu brain does not help).

My conclusion is that it started out as a fix for when an early draft
of putback_lru_page dropped the page lock on truncated pages, but at
the time b291f00 "mlock: mlocked pages are unevictable" went into the
tree it was merely an optimization anymore to avoid moving pages
between lists when they are to be freed soon anyway.

Is this correct?

> --- 3.6-rc6.orig/mm/mlock.c	2012-09-18 15:38:08.000000000 -0700
> +++ 3.6-rc6/mm/mlock.c	2012-09-18 17:51:02.871288773 -0700
> @@ -51,13 +51,10 @@ EXPORT_SYMBOL(can_do_mlock);
>  /*
>   *  LRU accounting for clear_page_mlock()
>   */
> -void __clear_page_mlock(struct page *page)
> +void clear_page_mlock(struct page *page)
>  {
> -	VM_BUG_ON(!PageLocked(page));
> -
> -	if (!page->mapping) {	/* truncated ? */
> +	if (!TestClearPageMlocked(page))
>  		return;
> -	}
>  
>  	dec_zone_page_state(page, NR_MLOCK);
>  	count_vm_event(UNEVICTABLE_PGCLEARED);
> @@ -290,14 +287,7 @@ void munlock_vma_pages_range(struct vm_a
>  		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
>  		if (page && !IS_ERR(page)) {
>  			lock_page(page);
> -			/*
> -			 * Like in __mlock_vma_pages_range(),
> -			 * because we lock page here and migration is
> -			 * blocked by the elevated reference, we need
> -			 * only check for file-cache page truncation.
> -			 */
> -			if (page->mapping)
> -				munlock_vma_page(page);
> +			munlock_vma_page(page);
>  			unlock_page(page);
>  			put_page(page);
>  		}
> --- 3.6-rc6.orig/mm/rmap.c	2012-09-18 16:39:50.000000000 -0700
> +++ 3.6-rc6/mm/rmap.c	2012-09-18 17:51:02.871288773 -0700
> @@ -1203,7 +1203,10 @@ void page_remove_rmap(struct page *page)
>  	} else {
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
>  		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	}
> +	if (unlikely(PageMlocked(page)))
> +		clear_page_mlock(page);
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
>  	 * but that might overwrite a racing page_add_anon_rmap
> @@ -1213,6 +1216,7 @@ void page_remove_rmap(struct page *page)
>  	 * Leaving it set also helps swapoff to reinstate ptes
>  	 * faster for those pages still in swapcache.
>  	 */
> +	return;
>  out:
>  	if (!anon)
>  		mem_cgroup_end_update_page_stat(page, &locked, &flags);

Would it be cleaner to fold this into the only goto site left?  One
certain upside of that would be the fantastic comment about leaving
page->mapping intact being the last operation in this function again :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
