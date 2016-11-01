Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 503206B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:15:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u144so18714613wmu.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:15:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o203si32140127wmo.101.2016.11.01.10.15.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 10:15:15 -0700 (PDT)
Date: Tue, 1 Nov 2016 16:37:27 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] mm/filemap: don't allow partially uptodate page for
 pipes
Message-ID: <20161101153727.GA2232@quack2.suse.cz>
References: <1477986187-12717-1-git-send-email-guaneryu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477986187-12717-1-git-send-email-guaneryu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eryu Guan <guaneryu@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.cz, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 01-11-16 15:43:07, Eryu Guan wrote:
> Starting from 4.9-rc1 kernel, I started noticing some test failures
> of sendfile(2) and splice(2) (sendfile0N and splice01 from LTP) when
> testing on sub-page block size filesystems (tested both XFS and
> ext4), these syscalls start to return EIO in the tests. e.g.
> 
> sendfile02    1  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 26, got: -1
> sendfile02    2  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 24, got: -1
> sendfile02    3  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 22, got: -1
> sendfile02    4  TFAIL  :  sendfile02.c:133: sendfile(2) failed to return expected value, expected: 20, got: -1
> 
> This is because that in sub-page block size cases, we don't need the
> whole page to be uptodate, only the part we care about is uptodate
> is OK (if fs has ->is_partially_uptodate defined). But
> page_cache_pipe_buf_confirm() doesn't have the ability to check the
> partially-uptodate case, it needs the whole page to be uptodate. So
> it returns EIO in this case.
> 
> This is a regression introduced by commit 82c156f85384 ("switch
> generic_file_splice_read() to use of ->read_iter()"). Prior to the
> change, generic_file_splice_read() doesn't allow partially-uptodate
> page either, so it worked fine.
> 
> Fix it by skipping the partially-uptodate check if we're working on
> a pipe in do_generic_file_read(), so we read the whole page from
> disk as long as the page is not uptodate.
> 
> Signed-off-by: Eryu Guan <guaneryu@gmail.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> 
> I think the other way to fix it is to add the ability to check & allow
> partially-uptodate page to page_cache_pipe_buf_confirm(), but that is much
> harder to do and seems gain little.
> 
> v2:
> - Update summary a little bit
> - Update commit log
> - Add comment to the code
> - Add more people/list to cc
> 
> v1: http://marc.info/?l=linux-mm&m=147756897431777&w=2
> 
>  mm/filemap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 849f459..670264d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1734,6 +1734,9 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
>  			if (inode->i_blkbits == PAGE_SHIFT ||
>  					!mapping->a_ops->is_partially_uptodate)
>  				goto page_not_up_to_date;
> +			/* pipes can't handle partially uptodate pages */
> +			if (unlikely(iter->type & ITER_PIPE))
> +				goto page_not_up_to_date;
>  			if (!trylock_page(page))
>  				goto page_not_up_to_date;
>  			/* Did it get truncated before we got the lock? */
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
