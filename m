Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0E56B000A
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:49:36 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id a14-v6so14128118otf.1
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:49:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e9-v6si11385359oiy.330.2018.05.31.06.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:49:35 -0700 (PDT)
Date: Thu, 31 May 2018 09:49:33 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 15/18] xfs: remove xfs_start_page_writeback
Message-ID: <20180531134933.GI2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-16-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-16-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:10PM +0200, Christoph Hellwig wrote:
> This helper only has two callers, one of them with a constant error
> argument.  Remove it to make pending changes to the code a little easier.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_aops.c | 47 +++++++++++++++++++++--------------------------
>  1 file changed, 21 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 025f2acac100..38021023131e 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -495,30 +495,6 @@ xfs_imap_valid(
>  		offset < imap->br_startoff + imap->br_blockcount;
>  }
>  
> -STATIC void
> -xfs_start_page_writeback(
> -	struct page		*page,
> -	int			clear_dirty)
> -{
> -	ASSERT(PageLocked(page));
> -	ASSERT(!PageWriteback(page));
> -
> -	/*
> -	 * if the page was not fully cleaned, we need to ensure that the higher
> -	 * layers come back to it correctly. That means we need to keep the page
> -	 * dirty, and for WB_SYNC_ALL writeback we need to ensure the
> -	 * PAGECACHE_TAG_TOWRITE index mark is not removed so another attempt to
> -	 * write this page in this writeback sweep will be made.
> -	 */
> -	if (clear_dirty) {
> -		clear_page_dirty_for_io(page);
> -		set_page_writeback(page);
> -	} else
> -		set_page_writeback_keepwrite(page);
> -
> -	unlock_page(page);
> -}
> -
>  /*
>   * Submit the bio for an ioend. We are passed an ioend with a bio attached to
>   * it, and we submit that bio. The ioend may be used for multiple bio
> @@ -877,6 +853,9 @@ xfs_writepage_map(
>  	ASSERT(wpc->ioend || list_empty(&submit_list));
>  
>  out:
> +	ASSERT(PageLocked(page));
> +	ASSERT(!PageWriteback(page));
> +
>  	/*
>  	 * On error, we have to fail the ioend here because we have locked
>  	 * buffers in the ioend. If we don't do this, we'll deadlock
> @@ -895,7 +874,21 @@ xfs_writepage_map(
>  	 * treated correctly on error.
>  	 */
>  	if (count) {
> -		xfs_start_page_writeback(page, !error);
> +		/*
> +		 * If the page was not fully cleaned, we need to ensure that the
> +		 * higher layers come back to it correctly.  That means we need
> +		 * to keep the page dirty, and for WB_SYNC_ALL writeback we need
> +		 * to ensure the PAGECACHE_TAG_TOWRITE index mark is not removed
> +		 * so another attempt to write this page in this writeback sweep
> +		 * will be made.
> +		 */
> +		if (error) {
> +			set_page_writeback_keepwrite(page);
> +		} else {
> +			clear_page_dirty_for_io(page);
> +			set_page_writeback(page);
> +		}
> +		unlock_page(page);
>  
>  		/*
>  		 * Preserve the original error if there was one, otherwise catch
> @@ -920,7 +913,9 @@ xfs_writepage_map(
>  		 * race with a partial page truncate on a sub-page block sized
>  		 * filesystem. In that case we need to mark the page clean.
>  		 */
> -		xfs_start_page_writeback(page, 1);
> +		clear_page_dirty_for_io(page);
> +		set_page_writeback(page);
> +		unlock_page(page);
>  		end_page_writeback(page);
>  	}
>  
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
