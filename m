Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 067B26B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:37:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m13so26946374pgd.12
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:37:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8si21552467pfj.239.2017.04.25.01.37.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 01:37:20 -0700 (PDT)
Date: Tue, 25 Apr 2017 10:37:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 3/4] mm/truncate: bail out early from
 invalidate_inode_pages2_range() if mapping is empty
Message-ID: <20170425083715.GD2793@quack2.suse.cz>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424164135.22350-4-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 24-04-17 19:41:34, Andrey Ryabinin wrote:
> If mapping is empty (both ->nrpages and ->nrexceptional is zero) we can
> avoid pointless lookups in empty radix tree and bail out immediately after
> cleancache invalidation.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/truncate.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 6263aff..8f12b0e 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -624,6 +624,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
>  	int did_range_unmap = 0;
>  
>  	cleancache_invalidate_inode(mapping);
> +	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
> +		return 0;
> +
>  	pagevec_init(&pvec, 0);
>  	index = start;
>  	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
