Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0ABE6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:51:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n82so4789481oig.1
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:51:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u31sor4798640oti.317.2017.10.12.13.51.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 13:51:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171012155027.3277-3-pagupta@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Oct 2017 13:51:30 -0700
Message-ID: <CAPcyv4i7k6aYK_y4zZtL6p8sW-E_Ft58d2HuxO=dYciqQxaoLg@mail.gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Thu, Oct 12, 2017 at 8:50 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
>   This patch adds virtio-pmem driver for KVM guest.
>   Guest reads the persistent memory range information
>   over virtio bus from Qemu and reserves the range
>   as persistent memory. Guest also allocates a block
>   device corresponding to the pmem range which later
>   can be accessed with DAX compatible file systems.
>   Idea is to use the virtio channel between guest and
>   host to perform the block device flush for guest pmem
>   DAX device.
>
>   There is work to do including DAX file system support
>   and other advanced features.
>
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> ---
>  drivers/virtio/Kconfig           |  10 ++
>  drivers/virtio/Makefile          |   1 +
>  drivers/virtio/virtio_pmem.c     | 322 +++++++++++++++++++++++++++++++++++++++
>  include/uapi/linux/virtio_pmem.h |  55 +++++++
>  4 files changed, 388 insertions(+)
>  create mode 100644 drivers/virtio/virtio_pmem.c
>  create mode 100644 include/uapi/linux/virtio_pmem.h
>
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index cff773f15b7e..0192c4bda54b 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -38,6 +38,16 @@ config VIRTIO_PCI_LEGACY
>
>           If unsure, say Y.
>
> +config VIRTIO_PMEM
> +       tristate "Virtio pmem driver"
> +       depends on VIRTIO
> +       ---help---
> +        This driver adds persistent memory range within a KVM guest.

I think we need to call this something other than persistent memory to
make it clear that this not memory where the persistence can be
managed from userspace. The persistence point always requires a driver
call, so this is something distinctly different than "persistent
memory". For example, it's a bug if this memory range ends up backing
a device-dax range in the guest where there is no such thing as a
driver callback to perform the flushing. How does this solution
protect against that scenario?

> +         It also associates a block device corresponding to the pmem
> +        range.
> +
> +        If unsure, say M.
> +
>  config VIRTIO_BALLOON
>         tristate "Virtio balloon driver"
>         depends on VIRTIO
> diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> index 41e30e3dc842..032ade725cc2 100644
> --- a/drivers/virtio/Makefile
> +++ b/drivers/virtio/Makefile
> @@ -5,3 +5,4 @@ virtio_pci-y := virtio_pci_modern.o virtio_pci_common.o
>  virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) += virtio_pci_legacy.o
>  obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
>  obj-$(CONFIG_VIRTIO_INPUT) += virtio_input.o
> +obj-$(CONFIG_VIRTIO_PMEM) += virtio_pmem.o
> diff --git a/drivers/virtio/virtio_pmem.c b/drivers/virtio/virtio_pmem.c
> new file mode 100644
> index 000000000000..74e47cae0e24
> --- /dev/null
> +++ b/drivers/virtio/virtio_pmem.c
> @@ -0,0 +1,322 @@
> +/*
> + * virtio-pmem driver
> + */
> +
> +#include <linux/virtio.h>
> +#include <linux/swap.h>
> +#include <linux/workqueue.h>
> +#include <linux/delay.h>
> +#include <linux/slab.h>
> +#include <linux/module.h>
> +#include <linux/oom.h>
> +#include <linux/wait.h>
> +#include <linux/mm.h>
> +#include <linux/mount.h>
> +#include <linux/magic.h>
> +#include <linux/virtio_pmem.h>
> +
> +void devm_vpmem_disable(struct device *dev, struct resource *res, void *addr)
> +{
> +       devm_memunmap(dev, addr);
> +       devm_release_mem_region(dev, res->start, resource_size(res));
> +}
> +
> +static void pmem_flush_done(struct virtqueue *vq)
> +{
> +       return;
> +};
> +
> +static void virtio_pmem_release_queue(void *q)
> +{
> +       blk_cleanup_queue(q);
> +}
> +
> +static void virtio_pmem_freeze_queue(void *q)
> +{
> +       blk_freeze_queue_start(q);
> +}
> +
> +static void virtio_pmem_release_disk(void *__pmem)
> +{
> +       struct virtio_pmem *pmem = __pmem;
> +
> +       del_gendisk(pmem->disk);
> +       put_disk(pmem->disk);
> +}

This code seems identical to the base pmem case, it should move to the
shared code object.

> +
> +static int init_vq(struct virtio_pmem *vpmem)
> +{
> +       struct virtqueue *vq;
> +
> +       /* single vq */
> +       vq = virtio_find_single_vq(vpmem->vdev, pmem_flush_done, "flush_queue");
> +
> +       if (IS_ERR(vq))
> +               return PTR_ERR(vq);
> +
> +       return 0;
> +}
> +
> +static struct vmem_altmap *setup_pmem_pfn(struct virtio_pmem *vpmem,
> +                       struct resource *res, struct vmem_altmap *altmap)
> +{
> +       u32 start_pad = 0, end_trunc = 0;
> +       resource_size_t start, size;
> +       unsigned long npfns;
> +       phys_addr_t offset;
> +
> +       size = resource_size(res);
> +       start = PHYS_SECTION_ALIGN_DOWN(res->start);
> +
> +       if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> +               IORES_DESC_NONE) == REGION_MIXED) {
> +
> +               start = res->start;
> +               start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
> +       }
> +       start = res->start;
> +       size = PHYS_SECTION_ALIGN_UP(start + size) - start;
> +
> +       if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> +               IORES_DESC_NONE) == REGION_MIXED) {
> +
> +               size = resource_size(res);
> +               end_trunc = start + size -
> +                               PHYS_SECTION_ALIGN_DOWN(start + size);
> +       }
> +
> +       start += start_pad;
> +       size = resource_size(res);
> +       npfns = PFN_SECTION_ALIGN_UP((size - start_pad - end_trunc - SZ_8K)
> +                                               / PAGE_SIZE);
> +
> +      /*
> +       * vmemmap_populate_hugepages() allocates the memmap array in
> +       * HPAGE_SIZE chunks.
> +       */
> +       offset = ALIGN(start + SZ_8K + 64 * npfns, HPAGE_SIZE) - start;
> +       vpmem->data_offset = offset;
> +
> +       struct vmem_altmap __altmap = {
> +               .base_pfn = init_altmap_base(start+start_pad),
> +               .reserve = init_altmap_reserve(start+start_pad),
> +       };
> +
> +       res->start += start_pad;
> +       res->end -= end_trunc;
> +       memcpy(altmap, &__altmap, sizeof(*altmap));
> +       altmap->free = PHYS_PFN(offset - SZ_8K);
> +       altmap->alloc = 0;
> +
> +       return altmap;
> +}
> +
> +static blk_status_t pmem_do_bvec(struct virtio_pmem *pmem, struct page *page,
> +                       unsigned int len, unsigned int off, bool is_write,
> +                       sector_t sector)
> +{
> +       blk_status_t rc = BLK_STS_OK;
> +       phys_addr_t pmem_off = sector * 512 + pmem->data_offset;
> +       void *pmem_addr = pmem->virt_addr + pmem_off;
> +
> +       if (!is_write) {
> +               rc = read_pmem(page, off, pmem_addr, len);
> +                       flush_dcache_page(page);
> +       } else {
> +               flush_dcache_page(page);
> +               write_pmem(pmem_addr, page, off, len);
> +       }
> +
> +       return rc;
> +}
> +
> +static int vpmem_rw_page(struct block_device *bdev, sector_t sector,
> +                      struct page *page, bool is_write)
> +{
> +       struct virtio_pmem  *pmem = bdev->bd_queue->queuedata;
> +       blk_status_t rc;
> +
> +       rc = pmem_do_bvec(pmem, page, hpage_nr_pages(page) * PAGE_SIZE,
> +                         0, is_write, sector);
> +
> +       if (rc == 0)
> +               page_endio(page, is_write, 0);
> +
> +       return blk_status_to_errno(rc);
> +}
> +
> +#ifndef REQ_FLUSH
> +#define REQ_FLUSH REQ_PREFLUSH
> +#endif
> +
> +static blk_qc_t virtio_pmem_make_request(struct request_queue *q,
> +                       struct bio *bio)
> +{
> +       blk_status_t rc = 0;
> +       struct bio_vec bvec;
> +       struct bvec_iter iter;
> +       struct virtio_pmem *pmem = q->queuedata;
> +
> +       if (bio->bi_opf & REQ_FLUSH)
> +               //todo host flush command
> +
> +       bio_for_each_segment(bvec, bio, iter) {
> +               rc = pmem_do_bvec(pmem, bvec.bv_page, bvec.bv_len,
> +                               bvec.bv_offset, op_is_write(bio_op(bio)),
> +                               iter.bi_sector);
> +               if (rc) {
> +                       bio->bi_status = rc;
> +                       break;
> +               }
> +       }
> +
> +       bio_endio(bio);
> +       return BLK_QC_T_NONE;
> +}

Again, the above could be shared by both drivers.

> +
> +static const struct block_device_operations pmem_fops = {
> +       .owner =                THIS_MODULE,
> +       .rw_page =              vpmem_rw_page,
> +       //.revalidate_disk =    nvdimm_revalidate_disk,
> +};
> +
> +static int virtio_pmem_probe(struct virtio_device *vdev)
> +{
> +       struct virtio_pmem *vpmem;
> +       int err = 0;
> +       void *addr;
> +       struct resource *res, res_pfn;
> +       struct request_queue *q;
> +       struct vmem_altmap __altmap, *altmap = NULL;
> +       struct gendisk *disk;
> +       struct device *gendev;
> +       int nid = dev_to_node(&vdev->dev);
> +
> +       if (!vdev->config->get) {
> +               dev_err(&vdev->dev, "%s failure: config disabled\n",
> +                       __func__);
> +               return -EINVAL;
> +       }
> +
> +       vdev->priv = vpmem = devm_kzalloc(&vdev->dev, sizeof(*vpmem),
> +                       GFP_KERNEL);
> +
> +       if (!vpmem) {
> +               err = -ENOMEM;
> +               goto out;
> +       }
> +
> +       dev_set_drvdata(&vdev->dev, vpmem);
> +
> +       vpmem->vdev = vdev;
> +       err = init_vq(vpmem);
> +       if (err)
> +               goto out;
> +
> +       if (!virtio_has_feature(vdev, VIRTIO_PMEM_PLUG)) {
> +               dev_err(&vdev->dev, "%s : pmem not supported\n",
> +                       __func__);
> +               goto out;
> +       }
> +
> +       virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> +                       start, &vpmem->start);
> +       virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> +                       size, &vpmem->size);
> +
> +       res_pfn.start = vpmem->start;
> +       res_pfn.end   = vpmem->start + vpmem->size-1;
> +
> +       /* used for allocating memmap in the pmem device */
> +       altmap        = setup_pmem_pfn(vpmem, &res_pfn, &__altmap);
> +
> +       res = devm_request_mem_region(&vdev->dev,
> +                       res_pfn.start, resource_size(&res_pfn), "virtio-pmem");
> +
> +       if (!res) {
> +               dev_warn(&vdev->dev, "could not reserve region ");
> +               return -EBUSY;
> +       }
> +
> +       q = blk_alloc_queue_node(GFP_KERNEL, dev_to_node(&vdev->dev));
> +
> +       if (!q)
> +               return -ENOMEM;
> +
> +       if (devm_add_action_or_reset(&vdev->dev,
> +                               virtio_pmem_release_queue, q))
> +               return -ENOMEM;
> +
> +       vpmem->pfn_flags = PFN_DEV;
> +
> +       /* allocate memap in pmem device itself */
> +       if (IS_ENABLED(CONFIG_ZONE_DEVICE)) {
> +
> +               addr = devm_memremap_pages(&vdev->dev, res,
> +                               &q->q_usage_counter, altmap);
> +               vpmem->pfn_flags |= PFN_MAP;
> +       } else
> +               addr = devm_memremap(&vdev->dev, vpmem->start,
> +                               vpmem->size, ARCH_MEMREMAP_PMEM);
> +
> +        /*
> +         * At release time the queue must be frozen before
> +         * devm_memremap_pages is unwound
> +         */
> +       if (devm_add_action_or_reset(&vdev->dev,
> +                               virtio_pmem_freeze_queue, q))
> +               return -ENOMEM;
> +
> +       if (IS_ERR(addr))
> +               return PTR_ERR(addr);
> +
> +       vpmem->virt_addr = addr;
> +       blk_queue_write_cache(q, 0, 0);
> +       blk_queue_make_request(q, virtio_pmem_make_request);
> +       blk_queue_physical_block_size(q, PAGE_SIZE);
> +       blk_queue_logical_block_size(q, 512);
> +       blk_queue_max_hw_sectors(q, UINT_MAX);
> +       queue_flag_set_unlocked(QUEUE_FLAG_NONROT, q);
> +       queue_flag_set_unlocked(QUEUE_FLAG_DAX, q);
> +       q->queuedata = vpmem;
> +
> +       disk = alloc_disk_node(0, nid);
> +       if (!disk)
> +               return -ENOMEM;
> +       vpmem->disk = disk;
> +
> +       disk->fops                = &pmem_fops;
> +       disk->queue               = q;
> +       disk->flags               = GENHD_FL_EXT_DEVT;
> +       strcpy(disk->disk_name, "vpmem");
> +       set_capacity(disk, vpmem->size/512);
> +       gendev = disk_to_dev(disk);
> +
> +       virtio_device_ready(vdev);
> +       device_add_disk(&vdev->dev, disk);
> +
> +       if (devm_add_action_or_reset(&vdev->dev,
> +                       virtio_pmem_release_disk, vpmem))
> +               return -ENOMEM;
> +
> +       revalidate_disk(disk);
> +       return 0;
> +out:
> +       vdev->config->del_vqs(vdev);
> +       return err;
> +}

Here we have a mix of code that is common and some that is virtio
specific, the shared code should be factored out into a common helper
that both drivers call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
