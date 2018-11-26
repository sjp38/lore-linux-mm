Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86C4E6B43F4
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 17:13:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 74so12382009pfk.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:13:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6sor2679598pfi.19.2018.11.26.14.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 14:12:59 -0800 (PST)
Date: Mon, 26 Nov 2018 14:12:56 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V12 03/20] block: remove the "cluster" flag
Message-ID: <20181126221256.GD30411@vader>
References: <20181126021720.19471-1-ming.lei@redhat.com>
 <20181126021720.19471-4-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126021720.19471-4-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Mon, Nov 26, 2018 at 10:17:03AM +0800, Ming Lei wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> The cluster flag implements some very old SCSI behavior.  As far as I
> can tell the original intent was to enable or disable any kind of
> segment merging.  But the actually visible effect to the LLDD is that
> it limits each segments to be inside a single page, which we can
> also affect by setting the maximum segment size and the segment
> boundary.

Reviewed-by: Omar Sandoval <osandov@fb.com>

One comment typo below.

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Replace virt boundary with segment boundary limit.
> 
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  block/blk-merge.c       | 20 ++++++++------------
>  block/blk-settings.c    |  3 ---
>  block/blk-sysfs.c       |  5 +----
>  drivers/scsi/scsi_lib.c | 20 ++++++++++++++++----
>  include/linux/blkdev.h  |  6 ------
>  5 files changed, 25 insertions(+), 29 deletions(-)
> 

[snip]

> diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
> index 0df15cb738d2..78d6d05992b0 100644
> --- a/drivers/scsi/scsi_lib.c
> +++ b/drivers/scsi/scsi_lib.c
> @@ -1810,6 +1810,8 @@ static int scsi_map_queues(struct blk_mq_tag_set *set)
>  void __scsi_init_queue(struct Scsi_Host *shost, struct request_queue *q)
>  {
>  	struct device *dev = shost->dma_dev;
> +	unsigned max_segment_size = dma_get_max_seg_size(dev);
> +	unsigned long segment_boundary = shost->dma_boundary;
>  
>  	/*
>  	 * this limit is imposed by hardware restrictions
> @@ -1828,13 +1830,23 @@ void __scsi_init_queue(struct Scsi_Host *shost, struct request_queue *q)
>  	blk_queue_max_hw_sectors(q, shost->max_sectors);
>  	if (shost->unchecked_isa_dma)
>  		blk_queue_bounce_limit(q, BLK_BOUNCE_ISA);
> -	blk_queue_segment_boundary(q, shost->dma_boundary);
>  	dma_set_seg_boundary(dev, shost->dma_boundary);
>  
> -	blk_queue_max_segment_size(q, dma_get_max_seg_size(dev));
> +	/*
> +	 * Clustering is a really old concept from the stone age of Linux
> +	 * SCSI support.  But the basic idea is that we never give the
> +	 * driver a segment that spans multiple pages.  For that we need
> +	 * to limit the segment size, and set the segment boundary so that
> +	 * we never merge a second segment which is no page aligned.

Typo, "which is not page aligned".
