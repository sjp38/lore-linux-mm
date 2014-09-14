Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AB5D46B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 10:12:05 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so4682144pad.0
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 07:12:05 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id gi1si18260583pac.168.2014.09.14.07.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 07:12:04 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so4678549pab.22
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 07:12:03 -0700 (PDT)
Message-ID: <5415A22F.2010900@gmail.com>
Date: Sun, 14 Sep 2014 17:11:59 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 07/21] Replace XIP read and write with DAX I/O
References: <cover.1409110741.git.matthew.r.wilcox@intel.com> <8fac9e35ef81c93d15f4ab393b187c26e09c5366.1409110741.git.matthew.r.wilcox@intel.com>
In-Reply-To: <8fac9e35ef81c93d15f4ab393b187c26e09c5366.1409110741.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Cc: willy@linux.intel.com

On 08/27/2014 06:45 AM, Matthew Wilcox wrote:
> Use the generic AIO infrastructure instead of custom read and write
> methods.  In addition to giving us support for AIO, this adds the missing
> locking between read() and truncate().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---
>  MAINTAINERS        |   6 ++
>  fs/Makefile        |   1 +
>  fs/dax.c           | 195 ++++++++++++++++++++++++++++++++++++++++++++
>  fs/ext2/file.c     |   6 +-
>  fs/ext2/inode.c    |   8 +-
>  include/linux/fs.h |  18 ++++-
>  mm/filemap.c       |   6 +-
>  mm/filemap_xip.c   | 234 -----------------------------------------------------
>  8 files changed, 229 insertions(+), 245 deletions(-)
>  create mode 100644 fs/dax.c
> 
<>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 90effcd..19bdb68 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1690,8 +1690,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
>  	loff_t *ppos = &iocb->ki_pos;
>  	loff_t pos = *ppos;
>  
> -	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
> -	if (file->f_flags & O_DIRECT) {
> +	if (io_is_direct(file)) {
>  		struct address_space *mapping = file->f_mapping;
>  		struct inode *inode = mapping->host;
>  		size_t count = iov_iter_count(iter);
> @@ -2579,8 +2578,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  	if (err)
>  		goto out;
>  
> -	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
> -	if (unlikely(file->f_flags & O_DIRECT)) {
> +	if (io_is_direct(file)) {
>  		loff_t endbyte;
>  
>  		written = generic_file_direct_write(iocb, from, pos);

Hi Matthew

As pointed out by Dave Chinner, I think we must add the below hunks to this patch.
I do not see a case where it is allowed with current DAX code for any FS to
enable both DAX access/mmap in parallel to any buffered read/write.

Do we want to also put a
	WARN_ON(IS_DAX(inode));

In generic_perform_write and/or in extX->write_begin() ?

----
diff --git a/mm/filemap.c b/mm/filemap.c
index 19bdb68..22210c9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1719,7 +1719,8 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 		 * and return.  Otherwise fallthrough to buffered io for
 		 * the rest of the read.
 		 */
-		if (retval < 0 || !iov_iter_count(iter) || *ppos >= size) {
+		if (retval < 0 || !iov_iter_count(iter) || *ppos >= size ||
+		    IS_DAX(inode)) {
 			file_accessed(file);
 			goto out;
 		}
@@ -2582,7 +2583,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		loff_t endbyte;
 
 		written = generic_file_direct_write(iocb, from, pos);
-		if (written < 0 || written == count)
+		if (written < 0 || written == count || IS_DAX(inode))
 			goto out;
 
 		/*
----

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
