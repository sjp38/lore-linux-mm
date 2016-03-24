Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C84E6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 07:45:04 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id u125so8911302wmg.1
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 04:45:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si8593446wjx.30.2016.03.24.04.45.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Mar 2016 04:45:01 -0700 (PDT)
Date: Thu, 24 Mar 2016 12:45:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/filemap: generic_file_read_iter(): check for zero
 reads unconditionally
Message-ID: <20160324114529.GC4025@quack.suse.cz>
References: <1458817738-2753-1-git-send-email-nicstange@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458817738-2753-1-git-send-email-nicstange@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolai Stange <nicstange@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Junichi Nomura <j-nomura@ce.jp.nec.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 24-03-16 12:08:58, Nicolai Stange wrote:
> If
> - generic_file_read_iter() gets called with a zero read length,
> - the read offset is at a page boundary,
> - IOCB_DIRECT is not set
> - and the page in question hasn't made it into the page cache yet,
> then do_generic_file_read() will trigger a readahead with a req_size hint
> of zero.
> 
> Since roundup_pow_of_two(0) is undefined, UBSAN reports
> 
>   UBSAN: Undefined behaviour in include/linux/log2.h:63:13
>   shift exponent 64 is too large for 64-bit type 'long unsigned int'
>   CPU: 3 PID: 1017 Comm: sa1 Tainted: G L 4.5.0-next-20160318+ #14
>   [...]
>   Call Trace:
>    [...]
>    [<ffffffff813ef61a>] ondemand_readahead+0x3aa/0x3d0
>    [<ffffffff813ef61a>] ? ondemand_readahead+0x3aa/0x3d0
>    [<ffffffff813c73bd>] ? find_get_entry+0x2d/0x210
>    [<ffffffff813ef9c3>] page_cache_sync_readahead+0x63/0xa0
>    [<ffffffff813cc04d>] do_generic_file_read+0x80d/0xf90
>    [<ffffffff813cc955>] generic_file_read_iter+0x185/0x420
>    [...]
>    [<ffffffff81510b06>] __vfs_read+0x256/0x3d0
>    [...]
> 
> when get_init_ra_size() gets called from ondemand_readahead().
> 
> The net effect is that the initial readahead size is arch dependent for
> requested read lengths of zero: for example, since
> 
>   1UL << (sizeof(unsigned long) * 8)
> 
> evaluates to 1 on x86 while its result is 0 on ARMv7, the initial readahead
> size becomes 4 on the former and 0 on the latter.
> 
> What's more, whether or not the file access timestamp is updated for zero
> length reads is decided differently for the two cases of IOCB_DIRECT
> being set or cleared: in the first case, generic_file_read_iter()
> explicitly skips updating that timestamp while in the latter case, it is
> always updated through the call to do_generic_file_read().
> 
> According to POSIX, zero length reads "do not modify the last data access
> timestamp" and thus, the IOCB_DIRECT behaviour is POSIXly correct.
> 
> Let generic_file_read_iter() unconditionally check the requested read
> length at its entry and return immediately with success if it is zero.
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>

Makes sense to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 7c00f10..a8c69c8 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1840,15 +1840,16 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
>  	ssize_t retval = 0;
>  	loff_t *ppos = &iocb->ki_pos;
>  	loff_t pos = *ppos;
> +	size_t count = iov_iter_count(iter);
> +
> +	if (!count)
> +		goto out; /* skip atime */
>  
>  	if (iocb->ki_flags & IOCB_DIRECT) {
>  		struct address_space *mapping = file->f_mapping;
>  		struct inode *inode = mapping->host;
> -		size_t count = iov_iter_count(iter);
>  		loff_t size;
>  
> -		if (!count)
> -			goto out; /* skip atime */
>  		size = i_size_read(inode);
>  		retval = filemap_write_and_wait_range(mapping, pos,
>  					pos + count - 1);
> -- 
> 2.7.4
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
