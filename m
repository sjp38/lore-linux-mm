Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 9133E6B0039
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:24:35 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:24:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 03/18] ext4: use ->invalidatepage() length argument
Message-ID: <20130409132433.GC13672@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-4-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-4-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue 09-04-13 11:14:12, Lukas Czerner wrote:
> ->invalidatepage() aop now accepts range to invalidate so we can make
> use of it in all ext4 invalidatepage routines.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> ---
>  fs/ext4/inode.c             |   30 +++++++++++++++++++-----------
>  include/trace/events/ext4.h |   22 ++++++++++++----------
>  2 files changed, 31 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 69595f5..f80e0c3 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -1411,21 +1411,28 @@ static void ext4_da_release_space(struct inode *inode, int to_free)
>  }
>  
>  static void ext4_da_page_release_reservation(struct page *page,
> -					     unsigned long offset)
> +					     unsigned int offset,
> +					     unsigned int length)
>  {
>  	int to_release = 0;
>  	struct buffer_head *head, *bh;
>  	unsigned int curr_off = 0;
>  	struct inode *inode = page->mapping->host;
>  	struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
> +	unsigned int stop = offset + length;
>  	int num_clusters;
>  	ext4_fsblk_t lblk;
>  
> +	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
> +
>  	head = page_buffers(page);
>  	bh = head;
>  	do {
>  		unsigned int next_off = curr_off + bh->b_size;
>  
> +		if (next_off > stop)
> +			break;
> +
>  		if ((offset <= curr_off) && (buffer_delay(bh))) {
>  			to_release++;
>  			clear_buffer_delay(bh);
> @@ -2825,7 +2832,7 @@ static void ext4_da_invalidatepage(struct page *page, unsigned int offset,
>  	if (!page_has_buffers(page))
>  		goto out;
>  
> -	ext4_da_page_release_reservation(page, offset);
> +	ext4_da_page_release_reservation(page, offset, length);
>  
>  out:
>  	ext4_invalidatepage(page, offset, length);
> @@ -2979,29 +2986,29 @@ ext4_readpages(struct file *file, struct address_space *mapping,
>  static void ext4_invalidatepage(struct page *page, unsigned int offset,
>  				unsigned int length)
>  {
> -	trace_ext4_invalidatepage(page, offset);
> +	trace_ext4_invalidatepage(page, offset, length);
>  
>  	/* No journalling happens on data buffers when this function is used */
>  	WARN_ON(page_has_buffers(page) && buffer_jbd(page_buffers(page)));
>  
> -	block_invalidatepage(page, offset, PAGE_CACHE_SIZE - offset);
> +	block_invalidatepage(page, offset, length);
>  }
>  
>  static int __ext4_journalled_invalidatepage(struct page *page,
> -					    unsigned long offset)
> +					    unsigned int offset,
> +					    unsigned int length)
>  {
>  	journal_t *journal = EXT4_JOURNAL(page->mapping->host);
>  
> -	trace_ext4_journalled_invalidatepage(page, offset);
> +	trace_ext4_journalled_invalidatepage(page, offset, length);
>  
>  	/*
>  	 * If it's a full truncate we just forget about the pending dirtying
>  	 */
> -	if (offset == 0)
> +	if (offset == 0 && length == PAGE_CACHE_SIZE)
>  		ClearPageChecked(page);
>  
> -	return jbd2_journal_invalidatepage(journal, page, offset,
> -					   PAGE_CACHE_SIZE - offset);
> +	return jbd2_journal_invalidatepage(journal, page, offset, length);
>  }
>  
>  /* Wrapper for aops... */
> @@ -3009,7 +3016,7 @@ static void ext4_journalled_invalidatepage(struct page *page,
>  					   unsigned int offset,
>  					   unsigned int length)
>  {
> -	WARN_ON(__ext4_journalled_invalidatepage(page, offset) < 0);
> +	WARN_ON(__ext4_journalled_invalidatepage(page, offset, length) < 0);
>  }
>  
>  static int ext4_releasepage(struct page *page, gfp_t wait)
> @@ -4607,7 +4614,8 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
>  				      inode->i_size >> PAGE_CACHE_SHIFT);
>  		if (!page)
>  			return;
> -		ret = __ext4_journalled_invalidatepage(page, offset);
> +		ret = __ext4_journalled_invalidatepage(page, offset,
> +						PAGE_CACHE_SIZE - offset);
>  		unlock_page(page);
>  		page_cache_release(page);
>  		if (ret != -EBUSY)
> diff --git a/include/trace/events/ext4.h b/include/trace/events/ext4.h
> index 58459b7..60b329a 100644
> --- a/include/trace/events/ext4.h
> +++ b/include/trace/events/ext4.h
> @@ -444,16 +444,16 @@ DEFINE_EVENT(ext4__page_op, ext4_releasepage,
>  );
>  
>  DECLARE_EVENT_CLASS(ext4_invalidatepage_op,
> -	TP_PROTO(struct page *page, unsigned long offset),
> +	TP_PROTO(struct page *page, unsigned int offset, unsigned int length),
>  
> -	TP_ARGS(page, offset),
> +	TP_ARGS(page, offset, length),
>  
>  	TP_STRUCT__entry(
>  		__field(	dev_t,	dev			)
>  		__field(	ino_t,	ino			)
>  		__field(	pgoff_t, index			)
> -		__field(	unsigned long, offset		)
> -
> +		__field(	unsigned int, offset		)
> +		__field(	unsigned int, length		)
>  	),
>  
>  	TP_fast_assign(
> @@ -461,24 +461,26 @@ DECLARE_EVENT_CLASS(ext4_invalidatepage_op,
>  		__entry->ino	= page->mapping->host->i_ino;
>  		__entry->index	= page->index;
>  		__entry->offset	= offset;
> +		__entry->length	= length;
>  	),
>  
> -	TP_printk("dev %d,%d ino %lu page_index %lu offset %lu",
> +	TP_printk("dev %d,%d ino %lu page_index %lu offset %u length %u",
>  		  MAJOR(__entry->dev), MINOR(__entry->dev),
>  		  (unsigned long) __entry->ino,
> -		  (unsigned long) __entry->index, __entry->offset)
> +		  (unsigned long) __entry->index,
> +		  __entry->offset, __entry->length)
>  );
>  
>  DEFINE_EVENT(ext4_invalidatepage_op, ext4_invalidatepage,
> -	TP_PROTO(struct page *page, unsigned long offset),
> +	TP_PROTO(struct page *page, unsigned int offset, unsigned int length),
>  
> -	TP_ARGS(page, offset)
> +	TP_ARGS(page, offset, length)
>  );
>  
>  DEFINE_EVENT(ext4_invalidatepage_op, ext4_journalled_invalidatepage,
> -	TP_PROTO(struct page *page, unsigned long offset),
> +	TP_PROTO(struct page *page, unsigned int offset, unsigned int length),
>  
> -	TP_ARGS(page, offset)
> +	TP_ARGS(page, offset, length)
>  );
>  
>  TRACE_EVENT(ext4_discard_blocks,
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
