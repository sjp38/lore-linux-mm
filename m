Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F00B6B0285
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 15:23:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so20988303pfj.6
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 12:23:17 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id p5si14835709pgk.156.2016.10.28.12.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 12:23:10 -0700 (PDT)
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <1476826937-20665-3-git-send-email-sbates@raithlin.com>
 <20161028064556.GA3231@infradead.org>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <f61ba5bd-b81e-d5bf-02e5-45f6b523dd4c@deltatee.com>
Date: Fri, 28 Oct 2016 13:22:16 -0600
MIME-Version: 1.0
In-Reply-To: <20161028064556.GA3231@infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 2/3] iopmem : Add a block device driver for PCIe attached
 IO memory.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Stephen Bates <stephen.bates@microsemi.com>
Cc: linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, willy@linux.intel.com, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, axboe@fb.com, corbet@lwn.net, jim.macdonald@everspin.com, sbates@raithin.com

Hi Christoph,

Thanks so much for the detailed review of the code! Even though by the
sounds of things we will be moving to device dax and most of this is
moot. Still, it's great to get some feedback and learn a few things.

I've given some responses below.

On 28/10/16 12:45 AM, Christoph Hellwig wrote:
>> + * This driver is heavily based on drivers/block/pmem.c.
>> + * Copyright (c) 2014, Intel Corporation.
>> + * Copyright (C) 2007 Nick Piggin
>> + * Copyright (C) 2007 Novell Inc.
> 
> Is there anything left of it actually?  I didn't spot anything
> obvious.  Nevermind that we don't have a file with that name anymore :)

Yes, actually there's still a lot of similarities with the current
pmem.c. Though, yes, the path was on oversight. Some of this code is
getting pretty old (it started from an out-of-tree version of pmem.c)
and we've tried our best to track as many of the changes to the pmem.c
as possible. This proved to be difficult. Note: this is now the nvdimm
pmem and not the dax pmem (drivers/nvdimm/pmem.c)

>> +  /*
>> +   * We can only access the iopmem device with full 32-bit word
>> +   * accesses which cannot be gaurantee'd by the regular memcpy
>> +   */
> 
> Odd comment formatting. 

Oops. I'm surprised check_patch didn't pick up on that.

> 
>> +static void memcpy_from_iopmem(void *dst, const void *src, size_t sz)
>> +{
>> +	u64 *wdst = dst;
>> +	const u64 *wsrc = src;
>> +	u64 tmp;
>> +
>> +	while (sz >= sizeof(*wdst)) {
>> +		*wdst++ = *wsrc++;
>> +		sz -= sizeof(*wdst);
>> +	}
>> +
>> +	if (!sz)
>> +		return;
>> +
>> +	tmp = *wsrc;
>> +	memcpy(wdst, &tmp, sz);
>> +}
> 
> And then we dod a memcpy here anyway.  And no volatile whatsover, so
> the compiler could do anything to it.  I defintively feel a bit uneasy
> about having this in the driver as well.  Can we define the exact
> semantics for this and define it by the system, possibly in an arch
> specific way?

Yeah, you're right. We should have reviewed this function a bit more.
Anyway, I'd be interested in learning a better approach to forcing a
copy from a mapped BAR with larger widths.


>> +static void iopmem_do_bvec(struct iopmem_device *iopmem, struct page *page,
>> +			   unsigned int len, unsigned int off, bool is_write,
>> +			   sector_t sector)
>> +{
>> +	phys_addr_t iopmem_off = sector * 512;
>> +	void *iopmem_addr = iopmem->virt_addr + iopmem_off;
>> +
>> +	if (!is_write) {
>> +		read_iopmem(page, off, iopmem_addr, len);
>> +		flush_dcache_page(page);
>> +	} else {
>> +		flush_dcache_page(page);
>> +		write_iopmem(iopmem_addr, page, off, len);
>> +	}
> 
> How about moving the  address and offset calculation as well as the
> cache flushing into read_iopmem/write_iopmem and removing this function?

Could do. This was copied from the existing pmem.c and once the bad_pmem
stuff was stripped out this function became relatively simple.


> 
>> +static blk_qc_t iopmem_make_request(struct request_queue *q, struct bio *bio)
>> +{
>> +	struct iopmem_device *iopmem = q->queuedata;
>> +	struct bio_vec bvec;
>> +	struct bvec_iter iter;
>> +
>> +	bio_for_each_segment(bvec, bio, iter) {
>> +		iopmem_do_bvec(iopmem, bvec.bv_page, bvec.bv_len,
>> +			    bvec.bv_offset, op_is_write(bio_op(bio)),
>> +			    iter.bi_sector);
> 
> op_is_write just checks the data direction.  I'd feel much more
> comfortable with a switch on the op, e.g.

That makes sense. This was also copied from pmem.c, so this same change
may make sense there too.


>> +static long iopmem_direct_access(struct block_device *bdev, sector_t sector,
>> +			       void **kaddr, pfn_t *pfn, long size)
>> +{
>> +	struct iopmem_device *iopmem = bdev->bd_queue->queuedata;
>> +	resource_size_t offset = sector * 512;
>> +
>> +	if (!iopmem)
>> +		return -ENODEV;
> 
> I don't think this can ever happen, can it?

Yes, I think now that's the case. This is probably a holdover from a
previous version.

> Just use ida_simple_get/ida_simple_remove instead to take care
> of the locking and preloading, and get rid of these two functions.

Thanks, noted. That would be much better. I never found a simple example
of that when I was looking, though I expected there should have been.

> 
>> +static int iopmem_attach_disk(struct iopmem_device *iopmem)
>> +{
>> +	struct gendisk *disk;
>> +	int nid = dev_to_node(iopmem->dev);
>> +	struct request_queue *q = iopmem->queue;
>> +
>> +	blk_queue_write_cache(q, true, true);
> 
> You don't handle flush commands or the fua bit in make_request, so
> this setting seems wrong.

Yup, ok. I'm afraid this is a case of copying without complete
comprehension.

> 
>> +	int err = 0;
>> +	int nid = dev_to_node(&pdev->dev);
>> +
>> +	if (pci_enable_device_mem(pdev) < 0) {
> 
> propagate the actual error code, please.

Hmm, yup. Not sure why that was missed.

Thanks,

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
