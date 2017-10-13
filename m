Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA8A06B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 06:48:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r18so5202373qkh.9
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 03:48:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y9si556276qtc.80.2017.10.13.03.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 03:48:23 -0700 (PDT)
Date: Fri, 13 Oct 2017 06:48:15 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <24301306.20068579.1507891695416.JavaMail.zimbra@redhat.com>
In-Reply-To: <20171013094431.GA27308@stefanha-x1.localdomain>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com> <20171013094431.GA27308@stefanha-x1.localdomain>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan j williams <dan.j.williams@intel.com>, riel@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross zwisler <ross.zwisler@intel.com>, david@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>


> 
> On Thu, Oct 12, 2017 at 09:20:26PM +0530, Pankaj Gupta wrote:
> >   This patch adds virtio-pmem driver for KVM guest.
> >   Guest reads the persistent memory range information
> >   over virtio bus from Qemu and reserves the range
> >   as persistent memory. Guest also allocates a block
> >   device corresponding to the pmem range which later
> >   can be accessed with DAX compatible file systems.
> >   Idea is to use the virtio channel between guest and
> >   host to perform the block device flush for guest pmem
> >   DAX device.
> > 
> >   There is work to do including DAX file system support
> >   and other advanced features.
> > 
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > ---
> >  drivers/virtio/Kconfig           |  10 ++
> >  drivers/virtio/Makefile          |   1 +
> >  drivers/virtio/virtio_pmem.c     | 322
> >  +++++++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_pmem.h |  55 +++++++
> >  4 files changed, 388 insertions(+)
> >  create mode 100644 drivers/virtio/virtio_pmem.c
> >  create mode 100644 include/uapi/linux/virtio_pmem.h
> > 
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index cff773f15b7e..0192c4bda54b 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -38,6 +38,16 @@ config VIRTIO_PCI_LEGACY
> >  
> >  	  If unsure, say Y.
> >  
> > +config VIRTIO_PMEM
> > +	tristate "Virtio pmem driver"
> > +	depends on VIRTIO
> > +	---help---
> > +	 This driver adds persistent memory range within a KVM guest.
> > +         It also associates a block device corresponding to the pmem
> > +	 range.
> > +
> > +	 If unsure, say M.
> > +
> >  config VIRTIO_BALLOON
> >  	tristate "Virtio balloon driver"
> >  	depends on VIRTIO
> > diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> > index 41e30e3dc842..032ade725cc2 100644
> > --- a/drivers/virtio/Makefile
> > +++ b/drivers/virtio/Makefile
> > @@ -5,3 +5,4 @@ virtio_pci-y := virtio_pci_modern.o virtio_pci_common.o
> >  virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) += virtio_pci_legacy.o
> >  obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
> >  obj-$(CONFIG_VIRTIO_INPUT) += virtio_input.o
> > +obj-$(CONFIG_VIRTIO_PMEM) += virtio_pmem.o
> > diff --git a/drivers/virtio/virtio_pmem.c b/drivers/virtio/virtio_pmem.c
> > new file mode 100644
> > index 000000000000..74e47cae0e24
> > --- /dev/null
> > +++ b/drivers/virtio/virtio_pmem.c
> > @@ -0,0 +1,322 @@
> > +/*
> > + * virtio-pmem driver
> > + */
> > +
> > +#include <linux/virtio.h>
> > +#include <linux/swap.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/delay.h>
> > +#include <linux/slab.h>
> > +#include <linux/module.h>
> > +#include <linux/oom.h>
> > +#include <linux/wait.h>
> > +#include <linux/mm.h>
> > +#include <linux/mount.h>
> > +#include <linux/magic.h>
> > +#include <linux/virtio_pmem.h>
> > +
> > +void devm_vpmem_disable(struct device *dev, struct resource *res, void
> > *addr)
> > +{
> > +	devm_memunmap(dev, addr);
> > +	devm_release_mem_region(dev, res->start, resource_size(res));
> > +}
> > +
> > +static void pmem_flush_done(struct virtqueue *vq)
> > +{
> > +	return;
> > +};
> > +
> > +static void virtio_pmem_release_queue(void *q)
> > +{
> > +	blk_cleanup_queue(q);
> > +}
> > +
> > +static void virtio_pmem_freeze_queue(void *q)
> > +{
> > +	blk_freeze_queue_start(q);
> > +}
> > +
> > +static void virtio_pmem_release_disk(void *__pmem)
> > +{
> > +	struct virtio_pmem *pmem = __pmem;
> > +
> > +	del_gendisk(pmem->disk);
> > +	put_disk(pmem->disk);
> > +}
> > +
> > +static int init_vq(struct virtio_pmem *vpmem)
> > +{
> > +	struct virtqueue *vq;
> > +
> > +	/* single vq */
> > +	vq = virtio_find_single_vq(vpmem->vdev, pmem_flush_done, "flush_queue");
> > +
> > +	if (IS_ERR(vq))
> > +		return PTR_ERR(vq);
> > +
> > +	return 0;
> > +}
> > +
> > +static struct vmem_altmap *setup_pmem_pfn(struct virtio_pmem *vpmem,
> > +			struct resource *res, struct vmem_altmap *altmap)
> > +{
> > +	u32 start_pad = 0, end_trunc = 0;
> > +	resource_size_t start, size;
> > +	unsigned long npfns;
> > +	phys_addr_t offset;
> > +
> > +	size = resource_size(res);
> > +	start = PHYS_SECTION_ALIGN_DOWN(res->start);
> > +
> > +	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> > +		IORES_DESC_NONE) == REGION_MIXED) {
> > +
> > +		start = res->start;
> > +		start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
> > +	}
> > +	start = res->start;
> > +	size = PHYS_SECTION_ALIGN_UP(start + size) - start;
> > +
> > +	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> > +		IORES_DESC_NONE) == REGION_MIXED) {
> > +
> > +		size = resource_size(res);
> > +		end_trunc = start + size -
> > +				PHYS_SECTION_ALIGN_DOWN(start + size);
> > +	}
> > +
> > +	start += start_pad;
> > +	size = resource_size(res);
> > +	npfns = PFN_SECTION_ALIGN_UP((size - start_pad - end_trunc - SZ_8K)
> > +						/ PAGE_SIZE);
> > +
> > +      /*
> > +       * vmemmap_populate_hugepages() allocates the memmap array in
> > +       * HPAGE_SIZE chunks.
> > +       */
> > +	offset = ALIGN(start + SZ_8K + 64 * npfns, HPAGE_SIZE) - start;
> > +	vpmem->data_offset = offset;
> > +
> > +	struct vmem_altmap __altmap = {
> > +		.base_pfn = init_altmap_base(start+start_pad),
> > +		.reserve = init_altmap_reserve(start+start_pad),
> > +	};
> > +
> > +	res->start += start_pad;
> > +	res->end -= end_trunc;
> > +	memcpy(altmap, &__altmap, sizeof(*altmap));
> > +	altmap->free = PHYS_PFN(offset - SZ_8K);
> > +	altmap->alloc = 0;
> 
> The __altmap part can be rewritten using compound literal syntax:
> 
>   *altmap = (struct vmem_altmap) {
>       .base_pfn = init_altmap_base(start+start_pad),
>       .reserve = init_altmap_reserve(start+start_pad),
>       .free = PHYS_PFN(offset - SZ_8K),
>   };
> 
> This eliminates the temporary variable, memcpy, and explicit alloc = 0
> initialization.

o.k will use it.
  
> 
> > +
> > +	return altmap;
> > +}
> > +
> > +static blk_status_t pmem_do_bvec(struct virtio_pmem *pmem, struct page
> > *page,
> > +			unsigned int len, unsigned int off, bool is_write,
> > +			sector_t sector)
> > +{
> > +	blk_status_t rc = BLK_STS_OK;
> > +	phys_addr_t pmem_off = sector * 512 + pmem->data_offset;
> > +	void *pmem_addr = pmem->virt_addr + pmem_off;
> > +
> > +	if (!is_write) {
> > +		rc = read_pmem(page, off, pmem_addr, len);
> > +			flush_dcache_page(page);
> > +	} else {
> > +		flush_dcache_page(page);
> 
> What are the semantics of this device?  Why flush the dcache here if an
> explicit flush command needs to be sent over the virtqueue?

yes, we don't need it in this case. I yet have to think more
about flushing with block and file-system level support :)

> 
> > +		write_pmem(pmem_addr, page, off, len);
> > +	}
> > +
> > +	return rc;
> > +}
> > +
> > +static int vpmem_rw_page(struct block_device *bdev, sector_t sector,
> > +		       struct page *page, bool is_write)
> > +{
> > +	struct virtio_pmem  *pmem = bdev->bd_queue->queuedata;
> > +	blk_status_t rc;
> > +
> > +	rc = pmem_do_bvec(pmem, page, hpage_nr_pages(page) * PAGE_SIZE,
> > +			  0, is_write, sector);
> > +
> > +	if (rc == 0)
> > +		page_endio(page, is_write, 0);
> > +
> > +	return blk_status_to_errno(rc);
> > +}
> > +
> > +#ifndef REQ_FLUSH
> > +#define REQ_FLUSH REQ_PREFLUSH
> > +#endif
> 
> Is this out-of-tree kernel module compatibility stuff that can be
> removed?

yes, will check what filesystem expects for flush if not used then
remove.

> 
> > +
> > +static blk_qc_t virtio_pmem_make_request(struct request_queue *q,
> > +			struct bio *bio)
> > +{
> > +	blk_status_t rc = 0;
> > +	struct bio_vec bvec;
> > +	struct bvec_iter iter;
> > +	struct virtio_pmem *pmem = q->queuedata;
> > +
> > +	if (bio->bi_opf & REQ_FLUSH)
> > +		//todo host flush command
> 
> This detail is critical to the device design.  What is the plan?

yes, this is good point.

was thinking of guest sending a flush command to Qemu which
will do a fsync on file fd.

If we do a async flush and move the task to wait queue till we receive 
flush complete reply from host we can allow other tasks to execute
in current cpu.

Any suggestions you have or anything I am not foreseeing here?

> 
> > +
> > +	bio_for_each_segment(bvec, bio, iter) {
> > +		rc = pmem_do_bvec(pmem, bvec.bv_page, bvec.bv_len,
> > +				bvec.bv_offset, op_is_write(bio_op(bio)),
> > +				iter.bi_sector);
> > +		if (rc) {
> > +			bio->bi_status = rc;
> > +			break;
> > +		}
> > +	}
> > +
> > +	bio_endio(bio);
> > +	return BLK_QC_T_NONE;
> > +}
> > +
> > +static const struct block_device_operations pmem_fops = {
> > +	.owner =		THIS_MODULE,
> > +	.rw_page =		vpmem_rw_page,
> > +	//.revalidate_disk =	nvdimm_revalidate_disk,
> > +};
> > +
> > +static int virtio_pmem_probe(struct virtio_device *vdev)
> > +{
> > +	struct virtio_pmem *vpmem;
> > +	int err = 0;
> > +	void *addr;
> > +	struct resource *res, res_pfn;
> > +	struct request_queue *q;
> > +	struct vmem_altmap __altmap, *altmap = NULL;
> > +	struct gendisk *disk;
> > +	struct device *gendev;
> > +	int nid = dev_to_node(&vdev->dev);
> > +
> > +	if (!vdev->config->get) {
> > +		dev_err(&vdev->dev, "%s failure: config disabled\n",
> > +			__func__);
> > +		return -EINVAL;
> > +	}
> > +
> > +	vdev->priv = vpmem = devm_kzalloc(&vdev->dev, sizeof(*vpmem),
> > +			GFP_KERNEL);
> > +
> > +	if (!vpmem) {
> > +		err = -ENOMEM;
> > +		goto out;
> > +	}
> > +
> > +	dev_set_drvdata(&vdev->dev, vpmem);
> > +
> > +	vpmem->vdev = vdev;
> > +	err = init_vq(vpmem);
> > +	if (err)
> > +		goto out;
> > +
> > +	if (!virtio_has_feature(vdev, VIRTIO_PMEM_PLUG)) {
> > +		dev_err(&vdev->dev, "%s : pmem not supported\n",
> > +			__func__);
> > +		goto out;
> > +	}
> 
> Why is VIRTIO_PMEM_PLUG optional for this new device type if it's
> already required by the first version of the driver?

I just added it, initially kept it a place holder for any feature bit use.
I will remove it if we are not using it.

> 
> err is not set when the error path is taken.
> 
> > +
> > +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> > +			start, &vpmem->start);
> > +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> > +			size, &vpmem->size);
> 
> The struct resource start and size fields can vary between
> architectures.  Virtio device configuration space layout must not vary
> between architectures.  Please use u64.

sure.

> 
> > +
> > +	res_pfn.start = vpmem->start;
> > +	res_pfn.end   = vpmem->start + vpmem->size-1;
> > +
> > +	/* used for allocating memmap in the pmem device */
> > +	altmap	      = setup_pmem_pfn(vpmem, &res_pfn, &__altmap);
> > +
> > +	res = devm_request_mem_region(&vdev->dev,
> > +			res_pfn.start, resource_size(&res_pfn), "virtio-pmem");
> > +
> > +	if (!res) {
> > +		dev_warn(&vdev->dev, "could not reserve region ");
> > +		return -EBUSY;
> > +	}
> > +
> > +	q = blk_alloc_queue_node(GFP_KERNEL, dev_to_node(&vdev->dev));
> > +
> > +	if (!q)
> > +		return -ENOMEM;
> > +
> > +	if (devm_add_action_or_reset(&vdev->dev,
> > +				virtio_pmem_release_queue, q))
> > +		return -ENOMEM;
> > +
> > +	vpmem->pfn_flags = PFN_DEV;
> > +
> > +	/* allocate memap in pmem device itself */
> > +	if (IS_ENABLED(CONFIG_ZONE_DEVICE)) {
> > +
> > +		addr = devm_memremap_pages(&vdev->dev, res,
> > +				&q->q_usage_counter, altmap);
> > +		vpmem->pfn_flags |= PFN_MAP;
> > +	} else
> > +		addr = devm_memremap(&vdev->dev, vpmem->start,
> > +				vpmem->size, ARCH_MEMREMAP_PMEM);
> > +
> > +        /*
> > +         * At release time the queue must be frozen before
> > +         * devm_memremap_pages is unwound
> > +         */
> > +	if (devm_add_action_or_reset(&vdev->dev,
> > +				virtio_pmem_freeze_queue, q))
> > +		return -ENOMEM;
> > +
> > +	if (IS_ERR(addr))
> > +		return PTR_ERR(addr);
> > +
> > +	vpmem->virt_addr = addr;
> > +	blk_queue_write_cache(q, 0, 0);
> > +	blk_queue_make_request(q, virtio_pmem_make_request);
> > +	blk_queue_physical_block_size(q, PAGE_SIZE);
> > +	blk_queue_logical_block_size(q, 512);
> > +	blk_queue_max_hw_sectors(q, UINT_MAX);
> > +	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, q);
> > +	queue_flag_set_unlocked(QUEUE_FLAG_DAX, q);
> > +	q->queuedata = vpmem;
> > +
> > +	disk = alloc_disk_node(0, nid);
> > +	if (!disk)
> > +		return -ENOMEM;
> 
> The return statements in this function look suspicious.  There probably
> needs to be a cleanup to avoid memory leaks.

Sure! valid point.
> 
> > +	vpmem->disk = disk;
> > +
> > +	disk->fops                = &pmem_fops;
> > +	disk->queue               = q;
> > +	disk->flags               = GENHD_FL_EXT_DEVT;
> > +	strcpy(disk->disk_name, "vpmem");
> > +	set_capacity(disk, vpmem->size/512);
> > +	gendev = disk_to_dev(disk);
> > +
> > +	virtio_device_ready(vdev);
> > +	device_add_disk(&vdev->dev, disk);
> > +
> > +	if (devm_add_action_or_reset(&vdev->dev,
> > +			virtio_pmem_release_disk, vpmem))
> > +		return -ENOMEM;
> > +
> > +	revalidate_disk(disk);
> > +	return 0;
> > +out:
> > +	vdev->config->del_vqs(vdev);
> > +	return err;
> > +}
> > +
> > +static struct virtio_driver virtio_pmem_driver = {
> > +	.feature_table		= features,
> > +	.feature_table_size	= ARRAY_SIZE(features),
> > +	.driver.name		= KBUILD_MODNAME,
> > +	.driver.owner		= THIS_MODULE,
> > +	.id_table		= id_table,
> > +	.probe			= virtio_pmem_probe,
> > +	//.remove		= virtio_pmem_remove,
> > +};
> > +
> > +module_virtio_driver(virtio_pmem_driver);
> > +MODULE_DEVICE_TABLE(virtio, id_table);
> > +MODULE_DESCRIPTION("Virtio pmem driver");
> > +MODULE_LICENSE("GPL");
> > diff --git a/include/uapi/linux/virtio_pmem.h
> > b/include/uapi/linux/virtio_pmem.h
> > new file mode 100644
> > index 000000000000..ec0c728c79ba
> > --- /dev/null
> > +++ b/include/uapi/linux/virtio_pmem.h
> > @@ -0,0 +1,55 @@
> > +/*
> > + * Virtio pmem Device
> > + *
> > + *
> > + */
> > +
> > +#ifndef _LINUX_VIRTIO_PMEM_H
> > +#define _LINUX_VIRTIO_PMEM_H
> > +
> > +#include <linux/types.h>
> > +#include <linux/virtio_types.h>
> > +#include <linux/virtio_ids.h>
> > +#include <linux/virtio_config.h>
> > +#include <linux/pfn_t.h>
> > +#include <linux/fs.h>
> > +#include <linux/blk-mq.h>
> > +#include <linux/pmem_common.h>
> 
> include/uapi/ headers must compile when included from userspace
> applications.  The header should define userspace APIs only.
> 
> If you want to define kernel-internal APIs, please add them to
> include/linux/ or similar.
> 
> This also means that include/uapi/ headers cannot include
> include/linux/pmem_common.h or other kernel headers outside #ifdef
> __KERNEL__.

o.k

> 
> This header file should only contain struct virtio_pmem_config,
> VIRTIO_PMEM_PLUG, and other virtio device definitions.

Sure!
> 
> > +
> > +bool pmem_should_map_pages(struct device *dev);
> > +
> > +#define VIRTIO_PMEM_PLUG 0
> > +
> > +struct virtio_pmem_config {
> > +
> > +uint64_t start;
> > +uint64_t size;
> > +uint64_t align;
> > +uint64_t data_offset;
> > +};
> > +
> > +struct virtio_pmem {
> > +
> > +	struct virtio_device *vdev;
> > +	struct virtqueue *req_vq;
> > +
> > +	uint64_t start;
> > +	uint64_t size;
> > +	uint64_t align;
> > +	uint64_t data_offset;
> > +	u64 pfn_flags;
> > +	void *virt_addr;
> > +	struct gendisk *disk;
> > +} __packed;
> > +
> > +static struct virtio_device_id id_table[] = {
> > +	{ VIRTIO_ID_PMEM, VIRTIO_DEV_ANY_ID },
> > +	{ 0 },
> > +};
> > +
> > +static unsigned int features[] = {
> > +	VIRTIO_PMEM_PLUG,
> > +};
> > +
> > +#endif
> > +
> > --
> > 2.13.0
> > 
> 

Thanks,
Pankaj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
