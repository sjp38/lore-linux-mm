Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8FE926B002C
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 21:35:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C775A3EE0B6
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:35:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F09445DE69
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:35:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8179945DE61
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:35:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D696E08004
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:35:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FD641DB804D
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:35:12 +0900 (JST)
Date: Mon, 27 Feb 2012 11:33:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-Id: <20120227113338.e8e1ecd6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
	<1329006098-5454-4-git-send-email-andrea@betterlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?B?UMOhZHJhaWc=?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sun, 12 Feb 2012 01:21:38 +0100
Andrea Righi <andrea@betterlinux.com> wrote:

> According to the POSIX standard the POSIX_FADV_NOREUSE hint means that
> the application expects to access the specified data once and then not
> reuse it thereafter.
> 
> It seems that the expected behavior is to implement a drop-behind
> policy where the application can set certain intervals of a file as
> FADV_NOREUSE _before_ accessing the data.
> 
> An interesting usage of this hint is to guarantee that pages marked as
> FADV_NOREUSE will never blow away the pages of the current working set.
> 
> A possible solution to satisfy this requirement is to prevent lru
> activation of the pages marked as FADV_NOREUSE, in other words, never
> add pages marked as FADV_NOREUSE to the active lru list. Moreover, all
> the file cache pages in a FADV_NOREUSE range can be immediately dropped
> after a read if the page was not present in the file cache before.
> 
> In general, the purpose of this approach is to preserve as much as
> possible the previous state of the file cache memory before reading data
> in ranges marked by FADV_NOREUSE.
> 
> All the pages read before (pre-)setting them as FADV_NOREUSE should be
> treated as normal, so they can be added to the active lru list as usual
> if they're accessed multiple times.
> 
> Only after setting them as FADV_NOREUSE we can prevent them for being
> promoted to the active lru list. If they are already in the active lru
> list before calling FADV_NOREUSE we should keep them there, but if they
> quit from the active list they can't get back anymore (except by
> explicitly setting a different caching hint).
> 

>From this part, it seems the behavior of systemcall is highly depends on
interanal kernel implemenatation...


> To achieve this goal we need to maintain the list of file ranges marked
> as FADV_NOREUSE until the pages are dropped from the page cache, or the
> inode is deleted, or they're explicitly marked to use a different cache
> behavior (FADV_NORMAL | FADV_WILLNEED).
> 
> The list of FADV_NOREUSE ranges is maintained in the address_space
> structure using an interval tree (kinterval).
> 
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>


Once an appliation sets a range of file as FILEMAP_CACHE_ONCE,
the effects will last until the inode is dropped....right ?
Won't this cause troubles which cannot be detected
(because kinterval information is hidden.) ?

I'm not sure but FADV_NOREUSE seems like one-shot call and should not have
very long time of effect (after the application exits.)
Can't we ties the liftime of kinteval to the application/file descriptor ?

Thanks,
-Kame

> ---
>  fs/inode.c         |    3 ++
>  include/linux/fs.h |   12 ++++++
>  mm/fadvise.c       |   18 +++++++++-
>  mm/filemap.c       |   95 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 125 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index fb10d86..6375163 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -254,6 +254,7 @@ void __destroy_inode(struct inode *inode)
>  	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
>  		posix_acl_release(inode->i_default_acl);
>  #endif
> +	filemap_clear_cache(&inode->i_data);
>  	this_cpu_dec(nr_inodes);
>  }
>  EXPORT_SYMBOL(__destroy_inode);
> @@ -360,6 +361,8 @@ void address_space_init_once(struct address_space *mapping)
>  	spin_lock_init(&mapping->private_lock);
>  	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
>  	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> +	INIT_KINTERVAL_TREE_ROOT(&mapping->nocache_tree);
> +	rwlock_init(&mapping->nocache_lock);
>  }
>  EXPORT_SYMBOL(address_space_init_once);
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 386da09..624a73e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -9,6 +9,7 @@
>  #include <linux/limits.h>
>  #include <linux/ioctl.h>
>  #include <linux/blk_types.h>
> +#include <linux/kinterval.h>
>  #include <linux/types.h>
>  
>  /*
> @@ -521,6 +522,11 @@ enum positive_aop_returns {
>  						* helper code (eg buffer layer)
>  						* to clear GFP_FS from alloc */
>  
> +enum filemap_cache_modes {
> +	FILEMAP_CACHE_NORMAL,	/* No special cache behavior */
> +	FILEMAP_CACHE_ONCE,	/* Pages will be used once */
> +};
> +
>  /*
>   * oh the beauties of C type declarations.
>   */
> @@ -655,6 +661,8 @@ struct address_space {
>  	spinlock_t		private_lock;	/* for use by the address_space */
>  	struct list_head	private_list;	/* ditto */
>  	struct address_space	*assoc_mapping;	/* ditto */
> +	struct rb_root		nocache_tree;	/* noreuse cache range tree */
> +	rwlock_t		nocache_lock;	/* protect the nocache_tree */
>  } __attribute__((aligned(sizeof(long))));
>  	/*
>  	 * On most architectures that alignment is already the case; but
> @@ -2189,6 +2197,10 @@ extern int invalidate_inode_pages2(struct address_space *mapping);
>  extern int invalidate_inode_pages2_range(struct address_space *mapping,
>  					 pgoff_t start, pgoff_t end);
>  extern int write_inode_now(struct inode *, int);
> +extern void filemap_clear_cache(struct address_space *mapping);
> +extern int filemap_set_cache(struct address_space *mapping,
> +				pgoff_t start, pgoff_t end, int mode);
> +extern int filemap_get_cache(struct address_space *mapping, pgoff_t index);
>  extern int filemap_fdatawrite(struct address_space *);
>  extern int filemap_flush(struct address_space *);
>  extern int filemap_fdatawait(struct address_space *);
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 469491e..22b1aa8 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -80,6 +80,12 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		spin_lock(&file->f_lock);
>  		file->f_mode &= ~FMODE_RANDOM;
>  		spin_unlock(&file->f_lock);
> +
> +		start_index = offset >> PAGE_CACHE_SHIFT;
> +		end_index = endbyte >> PAGE_CACHE_SHIFT;
> +
> +		ret = filemap_set_cache(mapping, start_index, end_index,
> +					FILEMAP_CACHE_NORMAL);
>  		break;
>  	case POSIX_FADV_RANDOM:
>  		spin_lock(&file->f_lock);
> @@ -102,11 +108,16 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		start_index = offset >> PAGE_CACHE_SHIFT;
>  		end_index = endbyte >> PAGE_CACHE_SHIFT;
>  
> +		ret = filemap_set_cache(mapping, start_index, end_index,
> +					FILEMAP_CACHE_NORMAL);
> +		if (ret < 0)
> +			break;
> +
>  		/* Careful about overflow on the "+1" */
>  		nrpages = end_index - start_index + 1;
>  		if (!nrpages)
>  			nrpages = ~0UL;
> -		
> +
>  		ret = force_page_cache_readahead(mapping, file,
>  				start_index,
>  				nrpages);
> @@ -114,6 +125,11 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  			ret = 0;
>  		break;
>  	case POSIX_FADV_NOREUSE:
> +		start_index = offset >> PAGE_CACHE_SHIFT;
> +		end_index = endbyte >> PAGE_CACHE_SHIFT;
> +
> +		ret = filemap_set_cache(mapping, start_index, end_index,
> +					FILEMAP_CACHE_ONCE);
>  		break;
>  	case POSIX_FADV_DONTNEED:
>  		if (!bdi_write_congested(mapping->backing_dev_info))
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b662757..610502a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -27,6 +27,7 @@
>  #include <linux/writeback.h>
>  #include <linux/backing-dev.h>
>  #include <linux/pagevec.h>
> +#include <linux/kinterval.h>
>  #include <linux/blkdev.h>
>  #include <linux/security.h>
>  #include <linux/syscalls.h>
> @@ -187,6 +188,82 @@ static int sleep_on_page_killable(void *word)
>  }
>  
>  /**
> + * filemap_clear_cache - clear all special cache settings
> + * @mapping:	target address space structure
> + *
> + * Reset all the special file cache settings previously defined by
> + * filemap_set_cache().
> + */
> +void filemap_clear_cache(struct address_space *mapping)
> +{
> +	write_lock(&mapping->nocache_lock);
> +	kinterval_clear(&mapping->nocache_tree);
> +	write_unlock(&mapping->nocache_lock);
> +}
> +
> +/**
> + * filemap_set_cache - set special cache behavior for a range of file pages
> + * @mapping:	target address space structure
> + * @start:	offset in pages where the range starts
> + * @end:	offset in pages where the range ends (inclusive)
> + * @mode:	cache behavior configuration
> + *
> + * This can be used to define special cache behavior in advance, before
> + * accessing the data.
> + *
> + * At the moment the supported cache behaviors are the following (see also
> + * filemap_cache_modes):
> + *
> + * FILEMAP_CACHE_NORMAL: normal page cache behavior;
> + *
> + * FILEMAP_CACHE_ONCE: specifies that the pages will be accessed once and the
> + * caller don't expect to reuse it thereafter. This prevents them for being
> + * promoted to the active lru list.
> + */
> +int filemap_set_cache(struct address_space *mapping,
> +				pgoff_t start, pgoff_t end, int mode)
> +{
> +	int ret;
> +
> +	write_lock(&mapping->nocache_lock);
> +	switch (mode) {
> +	case FILEMAP_CACHE_NORMAL:
> +		ret = kinterval_del(&mapping->nocache_tree,
> +				start, end, GFP_KERNEL);
> +		break;
> +	case FILEMAP_CACHE_ONCE:
> +		ret = kinterval_add(&mapping->nocache_tree,
> +				start, end, mode, GFP_KERNEL);
> +		break;
> +	default:
> +		ret = -EINVAL;
> +		break;
> +	}
> +	write_unlock(&mapping->nocache_lock);
> +
> +	return ret;
> +}
> +
> +/**
> + * filemap_get_cache - get special cache behavior of a file page
> + * @mapping:	target address space structure
> + * @index:	index of the page inside the address space
> + *
> + * If no special cache behavior are defined FILEMAP_CACHE_NORMAL is returned
> + * (that means no special page cache behavior is applied).
> + */
> +int filemap_get_cache(struct address_space *mapping, pgoff_t index)
> +{
> +	int mode;
> +
> +	read_lock(&mapping->nocache_lock);
> +	mode = kinterval_lookup(&mapping->nocache_tree, index);
> +	read_unlock(&mapping->nocache_lock);
> +
> +	return mode < 0 ? FILEMAP_CACHE_NORMAL : mode;
> +}
> +
> +/**
>   * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
>   * @mapping:	address space structure to write
>   * @start:	offset in bytes where the range starts
> @@ -1181,8 +1258,22 @@ page_ok:
>  		 * When a sequential read accesses a page several times,
>  		 * only mark it as accessed the first time.
>  		 */
> -		if (prev_index != index || offset != prev_offset)
> -			mark_page_accessed(page);
> +		if (prev_index != index || offset != prev_offset) {
> +			int mode;
> +
> +			mode = filemap_get_cache(mapping, index);
> +			switch (mode) {
> +			case FILEMAP_CACHE_NORMAL:
> +				mark_page_accessed(page);
> +				break;
> +			case FILEMAP_CACHE_ONCE:
> +				mark_page_usedonce(page);
> +				break;
> +			default:
> +				WARN_ON_ONCE(1);
> +				break;
> +			}
> +		}
>  		prev_index = index;
>  
>  		/*
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
