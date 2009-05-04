Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D0F256B008C
	for <linux-mm@kvack.org>; Mon,  4 May 2009 06:23:44 -0400 (EDT)
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090503031539.GC5702@localhost>
References: <1240987349.4512.18.camel@laptop>
	 <20090429114708.66114c03@cuia.bos.redhat.com>
	 <20090430072057.GA4663@eskimo.com>
	 <20090430174536.d0f438dd.akpm@linux-foundation.org>
	 <20090430205936.0f8b29fc@riellaptop.surriel.com>
	 <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <20090430215034.4748e615@riellaptop.surriel.com>
	 <20090430195439.e02edc26.akpm@linux-foundation.org>
	 <49FB01C1.6050204@redhat.com>
	 <20090501123541.7983a8ae.akpm@linux-foundation.org>
	 <20090503031539.GC5702@localhost>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 04 May 2009 12:23:55 +0200
Message-Id: <1241432635.7620.4732.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, elladan@eskimo.com, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2009-05-03 at 11:15 +0800, Wu Fengguang wrote:
> On Fri, May 01, 2009 at 12:35:41PM -0700, Andrew Morton wrote:
> > On Fri, 01 May 2009 10:05:53 -0400
> > Rik van Riel <riel@redhat.com> wrote:
> > 
> > > Andrew Morton wrote:
> > > 
> > > >> When we implement working set protection, we might as well
> > > >> do it for frequently accessed unmapped pages too.  There is
> > > >> no reason to restrict this protection to mapped pages.
> > > > 
> > > > Well.  Except for empirical observation, which tells us that biasing
> > > > reclaim to prefer to retain mapped memory produces a better result.
> > > 
> > > That used to be the case because file-backed and
> > > swap-backed pages shared the same set of LRUs,
> > > while each following a different page reclaim
> > > heuristic!
> > 
> > No, I think it still _is_ the case.  When reclaim is treating mapped
> > and non-mapped pages equally, the end result sucks.  Applications get
> > all laggy and humans get irritated.  It may be that the system was
> > optimised from an overall throughput POV, but the result was
> > *irritating*.
> > 
> > Which led us to prefer to retain mapped pages.  This had nothing at all
> > to do with internal impementation details - it was a design objective
> > based upon empirical observation of system behaviour.
> 
> Heartily Agreed. We shall try hard to protect the running applications.
> 
> Commit 7e9cd484204f(vmscan: fix pagecache reclaim referenced bit check)
> tries to address scalability problem when every page get mapped and
> referenced, so that logic(which lowed the priority of mapped pages)
> could be enabled only on conditions like (priority < DEF_PRIORITY).
> 
> Or preferably we can explicitly protect the mapped executables,
> as illustrated by this patch (a quick prototype).

Ah, nice, this re-instates the young bit for PROT_EXEC pages.
I very much like this.


> Thanks,
> Fengguang
> ---
>  include/linux/pagemap.h |    1 +
>  mm/mmap.c               |    2 ++
>  mm/nommu.c              |    2 ++
>  mm/vmscan.c             |   37 +++++++++++++++++++++++++++++++++++--
>  4 files changed, 40 insertions(+), 2 deletions(-)
> 
> --- linux.orig/include/linux/pagemap.h
> +++ linux/include/linux/pagemap.h
> @@ -25,6 +25,7 @@ enum mapping_flags {
>  #ifdef CONFIG_UNEVICTABLE_LRU
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>  #endif
> +	AS_EXEC		= __GFP_BITS_SHIFT + 4,	/* mapped PROT_EXEC somewhere */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> --- linux.orig/mm/mmap.c
> +++ linux/mm/mmap.c
> @@ -1198,6 +1198,8 @@ munmap_back:
>  			goto unmap_and_free_vma;
>  		if (vm_flags & VM_EXECUTABLE)
>  			added_exe_file_vma(mm);
> +		if (vm_flags & VM_EXEC)
> +			set_bit(AS_EXEC, &file->f_mapping->flags);
>  	} else if (vm_flags & VM_SHARED) {
>  		error = shmem_zero_setup(vma);
>  		if (error)
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1220,6 +1220,7 @@ static void shrink_active_list(unsigned 
>  	int pgdeactivate = 0;
>  	unsigned long pgscanned;
>  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
> +	LIST_HEAD(l_active);
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
>  	struct pagevec pvec;
> @@ -1259,8 +1260,15 @@ static void shrink_active_list(unsigned 
>  
>  		/* page_referenced clears PageReferenced */
>  		if (page_mapping_inuse(page) &&
> -		    page_referenced(page, 0, sc->mem_cgroup))
> +		    page_referenced(page, 0, sc->mem_cgroup)) {
> +			struct address_space *mapping = page_mapping(page);
> +
>  			pgmoved++;
> +			if (mapping && test_bit(AS_EXEC, &mapping->flags)) {
> +				list_add(&page->lru, &l_active);
> +				continue;
> +			}
> +		}
>  
>  		list_add(&page->lru, &l_inactive);
>  	}
> @@ -1269,7 +1277,6 @@ static void shrink_active_list(unsigned 
>  	 * Move the pages to the [file or anon] inactive list.
>  	 */
>  	pagevec_init(&pvec, 1);
> -	lru = LRU_BASE + file * LRU_FILE;
>  
>  	spin_lock_irq(&zone->lru_lock);
>  	/*
> @@ -1281,6 +1288,7 @@ static void shrink_active_list(unsigned 
>  	reclaim_stat->recent_rotated[!!file] += pgmoved;
>  
>  	pgmoved = 0;
> +	lru = LRU_BASE + file * LRU_FILE;
>  	while (!list_empty(&l_inactive)) {
>  		page = lru_to_page(&l_inactive);
>  		prefetchw_prev_lru_page(page, &l_inactive, flags);
> @@ -1305,6 +1313,31 @@ static void shrink_active_list(unsigned 
>  	}
>  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
>  	pgdeactivate += pgmoved;
> +
> +	pgmoved = 0;
> +	lru = LRU_ACTIVE + file * LRU_FILE;
> +	while (!list_empty(&l_active)) {
> +		page = lru_to_page(&l_active);
> +		prefetchw_prev_lru_page(page, &l_active, flags);
> +		VM_BUG_ON(PageLRU(page));
> +		SetPageLRU(page);
> +		VM_BUG_ON(!PageActive(page));
> +
> +		list_move(&page->lru, &zone->lru[lru].list);
> +		mem_cgroup_add_lru_list(page, lru);
> +		pgmoved++;
> +		if (!pagevec_add(&pvec, page)) {
> +			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +			pgmoved = 0;
> +			spin_unlock_irq(&zone->lru_lock);
> +			if (buffer_heads_over_limit)
> +				pagevec_strip(&pvec);
> +			__pagevec_release(&pvec);
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +	}
> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
>  	__count_vm_events(PGDEACTIVATE, pgdeactivate);
>  	spin_unlock_irq(&zone->lru_lock);
> --- linux.orig/mm/nommu.c
> +++ linux/mm/nommu.c
> @@ -1220,6 +1220,8 @@ unsigned long do_mmap_pgoff(struct file 
>  			added_exe_file_vma(current->mm);
>  			vma->vm_mm = current->mm;
>  		}
> +		if (vm_flags & VM_EXEC)
> +			set_bit(AS_EXEC, &file->f_mapping->flags);
>  	}
>  
>  	down_write(&nommu_region_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
