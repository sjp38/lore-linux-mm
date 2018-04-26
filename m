Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 824FE6B0008
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:45:02 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id b5-v6so5078652otf.7
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:45:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32-v6si7494342ote.128.2018.04.26.08.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 08:45:01 -0700 (PDT)
Date: Thu, 26 Apr 2018 11:44:59 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <197910974.22984070.1524757499459.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180426131236.GA30991@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-2-pagupta@redhat.com> <20180426131236.GA30991@stefanha-x1.localdomain>
Subject: Re: [Qemu-devel] [RFC v2 1/2] virtio: add pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, kwolf@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, jack@suse.cz, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, riel@surriel.com, niteshnarayanlal@hotmail.com, david@redhat.com, ross zwisler <ross.zwisler@intel.com>, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, imammedo@redhat.com, marcel@redhat.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, nilal@redhat.com


> > This patch adds virtio-pmem driver for KVM
> > guest.
> > 
> > Guest reads the persistent memory range
> > information from Qemu over VIRTIO and registers
> > it on nvdimm_bus. It also creates a nd_region
> > object with the persistent memory range
> > information so that existing 'nvdimm/pmem'
> > driver can reserve this into system memory map.
> > This way 'virtio-pmem' driver uses existing
> > functionality of pmem driver to register persistent
> > memory compatible for DAX capable filesystems.
> > 
> > This also provides function to perform guest flush
> > over VIRTIO from 'pmem' driver when userspace
> > performs flush on DAX memory range.
> > 
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > ---
> >  drivers/virtio/Kconfig           |  12 ++++
> >  drivers/virtio/Makefile          |   1 +
> >  drivers/virtio/virtio_pmem.c     | 118
> >  +++++++++++++++++++++++++++++++++++++++
> >  include/linux/libnvdimm.h        |   4 ++
> >  include/uapi/linux/virtio_ids.h  |   1 +
> >  include/uapi/linux/virtio_pmem.h |  58 +++++++++++++++++++
> >  6 files changed, 194 insertions(+)
> >  create mode 100644 drivers/virtio/virtio_pmem.c
> >  create mode 100644 include/uapi/linux/virtio_pmem.h
> > 
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index 3589764..879335d 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -42,6 +42,18 @@ config VIRTIO_PCI_LEGACY
> >  
> >  	  If unsure, say Y.
> >  
> > +config VIRTIO_PMEM
> > +	tristate "Virtio pmem driver"
> > +	depends on VIRTIO
> > +	help
> > +	 This driver adds persistent memory range to nd_region and registers
> > +	 with nvdimm bus. NVDIMM 'pmem' driver later allocates a persistent
> > +	 memory range on the memory information added by this driver. In addition
> > +	 to this, 'virtio-pmem' driver also provides a paravirt flushing
> > interface
> > +	 from guest to host.
> > +
> > +	 If unsure, say M.
> > +
> >  config VIRTIO_BALLOON
> >  	tristate "Virtio balloon driver"
> >  	depends on VIRTIO
> > diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> > index 3a2b5c5..cbe91c6 100644
> > --- a/drivers/virtio/Makefile
> > +++ b/drivers/virtio/Makefile
> > @@ -6,3 +6,4 @@ virtio_pci-y := virtio_pci_modern.o virtio_pci_common.o
> >  virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) += virtio_pci_legacy.o
> >  obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
> >  obj-$(CONFIG_VIRTIO_INPUT) += virtio_input.o
> > +obj-$(CONFIG_VIRTIO_PMEM) += virtio_pmem.o
> > diff --git a/drivers/virtio/virtio_pmem.c b/drivers/virtio/virtio_pmem.c
> > new file mode 100644
> > index 0000000..0906d2d
> > --- /dev/null
> > +++ b/drivers/virtio/virtio_pmem.c
> > @@ -0,0 +1,118 @@
> 
> SPDX license line?  See Documentation/process/license-rules.rst.

o.k. 

> 
> > +/* Virtio pmem Driver
> > + *
> > + * Discovers persitent memory range information
> 
> s/persitent/persistent/
> 
> > + * from host and provides a virtio based flushing
> > + * interface.
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
> > +#include <linux/magic.h>
> > +#include <linux/virtio_pmem.h>
> > +#include <linux/libnvdimm.h>
> 
> Are all these headers really needed?  delay.h?  oom.h?

Will remove not required ones. There are from previous
RFC where used *memremap* and other mm & block includes.

> 
> > +
> > +static int init_vq(struct virtio_pmem *vpmem)
> > +{
> > +	struct virtqueue *vq;
> > +
> > +	/* single vq */
> > +	vpmem->req_vq = vq = virtio_find_single_vq(vpmem->vdev,
> > +				NULL, "flush_queue");
> > +
> > +	if (IS_ERR(vq))
> > +		return PTR_ERR(vq);
> > +
> > +	return 0;
> > +};
> > +
> > +static int virtio_pmem_probe(struct virtio_device *vdev)
> > +{
> > +	int err = 0;
> > +	struct resource res;
> > +	struct virtio_pmem *vpmem;
> > +	struct nvdimm_bus *nvdimm_bus;
> > +	struct nd_region_desc ndr_desc;
> > +	int nid = dev_to_node(&vdev->dev);
> > +	static struct nvdimm_bus_descriptor nd_desc;
> > +
> > +	if (!vdev->config->get) {
> > +		dev_err(&vdev->dev, "%s failure: config disabled\n",
> > +			__func__);
> > +		return -EINVAL;
> > +	}
> > +
> > +	vdev->priv = vpmem = devm_kzalloc(&vdev->dev, sizeof(*vpmem),
> > +			GFP_KERNEL);
> > +	if (!vpmem) {
> > +		err = -ENOMEM;
> > +		goto out;
> > +	}
> > +
> > +	vpmem->vdev = vdev;
> > +	err = init_vq(vpmem);
> > +	if (err)
> > +		goto out;
> > +
> > +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> > +			start, &vpmem->start);
> > +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> > +			size, &vpmem->size);
> > +
> > +	res.start = vpmem->start;
> > +	res.end   = vpmem->start + vpmem->size-1;
> > +
> > +	memset(&nd_desc, 0, sizeof(nd_desc));
> > +	nd_desc.provider_name = "virtio-pmem";
> > +	nd_desc.module = THIS_MODULE;
> > +	nvdimm_bus = nvdimm_bus_register(&vdev->dev, &nd_desc);
> > +
> > +	if (!nvdimm_bus)
> > +		goto out_nd;
> > +	dev_set_drvdata(&vdev->dev, nvdimm_bus);
> > +
> > +	memset(&ndr_desc, 0, sizeof(ndr_desc));
> > +	ndr_desc.res = &res;
> > +	ndr_desc.numa_node = nid;
> > +	set_bit(ND_REGION_PAGEMAP, &ndr_desc.flags);
> > +	set_bit(ND_REGION_VIRTIO, &ndr_desc.flags);
> > +
> > +	if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
> > +		goto out_nd;
> > +
> > +	virtio_device_ready(vdev);
> > +	return 0;
> > +
> > +out_nd:
> > +	nvdimm_bus_unregister(nvdimm_bus);
> > +out:
> > +	dev_err(&vdev->dev, "failed to register virtio pmem memory\n");
> > +	vdev->config->del_vqs(vdev);
> > +	return err;
> > +}
> > +
> > +static void virtio_pmem_remove(struct virtio_device *vdev)
> > +{
> > +	struct nvdimm_bus *nvdimm_bus = dev_get_drvdata(&vdev->dev);
> > +
> > +	nvdimm_bus_unregister(nvdimm_bus);
> > +	vdev->config->del_vqs(vdev);
> > +}
> > +
> > +static struct virtio_driver virtio_pmem_driver = {
> > +	.driver.name		= KBUILD_MODNAME,
> > +	.driver.owner		= THIS_MODULE,
> > +	.id_table		= id_table,
> > +	.probe			= virtio_pmem_probe,
> > +	.remove			= virtio_pmem_remove,
> > +};
> > +
> > +module_virtio_driver(virtio_pmem_driver);
> > +MODULE_DEVICE_TABLE(virtio, id_table);
> > +MODULE_DESCRIPTION("Virtio pmem driver");
> > +MODULE_LICENSE("GPL");
> > diff --git a/include/linux/libnvdimm.h b/include/linux/libnvdimm.h
> > index 097072c..b1b7f14 100644
> > --- a/include/linux/libnvdimm.h
> > +++ b/include/linux/libnvdimm.h
> > @@ -58,6 +58,10 @@ enum {
> >  	 * (ADR)
> >  	 */
> >  	ND_REGION_PERSIST_MEMCTRL = 2,
> > +	/*
> > +	 * region flag indicating to use VIRTIO flush interface for pmem
> > +	 */
> > +	ND_REGION_VIRTIO = 3,
> 
> Can you add a generic flush callback to libnvdimm instead?  That way
> virtio and other drivers can hook in without hardcoding knowledge of
> these drivers into libnvdimm.

Sure! Working on this. Same suggestion by Dan.

> 
> >  
> >  	/* mark newly adjusted resources as requiring a label update */
> >  	DPA_RESOURCE_ADJUSTED = 1 << 0,
> > diff --git a/include/uapi/linux/virtio_ids.h
> > b/include/uapi/linux/virtio_ids.h
> > index 6d5c3b2..5ebd049 100644
> > --- a/include/uapi/linux/virtio_ids.h
> > +++ b/include/uapi/linux/virtio_ids.h
> > @@ -43,5 +43,6 @@
> >  #define VIRTIO_ID_INPUT        18 /* virtio input */
> >  #define VIRTIO_ID_VSOCK        19 /* virtio vsock transport */
> >  #define VIRTIO_ID_CRYPTO       20 /* virtio crypto */
> > +#define VIRTIO_ID_PMEM         21 /* virtio pmem */
> >  
> >  #endif /* _LINUX_VIRTIO_IDS_H */
> > diff --git a/include/uapi/linux/virtio_pmem.h
> > b/include/uapi/linux/virtio_pmem.h
> > new file mode 100644
> > index 0000000..2ec27cb
> > --- /dev/null
> > +++ b/include/uapi/linux/virtio_pmem.h
> > @@ -0,0 +1,58 @@
> > +/* Virtio pmem Driver
> > + *
> > + * Discovers persitent memory range information
> 
> s/persitent/persistent/
> 
> > + * from host and provides a virtio based flushing
> > + * interface.
> > + */
> > +
> > +#ifndef _LINUX_VIRTIO_PMEM_H
> > +#define _LINUX_VIRTIO_PMEM_H
> > +
> > +#include <linux/types.h>
> > +#include <linux/virtio_types.h>
> > +#include <linux/virtio_ids.h>
> > +#include <linux/virtio_config.h>
> > +#include <linux/virtio_ring.h>
> > +
> > +
> > +struct virtio_pmem_config {
> > +
> > +	uint64_t start;
> > +	uint64_t size;
> > +};
> > +
> > +struct virtio_pmem {
> > +
> > +	struct virtio_device *vdev;
> > +	struct virtqueue *req_vq;
> > +
> > +	uint64_t start;
> > +	uint64_t size;
> > +} __packed;
> 
> This is a userspace API header file, it should contain definitions that
> userspace programs need.  struct virtio_pmem is a kernel-internal struct
> that should not be in the uapi headers.
> 
> Only define virtio spec structs in this header file (e.g. config space,
> request structs, etc).

o.k 

> 
> > +static struct virtio_device_id id_table[] = {
> > +	{ VIRTIO_ID_PMEM, VIRTIO_DEV_ANY_ID },
> > +	{ 0 },
> > +};
> 
> Why is static variable in the header file?

mistake :)

> 
> > +
> > +void virtio_pmem_flush(struct device *dev)
> 
> This only implements flush command submission, not completion.  Maybe
> the next patch will implement that but it's a little strange to only see
> half of the flush operation.
> 
> Please put the whole flush operation in one patch so it can be reviewed
> easily.  At this point I don't know if you've forgotten to implement
> wait for completion.
> 
> > +{
> 
> Why is this function body in the header file?

Because I was trying to use it from pmem module without loading
virtio_pmem driver or load it dynamically. I think adding flush function in
'nd_region' struct and set it as per region type looks better solution. 
Suggested by Dan & you. 

> 
> > +	struct scatterlist sg;
> > +	struct virtio_device *vdev  = dev_to_virtio(dev->parent->parent);
> > +	struct virtio_pmem   *vpmem = vdev->priv;
> > +	char *buf = "FLUSH";
> 
> I'm surprised this compiles without a warning.  String literals should
> be constant but the char pointer isn't constant.

Point taken.

> 
> > +	int err;
> > +
> > +	sg_init_one(&sg, buf, sizeof(buf));
> > +
> > +	err = virtqueue_add_outbuf(vpmem->req_vq, &sg, 1, buf, GFP_KERNEL);
> > +
> > +	if (err) {
> > +		dev_err(&vdev->dev, "failed to send command to virtio pmem device\n");
> > +		return;
> > +	}
> > +
> > +	virtqueue_kick(vpmem->req_vq);
> 
> Is any locking necessary?  Two CPUs must not invoke virtio_pmem_flush()
> at the same time.  Not sure if anything guarantees this, maybe you're
> relying on libnvdimm but I haven't checked.

I thought about it to some extent, and wanted to go ahead with simple version first:

- I think file 'inode -> locking' sill is there for request on single file.
- For multiple files, our aim is to just flush the backend block image.
- Even there is collision for virt queue read/write entry it should just trigger a Qemu fsync. 
  We just want most recent flush to assure guest writes are synced properly.

Important point here: We are doing entire block fsync for guest virtual disk.

> 
> > +};
> > +
> > +#endif
> > --
> > 2.9.3
> > 
> > 
> 
