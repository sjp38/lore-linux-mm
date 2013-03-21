Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 47EE76B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:13:55 -0400 (EDT)
Message-ID: <514B4E2B.2010506@sr71.net>
Date: Thu, 21 Mar 2013 11:15:07 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 13/30] thp, mm: implement grab_cache_huge_page_write_begin()
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> The function is grab_cache_page_write_begin() twin but it tries to
> allocate huge page at given position aligned to HPAGE_CACHE_NR.

The obvious question, then, is whether we should just replace
grab_cache_page_write_begin() with this code and pass in HPAGE_CACHE_NR
or 1 based on whether we're doing a huge or normal page.

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 38fdc92..bdedb1b 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2332,6 +2332,64 @@ found:
>  }
>  EXPORT_SYMBOL(grab_cache_page_write_begin);
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +/*
> + * Find or create a huge page at the given pagecache position, aligned to
> + * HPAGE_CACHE_NR. Return the locked huge page.
> + *
> + * If, for some reason, it's not possible allocate a huge page at this
> + * possition, it returns NULL. Caller should take care of fallback to small
> + * pages.
> + *
> + * This function is specifically for buffered writes.
> + */
> +struct page *grab_cache_huge_page_write_begin(struct address_space *mapping,
> +		pgoff_t index, unsigned flags)
> +{
> +	int status;
> +	gfp_t gfp_mask;
> +	struct page *page;
> +	gfp_t gfp_notmask = 0;
> +
> +	BUG_ON(index & HPAGE_CACHE_INDEX_MASK);

--
> +	gfp_mask = mapping_gfp_mask(mapping);
> +	BUG_ON(!(gfp_mask & __GFP_COMP));
> +	if (mapping_cap_account_dirty(mapping))
> +		gfp_mask |= __GFP_WRITE;
> +	if (flags & AOP_FLAG_NOFS)
> +		gfp_notmask = __GFP_FS;

This whole hunk is both non-obvious and copy-n-pasted from
grab_cache_page_write_begin().  That makes me worry that bugs/features
will get added/removed in one and not the other.  I really think they
need to get consolidated somehow.

> +repeat:
> +	page = find_lock_page(mapping, index);
> +	if (page) {
> +		if (!PageTransHuge(page)) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +			return NULL;
> +		}
> +		goto found;
> +	}
> +
> +	page = alloc_pages(gfp_mask & ~gfp_notmask, HPAGE_PMD_ORDER);

I alluded to this a second ago, but what's wrong with alloc_hugepage()?

> +	if (!page) {
> +		count_vm_event(THP_WRITE_FAILED);
> +		return NULL;
> +	}
> +
> +	count_vm_event(THP_WRITE_ALLOC);
> +	status = add_to_page_cache_lru(page, mapping, index,
> +			GFP_KERNEL & ~gfp_notmask);
> +	if (unlikely(status)) {
> +		page_cache_release(page);
> +		if (status == -EEXIST)
> +			goto repeat;
> +		return NULL;
> +	}

I'm rather un-fond of sprinking likely/unlikelies around.  But, I guess
this is really just copied from the existing one.  <sigh>

> +found:
> +	wait_on_page_writeback(page);
> +	return page;
> +}
> +#endif

So, I diffed :

-struct page *grab_cache_page_write_begin(struct address_space
vs.
+struct page *grab_cache_huge_page_write_begin(struct address_space

They're just to similar to ignore.  Please consolidate them somehow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
