Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D19216B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 02:46:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so37895943pac.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 23:46:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l5si12053122pgj.98.2016.10.27.23.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 23:45:59 -0700 (PDT)
Date: Thu, 27 Oct 2016 23:45:56 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/3] iopmem : Add a block device driver for PCIe attached
 IO memory.
Message-ID: <20161028064556.GA3231@infradead.org>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <1476826937-20665-3-git-send-email-sbates@raithlin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476826937-20665-3-git-send-email-sbates@raithlin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <stephen.bates@microsemi.com>
Cc: linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, willy@linux.intel.com, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, hch@infradead.org, axboe@fb.com, corbet@lwn.net, jim.macdonald@everspin.com, sbates@raithin.com, logang@deltatee.com

> Signed-off-by: Stephen Bates <sbates@raithlin.com>

FYI, that address has bounced throught the whole thread for me,
replacing it with a known good one for now.


> + * This driver is heavily based on drivers/block/pmem.c.
> + * Copyright (c) 2014, Intel Corporation.
> + * Copyright (C) 2007 Nick Piggin
> + * Copyright (C) 2007 Novell Inc.

Is there anything left of it actually?  I didn't spot anything
obvious.  Nevermind that we don't have a file with that name anymore :)

> +  /*
> +   * We can only access the iopmem device with full 32-bit word
> +   * accesses which cannot be gaurantee'd by the regular memcpy
> +   */

Odd comment formatting. 

> +static void memcpy_from_iopmem(void *dst, const void *src, size_t sz)
> +{
> +	u64 *wdst = dst;
> +	const u64 *wsrc = src;
> +	u64 tmp;
> +
> +	while (sz >= sizeof(*wdst)) {
> +		*wdst++ = *wsrc++;
> +		sz -= sizeof(*wdst);
> +	}
> +
> +	if (!sz)
> +		return;
> +
> +	tmp = *wsrc;
> +	memcpy(wdst, &tmp, sz);
> +}

And then we dod a memcpy here anyway.  And no volatile whatsover, so
the compiler could do anything to it.  I defintively feel a bit uneasy
about having this in the driver as well.  Can we define the exact
semantics for this and define it by the system, possibly in an arch
specific way?

> +static void iopmem_do_bvec(struct iopmem_device *iopmem, struct page *page,
> +			   unsigned int len, unsigned int off, bool is_write,
> +			   sector_t sector)
> +{
> +	phys_addr_t iopmem_off = sector * 512;
> +	void *iopmem_addr = iopmem->virt_addr + iopmem_off;
> +
> +	if (!is_write) {
> +		read_iopmem(page, off, iopmem_addr, len);
> +		flush_dcache_page(page);
> +	} else {
> +		flush_dcache_page(page);
> +		write_iopmem(iopmem_addr, page, off, len);
> +	}

How about moving the  address and offset calculation as well as the
cache flushing into read_iopmem/write_iopmem and removing this function?

> +static blk_qc_t iopmem_make_request(struct request_queue *q, struct bio *bio)
> +{
> +	struct iopmem_device *iopmem = q->queuedata;
> +	struct bio_vec bvec;
> +	struct bvec_iter iter;
> +
> +	bio_for_each_segment(bvec, bio, iter) {
> +		iopmem_do_bvec(iopmem, bvec.bv_page, bvec.bv_len,
> +			    bvec.bv_offset, op_is_write(bio_op(bio)),
> +			    iter.bi_sector);

op_is_write just checks the data direction.  I'd feel much more
comfortable with a switch on the op, e.g.

	switch (bio_op(bio))) {
	case REQ_OP_READ:
		bio_for_each_segment(bvec, bio, iter)
			read_iopmem(iopmem, bvec, iter.bi_sector);
		break;
	case REQ_OP_READ:
		bio_for_each_segment(bvec, bio, iter)
			write_iopmem(iopmem, bvec, iter.bi_sector);
	defualt:
		WARN_ON_ONCE(1);
		bio->bi_error = -EIO;
		break;
	}
			

> +static long iopmem_direct_access(struct block_device *bdev, sector_t sector,
> +			       void **kaddr, pfn_t *pfn, long size)
> +{
> +	struct iopmem_device *iopmem = bdev->bd_queue->queuedata;
> +	resource_size_t offset = sector * 512;
> +
> +	if (!iopmem)
> +		return -ENODEV;

I don't think this can ever happen, can it?

> +static DEFINE_IDA(iopmem_instance_ida);
> +static DEFINE_SPINLOCK(ida_lock);
> +
> +static int iopmem_set_instance(struct iopmem_device *iopmem)
> +{
> +	int instance, error;
> +
> +	do {
> +		if (!ida_pre_get(&iopmem_instance_ida, GFP_KERNEL))
> +			return -ENODEV;
> +
> +		spin_lock(&ida_lock);
> +		error = ida_get_new(&iopmem_instance_ida, &instance);
> +		spin_unlock(&ida_lock);
> +
> +	} while (error == -EAGAIN);
> +
> +	if (error)
> +		return -ENODEV;
> +
> +	iopmem->instance = instance;
> +	return 0;
> +}
> +
> +static void iopmem_release_instance(struct iopmem_device *iopmem)
> +{
> +	spin_lock(&ida_lock);
> +	ida_remove(&iopmem_instance_ida, iopmem->instance);
> +	spin_unlock(&ida_lock);
> +}
> +

Just use ida_simple_get/ida_simple_remove instead to take care
of the locking and preloading, and get rid of these two functions.


> +static int iopmem_attach_disk(struct iopmem_device *iopmem)
> +{
> +	struct gendisk *disk;
> +	int nid = dev_to_node(iopmem->dev);
> +	struct request_queue *q = iopmem->queue;
> +
> +	blk_queue_write_cache(q, true, true);

You don't handle flush commands or the fua bit in make_request, so
this setting seems wrong.

> +	int err = 0;
> +	int nid = dev_to_node(&pdev->dev);
> +
> +	if (pci_enable_device_mem(pdev) < 0) {

propagate the actual error code, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
