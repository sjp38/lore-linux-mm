Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EB0726B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:52:17 -0400 (EDT)
Date: Tue, 4 Sep 2012 10:52:13 -0400
Subject: Re: [PATCH 02/15 v2] jbd2: implement
 jbd2_journal_invalidatepage_range
Message-ID: <20120904145213.GA26656@fieldses.org>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
 <1346451711-1931-3-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346451711-1931-3-git-send-email-lczerner@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Fri, Aug 31, 2012 at 06:21:38PM -0400, Lukas Czerner wrote:
> mm now supports invalidatepage_range address space operation and there
> are two file system using jbd2 also implementing punch hole feature
> which can benefit from this. We need to implement the same thing for
> jbd2 layer in order to allow those file system take benefit of this
> functionality.
> 
> With new function jbd2_journal_invalidatepage_range() we can now specify
> length to invalidate, rather than assuming invalidate to the end of the
> page.
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> ---
>  fs/jbd2/journal.c     |    1 +
>  fs/jbd2/transaction.c |   19 +++++++++++++++++--
>  include/linux/jbd2.h  |    2 ++
>  3 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index e149b99..e4618e9 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -86,6 +86,7 @@ EXPORT_SYMBOL(jbd2_journal_force_commit_nested);
>  EXPORT_SYMBOL(jbd2_journal_wipe);
>  EXPORT_SYMBOL(jbd2_journal_blocks_per_page);
>  EXPORT_SYMBOL(jbd2_journal_invalidatepage);
> +EXPORT_SYMBOL(jbd2_journal_invalidatepage_range);
>  EXPORT_SYMBOL(jbd2_journal_try_to_free_buffers);
>  EXPORT_SYMBOL(jbd2_journal_force_commit);
>  EXPORT_SYMBOL(jbd2_journal_file_inode);
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index fb1ab953..65c1374 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -1993,10 +1993,20 @@ zap_buffer_unlocked:
>   *
>   */
>  void jbd2_journal_invalidatepage(journal_t *journal,
> -		      struct page *page,
> -		      unsigned long offset)
> +				 struct page *page,
> +				 unsigned long offset)
> +{
> +	jbd2_journal_invalidatepage_range(journal, page, offset,
> +					  PAGE_CACHE_SIZE - offset);
> +}
> +
> +void jbd2_journal_invalidatepage_range(journal_t *journal,
> +				       struct page *page,
> +				       unsigned int offset,
> +				       unsigned int length)
>  {
>  	struct buffer_head *head, *bh, *next;
> +	unsigned int stop = offset + length;
>  	unsigned int curr_off = 0;
>  	int may_free = 1;
>  
> @@ -2005,6 +2015,8 @@ void jbd2_journal_invalidatepage(journal_t *journal,
>  	if (!page_has_buffers(page))
>  		return;
>  
> +	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);

This misses e.g. length == (unsigned int)(-1), offset = 1.  Could make
it obvious with:

	BUG_ON(offset > PAGE_CACHE_SIZE || length > PAGE_CACHE_SIZE);
	BUG_ON(stop > PAGE_CACHE_SIZE);

Or is that overkill?

--b.

> +
>  	/* We will potentially be playing with lists other than just the
>  	 * data lists (especially for journaled data mode), so be
>  	 * cautious in our locking. */
> @@ -2014,6 +2026,9 @@ void jbd2_journal_invalidatepage(journal_t *journal,
>  		unsigned int next_off = curr_off + bh->b_size;
>  		next = bh->b_this_page;
>  
> +		if (next_off > stop)
> +			return;
> +
>  		if (offset <= curr_off) {
>  			/* This block is wholly outside the truncation point */
>  			lock_buffer(bh);
> diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
> index 3efc43f..21288fa 100644
> --- a/include/linux/jbd2.h
> +++ b/include/linux/jbd2.h
> @@ -1101,6 +1101,8 @@ extern int	 jbd2_journal_forget (handle_t *, struct buffer_head *);
>  extern void	 journal_sync_buffer (struct buffer_head *);
>  extern void	 jbd2_journal_invalidatepage(journal_t *,
>  				struct page *, unsigned long);
> +extern void	 jbd2_journal_invalidatepage_range(journal_t *, struct page *,
> +						   unsigned int, unsigned int);
>  extern int	 jbd2_journal_try_to_free_buffers(journal_t *, struct page *, gfp_t);
>  extern int	 jbd2_journal_stop(handle_t *);
>  extern int	 jbd2_journal_flush (journal_t *);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
