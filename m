Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6DA72808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:14:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z88so7698608wrc.9
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:14:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si3806141wma.6.2017.05.10.04.14.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 04:14:48 -0700 (PDT)
Date: Wed, 10 May 2017 13:14:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 12/27] cifs: set mapping error when page writeback
 fails in writepage or launder_pages
Message-ID: <20170510111446.GD25137@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-13-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-13-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue 09-05-17 11:49:15, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/cifs/file.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 21d404535739..0bee7f8d91ad 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -2234,14 +2234,16 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
>  	set_page_writeback(page);
>  retry_write:
>  	rc = cifs_partialpagewrite(page, 0, PAGE_SIZE);
> -	if (rc == -EAGAIN && wbc->sync_mode == WB_SYNC_ALL)
> -		goto retry_write;
> -	else if (rc == -EAGAIN)
> +	if (rc == -EAGAIN) {
> +		if (wbc->sync_mode == WB_SYNC_ALL)
> +			goto retry_write;
>  		redirty_page_for_writepage(wbc, page);
> -	else if (rc != 0)
> +	} else if (rc != 0) {
>  		SetPageError(page);
> -	else
> +		mapping_set_error(page->mapping, rc);
> +	} else {
>  		SetPageUptodate(page);
> +	}
>  	end_page_writeback(page);
>  	put_page(page);
>  	free_xid(xid);
> -- 
> 2.9.3
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
