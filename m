Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 385C96B0036
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:59:23 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so8909850pab.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:59:22 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id gp6si45506606pac.215.2014.07.09.01.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:59:21 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so8633611pdi.4
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:59:21 -0700 (PDT)
Date: Wed, 9 Jul 2014 01:57:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v3 7/7] shm: isolate pinned pages when sealing files
In-Reply-To: <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1407090155250.7841@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

On Fri, 13 Jun 2014, David Herrmann wrote:

> When setting SEAL_WRITE, we must make sure nobody has a writable reference
> to the pages (via GUP or similar). We currently check references and wait
> some time for them to be dropped. This, however, might fail for several
> reasons, including:
>  - the page is pinned for longer than we wait
>  - while we wait, someone takes an already pinned page for read-access
> 
> Therefore, this patch introduces page-isolation. When sealing a file with
> SEAL_WRITE, we copy all pages that have an elevated ref-count. The newpage
> is put in place atomically, the old page is detached and left alone. It
> will get reclaimed once the last external user dropped it.
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

I've not checked it line by line, but this seems to be very good work;
and I'm glad you have posted it, where we can refer back to it in future.

However, I'm NAKing this patch, at least for now.

The reason is simple and twofold.

I absolutely do not want to be maintaining an alternative form of
page migration in mm/shmem.c.  Shmem has its own peculiar problems
(mostly because of swap): adding a new dimension of very rarely
exercised complication, and dependence on the rest mm, is not wise.

And sealing just does not need this.  It is clearly technically
superior to, and more satisfying than, the "wait-a-while-then-give-up"
technique which it would replace.  But in practice, the wait-a-while
technique is quite good enough (and much better self-contained than this). 

I've heard no requirement to support sealing of objects pinned for I/O,
and the sealer just would not have given the object out for that; the
requirement is to give the recipient of a sealed object confidence
that it cannot be susceptible to modification in that way.

I doubt there will ever be an actual need for sealing to use this
migration technique; but I can imagine us referring back to your work in
future, when/if implementing revoke on regular files.  And integrating
this into mm/migrate.c's unmap_and_move() as an extra-force mode
(proceed even when the page count is raised).

I think the concerns I had, when Tony first proposed this migration copy
technique, were in fact unfounded - I was worried by the new inverse COW.
On reflection, I don't think this introduces any new risks, which are
not already present in page migration, truncation and orphaned pages.

I didn't begin to test it at all, but the only defects that stood out
in your code were in the areas of memcg and mlock.  I think that if we
go down the road of duplicating pinned pages, then we do have to make
a memcg charge on the new page in addition to the old page.  And if
any pages happen to be mlock'ed into an address space, then we ought
to map in the replacement pages afterwards (as page migration does,
whether mlock'ed or not).

(You were perfectly correct to use unmap_mapping_range(), rather than
try_to_unmap() as page migration does: because unmap_mapping_range()
manages the VM_NONLINEAR case.  But our intention, under way, is to
scrap all VM_NONLINEAR code, and just emulate it with multiple vmas,
in which case try_to_unmap() should do.)

Hugh

> ---
>  mm/shmem.c | 218 +++++++++++++++++++++++++++++--------------------------------
>  1 file changed, 105 insertions(+), 113 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ddc3998..34b14fb 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1237,6 +1237,110 @@ unlock:
>  	return error;
>  }
>  
> +static int shmem_isolate_page(struct inode *inode, struct page *oldpage)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct page *newpage;
> +	int error;
> +
> +	if (oldpage->mapping != mapping)
> +		return 0;
> +	if (page_count(oldpage) - page_mapcount(oldpage) <= 2)
> +		return 0;
> +
> +	if (page_mapped(oldpage))
> +		unmap_mapping_range(mapping,
> +				    (loff_t)oldpage->index << PAGE_CACHE_SHIFT,
> +				    PAGE_CACHE_SIZE, 0);
> +
> +	VM_BUG_ON_PAGE(PageWriteback(oldpage), oldpage);
> +	VM_BUG_ON_PAGE(page_has_private(oldpage), oldpage);
> +
> +	newpage = shmem_alloc_page(mapping_gfp_mask(mapping), info,
> +				   oldpage->index);
> +	if (!newpage)
> +		return -ENOMEM;
> +
> +	__set_page_locked(newpage);
> +	copy_highpage(newpage, oldpage);
> +	flush_dcache_page(newpage);
> +
> +	page_cache_get(newpage);
> +	SetPageUptodate(newpage);
> +	SetPageSwapBacked(newpage);
> +	newpage->mapping = mapping;
> +	newpage->index = oldpage->index;
> +
> +	cancel_dirty_page(oldpage, PAGE_CACHE_SIZE);
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	error = shmem_radix_tree_replace(mapping, oldpage->index,
> +					 oldpage, newpage);
> +	if (!error) {
> +		__inc_zone_page_state(newpage, NR_FILE_PAGES);
> +		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
> +	}
> +	spin_unlock_irq(&mapping->tree_lock);
> +
> +	if (error) {
> +		newpage->mapping = NULL;
> +		unlock_page(newpage);
> +		page_cache_release(newpage);
> +		page_cache_release(newpage);
> +		return error;
> +	}
> +
> +	mem_cgroup_replace_page_cache(oldpage, newpage);
> +	lru_cache_add_anon(newpage);
> +
> +	oldpage->mapping = NULL;
> +	page_cache_release(oldpage);
> +	unlock_page(newpage);
> +	page_cache_release(newpage);
> +
> +	return 1;
> +}
> +
> +static int shmem_isolate_pins(struct inode *inode)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	struct pagevec pvec;
> +	pgoff_t indices[PAGEVEC_SIZE];
> +	pgoff_t index;
> +	int i, ret, error;
> +
> +	pagevec_init(&pvec, 0);
> +	index = 0;
> +	error = 0;
> +	while ((pvec.nr = find_get_entries(mapping, index, PAGEVEC_SIZE,
> +					   pvec.pages, indices))) {
> +		for (i = 0; i < pagevec_count(&pvec); i++) {
> +			struct page *page = pvec.pages[i];
> +
> +			index = indices[i];
> +			if (radix_tree_exceptional_entry(page))
> +				continue;
> +			if (page->mapping != mapping)
> +				continue;
> +			if (page_count(page) - page_mapcount(page) <= 2)
> +				continue;
> +
> +			lock_page(page);
> +			ret = shmem_isolate_page(inode, page);
> +			if (ret < 0)
> +				error = ret;
> +			unlock_page(page);
> +		}
> +		pagevec_remove_exceptionals(&pvec);
> +		pagevec_release(&pvec);
> +		cond_resched();
> +		index++;
> +	}
> +
> +	return error;
> +}
> +
>  static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct inode *inode = file_inode(vma->vm_file);
> @@ -1734,118 +1838,6 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
>  	return offset;
>  }
>  
> -/*
> - * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
> - * so reuse a tag which we firmly believe is never set or cleared on shmem.
> - */
> -#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
> -#define LAST_SCAN               4       /* about 150ms max */
> -
> -static void shmem_tag_pins(struct address_space *mapping)
> -{
> -	struct radix_tree_iter iter;
> -	void **slot;
> -	pgoff_t start;
> -	struct page *page;
> -
> -	start = 0;
> -	rcu_read_lock();
> -
> -restart:
> -	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> -		page = radix_tree_deref_slot(slot);
> -		if (!page || radix_tree_exception(page)) {
> -			if (radix_tree_deref_retry(page))
> -				goto restart;
> -		} else if (page_count(page) - page_mapcount(page) > 1) {
> -			spin_lock_irq(&mapping->tree_lock);
> -			radix_tree_tag_set(&mapping->page_tree, iter.index,
> -					   SHMEM_TAG_PINNED);
> -			spin_unlock_irq(&mapping->tree_lock);
> -		}
> -
> -		if (need_resched()) {
> -			cond_resched_rcu();
> -			start = iter.index + 1;
> -			goto restart;
> -		}
> -	}
> -	rcu_read_unlock();
> -}
> -
> -/*
> - * Setting SEAL_WRITE requires us to verify there's no pending writer. However,
> - * via get_user_pages(), drivers might have some pending I/O without any active
> - * user-space mappings (eg., direct-IO, AIO). Therefore, we look at all pages
> - * and see whether it has an elevated ref-count. If so, we tag them and wait for
> - * them to be dropped.
> - * The caller must guarantee that no new user will acquire writable references
> - * to those pages to avoid races.
> - */
> -static int shmem_wait_for_pins(struct address_space *mapping)
> -{
> -	struct radix_tree_iter iter;
> -	void **slot;
> -	pgoff_t start;
> -	struct page *page;
> -	int error, scan;
> -
> -	shmem_tag_pins(mapping);
> -
> -	error = 0;
> -	for (scan = 0; scan <= LAST_SCAN; scan++) {
> -		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
> -			break;
> -
> -		if (!scan)
> -			lru_add_drain_all();
> -		else if (schedule_timeout_killable((HZ << scan) / 200))
> -			scan = LAST_SCAN;
> -
> -		start = 0;
> -		rcu_read_lock();
> -restart:
> -		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
> -					   start, SHMEM_TAG_PINNED) {
> -
> -			page = radix_tree_deref_slot(slot);
> -			if (radix_tree_exception(page)) {
> -				if (radix_tree_deref_retry(page))
> -					goto restart;
> -
> -				page = NULL;
> -			}
> -
> -			if (page &&
> -			    page_count(page) - page_mapcount(page) != 1) {
> -				if (scan < LAST_SCAN)
> -					goto continue_resched;
> -
> -				/*
> -				 * On the last scan, we clean up all those tags
> -				 * we inserted; but make a note that we still
> -				 * found pages pinned.
> -				 */
> -				error = -EBUSY;
> -			}
> -
> -			spin_lock_irq(&mapping->tree_lock);
> -			radix_tree_tag_clear(&mapping->page_tree,
> -					     iter.index, SHMEM_TAG_PINNED);
> -			spin_unlock_irq(&mapping->tree_lock);
> -continue_resched:
> -			if (need_resched()) {
> -				cond_resched_rcu();
> -				start = iter.index + 1;
> -				goto restart;
> -			}
> -		}
> -		rcu_read_unlock();
> -	}
> -
> -	return error;
> -}
> -
>  #define F_ALL_SEALS (F_SEAL_SEAL | \
>  		     F_SEAL_SHRINK | \
>  		     F_SEAL_GROW | \
> @@ -1907,7 +1899,7 @@ int shmem_add_seals(struct file *file, unsigned int seals)
>  		if (error)
>  			goto unlock;
>  
> -		error = shmem_wait_for_pins(file->f_mapping);
> +		error = shmem_isolate_pins(inode);
>  		if (error) {
>  			mapping_allow_writable(file->f_mapping);
>  			goto unlock;
> -- 
> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
