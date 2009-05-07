Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 912A26B004D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:13:07 -0400 (EDT)
Date: Thu, 7 May 2009 17:10:39 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class citizen
Message-ID: <20090507151039.GA2413@cmpxchg.org>
References: <20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com> <20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507121101.GB20934@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 07, 2009 at 08:11:01PM +0800, Wu Fengguang wrote:
> Introduce AS_EXEC to mark executables and their linked libraries, and to
> protect their referenced active pages from being deactivated.
> 
> CC: Elladan <elladan@eskimo.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/pagemap.h |    1 +
>  mm/mmap.c               |    2 ++
>  mm/nommu.c              |    2 ++
>  mm/vmscan.c             |   35 +++++++++++++++++++++++++++++++++--
>  4 files changed, 38 insertions(+), 2 deletions(-)
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
> @@ -1194,6 +1194,8 @@ munmap_back:
>  			goto unmap_and_free_vma;
>  		if (vm_flags & VM_EXECUTABLE)
>  			added_exe_file_vma(mm);
> +		if (vm_flags & VM_EXEC)
> +			set_bit(AS_EXEC, &file->f_mapping->flags);
>  	} else if (vm_flags & VM_SHARED) {
>  		error = shmem_zero_setup(vma);
>  		if (error)
> --- linux.orig/mm/nommu.c
> +++ linux/mm/nommu.c
> @@ -1224,6 +1224,8 @@ unsigned long do_mmap_pgoff(struct file 
>  			added_exe_file_vma(current->mm);
>  			vma->vm_mm = current->mm;
>  		}
> +		if (vm_flags & VM_EXEC)
> +			set_bit(AS_EXEC, &file->f_mapping->flags);
>  	}

I find it a bit ugly that it applies an attribute of the memory area
(per mm) to the page cache mapping (shared).  Because this in turn
means that the reference through a non-executable vma might get the
pages rotated just because there is/was an executable mmap around.

>  	down_write(&nommu_region_sem);
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1230,6 +1230,7 @@ static void shrink_active_list(unsigned 
>  	unsigned long pgmoved;
>  	unsigned long pgscanned;
>  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
> +	LIST_HEAD(l_active);
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
>  	struct pagevec pvec;
> @@ -1269,8 +1270,15 @@ static void shrink_active_list(unsigned 
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

Since we walk the VMAs in page_referenced anyway, wouldn't it be
better to check if one of them is executable?  This would even work
for executable anon pages.  After all, there are applications that cow
executable mappings (sbcl and other language environments that use an
executable, run-time modified core image come to mind).

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
