Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA0196B02FD
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:33:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so22435044wrd.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:33:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6si13516981wrc.74.2017.06.20.08.33.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 08:33:23 -0700 (PDT)
Date: Tue, 20 Jun 2017 17:33:21 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 01/22] fs: remove call_fsync helper function
Message-ID: <20170620153321.GC31922@quack2.suse.cz>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-2-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-2-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri 16-06-17 15:34:06, Jeff Layton wrote:
> Requested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>
	
								Honza
> ---
>  fs/sync.c          | 2 +-
>  include/linux/fs.h | 6 ------
>  ipc/shm.c          | 2 +-
>  3 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/sync.c b/fs/sync.c
> index 11ba023434b1..2a54c1f22035 100644
> --- a/fs/sync.c
> +++ b/fs/sync.c
> @@ -192,7 +192,7 @@ int vfs_fsync_range(struct file *file, loff_t start, loff_t end, int datasync)
>  		spin_unlock(&inode->i_lock);
>  		mark_inode_dirty_sync(inode);
>  	}
> -	return call_fsync(file, start, end, datasync);
> +	return file->f_op->fsync(file, start, end, datasync);
>  }
>  EXPORT_SYMBOL(vfs_fsync_range);
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 4929a8f28cc3..1a135274b4f8 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1740,12 +1740,6 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
>  	return file->f_op->mmap(file, vma);
>  }
>  
> -static inline int call_fsync(struct file *file, loff_t start, loff_t end,
> -			     int datasync)
> -{
> -	return file->f_op->fsync(file, start, end, datasync);
> -}
> -
>  ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
>  			      unsigned long nr_segs, unsigned long fast_segs,
>  			      struct iovec *fast_pointer,
> diff --git a/ipc/shm.c b/ipc/shm.c
> index ec5688e98f25..28a444861a8f 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -453,7 +453,7 @@ static int shm_fsync(struct file *file, loff_t start, loff_t end, int datasync)
>  
>  	if (!sfd->file->f_op->fsync)
>  		return -EINVAL;
> -	return call_fsync(sfd->file, start, end, datasync);
> +	return sfd->file->f_op->fsync(sfd->file, start, end, datasync);
>  }
>  
>  static long shm_fallocate(struct file *file, int mode, loff_t offset,
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
