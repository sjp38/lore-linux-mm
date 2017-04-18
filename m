Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75FF92806DA
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:52:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 6so141347wra.23
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 11:52:04 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id c20si17187514wmc.147.2017.04.18.11.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 11:52:03 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id d79so1038510wmi.2
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 11:52:02 -0700 (PDT)
Subject: Re: [PATCH 2/4] fs/block_dev: always invalidate cleancache in
 invalidate_bdev()
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-3-aryabinin@virtuozzo.com>
From: Nikolay Borisov <n.borisov.lkml@gmail.com>
Message-ID: <705067e3-eb15-ce2a-cfc8-d048dfc8be4f@gmail.com>
Date: Tue, 18 Apr 2017 21:51:59 +0300
MIME-Version: 1.0
In-Reply-To: <20170414140753.16108-3-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org



On 14.04.2017 17:07, Andrey Ryabinin wrote:
> invalidate_bdev() calls cleancache_invalidate_inode() iff ->nrpages != 0
> which doen't make any sense.
> Make invalidate_bdev() always invalidate cleancache data.
> 
> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  fs/block_dev.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index e405d8e..7af4787 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -103,12 +103,11 @@ void invalidate_bdev(struct block_device *bdev)
>  {
>  	struct address_space *mapping = bdev->bd_inode->i_mapping;
>  
> -	if (mapping->nrpages == 0)
> -		return;
> -
> -	invalidate_bh_lrus();
> -	lru_add_drain_all();	/* make sure all lru add caches are flushed */
> -	invalidate_mapping_pages(mapping, 0, -1);
> +	if (mapping->nrpages) {
> +		invalidate_bh_lrus();
> +		lru_add_drain_all();	/* make sure all lru add caches are flushed */
> +		invalidate_mapping_pages(mapping, 0, -1);
> +	}

How is this different than the current code? You will only invalidate
the mapping iff ->nrpages > 0 ( I assume it can't go down below 0) ?
Perhaps just remove the if altogether?

>  	/* 99% of the time, we don't need to flush the cleancache on the bdev.
>  	 * But, for the strange corners, lets be cautious
>  	 */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
