Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A4C376B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 09:41:08 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so28289500pdj.13
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 06:41:08 -0800 (PST)
Received: from mx12.netapp.com (mx12.netapp.com. [216.240.18.77])
        by mx.google.com with ESMTPS id e1si66957230pdo.117.2015.01.05.06.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 06:41:07 -0800 (PST)
Message-ID: <54AAA27C.6040906@Netapp.com>
Date: Mon, 5 Jan 2015 09:41:00 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/5] nfs: don't dirty ITER_BVEC pages read through
 direct I/O
References: <cover.1419044605.git.osandov@osandov.com> <b42b9a61d22260ee44b312d0119f1856e8f5840d.1419044605.git.osandov@osandov.com>
In-Reply-To: <b42b9a61d22260ee44b312d0119f1856e8f5840d.1419044605.git.osandov@osandov.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Omar,

On 12/19/2014 10:18 PM, Omar Sandoval wrote:
> As with the generic blockdev code, kernel pages shouldn't be dirtied by
> the direct I/O path.
> 
> Signed-off-by: Omar Sandoval <osandov@osandov.com>
> ---
>  fs/nfs/direct.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 10bf072..b6ca65c 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -88,6 +88,7 @@ struct nfs_direct_req {
>  	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
>  	struct work_struct	work;
>  	int			flags;
> +	int			should_dirty;	/* should we mark read pages dirty? */
>  #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
>  #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
>  	struct nfs_writeverf	verf;		/* unstable write verifier */

Can you add should_dirty after the NFS_ODIRECT_* flags?

Thanks,
Anna

> @@ -370,7 +371,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
>  		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
>  		struct page *page = req->wb_page;
>  
> -		if (!PageCompound(page) && bytes < hdr->good_bytes)
> +		if (!PageCompound(page) && bytes < hdr->good_bytes &&
> +		    dreq->should_dirty)
>  			set_page_dirty(page);
>  		bytes += req->wb_bytes;
>  		nfs_list_remove_request(req);
> @@ -542,6 +544,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
>  	dreq->inode = inode;
>  	dreq->bytes_left = count;
>  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
> +	dreq->should_dirty = !iov_iter_is_bvec(iter);
>  	l_ctx = nfs_get_lock_context(dreq->ctx);
>  	if (IS_ERR(l_ctx)) {
>  		result = PTR_ERR(l_ctx);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
