Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40F4D6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 12:52:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so7282470pla.18
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:52:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id y17-v6si678185pll.296.2018.04.09.09.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 09:52:04 -0700 (PDT)
Date: Mon, 9 Apr 2018 09:52:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 7/7] block: use GFP_KERNEL for allocations from
 blk_get_request
Message-ID: <20180409165203.GE11756@bombadil.infradead.org>
References: <20180409153916.23901-1-hch@lst.de>
 <20180409153916.23901-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409153916.23901-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: axboe@kernel.dk, Bart.VanAssche@wdc.com, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 09, 2018 at 05:39:16PM +0200, Christoph Hellwig wrote:
> blk_get_request is used for pass-through style I/O and thus doesn't need
> GFP_NOIO.

Obviously GFP_KERNEL is a big improvement over GFP_NOIO!  But can we take
it all the way to GFP_USER, if this is always done in the ioctl path
(which it seems to be, except for nfsd, which presumably won't have
a cpuset memory allocation policy ... and if it did, the admin might
appreciate it honouring said policy).

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  block/blk-core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 432923751551..253a869558f9 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -1578,7 +1578,7 @@ static struct request *blk_old_get_request(struct request_queue *q,
>  				unsigned int op, blk_mq_req_flags_t flags)
>  {
>  	struct request *rq;
> -	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC : GFP_NOIO;
> +	gfp_t gfp_mask = flags & BLK_MQ_REQ_NOWAIT ? GFP_ATOMIC : GFP_KERNEL;
>  	int ret = 0;
>  
>  	WARN_ON_ONCE(q->mq_ops);
> -- 
> 2.16.3
> 
