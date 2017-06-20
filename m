Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6A0A6B02FA
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:32:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so9799597wrz.10
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:32:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d30si14003549wrd.222.2017.06.20.08.32.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 08:32:46 -0700 (PDT)
Date: Tue, 20 Jun 2017 17:32:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 05/22] jbd2: don't clear and reset errors after
 waiting on writeback
Message-ID: <20170620153243.GB31922@quack2.suse.cz>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-6-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-6-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri 16-06-17 15:34:10, Jeff Layton wrote:
> Resetting this flag is almost certainly racy, and will be problematic
> with some coming changes.
> 
> Make filemap_fdatawait_keep_errors return int, but not clear the flag(s).
> Have jbd2 call it instead of filemap_fdatawait and don't attempt to
> re-set the error flag if it fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/jbd2/commit.c   | 15 +++------------
>  include/linux/fs.h |  2 +-
>  mm/filemap.c       | 16 ++++++++++++++--
>  3 files changed, 18 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
> index b6b194ec1b4f..502110540598 100644
> --- a/fs/jbd2/commit.c
> +++ b/fs/jbd2/commit.c
> @@ -263,18 +263,9 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
>  			continue;
>  		jinode->i_flags |= JI_COMMIT_RUNNING;
>  		spin_unlock(&journal->j_list_lock);
> -		err = filemap_fdatawait(jinode->i_vfs_inode->i_mapping);
> -		if (err) {
> -			/*
> -			 * Because AS_EIO is cleared by
> -			 * filemap_fdatawait_range(), set it again so
> -			 * that user process can get -EIO from fsync().
> -			 */
> -			mapping_set_error(jinode->i_vfs_inode->i_mapping, -EIO);
> -
> -			if (!ret)
> -				ret = err;
> -		}
> +		err = filemap_fdatawait_keep_errors(jinode->i_vfs_inode->i_mapping);
> +		if (!ret)
> +			ret = err;
>  		spin_lock(&journal->j_list_lock);
>  		jinode->i_flags &= ~JI_COMMIT_RUNNING;
>  		smp_mb();
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1a135274b4f8..1b1233a1db1e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2509,7 +2509,7 @@ extern int write_inode_now(struct inode *, int);
>  extern int filemap_fdatawrite(struct address_space *);
>  extern int filemap_flush(struct address_space *);
>  extern int filemap_fdatawait(struct address_space *);
> -extern void filemap_fdatawait_keep_errors(struct address_space *);
> +extern int filemap_fdatawait_keep_errors(struct address_space *);
>  extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
>  				   loff_t lend);
>  extern int filemap_write_and_wait(struct address_space *mapping);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b9e870600572..37f286df7c95 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -311,6 +311,16 @@ int filemap_check_errors(struct address_space *mapping)
>  }
>  EXPORT_SYMBOL(filemap_check_errors);
>  
> +static int filemap_check_and_keep_errors(struct address_space *mapping)
> +{
> +	/* Check for outstanding write errors */
> +	if (test_bit(AS_EIO, &mapping->flags))
> +		return -EIO;
> +	if (test_bit(AS_ENOSPC, &mapping->flags))
> +		return -ENOSPC;
> +	return 0;
> +}
> +
>  /**
>   * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
>   * @mapping:	address space structure to write
> @@ -455,15 +465,17 @@ EXPORT_SYMBOL(filemap_fdatawait_range);
>   * call sites are system-wide / filesystem-wide data flushers: e.g. sync(2),
>   * fsfreeze(8)
>   */
> -void filemap_fdatawait_keep_errors(struct address_space *mapping)
> +int filemap_fdatawait_keep_errors(struct address_space *mapping)
>  {
>  	loff_t i_size = i_size_read(mapping->host);
>  
>  	if (i_size == 0)
> -		return;
> +		return 0;
>  
>  	__filemap_fdatawait_range(mapping, 0, i_size - 1);
> +	return filemap_check_and_keep_errors(mapping);
>  }
> +EXPORT_SYMBOL(filemap_fdatawait_keep_errors);
>  
>  /**
>   * filemap_fdatawait - wait for all under-writeback pages to complete
> -- 
> 2.13.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
