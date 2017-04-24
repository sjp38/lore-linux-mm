Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74FDD6B02C6
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:27:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c198so13622121pfc.19
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:27:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b85si19349777pfe.58.2017.04.24.08.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 08:27:09 -0700 (PDT)
Date: Mon, 24 Apr 2017 08:27:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 11/20] cifs: set mapping error when page writeback
 fails in writepage or launder_pages
Message-ID: <20170424152708.GK9112@infradead.org>
References: <20170424132259.8680-1-jlayton@redhat.com>
 <20170424132259.8680-12-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424132259.8680-12-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon, Apr 24, 2017 at 09:22:50AM -0400, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/cifs/file.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 21d404535739..4b696a23b0b1 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -2234,14 +2234,16 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
>  	set_page_writeback(page);
>  retry_write:
>  	rc = cifs_partialpagewrite(page, 0, PAGE_SIZE);
> +	if (rc == -EAGAIN && wbc->sync_mode == WB_SYNC_ALL) {
>  		goto retry_write;
> +	} else if (rc == -EAGAIN) {
>  		redirty_page_for_writepage(wbc, page);
> +	} else if (rc != 0) {
>  		SetPageError(page);
> +		mapping_set_error(page->mapping, rc);
> +	} else {
>  		SetPageUptodate(page);
> +	}

Hmmm.  I might be a little too nitpicky, but I hate having the same
partial condition duplicated if possible.  Why not:

	if (rc == -EAGAIN) {
		if (wbc->sync_mode == WB_SYNC_ALL)
			goto retry_write;
		redirty_page_for_writepage(wbc, page);
	} else if (rc) {
		SetPageError(page);
		mapping_set_error(page->mapping, rc);
	} else {
		SetPageUptodate(page);
	}

Otherwise this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
