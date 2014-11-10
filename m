Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 00237280012
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 11:08:00 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so8541597pab.32
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 08:08:00 -0800 (PST)
Date: Mon, 10 Nov 2014 08:07:58 -0800 (PST)
From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH v5 7/7] fs: add a flag for per-operation O_DSYNC
 semantics
In-Reply-To: <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
Message-ID: <alpine.DEB.2.00.1411100807350.11379@cobra.newdream.net>
References: <cover.1415220890.git.milosz@adfin.com> <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Mel Gorman <mgorman@suse.de>, Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>, Jeff Moyer <jmoyer@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org, ceph-devel@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org

On Wed, 5 Nov 2014, Milosz Tanski wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> With the new read/write with flags syscalls we can support a flag
> to enable O_DSYNC semantics on a per-operation basis.  This ?s
> useful to implement protocols like SMB, NFS or SCSI that have such
> per-operation flags.
> 
> Example program below:
> 
> cat > pwritev2.c << EOF
> 
>         (off_t) val,                              \
>         (off_t) ((((uint64_t) (val)) >> (sizeof (long) * 4)) >> (sizeof (long) * 4))
> 
> static ssize_t
> pwritev2(int fd, const struct iovec *iov, int iovcnt, off_t offset, int flags)
> {
>         return syscall(__NR_pwritev2, fd, iov, iovcnt, LO_HI_LONG(offset),
> 			 flags);
> }
> 
> int main(int argc, char **argv)
> {
> 	int fd = open(argv[1], O_WRONLY|O_CREAT|O_TRUNC, 0666);
> 	char buf[1024];
> 	struct iovec iov = { .iov_base = buf, .iov_len = 1024 };
> 	int ret;
> 
>         if (fd < 0) {
>                 perror("open");
>                 return 0;
>         }
> 
> 	memset(buf, 0xfe, sizeof(buf));
> 
> 	ret = pwritev2(fd, &iov, 1, 0, RWF_DSYNC);
> 	if (ret < 0)
> 		perror("pwritev2");
> 	else
> 		printf("ret = %d\n", ret);
> 
> 	return 0;
> }
> EOF
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> [milosz@adfin.com: added flag check to compat_do_readv_writev()]
> Signed-off-by: Milosz Tanski <milosz@adfin.com>

Ceph bits

Acked-by: Sage Weil <sage@redhat.com>

> ---
>  fs/ceph/file.c     |  4 +++-
>  fs/fuse/file.c     |  2 ++
>  fs/nfs/file.c      | 10 ++++++----
>  fs/ocfs2/file.c    |  6 ++++--
>  fs/read_write.c    | 20 +++++++++++++++-----
>  include/linux/fs.h |  3 ++-
>  mm/filemap.c       |  4 +++-
>  7 files changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index b798b5c..2d4e15a 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -983,7 +983,9 @@ retry_snap:
>  	ceph_put_cap_refs(ci, got);
>  
>  	if (written >= 0 &&
> -	    ((file->f_flags & O_SYNC) || IS_SYNC(file->f_mapping->host) ||
> +	    ((file->f_flags & O_SYNC) ||
> +	     IS_SYNC(file->f_mapping->host) ||
> +	     (iocb->ki_rwflags & RWF_DSYNC) ||
>  	     ceph_osdmap_flag(osdc->osdmap, CEPH_OSDMAP_NEARFULL))) {
>  		err = vfs_fsync_range(file, pos, pos + written - 1, 1);
>  		if (err < 0)
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index caa8d95..bb4fb23 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -1248,6 +1248,8 @@ static ssize_t fuse_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  		written += written_buffered;
>  		iocb->ki_pos = pos + written_buffered;
>  	} else {
> +		if (iocb->ki_rwflags & RWF_DSYNC)
> +			return -EINVAL;
>  		written = fuse_perform_write(file, mapping, from, pos);
>  		if (written >= 0)
>  			iocb->ki_pos = pos + written;
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index aa9046f..c59b0b7 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -652,13 +652,15 @@ static const struct vm_operations_struct nfs_file_vm_ops = {
>  	.remap_pages = generic_file_remap_pages,
>  };
>  
> -static int nfs_need_sync_write(struct file *filp, struct inode *inode)
> +static int nfs_need_sync_write(struct kiocb *iocb, struct inode *inode)
>  {
>  	struct nfs_open_context *ctx;
>  
> -	if (IS_SYNC(inode) || (filp->f_flags & O_DSYNC))
> +	if (IS_SYNC(inode) ||
> +	    (iocb->ki_filp->f_flags & O_DSYNC) ||
> +	    (iocb->ki_rwflags & RWF_DSYNC))
>  		return 1;
> -	ctx = nfs_file_open_context(filp);
> +	ctx = nfs_file_open_context(iocb->ki_filp);
>  	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags) ||
>  	    nfs_ctx_key_to_expire(ctx))
>  		return 1;
> @@ -705,7 +707,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
>  		written = result;
>  
>  	/* Return error values for O_DSYNC and IS_SYNC() */
> -	if (result >= 0 && nfs_need_sync_write(file, inode)) {
> +	if (result >= 0 && nfs_need_sync_write(iocb, inode)) {
>  		int err = vfs_fsync(file, 0);
>  		if (err < 0)
>  			result = err;
> diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
> index bb66ca4..8f9a86b 100644
> --- a/fs/ocfs2/file.c
> +++ b/fs/ocfs2/file.c
> @@ -2374,8 +2374,10 @@ out_dio:
>  	/* buffered aio wouldn't have proper lock coverage today */
>  	BUG_ON(ret == -EIOCBQUEUED && !(file->f_flags & O_DIRECT));
>  
> -	if (((file->f_flags & O_DSYNC) && !direct_io) || IS_SYNC(inode) ||
> -	    ((file->f_flags & O_DIRECT) && !direct_io)) {
> +	if (((file->f_flags & O_DSYNC) && !direct_io) ||
> +	    IS_SYNC(inode) ||
> +	    ((file->f_flags & O_DIRECT) && !direct_io) ||
> +	    (iocb->ki_rwflags & RWF_DSYNC)) {
>  		ret = filemap_fdatawrite_range(file->f_mapping, *ppos,
>  					       *ppos + count - 1);
>  		if (ret < 0)
> diff --git a/fs/read_write.c b/fs/read_write.c
> index cba7d4c..3443265 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -839,8 +839,13 @@ static ssize_t do_readv_writev(int type, struct file *file,
>  		ret = do_iter_readv_writev(file, type, iov, nr_segs, tot_len,
>  						pos, iter_fn, flags);
>  	} else {
> -		if (type == READ && (flags & RWF_NONBLOCK))
> -			return -EAGAIN;
> +		if (type == READ) {
> +			if (flags & RWF_NONBLOCK)
> +				return -EAGAIN;
> +		} else {
> +			if (flags & RWF_DSYNC)
> +				return -EINVAL;
> +		}
>  
>  		if (fnv)
>  			ret = do_sync_readv_writev(file, iov, nr_segs, tot_len,
> @@ -888,7 +893,7 @@ ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
>  		return -EBADF;
>  	if (!(file->f_mode & FMODE_CAN_WRITE))
>  		return -EINVAL;
> -	if (flags & ~0)
> +	if (flags & ~RWF_DSYNC)
>  		return -EINVAL;
>  
>  	return do_readv_writev(WRITE, file, vec, vlen, pos, flags);
> @@ -1080,8 +1085,13 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
>  		ret = do_iter_readv_writev(file, type, iov, nr_segs, tot_len,
>  						pos, iter_fn, flags);
>  	} else {
> -		if (type == READ && (flags & RWF_NONBLOCK))
> -			return -EAGAIN;
> +		if (type == READ) {
> +			if (flags & RWF_NONBLOCK)
> +				return -EAGAIN;
> +		} else {
> +			if (flags & RWF_DSYNC)
> +				return -EINVAL;
> +		}
>  
>  		if (fnv)
>  			ret = do_sync_readv_writev(file, iov, nr_segs, tot_len,
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7d0e116..7786b88 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1460,7 +1460,8 @@ struct block_device_operations;
>  #define HAVE_UNLOCKED_IOCTL 1
>  
>  /* These flags are used for the readv/writev syscalls with flags. */
> -#define RWF_NONBLOCK 0x00000001
> +#define RWF_NONBLOCK	0x00000001
> +#define RWF_DSYNC	0x00000002
>  
>  struct iov_iter;
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 6107058..4fbef99 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2669,7 +2669,9 @@ int generic_write_sync(struct kiocb *iocb, loff_t count)
>  	struct file *file = iocb->ki_filp;
>  
>  	if (count > 0 &&
> -	    ((file->f_flags & O_DSYNC) || IS_SYNC(file->f_mapping->host))) {
> +	    ((file->f_flags & O_DSYNC) ||
> +	     (iocb->ki_rwflags & RWF_DSYNC) ||
> +	     IS_SYNC(file->f_mapping->host))) {
>  		bool fdatasync = !(file->f_flags & __O_SYNC);
>  		ssize_t ret = 0;
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
