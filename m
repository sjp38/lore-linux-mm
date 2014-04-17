Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id B9AA76B003D
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 20:16:53 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so11446912pbb.36
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:16:53 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id ev1si8362117pbb.165.2014.04.16.17.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 17:16:52 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so11262439pdi.7
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:16:52 -0700 (PDT)
Date: Wed, 16 Apr 2014 17:15:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [3.14+] kernel BUG at mm/filemap.c:1347!
In-Reply-To: <20140416162326.GA4439@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1404161642020.11154@eggly.anvils>
References: <20140414202059.GA11170@redhat.com> <alpine.LSU.2.11.1404141952230.2980@eggly.anvils> <20140416162326.GA4439@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 16 Apr 2014, Johannes Weiner wrote:
> Subject: [patch] mm: filemap: update find_get_pages_tag() to deal with shadow
>  entries
> 
> Dave Jones reports the following crash when find_get_pages_tag() runs
> into an exceptional entry:
> 
> kernel BUG at mm/filemap.c:1347!
> RIP: 0010:[<ffffffffb815aeab>]  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
> Call Trace:
>  [<ffffffffb815ad16>] ? find_get_pages_tag+0x36/0x220
>  [<ffffffffb8168511>] pagevec_lookup_tag+0x21/0x30
>  [<ffffffffb81595de>] filemap_fdatawait_range+0xbe/0x1e0
>  [<ffffffffb8159727>] filemap_fdatawait+0x27/0x30
>  [<ffffffffb81f2fa4>] sync_inodes_sb+0x204/0x2a0
>  [<ffffffffb874d98f>] ? wait_for_completion+0xff/0x130
>  [<ffffffffb81fa5b0>] ? vfs_fsync+0x40/0x40
>  [<ffffffffb81fa5c9>] sync_inodes_one_sb+0x19/0x20
>  [<ffffffffb81caab2>] iterate_supers+0xb2/0x110
>  [<ffffffffb81fa864>] sys_sync+0x44/0xb0
>  [<ffffffffb875c4a9>] ia32_do_call+0x13/0x13
> 
> 1343                         /*
> 1344                          * This function is never used on a shmem/tmpfs
> 1345                          * mapping, so a swap entry won't be found here.
> 1346                          */
> 1347                         BUG();
> 
> After 0cd6144aadd2 ("mm + fs: prepare for non-page entries in page
> cache radix trees") this comment and BUG() are out of date because
> exceptional entries can now appear in all mappings - as shadows of
> recently evicted pages.
> 
> However, as Hugh Dickins notes,
> 
>   "it is truly surprising for a PAGECACHE_TAG_WRITEBACK (and probably
>    any other PAGECACHE_TAG_*) to appear on an exceptional entry.
> 
>    I expect it comes down to an occasional race in RCU lookup of the
>    radix_tree: lacking absolute synchronization, we might sometimes
>    catch an exceptional entry, with the tag which really belongs with
>    the unexceptional entry which was there an instant before."
> 
> And indeed, not only is the tree walk lockless, the tags are also read
> in chunks, one radix tree node at a time.  There is plenty of time for
> page reclaim to swoop in and replace a page that was already looked up
> as tagged with a shadow entry.
> 
> Remove the BUG() and update the comment.  While reviewing all other
> lookup sites for whether they properly deal with shadow entries of
> evicted pages, update all the comments and fix memcg file charge
> moving to not miss shmem/tmpfs swapcache pages.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Fixes: 0cd6144aadd2 ("mm + fs: prepare for non-page entries in page cache radix trees")

Looks exactly right to me, thanks Hannes.  Good catch in memcontrol.c.

Acked-by: Hugh Dickins <hughd@google.com>

And I realize now that the tag races which led me to defer to you, are
actually just races we have lived with for years; but before they were
all handled invisibly at the "unlikely(!page)" stage, whereas now they
simply need active handling at the radix_tree_exception stage too.

There is, by the way, a separate cleanup that I noticed last night,
while puzzing over the filemap.c:202 bug.  In mm/truncate.c there
are several "We rely upon deletion not changing page->index" comments
(and in mm/filemap.c "Leave page->index set: truncation relies upon it").
I think your indices[] everywhere have ended that reliance?  Whether you
also remove the "WARN_ON(page->index != index)"s is a matter of taste:
it is reassuring to have that checked somewhere, but no longer so
particular to those loops.

> ---
>  mm/filemap.c    | 49 ++++++++++++++++++++++++++++---------------------
>  mm/memcontrol.c | 20 ++++++++++++--------
>  mm/truncate.c   |  8 --------
>  3 files changed, 40 insertions(+), 37 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a82fbe4c9e8e..d92c437a79c4 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -906,8 +906,8 @@ EXPORT_SYMBOL(page_cache_prev_hole);
>   * Looks up the page cache slot at @mapping & @offset.  If there is a
>   * page cache page, it is returned with an increased refcount.
>   *
> - * If the slot holds a shadow entry of a previously evicted page, it
> - * is returned.
> + * If the slot holds a shadow entry of a previously evicted page, or a
> + * swap entry from shmem/tmpfs, it is returned.
>   *
>   * Otherwise, %NULL is returned.
>   */
> @@ -928,9 +928,9 @@ repeat:
>  			if (radix_tree_deref_retry(page))
>  				goto repeat;
>  			/*
> -			 * Otherwise, shmem/tmpfs must be storing a swap entry
> -			 * here as an exceptional entry: so return it without
> -			 * attempting to raise page count.
> +			 * A shadow entry of a recently evicted page,
> +			 * or a swap entry from shmem/tmpfs.  Return
> +			 * it without attempting to raise page count.
>  			 */
>  			goto out;
>  		}
> @@ -983,8 +983,8 @@ EXPORT_SYMBOL(find_get_page);
>   * page cache page, it is returned locked and with an increased
>   * refcount.
>   *
> - * If the slot holds a shadow entry of a previously evicted page, it
> - * is returned.
> + * If the slot holds a shadow entry of a previously evicted page, or a
> + * swap entry from shmem/tmpfs, it is returned.
>   *
>   * Otherwise, %NULL is returned.
>   *
> @@ -1099,8 +1099,8 @@ EXPORT_SYMBOL(find_or_create_page);
>   * with ascending indexes.  There may be holes in the indices due to
>   * not-present pages.
>   *
> - * Any shadow entries of evicted pages are included in the returned
> - * array.
> + * Any shadow entries of evicted pages, or swap entries from
> + * shmem/tmpfs, are included in the returned array.
>   *
>   * find_get_entries() returns the number of pages and shadow entries
>   * which were found.
> @@ -1128,9 +1128,9 @@ repeat:
>  			if (radix_tree_deref_retry(page))
>  				goto restart;
>  			/*
> -			 * Otherwise, we must be storing a swap entry
> -			 * here as an exceptional entry: so return it
> -			 * without attempting to raise page count.
> +			 * A shadow entry of a recently evicted page,
> +			 * or a swap entry from shmem/tmpfs.  Return
> +			 * it without attempting to raise page count.
>  			 */
>  			goto export;
>  		}
> @@ -1198,9 +1198,9 @@ repeat:
>  				goto restart;
>  			}
>  			/*
> -			 * Otherwise, shmem/tmpfs must be storing a swap entry
> -			 * here as an exceptional entry: so skip over it -
> -			 * we only reach this from invalidate_mapping_pages().
> +			 * A shadow entry of a recently evicted page,
> +			 * or a swap entry from shmem/tmpfs.  Skip
> +			 * over it.
>  			 */
>  			continue;
>  		}
> @@ -1265,9 +1265,9 @@ repeat:
>  				goto restart;
>  			}
>  			/*
> -			 * Otherwise, shmem/tmpfs must be storing a swap entry
> -			 * here as an exceptional entry: so stop looking for
> -			 * contiguous pages.
> +			 * A shadow entry of a recently evicted page,
> +			 * or a swap entry from shmem/tmpfs.  Stop
> +			 * looking for contiguous pages.
>  			 */
>  			break;
>  		}
> @@ -1341,10 +1341,17 @@ repeat:
>  				goto restart;
>  			}
>  			/*
> -			 * This function is never used on a shmem/tmpfs
> -			 * mapping, so a swap entry won't be found here.
> +			 * A shadow entry of a recently evicted page.
> +			 *
> +			 * Those entries should never be tagged, but
> +			 * this tree walk is lockless and the tags are
> +			 * looked up in bulk, one radix tree node at a
> +			 * time, so there is a sizable window for page
> +			 * reclaim to evict a page we saw tagged.
> +			 *
> +			 * Skip over it.
>  			 */
> -			BUG();
> +			continue;
>  		}
>  
>  		if (!page_cache_get_speculative(page))
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 29501f040568..c47dffdcb246 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6686,16 +6686,20 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  		pgoff = pte_to_pgoff(ptent);
>  
>  	/* page is moved even if it's not RSS of this task(page-faulted). */
> -	page = find_get_page(mapping, pgoff);
> -
>  #ifdef CONFIG_SWAP
>  	/* shmem/tmpfs may report page out on swap: account for that too. */
> -	if (radix_tree_exceptional_entry(page)) {
> -		swp_entry_t swap = radix_to_swp_entry(page);
> -		if (do_swap_account)
> -			*entry = swap;
> -		page = find_get_page(swap_address_space(swap), swap.val);
> -	}
> +	if (shmem_mapping(mapping)) {
> +		page = find_get_entry(mapping, pgoff);
> +		if (radix_tree_exceptional_entry(page)) {
> +			swp_entry_t swp = radix_to_swp_entry(page);
> +			if (do_swap_account)
> +				*entry = swp;
> +			page = find_get_page(swap_address_space(swp), swp.val);
> +		}
> +	} else
> +		page = find_get_page(mapping, pgoff);
> +#else
> +	page = find_get_page(mapping, pgoff);
>  #endif
>  	return page;
>  }
> diff --git a/mm/truncate.c b/mm/truncate.c
> index e5cc39ab0751..6a78c814bebf 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -484,14 +484,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  	unsigned long count = 0;
>  	int i;
>  
> -	/*
> -	 * Note: this function may get called on a shmem/tmpfs mapping:
> -	 * pagevec_lookup() might then return 0 prematurely (because it
> -	 * got a gangful of swap entries); but it's hardly worth worrying
> -	 * about - it can rarely have anything to free from such a mapping
> -	 * (most pages are dirty), and already skips over any difficulties.
> -	 */
> -
>  	pagevec_init(&pvec, 0);
>  	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
>  			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
> -- 
> 1.9.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
