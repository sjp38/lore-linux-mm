Date: Thu, 26 Sep 2002 15:08:20 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <bcrl@kvack.org>
Subject: Re: [PATCH] 2.5.38-mm3 : use struct file to call generic_file_direct_IO
In-Reply-To: <OFA4BB5A35.3807A0D1-ON88256C40.00593B2F@boulder.ibm.com>
Message-ID: <Pine.LNX.4.44.0209261507440.13448-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <badari@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Could the ibmers on the list stop replying to owner-linux-mm, *please*!

		-ben

On Thu, 26 Sep 2002, Badari Pulavarty wrote:

> 
> Hi Andrew & Chuck,
> 
> This patch looks good. As we discussed earlier, this breaks "raw" driver.
> I can fix it. Please let me know, if you want me to work on it.
> 
> Thanks,
> Badari
> 
> 
> 
>                                                                                                                                  
>                       Chuck Lever                                                                                                
>                       <cel@citi.umich.e        To:       Andrew Morton <akpm@digeo.com>                                          
>                       du>                      cc:       linux-mm@kvack.org                                                      
>                       Sent by:                 Subject:  [PATCH] 2.5.38-mm3 : use struct file to call generic_file_direct_IO     
>                       owner-linux-mm@kv                                                                                          
>                       ack.org                                                                                                    
>                                                                                                                                  
>                                                                                                                                  
>                       09/26/02 08:47 AM                                                                                          
>                                                                                                                                  
>                                                                                                                                  
> 
> 
> 
> hi andrew-
> 
> this patch replaces "struct inode *" with "struct file *" in the arguments
> of *direct_IO and generic_file_direct_IO.  i built a 2.5.38-mm3 kernel
> with ext2, ext3, jfs, xfs, nfs, and raw enabled, with no compiler
> complaints.  i did not test direct I/O in any of these file systems.
> 
> 
> diff -drN -U2 mm3/drivers/char/raw.c mm3-file/drivers/char/raw.c
> --- mm3/drivers/char/raw.c           Sun Sep 22 00:25:12 2002
> +++ mm3-file/drivers/char/raw.c            Thu Sep 26 11:35:26 2002
> @@ -223,5 +223,5 @@
>                          nr_segs = iov_shorten((struct iovec *)iov,
> nr_segs, count);
>              }
> -            ret = generic_file_direct_IO(rw, inode, iov, *offp, nr_segs);
> +            ret = generic_file_direct_IO(rw, filp, iov, *offp, nr_segs);
> 
>              if (ret > 0)
> diff -drN -U2 mm3/fs/block_dev.c mm3-file/fs/block_dev.c
> --- mm3/fs/block_dev.c         Thu Sep 26 10:57:30 2002
> +++ mm3-file/fs/block_dev.c          Thu Sep 26 11:09:47 2002
> @@ -117,7 +117,9 @@
> 
>  static int
> -blkdev_direct_IO(int rw, struct inode *inode, const struct iovec *iov,
> +blkdev_direct_IO(int rw, struct file *file, const struct iovec *iov,
>                                      loff_t offset, unsigned long nr_segs)
>  {
> +            struct inode *inode =
> file->f_dentry->d_inode->i_mapping->host;
> +
>              return generic_direct_IO(rw, inode, iov, offset,
>                                                  nr_segs,
> blkdev_get_blocks);
> diff -drN -U2 mm3/fs/direct-io.c mm3-file/fs/direct-io.c
> --- mm3/fs/direct-io.c         Thu Sep 26 10:57:30 2002
> +++ mm3-file/fs/direct-io.c          Thu Sep 26 11:15:20 2002
> @@ -650,13 +650,13 @@
> 
>  ssize_t
> -generic_file_direct_IO(int rw, struct inode *inode, const struct iovec
> *iov,
> +generic_file_direct_IO(int rw, struct file *file, const struct iovec *iov,
> 
>              loff_t offset, unsigned long nr_segs)
>  {
> -            struct address_space *mapping = inode->i_mapping;
> +            struct address_space *mapping =
> file->f_dentry->d_inode->i_mapping;
>              ssize_t retval;
> 
> -            retval = mapping->a_ops->direct_IO(rw, inode, iov, offset,
> nr_segs);
> -            if (inode->i_mapping->nrpages)
> -                        invalidate_inode_pages2(inode->i_mapping);
> +            retval = mapping->a_ops->direct_IO(rw, file, iov, offset,
> nr_segs);
> +            if (mapping->nrpages)
> +                        invalidate_inode_pages2(mapping);
>              return retval;
>  }
> diff -drN -U2 mm3/fs/ext2/inode.c mm3-file/fs/ext2/inode.c
> --- mm3/fs/ext2/inode.c        Thu Sep 26 10:57:30 2002
> +++ mm3-file/fs/ext2/inode.c         Thu Sep 26 11:10:18 2002
> @@ -620,7 +620,9 @@
> 
>  static int
> -ext2_direct_IO(int rw, struct inode *inode, const struct iovec *iov,
> +ext2_direct_IO(int rw, struct file *file, const struct iovec *iov,
>                                      loff_t offset, unsigned long nr_segs)
>  {
> +            struct inode *inode =
> file->f_dentry->d_inode->i_mapping->host;
> +
>              return generic_direct_IO(rw, inode, iov,
>                                                  offset, nr_segs,
> ext2_get_blocks);
> diff -drN -U2 mm3/fs/ext3/inode.c mm3-file/fs/ext3/inode.c
> --- mm3/fs/ext3/inode.c        Thu Sep 26 10:57:30 2002
> +++ mm3-file/fs/ext3/inode.c         Thu Sep 26 11:25:21 2002
> @@ -1400,8 +1400,9 @@
>   * crashes then stale disk data _may_ be exposed inside the file.
>   */
> -static int ext3_direct_IO(int rw, struct inode *inode,
> +static int ext3_direct_IO(int rw, struct file *file,
>                                      const struct iovec *iov, loff_t
> offset,
>                                      unsigned long nr_segs)
>  {
> +            struct inode *inode =
> file->f_dentry->d_inode->i_mapping->host;
>              struct ext3_inode_info *ei = EXT3_I(inode);
>              handle_t *handle = NULL;
> diff -drN -U2 mm3/fs/jfs/inode.c mm3-file/fs/jfs/inode.c
> --- mm3/fs/jfs/inode.c         Sun Sep 22 00:24:57 2002
> +++ mm3-file/fs/jfs/inode.c          Thu Sep 26 11:10:47 2002
> @@ -311,7 +311,9 @@
>  }
> 
> -static int jfs_direct_IO(int rw, struct inode *inode, const struct iovec
> *iov,
> +static int jfs_direct_IO(int rw, struct file *file, const struct iovec
> *iov,
>                                      loff_t offset, unsigned long nr_segs)
>  {
> +            struct inode *inode =
> file->f_dentry->d_inode->i_mapping->host;
> +
>              return generic_direct_IO(rw, inode, iov,
>                                                  offset, nr_segs,
> jfs_get_blocks);
> diff -drN -U2 mm3/fs/xfs/linux/xfs_aops.c mm3-file/fs/xfs/linux/xfs_aops.c
> --- mm3/fs/xfs/linux/xfs_aops.c            Sun Sep 22 00:25:18 2002
> +++ mm3-file/fs/xfs/linux/xfs_aops.c             Thu Sep 26 11:11:59 2002
> @@ -653,9 +653,11 @@
>  linvfs_direct_IO(
>              int                                 rw,
> -            struct inode                        *inode,
> +            struct file                         *file,
>              const struct iovec            *iov,
>              loff_t                                    offset,
>              unsigned long                       nr_segs)
>  {
> +            struct inode                        *inode =
> file->f_dentry->d_inode->i_mapping->host;
> +
>          return generic_direct_IO(rw, inode, iov, offset, nr_segs,
> 
> linvfs_get_blocks_direct);
> @@ -814,9 +816,10 @@
>  linvfs_direct_IO(
>              int                                 rw,
> -            struct inode                        *inode,
> +            struct file                         *file,
>              struct kiobuf                       *iobuf,
>              unsigned long                       blocknr,
>              int                                 blocksize)
>  {
> +            struct inode                        *inode =
> file->f_dentry->d_inode->i_mapping->host;
>              struct page                         **maplist;
>              size_t                                    page_offset;
> diff -drN -U2 mm3/include/linux/fs.h mm3-file/include/linux/fs.h
> --- mm3/include/linux/fs.h           Thu Sep 26 10:57:31 2002
> +++ mm3-file/include/linux/fs.h            Thu Sep 26 11:13:55 2002
> @@ -309,5 +309,5 @@
>              int (*invalidatepage) (struct page *, unsigned long);
>              int (*releasepage) (struct page *, int);
> -            int (*direct_IO)(int, struct inode *, const struct iovec *iov,
> loff_t offset, unsigned long nr_segs);
> +            int (*direct_IO)(int, struct file *, const struct iovec *iov,
> loff_t offset, unsigned long nr_segs);
>  };
> 
> @@ -1248,5 +1248,5 @@
>  extern ssize_t generic_file_sendfile(struct file *, struct file *, loff_t
> *, size_t);
>  extern void do_generic_file_read(struct file *, loff_t *,
> read_descriptor_t *, read_actor_t);
> -extern ssize_t generic_file_direct_IO(int rw, struct inode *inode,
> +extern ssize_t generic_file_direct_IO(int rw, struct file *file,
>              const struct iovec *iov, loff_t offset, unsigned long
> nr_segs);
>  extern int generic_direct_IO(int rw, struct inode *inode, const struct
> iovec
> diff -drN -U2 mm3/include/linux/nfs_fs.h mm3-file/include/linux/nfs_fs.h
> --- mm3/include/linux/nfs_fs.h             Sun Sep 22 00:25:06 2002
> +++ mm3-file/include/linux/nfs_fs.h        Thu Sep 26 11:19:56 2002
> @@ -15,4 +15,5 @@
>  #include <linux/pagemap.h>
>  #include <linux/wait.h>
> +#include <linux/uio.h>
> 
>  #include <linux/nfs_fs_sb.h>
> @@ -285,4 +286,10 @@
> 
>  /*
> + * linux/fs/nfs/direct.c
> + */
> +extern int nfs_direct_IO(int, struct file *, const struct iovec *,
> +                        unsigned long, int);
> +
> +/*
>   * linux/fs/nfs/dir.c
>   */
> diff -drN -U2 mm3/kernel/ksyms.c mm3-file/kernel/ksyms.c
> --- mm3/kernel/ksyms.c         Thu Sep 26 10:57:31 2002
> +++ mm3-file/kernel/ksyms.c          Thu Sep 26 11:06:14 2002
> @@ -196,4 +196,5 @@
>  EXPORT_SYMBOL(invalidate_device);
>  EXPORT_SYMBOL(invalidate_inode_pages);
> +EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
>  EXPORT_SYMBOL(truncate_inode_pages);
>  EXPORT_SYMBOL(fsync_bdev);
> diff -drN -U2 mm3/mm/filemap.c mm3-file/mm/filemap.c
> --- mm3/mm/filemap.c           Thu Sep 26 10:57:31 2002
> +++ mm3-file/mm/filemap.c            Thu Sep 26 11:07:07 2002
> @@ -854,5 +854,5 @@
> 
>        nr_segs, count);
>                                      }
> -                                    retval = generic_file_direct_IO(READ,
> inode,
> +                                    retval = generic_file_direct_IO(READ,
> filp,
>                                                              iov, pos,
> nr_segs);
>                                      if (retval > 0)
> @@ -1553,5 +1553,5 @@
>                                      nr_segs = iov_shorten((struct iovec
> *)iov,
> 
> nr_segs, count);
> -                        written = generic_file_direct_IO(WRITE, inode,
> +                        written = generic_file_direct_IO(WRITE, file,
>                                                              iov, pos,
> nr_segs);
>                          if (written > 0) {
> 
> --
> 
> corporate:         <cel at netapp dot com>
> personal:          <chucklever at bigfoot dot com>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
