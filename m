Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D647C6B0072
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:43:17 -0400 (EDT)
Date: Tue, 4 Sep 2012 16:43:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/15 v2] mm: add invalidatepage_range address space
 operation
Message-Id: <20120904164316.6e058cbe.akpm@linux-foundation.org>
In-Reply-To: <1346451711-1931-2-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
	<1346451711-1931-2-git-send-email-lczerner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Fri, 31 Aug 2012 18:21:37 -0400
Lukas Czerner <lczerner@redhat.com> wrote:

> Currently there is no way to truncate partial page where the end
> truncate point is not at the end of the page. This is because it was not
> needed and the functionality was enough for file system truncate
> operation to work properly. However more file systems now support punch
> hole feature and it can benefit from mm supporting truncating page just
> up to the certain point.
> 
> Specifically, with this functionality truncate_inode_pages_range() can
> be changed so it supports truncating partial page at the end of the
> range (currently it will BUG_ON() if 'end' is not at the end of the
> page).
> 
> This commit add new address space operation invalidatepage_range which
> allows specifying length of bytes to invalidate, rather than assuming
> truncate to the end of the page. It also introduce
> block_invalidatepage_range() and do_invalidatepage)range() functions for
> exactly the same reason.
> 
> The caller does not have to implement both aops (invalidatepage and
> invalidatepage_range) and the latter is preferred. The old method will be
> used only if invalidatepage_range is not implemented by the caller.
> 
> ...
>
> +/**
> + * do_invalidatepage_range - invalidate range of the page
> + *
> + * @page: the page which is affected
> + * @offset: start of the range to invalidate
> + * @length: length of the range to invalidate
> +  */
> +void do_invalidatepage_range(struct page *page, unsigned int offset,
> +			     unsigned int length)
> +{
> +	void (*invalidatepage_range)(struct page *, unsigned int,
> +				     unsigned int);
>  	void (*invalidatepage)(struct page *, unsigned long);
> +
> +	/*
> +	 * Try invalidatepage_range first
> +	 */
> +	invalidatepage_range = page->mapping->a_ops->invalidatepage_range;
> +	if (invalidatepage_range) {
> +		(*invalidatepage_range)(page, offset, length);
> +		return;
> +	}
> +
> +	/*
> +	 * When only invalidatepage is registered length + offset must be
> +	 * PAGE_CACHE_SIZE
> +	 */
>  	invalidatepage = page->mapping->a_ops->invalidatepage;
> +	if (invalidatepage) {
> +		BUG_ON(length + offset != PAGE_CACHE_SIZE);
> +		(*invalidatepage)(page, offset);
> +	}
>  #ifdef CONFIG_BLOCK
> -	if (!invalidatepage)
> -		invalidatepage = block_invalidatepage;
> +	if (!invalidatepage_range && !invalidatepage)
> +		block_invalidatepage_range(page, offset, length);
>  #endif
> -	if (invalidatepage)
> -		(*invalidatepage)(page, offset);
>  }

This interface is ...  strange.  If the caller requests a
non-page-aligned invalidateion against an fs which doesn't implement
->invalidatepage_range then the kernel goes BUG.  So the caller must
know beforehand that the underlying fs _does_ implement
->invalidatepage_range.

For practical purposes, this implies that invalidation of a
non-page-aligned region will only be performed by fs code, because the
fs implicitly knows that it implements ->invalidatepage_range.

However this function isn't exported to modules, so scratch that.

So how is calling code supposed to determine whether it can actually
_use_ this interface?



Also...  one would obviously like to see the old ->invalidatepage() get
removed entirely.  But about 20 filesystems implement
->invalidatepage() and implementation of ->invalidatepage_range() is
non-trivial and actually unnecessary.

So I dunno.  Perhaps we should keep ->invalidatepage() and
->invalidatepage_range() completely separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
