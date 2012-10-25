Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 029106B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 15:45:53 -0400 (EDT)
Date: Thu, 25 Oct 2012 21:45:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3] ext3: introduce ext3_error_remove_page
Message-ID: <20121025194551.GE3262@quack.suse.cz>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351177969-893-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu 25-10-12 11:12:49, Naoya Horiguchi wrote:
> What I suggested in the previous patch for ext4 is ditto with ext3,
> so do the same thing for ext3.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/ext3/inode.c | 33 ++++++++++++++++++++++++++++++---
>  1 file changed, 30 insertions(+), 3 deletions(-)
> 
> diff --git v3.7-rc2.orig/fs/ext3/inode.c v3.7-rc2/fs/ext3/inode.c
> index 7e87e37..7f708bf 100644
> --- v3.7-rc2.orig/fs/ext3/inode.c
> +++ v3.7-rc2/fs/ext3/inode.c
> @@ -1967,6 +1967,33 @@ static int ext3_journalled_set_page_dirty(struct page *page)
>  	return __set_page_dirty_nobuffers(page);
>  }
>  
> +static int ext3_error_remove_page(struct address_space *mapping,
> +				struct page *page)
> +{
> +	struct inode *inode = mapping->host;
> +	struct buffer_head *bh, *head;
> +	ext3_fsblk_t block = 0;
> +
> +	if (!PageDirty(page) || !page_has_buffers(page))
> +		goto remove_page;
> +
> +	/* Lost data. Handle as critical fs error. */
> +	bh = head = page_buffers(page);
> +	do {
> +		if (buffer_dirty(bh)) {
  For ext3, you should check that buffer_mapped() is set because we can
have dirty and unmapped buffers. Otherwise the patch looks OK.

> +			block = bh->b_blocknr;
> +			ext3_error(inode->i_sb, "ext3_error_remove_page",
> +				"inode #%lu: block %lu: "
> +				"Removing dirty pagecache page",
> +				inode->i_ino, block);
> +		}
> +		bh = bh->b_this_page;
> +	} while (bh != head);
> +
> +remove_page:
> +	return generic_error_remove_page(mapping, page);
> +}
> +
>  static const struct address_space_operations ext3_ordered_aops = {
>  	.readpage		= ext3_readpage,
>  	.readpages		= ext3_readpages,
> @@ -1979,7 +2006,7 @@ static const struct address_space_operations ext3_ordered_aops = {
>  	.direct_IO		= ext3_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> -	.error_remove_page	= generic_error_remove_page,
> +	.error_remove_page	= ext3_error_remove_page,
>  };
>  
>  static const struct address_space_operations ext3_writeback_aops = {
> @@ -1994,7 +2021,7 @@ static const struct address_space_operations ext3_writeback_aops = {
>  	.direct_IO		= ext3_direct_IO,
>  	.migratepage		= buffer_migrate_page,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> -	.error_remove_page	= generic_error_remove_page,
> +	.error_remove_page	= ext3_error_remove_page,
>  };
>  
>  static const struct address_space_operations ext3_journalled_aops = {
> @@ -2008,7 +2035,7 @@ static const struct address_space_operations ext3_journalled_aops = {
>  	.invalidatepage		= ext3_invalidatepage,
>  	.releasepage		= ext3_releasepage,
>  	.is_partially_uptodate  = block_is_partially_uptodate,
> -	.error_remove_page	= generic_error_remove_page,
> +	.error_remove_page	= ext3_error_remove_page,
>  };
>  
>  void ext3_set_aops(struct inode *inode)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
