Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2789D6B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 12:03:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f4-v6so7226999plm.12
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:03:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id 75si407629pga.647.2018.04.09.09.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 09:03:56 -0700 (PDT)
Date: Mon, 9 Apr 2018 09:03:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/7] block: consistently use GFP_NOIO instead of
 __GFP_NORECLAIM
Message-ID: <20180409160354.GD11756@bombadil.infradead.org>
References: <20180409153916.23901-1-hch@lst.de>
 <20180409153916.23901-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409153916.23901-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: axboe@kernel.dk, Bart.VanAssche@wdc.com, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 09, 2018 at 05:39:15PM +0200, Christoph Hellwig wrote:
> Same numerical value (for now at least), but a much better documentation
> of intent.

> @@ -499,7 +499,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
>  		break;
>  	}
>  
> -	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, __GFP_RECLAIM)) {
> +	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, GFP_NOIO)) {

We don't seem to have grabbed any locks between the line which allocates
memory using GFP_USER (line 446) and here, so I don't see why we should
prohibit I/O?
