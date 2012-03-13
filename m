Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3EED36B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:43:11 -0400 (EDT)
Received: by dadv6 with SMTP id v6so510004dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 23:43:10 -0700 (PDT)
Date: Tue, 13 Mar 2012 14:48:32 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Fwd: Control page reclaim granularity
Message-ID: <20120313064832.GA4968@gmail.com>
References: <20120313024818.GA7125@barrios>
 <1331620214-4893-1-git-send-email-wenqing.lz@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331620214-4893-1-git-send-email-wenqing.lz@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: khlebnikov@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, Zheng Liu <wenqing.lz@taobao.com>

Sorry, please forgive me.  This patch has a defect.  When one page is
scaned and flag is clear, all other's flags also are clear too.

Regards,
Zheng

On Tue, Mar 13, 2012 at 02:30:14PM +0800, Zheng Liu wrote:
> This only a first trivial try.  If this flag is set, reclaimer just give this
> page one more round trip rather than promote it into active list.  Any comments
> or advices are welcomed.
> 
> Regards,
> Zheng
> 
> [PATCH] mm: per-inode mmaped page reclaim
> 
> From: Zheng Liu <wenqing.lz@taobao.com>
> 
> In some cases, user wants to control mmaped page reclaim granularity.  A new
> flag is added into struct address_space to give the page one more round trip.
> AS_WORKINGSET flag cannot be added in vma->vm_flags because this flag has no
> room for a new flag in 32 bit.  Now user can call madvise(2) to set this flag
> for a file.  If this flag is set, all pages will be given one more round trip
> when reclaimer tries to shrink pages.
> 
> Signed-off-by: Zheng Liu <wenqing.lz@taobao.com>
> ---
>  include/asm-generic/mman-common.h |    2 ++
>  include/linux/pagemap.h           |   16 ++++++++++++++++
>  mm/madvise.c                      |    8 ++++++++
>  mm/vmscan.c                       |   15 +++++++++++++++
>  4 files changed, 41 insertions(+), 0 deletions(-)
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> index 787abbb..7d26c9b 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -48,6 +48,8 @@
>  #define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
>  #define MADV_NOHUGEPAGE	15		/* Not worth backing with hugepages */
>  
> +#define MADV_WORKINGSET 16		/* give one more round trip */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index cfaaa69..80532a0 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -24,6 +24,7 @@ enum mapping_flags {
>  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> +	AS_WORKINGSET	= __GFP_BITS_SHIFT + 4, /* give one more round trip */
>  };
>  
>  static inline void mapping_set_error(struct address_space *mapping, int error)
> @@ -36,6 +37,21 @@ static inline void mapping_set_error(struct address_space *mapping, int error)
>  	}
>  }
>  
> +static inline void mapping_set_workingset(struct address_space *mapping)
> +{
> +	set_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
> +static inline void mapping_clear_workingset(struct address_space *mapping)
> +{
> +	clear_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
> +static inline int mapping_test_workingset(struct address_space *mapping)
> +{
> +	return mapping && test_bit(AS_WORKINGSET, &mapping->flags);
> +}
> +
>  static inline void mapping_set_unevictable(struct address_space *mapping)
>  {
>  	set_bit(AS_UNEVICTABLE, &mapping->flags);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 74bf193..8ca6c9b 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -77,6 +77,14 @@ static long madvise_behavior(struct vm_area_struct * vma,
>  		if (error)
>  			goto out;
>  		break;
> +	case MADV_WORKINGSET:
> +		if (vma->vm_file && vma->vm_file->f_mapping) {
> +			mapping_set_workingset(vma->vm_file->f_mapping);
> +		} else {
> +			error = -EPERM;
> +			goto out;
> +		}
> +		break;
>  	}
>  
>  	if (new_flags == vma->vm_flags) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c52b235..51f745b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -721,6 +721,15 @@ static enum page_references page_check_references(struct page *page,
>  	if (vm_flags & VM_LOCKED)
>  		return PAGEREF_RECLAIM;
>  
> +	/*
> +	 * give this page one more round trip because workingset
> +	 * flag is set.
> +	 */
> +	if (mapping_test_workingset(page_mapping(page))) {
> +		mapping_clear_workingset(page_mapping(page));
> +		return PAGEREF_KEEP;
> +	}
> +
>  	if (referenced_ptes) {
>  		if (PageAnon(page))
>  			return PAGEREF_ACTIVATE;
> @@ -1737,6 +1746,12 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  			continue;
>  		}
>  
> +		if (mapping_test_workingset(page_mapping(page))) {
> +			mapping_clear_workingset(page_mapping(page));
> +			list_add(&page->lru, &l_active);
> +			continue;
> +		}
> +
>  		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
>  			nr_rotated += hpage_nr_pages(page);
>  			/*
> -- 
> 1.7.4.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
