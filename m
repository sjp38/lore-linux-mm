Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9C156B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:52:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p45so14103420qtg.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:52:17 -0700 (PDT)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id c24si5492722qtc.31.2017.06.29.10.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 10:52:16 -0700 (PDT)
Received: by mail-qk0-f172.google.com with SMTP id p21so82685960qke.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:52:16 -0700 (PDT)
Message-ID: <1498758733.22569.11.camel@redhat.com>
Subject: Re: [PATCH v8 10/18] fs: new infrastructure for writeback error
 handling and reporting
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 29 Jun 2017 13:52:13 -0400
In-Reply-To: <20170629131954.28733-11-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
	 <20170629131954.28733-11-jlayton@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Thu, 2017-06-29 at 09:19 -0400, jlayton@kernel.org wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> Most filesystems currently use mapping_set_error and
> filemap_check_errors for setting and reporting/clearing writeback errors
> at the mapping level. filemap_check_errors is indirectly called from
> most of the filemap_fdatawait_* functions and from
> filemap_write_and_wait*. These functions are called from all sorts of
> contexts to wait on writeback to finish -- e.g. mostly in fsync, but
> also in truncate calls, getattr, etc.
> 
> The non-fsync callers are problematic. We should be reporting writeback
> errors during fsync, but many places spread over the tree clear out
> errors before they can be properly reported, or report errors at
> nonsensical times.
> 
> If I get -EIO on a stat() call, there is no reason for me to assume that
> it is because some previous writeback failed. The fact that it also
> clears out the error such that a subsequent fsync returns 0 is a bug,
> and a nasty one since that's potentially silent data corruption.
> 
> This patch adds a small bit of new infrastructure for setting and
> reporting errors during address_space writeback. While the above was my
> original impetus for adding this, I think it's also the case that
> current fsync semantics are just problematic for userland. Most
> applications that call fsync do so to ensure that the data they wrote
> has hit the backing store.
> 
> In the case where there are multiple writers to the file at the same
> time, this is really hard to determine. The first one to call fsync will
> see any stored error, and the rest get back 0. The processes with open
> fds may not be associated with one another in any way. They could even
> be in different containers, so ensuring coordination between all fsync
> callers is not really an option.
> 
> One way to remedy this would be to track what file descriptor was used
> to dirty the file, but that's rather cumbersome and would likely be
> slow. However, there is a simpler way to improve the semantics here
> without incurring too much overhead.
> 
> This set adds an errseq_t to struct address_space, and a corresponding
> one is added to struct file. Writeback errors are recorded in the
> mapping's errseq_t, and the one in struct file is used as the "since"
> value.
> 
> This changes the semantics of the Linux fsync implementation such that
> applications can now use it to determine whether there were any
> writeback errors since fsync(fd) was last called (or since the file was
> opened in the case of fsync having never been called).
> 
> Note that those writeback errors may have occurred when writing data
> that was dirtied via an entirely different fd, but that's the case now
> with the current mapping_set_error/filemap_check_error infrastructure.
> This will at least prevent you from getting a false report of success.
> 
> The new behavior is still consistent with the POSIX spec, and is more
> reliable for application developers. This patch just adds some basic
> infrastructure for doing this, and ensures that the f_wb_err "cursor"
> is properly set when a file is opened. Later patches will change the
> existing code to use this new infrastructure for reporting errors at
> fsync time.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---
>  drivers/dax/device.c           |  1 +
>  fs/block_dev.c                 |  1 +
>  fs/file_table.c                |  1 +
>  fs/open.c                      |  3 ++
>  include/linux/fs.h             | 60 ++++++++++++++++++++++++++++-
>  include/trace/events/filemap.h | 57 ++++++++++++++++++++++++++++
>  mm/filemap.c                   | 86 ++++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 208 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index 006e657dfcb9..12943d19bfc4 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -499,6 +499,7 @@ static int dax_open(struct inode *inode, struct file *filp)
>  	inode->i_mapping = __dax_inode->i_mapping;
>  	inode->i_mapping->host = __dax_inode;
>  	filp->f_mapping = inode->i_mapping;
> +	filp->f_wb_err = filemap_sample_wb_err(filp->f_mapping);
>  	filp->private_data = dev_dax;
>  	inode->i_flags = S_DAX;
>  
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 519599dddd36..4d62fe771587 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -1743,6 +1743,7 @@ static int blkdev_open(struct inode * inode, struct file * filp)
>  		return -ENOMEM;
>  
>  	filp->f_mapping = bdev->bd_inode->i_mapping;
> +	filp->f_wb_err = filemap_sample_wb_err(filp->f_mapping);
>  
>  	return blkdev_get(bdev, filp->f_mode, filp);
>  }
> diff --git a/fs/file_table.c b/fs/file_table.c
> index 954d510b765a..72e861a35a7f 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -168,6 +168,7 @@ struct file *alloc_file(const struct path *path, fmode_t mode,
>  	file->f_path = *path;
>  	file->f_inode = path->dentry->d_inode;
>  	file->f_mapping = path->dentry->d_inode->i_mapping;
> +	file->f_wb_err = filemap_sample_wb_err(file->f_mapping);
>  	if ((mode & FMODE_READ) &&
>  	     likely(fop->read || fop->read_iter))
>  		mode |= FMODE_CAN_READ;
> diff --git a/fs/open.c b/fs/open.c
> index cd0c5be8d012..280d4a963791 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -707,6 +707,9 @@ static int do_dentry_open(struct file *f,
>  	f->f_inode = inode;
>  	f->f_mapping = inode->i_mapping;
>  
> +	/* Ensure that we skip any errors that predate opening of the file */
> +	f->f_wb_err = filemap_sample_wb_err(f->f_mapping);
> +
>  	if (unlikely(f->f_flags & O_PATH)) {
>  		f->f_mode = FMODE_PATH;
>  		f->f_op = &empty_fops;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 74872c0f1c07..b524fd442057 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -30,7 +30,7 @@
>  #include <linux/percpu-rwsem.h>
>  #include <linux/workqueue.h>
>  #include <linux/delayed_call.h>
> -
> +#include <linux/errseq.h>
>  #include <asm/byteorder.h>
>  #include <uapi/linux/fs.h>
>  
> @@ -392,6 +392,7 @@ struct address_space {
>  	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
>  	struct list_head	private_list;	/* ditto */
>  	void			*private_data;	/* ditto */
> +	errseq_t		wb_err;
>  } __attribute__((aligned(sizeof(long))));
>  	/*
>  	 * On most architectures that alignment is already the case; but
> @@ -846,6 +847,7 @@ struct file {
>  	 * Must not be taken from IRQ context.
>  	 */
>  	spinlock_t		f_lock;
> +	errseq_t		f_wb_err;
>  	atomic_long_t		f_count;
>  	unsigned int 		f_flags;
>  	fmode_t			f_mode;
> @@ -2520,6 +2522,62 @@ extern int filemap_fdatawrite_range(struct address_space *mapping,
>  				loff_t start, loff_t end);
>  extern int filemap_check_errors(struct address_space *mapping);
>  
> +extern void __filemap_set_wb_err(struct address_space *mapping, int err);
> +extern int __must_check file_check_and_advance_wb_err(struct file *file);
> +extern int __must_check file_write_and_wait_range(struct file *file,
> +						loff_t start, loff_t end);
> +
> +/**
> + * filemap_set_wb_err - set a writeback error on an address_space
> + * @mapping: mapping in which to set writeback error
> + * @err: error to be set in mapping
> + *
> + * When writeback fails in some way, we must record that error so that
> + * userspace can be informed when fsync and the like are called.  We endeavor
> + * to report errors on any file that was open at the time of the error.  Some
> + * internal callers also need to know when writeback errors have occurred.
> + *
> + * When a writeback error occurs, most filesystems will want to call
> + * filemap_set_wb_err to record the error in the mapping so that it will be
> + * automatically reported whenever fsync is called on the file.
> + *
> + * FIXME: mention FS_* flag here?
> + */
> +static inline void filemap_set_wb_err(struct address_space *mapping, int err)
> +{
> +	/* Fastpath for common case of no error */
> +	if (unlikely(err))
> +		__filemap_set_wb_err(mapping, err);
> +}
> +
> +/**
> + * filemap_check_wb_error - has an error occurred since the mark was sampled?
> + * @mapping: mapping to check for writeback errors
> + * @since: previously-sampled errseq_t
> + *
> + * Grab the errseq_t value from the mapping, and see if it has changed "since"
> + * the given value was sampled.
> + *
> + * If it has then report the latest error set, otherwise return 0.
> + */
> +static inline int filemap_check_wb_err(struct address_space *mapping,
> +					errseq_t since)
> +{
> +	return errseq_check(&mapping->wb_err, since);
> +}
> +
> +/**
> + * filemap_sample_wb_err - sample the current errseq_t to test for later errors
> + * @mapping: mapping to be sampled
> + *
> + * Writeback errors are always reported relative to a particular sample point
> + * in the past. This function provides those sample points.
> + */
> +static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
> +{
> +	return errseq_sample(&mapping->wb_err);
> +}
> +
>  extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
>  			   int datasync);
>  extern int vfs_fsync(struct file *file, int datasync);
> diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
> index 42febb6bc1d5..ff91325b8123 100644
> --- a/include/trace/events/filemap.h
> +++ b/include/trace/events/filemap.h
> @@ -10,6 +10,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/device.h>
>  #include <linux/kdev_t.h>
> +#include <linux/errseq.h>
>  
>  DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
>  
> @@ -52,6 +53,62 @@ DEFINE_EVENT(mm_filemap_op_page_cache, mm_filemap_add_to_page_cache,
>  	TP_ARGS(page)
>  	);
>  
> +TRACE_EVENT(filemap_set_wb_err,
> +		TP_PROTO(struct address_space *mapping, errseq_t eseq),
> +
> +		TP_ARGS(mapping, eseq),
> +
> +		TP_STRUCT__entry(
> +			__field(unsigned long, i_ino)
> +			__field(dev_t, s_dev)
> +			__field(errseq_t, errseq)
> +		),
> +
> +		TP_fast_assign(
> +			__entry->i_ino = mapping->host->i_ino;
> +			__entry->errseq = eseq;
> +			if (mapping->host->i_sb)
> +				__entry->s_dev = mapping->host->i_sb->s_dev;
> +			else
> +				__entry->s_dev = mapping->host->i_rdev;
> +		),
> +
> +		TP_printk("dev=%d:%d ino=0x%lx errseq=0x%x",
> +			MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
> +			__entry->i_ino, __entry->errseq)
> +);
> +
> +TRACE_EVENT(file_check_and_advance_wb_err,
> +		TP_PROTO(struct file *file, errseq_t old),
> +
> +		TP_ARGS(file, old),
> +
> +		TP_STRUCT__entry(
> +			__field(struct file *, file);
> +			__field(unsigned long, i_ino)
> +			__field(dev_t, s_dev)
> +			__field(errseq_t, old)
> +			__field(errseq_t, new)
> +		),
> +
> +		TP_fast_assign(
> +			__entry->file = file;
> +			__entry->i_ino = file->f_mapping->host->i_ino;
> +			if (file->f_mapping->host->i_sb)
> +				__entry->s_dev =
> +					file->f_mapping->host->i_sb->s_dev;
> +			else
> +				__entry->s_dev =
> +					file->f_mapping->host->i_rdev;
> +			__entry->old = old;
> +			__entry->new = file->f_wb_err;
> +		),
> +
> +		TP_printk("file=%p dev=%d:%d ino=0x%lx old=0x%x new=0x%x",
> +			__entry->file, MAJOR(__entry->s_dev),
> +			MINOR(__entry->s_dev), __entry->i_ino, __entry->old,
> +			__entry->new)
> +);
>  #endif /* _TRACE_FILEMAP_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/filemap.c b/mm/filemap.c
> index eb99b5f23c61..5d03381dc0e0 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -553,6 +553,92 @@ int filemap_write_and_wait_range(struct address_space *mapping,
>  }
>  EXPORT_SYMBOL(filemap_write_and_wait_range);
>  
> +void __filemap_set_wb_err(struct address_space *mapping, int err)
> +{
> +	errseq_t eseq = __errseq_set(&mapping->wb_err, err);
> +
> +	trace_filemap_set_wb_err(mapping, eseq);
> +}
> +EXPORT_SYMBOL(__filemap_set_wb_err);
> +
> +/**
> + * file_check_and_advance_wb_err - report wb error (if any) that was previously
> + * 				   and advance wb_err to current one
> + * @file: struct file on which the error is being reported
> + *
> + * When userland calls fsync (or something like nfsd does the equivalent), we
> + * want to report any writeback errors that occurred since the last fsync (or
> + * since the file was opened if there haven't been any).
> + *
> + * Grab the wb_err from the mapping. If it matches what we have in the file,
> + * then just quickly return 0. The file is all caught up.
> + *
> + * If it doesn't match, then take the mapping value, set the "seen" flag in
> + * it and try to swap it into place. If it works, or another task beat us
> + * to it with the new value, then update the f_wb_err and return the error
> + * portion. The error at this point must be reported via proper channels
> + * (a'la fsync, or NFS COMMIT operation, etc.).
> + *
> + * While we handle mapping->wb_err with atomic operations, the f_wb_err
> + * value is protected by the f_lock since we must ensure that it reflects
> + * the latest value swapped in for this file descriptor.
> + */
> +int file_check_and_advance_wb_err(struct file *file)
> +{
> +	int err = 0;
> +	errseq_t old = READ_ONCE(file->f_wb_err);
> +	struct address_space *mapping = file->f_mapping;
> +
> +	/* Locklessly handle the common case where nothing has changed */
> +	if (errseq_check(&mapping->wb_err, old)) {
> +		/* Something changed, must use slow path */
> +		spin_lock(&file->f_lock);
> +		old = file->f_wb_err;
> +		err = errseq_check_and_advance(&mapping->wb_err,
> +						&file->f_wb_err);
> +		trace_file_check_and_advance_wb_err(file, old);
> +		spin_unlock(&file->f_lock);
> +	}
> +	return err;
> +}
> +EXPORT_SYMBOL(file_check_and_advance_wb_err);
> +
> +/**
> + * file_write_and_wait_range - write out & wait on a file range
> + * @file:	file pointing to address_space with pages
> + * @lstart:	offset in bytes where the range starts
> + * @lend:	offset in bytes where the range ends (inclusive)
> + *
> + * Write out and wait upon file offsets lstart->lend, inclusive.
> + *
> + * Note that @lend is inclusive (describes the last byte to be written) so
> + * that this function can be used to write to the very end-of-file (end = -1).
> + *
> + * After writing out and waiting on the data, we check and advance the
> + * f_wb_err cursor to the latest value, and return any errors detected there.
> + */
> +int file_write_and_wait_range(struct file *file, loff_t lstart, loff_t lend)
> +{
> +	int err = 0;
> +	struct address_space *mapping = file->f_mapping;
> +
> +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> +		int err2;
> +
> +		err = __filemap_fdatawrite_range(mapping, lstart, lend,
> +						 WB_SYNC_ALL);
> +		/* See comment of filemap_write_and_wait() */
> +		if (err != -EIO)
> +			__filemap_fdatawait_range(mapping, lstart, lend);
> +		err2 = file_check_and_advance_wb_err(file);
> +		if (!err)
> +			err = err2;

Braino on my part here.

We need to do the check and advance unconditionally in this function to
handle the case where the nrpages and/or nrexceptional are 0. Fixed in
my tree.

> +	}
> +	return err;
> +}
> +EXPORT_SYMBOL(file_write_and_wait_range);
> +
>  /**
>   * replace_page_cache_page - replace a pagecache page with a new one
>   * @old:	page to be replaced

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
