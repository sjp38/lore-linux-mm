Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51D566B000D
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:49:40 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id w12-v6so13505597otg.2
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:49:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p22-v6si13050734otk.138.2018.05.31.06.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:49:39 -0700 (PDT)
Date: Thu, 31 May 2018 09:49:37 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 16/18] xfs: refactor the tail of xfs_writepage_map
Message-ID: <20180531134937.GJ2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-17-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-17-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:11PM +0200, Christoph Hellwig wrote:
> Rejuggle how we deal with the different error vs non-error and have
> ioends vs not have ioend cases to keep the fast path streamlined, and
> the duplicate code at a minimum.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_aops.c | 65 +++++++++++++++++++++++------------------------
>  1 file changed, 32 insertions(+), 33 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 38021023131e..ac417ef326a9 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -873,7 +873,14 @@ xfs_writepage_map(
>  	 * submission of outstanding ioends on the writepage context so they are
>  	 * treated correctly on error.
>  	 */
> -	if (count) {
> +	if (unlikely(error)) {
> +		if (!count) {
> +			xfs_aops_discard_page(page);
> +			ClearPageUptodate(page);
> +			unlock_page(page);
> +			goto done;
> +		}
> +
>  		/*
>  		 * If the page was not fully cleaned, we need to ensure that the
>  		 * higher layers come back to it correctly.  That means we need
> @@ -882,43 +889,35 @@ xfs_writepage_map(
>  		 * so another attempt to write this page in this writeback sweep
>  		 * will be made.
>  		 */
> -		if (error) {
> -			set_page_writeback_keepwrite(page);
> -		} else {
> -			clear_page_dirty_for_io(page);
> -			set_page_writeback(page);
> -		}
> -		unlock_page(page);
> -
> -		/*
> -		 * Preserve the original error if there was one, otherwise catch
> -		 * submission errors here and propagate into subsequent ioend
> -		 * submissions.
> -		 */
> -		list_for_each_entry_safe(ioend, next, &submit_list, io_list) {
> -			int error2;
> -
> -			list_del_init(&ioend->io_list);
> -			error2 = xfs_submit_ioend(wbc, ioend, error);
> -			if (error2 && !error)
> -				error = error2;
> -		}
> -	} else if (error) {
> -		xfs_aops_discard_page(page);
> -		ClearPageUptodate(page);
> -		unlock_page(page);
> +		set_page_writeback_keepwrite(page);
>  	} else {
> -		/*
> -		 * We can end up here with no error and nothing to write if we
> -		 * race with a partial page truncate on a sub-page block sized
> -		 * filesystem. In that case we need to mark the page clean.
> -		 */
>  		clear_page_dirty_for_io(page);
>  		set_page_writeback(page);
> -		unlock_page(page);
> -		end_page_writeback(page);
>  	}
>  
> +	unlock_page(page);
> +
> +	/*
> +	 * Preserve the original error if there was one, otherwise catch
> +	 * submission errors here and propagate into subsequent ioend
> +	 * submissions.
> +	 */
> +	list_for_each_entry_safe(ioend, next, &submit_list, io_list) {
> +		int error2;
> +
> +		list_del_init(&ioend->io_list);
> +		error2 = xfs_submit_ioend(wbc, ioend, error);
> +		if (error2 && !error)
> +			error = error2;
> +	}
> +
> +	/*
> +	 * We can end up here with no error and nothing to write if we race with
> +	 * a partial page truncate on a sub-page block sized filesystem.
> +	 */
> +	if (!count)
> +		end_page_writeback(page);
> +done:
>  	mapping_set_error(page->mapping, error);
>  	return error;
>  }
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
