Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4D376B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 21:41:31 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h185so239180ite.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 18:41:31 -0700 (PDT)
Received: from tama50.ecl.ntt.co.jp (tama50.ecl.ntt.co.jp. [129.60.39.147])
        by mx.google.com with ESMTP id a198si332363ioe.403.2017.09.27.18.41.30
        for <linux-mm@kvack.org>;
        Wed, 27 Sep 2017 18:41:30 -0700 (PDT)
Subject: Re: [PATCH 09/15] nilfs2: Use pagevec_lookup_range_tag()
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-10-jack@suse.cz>
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Message-ID: <8960b327-5541-40ec-9966-ca4e43e8e9a0@lab.ntt.co.jp>
Date: Thu, 28 Sep 2017 10:40:50 +0900
MIME-Version: 1.0
In-Reply-To: <20170927160334.29513-10-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nilfs@vger.kernel.org


On 2017/09/28 1:03, Jan Kara wrote:
> We want only pages from given range in
> nilfs_lookup_dirty_data_buffers(). Use pagevec_lookup_range_tag()
> instead of pagevec_lookup_tag() and remove unnecessary code.
> 
> CC: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
> CC: linux-nilfs@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   fs/nilfs2/segment.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)

Nice patch. Thanks.

Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

> 
> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> index 70ded52dc1dd..68e5769cef3b 100644
> --- a/fs/nilfs2/segment.c
> +++ b/fs/nilfs2/segment.c
> @@ -711,18 +711,14 @@ static size_t nilfs_lookup_dirty_data_buffers(struct inode *inode,
>   	pagevec_init(&pvec, 0);
>    repeat:
>   	if (unlikely(index > last) ||
> -	    !pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
> -				min_t(pgoff_t, last - index,
> -				      PAGEVEC_SIZE - 1) + 1))
> +	    !pagevec_lookup_range_tag(&pvec, mapping, &index, last,
> +				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE))
>   		return ndirties;
>   
>   	for (i = 0; i < pagevec_count(&pvec); i++) {
>   		struct buffer_head *bh, *head;
>   		struct page *page = pvec.pages[i];
>   
> -		if (unlikely(page->index > last))
> -			break;
> -
>   		lock_page(page);
>   		if (!page_has_buffers(page))
>   			create_empty_buffers(page, i_blocksize(inode), 0);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
