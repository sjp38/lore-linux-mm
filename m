Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1FB6B0315
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:18:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j186so89632007pge.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:18:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i62si3811071pfi.231.2017.06.29.07.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 07:18:15 -0700 (PDT)
Date: Thu, 29 Jun 2017 07:17:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v8 18/18] btrfs: minimal conversion to errseq_t writeback
 error reporting on fsync
Message-ID: <20170629141741.GC17251@infradead.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
 <20170629131954.28733-19-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629131954.28733-19-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Thu, Jun 29, 2017 at 09:19:54AM -0400, jlayton@kernel.org wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> Just check and advance the errseq_t in the file before returning.
> Internal callers of filemap_* functions are left as-is.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/btrfs/file.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
> index da1096eb1a40..1f57e1a523d9 100644
> --- a/fs/btrfs/file.c
> +++ b/fs/btrfs/file.c
> @@ -2011,7 +2011,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
>  	struct btrfs_root *root = BTRFS_I(inode)->root;
>  	struct btrfs_trans_handle *trans;
>  	struct btrfs_log_ctx ctx;
> -	int ret = 0;
> +	int ret = 0, err;
>  	bool full_sync = 0;
>  	u64 len;
>  
> @@ -2030,7 +2030,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
>  	 */
>  	ret = start_ordered_ops(inode, start, end);
>  	if (ret)
> -		return ret;
> +		goto out;
>  
>  	inode_lock(inode);
>  	atomic_inc(&root->log_batch);
> @@ -2227,6 +2227,9 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
>  		ret = btrfs_end_transaction(trans);
>  	}
>  out:
> +	err = file_check_and_advance_wb_err(file);
> +	if (!ret)
> +		ret = err;
>  	return ret > 0 ? -EIO : ret;

This means that we'll lose the exact error returned from
start_ordered_ops.  Beyond that I can't really provide good feedback
as the btrfs fsync code looks so much different from all the other
fs fsync code..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
