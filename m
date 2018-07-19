Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A30786B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:58:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f8-v6so3004225eds.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:58:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x13-v6si2295070edm.270.2018.07.19.01.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:58:13 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:58:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: adjust max read count in generic_file_buffered_read()
Message-ID: <20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719081726.3341-1-cgxu519@gmx.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chengguang Xu <cgxu519@gmx.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>

On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> When we try to truncate read count in generic_file_buffered_read(),
> should deliver (sb->s_maxbytes - offset) as maximum count not
> sb->s_maxbytes itself.
> 
> Signed-off-by: Chengguang Xu <cgxu519@gmx.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

BTW, I can see you didn't include two (I'd say the most important ;)
addresses to CC: Al Viro as a VFS maintainer and linux-fsdevel mailing
list. Although this code resides in mm/ it is in fact a filesystem code.
Added now.

								Honza

> ---
>  mm/filemap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 52517f28e6f4..5c2d481d21cf 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2064,7 +2064,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
>  
>  	if (unlikely(*ppos >= inode->i_sb->s_maxbytes))
>  		return 0;
> -	iov_iter_truncate(iter, inode->i_sb->s_maxbytes);
> +	iov_iter_truncate(iter, inode->i_sb->s_maxbytes - *ppos);
>  
>  	index = *ppos >> PAGE_SHIFT;
>  	prev_index = ra->prev_pos >> PAGE_SHIFT;
> -- 
> 2.17.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
