Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 776626B02B4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:06:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so28102081wrc.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:06:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n198si7295433wmg.221.2017.07.25.05.06.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 05:06:11 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:06:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] fs: convert sync_file_range to use errseq_t based
 error-tracking
Message-ID: <20170725120609.GE19943@quack2.suse.cz>
References: <20170719173707.21933-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170719173707.21933-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On Wed 19-07-17 13:37:07, Jeff Layton wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> sync_file_range doesn't call down into the filesystem directly at all.
> It only kicks off writeback of pagecache pages and optionally waits
> on the result.
> 
> Convert sync_file_range to use errseq_t based error tracking, under the
> assumption that most users will prefer this behavior when errors occur.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/sync.c          |  4 ++--
>  include/linux/fs.h |  2 ++
>  mm/filemap.c       | 22 ++++++++++++++++++++++
>  3 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/sync.c b/fs/sync.c
> index 2a54c1f22035..27d6b8bbcb6a 100644
> --- a/fs/sync.c
> +++ b/fs/sync.c
> @@ -342,7 +342,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
>  
>  	ret = 0;
>  	if (flags & SYNC_FILE_RANGE_WAIT_BEFORE) {
> -		ret = filemap_fdatawait_range(mapping, offset, endbyte);
> +		ret = file_fdatawait_range(f.file, offset, endbyte);
>  		if (ret < 0)
>  			goto out_put;
>  	}
> @@ -355,7 +355,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
>  	}
>  
>  	if (flags & SYNC_FILE_RANGE_WAIT_AFTER)
> -		ret = filemap_fdatawait_range(mapping, offset, endbyte);
> +		ret = file_fdatawait_range(f.file, offset, endbyte);
>  
>  out_put:
>  	fdput(f);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7b5d6816542b..fb615e1eb1d4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2544,6 +2544,8 @@ extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
>  				   loff_t lend);
>  extern bool filemap_range_has_page(struct address_space *, loff_t lstart,
>  				  loff_t lend);
> +extern int __must_check file_fdatawait_range(struct file *file, loff_t lstart,
> +						loff_t lend);
>  extern int filemap_write_and_wait(struct address_space *mapping);
>  extern int filemap_write_and_wait_range(struct address_space *mapping,
>  				        loff_t lstart, loff_t lend);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a49702445ce0..bb17590d7c67 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -476,6 +476,28 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
>  EXPORT_SYMBOL(filemap_fdatawait_range);
>  
>  /**
> + * file_fdatawait_range - wait for writeback to complete
> + * @file:		file pointing to address space structure to wait for
> + * @start_byte:		offset in bytes where the range starts
> + * @end_byte:		offset in bytes where the range ends (inclusive)
> + *
> + * Walk the list of under-writeback pages of the address space that file
> + * refers to, in the given range and wait for all of them.  Check error
> + * status of the address space vs. the file->f_wb_err cursor and return it.
> + *
> + * Since the error status of the file is advanced by this function,
> + * callers are responsible for checking the return value and handling and/or
> + * reporting the error.
> + */
> +int file_fdatawait_range(struct file *file, loff_t start_byte, loff_t end_byte)
> +{
> +	struct address_space *mapping = file->f_mapping;
> +
> +	__filemap_fdatawait_range(mapping, start_byte, end_byte);
> +	return file_check_and_advance_wb_err(file);
> +}
> +
> +/**
>   * filemap_fdatawait_keep_errors - wait for writeback without clearing errors
>   * @mapping: address space structure to wait for
>   *
> -- 
> 2.13.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
