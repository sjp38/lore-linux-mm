Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF4B6B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:12:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x16so4167552wmc.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:12:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x65sor1063689wme.80.2018.04.26.06.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 06:12:39 -0700 (PDT)
Date: Thu, 26 Apr 2018 14:12:36 +0100
From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] [RFC v2 1/2] virtio: add pmem driver
Message-ID: <20180426131236.GA30991@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180425112415.12327-2-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Content-Disposition: inline
In-Reply-To: <20180425112415.12327-2-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, kwolf@redhat.com, haozhong.zhang@intel.com, jack@suse.cz, xiaoguangrong.eric@gmail.com, riel@surriel.com, niteshnarayanlal@hotmail.com, david@redhat.com, ross.zwisler@intel.com, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, imammedo@redhat.com, marcel@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com, nilal@redhat.com


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 25, 2018 at 04:54:13PM +0530, Pankaj Gupta wrote:
> This patch adds virtio-pmem driver for KVM=20
> guest.=20
>=20
> Guest reads the persistent memory range=20
> information from Qemu over VIRTIO and registers=20
> it on nvdimm_bus. It also creates a nd_region=20
> object with the persistent memory range=20
> information so that existing 'nvdimm/pmem'=20
> driver can reserve this into system memory map.=20
> This way 'virtio-pmem' driver uses existing=20
> functionality of pmem driver to register persistent=20
> memory compatible for DAX capable filesystems.
>=20
> This also provides function to perform guest flush=20
> over VIRTIO from 'pmem' driver when userspace=20
> performs flush on DAX memory range.
>=20
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> ---
>  drivers/virtio/Kconfig           |  12 ++++
>  drivers/virtio/Makefile          |   1 +
>  drivers/virtio/virtio_pmem.c     | 118 +++++++++++++++++++++++++++++++++=
++++++
>  include/linux/libnvdimm.h        |   4 ++
>  include/uapi/linux/virtio_ids.h  |   1 +
>  include/uapi/linux/virtio_pmem.h |  58 +++++++++++++++++++
>  6 files changed, 194 insertions(+)
>  create mode 100644 drivers/virtio/virtio_pmem.c
>  create mode 100644 include/uapi/linux/virtio_pmem.h
>=20
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 3589764..879335d 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -42,6 +42,18 @@ config VIRTIO_PCI_LEGACY
> =20
>  	  If unsure, say Y.
> =20
> +config VIRTIO_PMEM
> +	tristate "Virtio pmem driver"
> +	depends on VIRTIO
> +	help
> +	 This driver adds persistent memory range to nd_region and registers
> +	 with nvdimm bus. NVDIMM 'pmem' driver later allocates a persistent
> +	 memory range on the memory information added by this driver. In additi=
on
> +	 to this, 'virtio-pmem' driver also provides a paravirt flushing interf=
ace
> +	 from guest to host.
> +
> +	 If unsure, say M.
> +
>  config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
> diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
> index 3a2b5c5..cbe91c6 100644
> --- a/drivers/virtio/Makefile
> +++ b/drivers/virtio/Makefile
> @@ -6,3 +6,4 @@ virtio_pci-y :=3D virtio_pci_modern.o virtio_pci_common.o
>  virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) +=3D virtio_pci_legacy.o
>  obj-$(CONFIG_VIRTIO_BALLOON) +=3D virtio_balloon.o
>  obj-$(CONFIG_VIRTIO_INPUT) +=3D virtio_input.o
> +obj-$(CONFIG_VIRTIO_PMEM) +=3D virtio_pmem.o
> diff --git a/drivers/virtio/virtio_pmem.c b/drivers/virtio/virtio_pmem.c
> new file mode 100644
> index 0000000..0906d2d
> --- /dev/null
> +++ b/drivers/virtio/virtio_pmem.c
> @@ -0,0 +1,118 @@

SPDX license line?  See Documentation/process/license-rules.rst.

> +/* Virtio pmem Driver
> + *
> + * Discovers persitent memory range information

s/persitent/persistent/

> + * from host and provides a virtio based flushing
> + * interface.
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
> +#include <linux/magic.h>
> +#include <linux/virtio_pmem.h>
> +#include <linux/libnvdimm.h>

Are all these headers really needed?  delay.h?  oom.h?

> +
> +static int init_vq(struct virtio_pmem *vpmem)
> +{
> +	struct virtqueue *vq;
> +
> +	/* single vq */
> +	vpmem->req_vq =3D vq =3D virtio_find_single_vq(vpmem->vdev,
> +				NULL, "flush_queue");
> +
> +	if (IS_ERR(vq))
> +		return PTR_ERR(vq);
> +
> +	return 0;
> +};
> +
> +static int virtio_pmem_probe(struct virtio_device *vdev)
> +{
> +	int err =3D 0;
> +	struct resource res;
> +	struct virtio_pmem *vpmem;
> +	struct nvdimm_bus *nvdimm_bus;
> +	struct nd_region_desc ndr_desc;
> +	int nid =3D dev_to_node(&vdev->dev);
> +	static struct nvdimm_bus_descriptor nd_desc;
> +
> +	if (!vdev->config->get) {
> +		dev_err(&vdev->dev, "%s failure: config disabled\n",
> +			__func__);
> +		return -EINVAL;
> +	}
> +
> +	vdev->priv =3D vpmem =3D devm_kzalloc(&vdev->dev, sizeof(*vpmem),
> +			GFP_KERNEL);
> +	if (!vpmem) {
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	vpmem->vdev =3D vdev;
> +	err =3D init_vq(vpmem);
> +	if (err)
> +		goto out;
> +
> +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> +			start, &vpmem->start);
> +	virtio_cread(vpmem->vdev, struct virtio_pmem_config,
> +			size, &vpmem->size);
> +
> +	res.start =3D vpmem->start;
> +	res.end   =3D vpmem->start + vpmem->size-1;
> +
> +	memset(&nd_desc, 0, sizeof(nd_desc));
> +	nd_desc.provider_name =3D "virtio-pmem";
> +	nd_desc.module =3D THIS_MODULE;
> +	nvdimm_bus =3D nvdimm_bus_register(&vdev->dev, &nd_desc);
> +
> +	if (!nvdimm_bus)
> +		goto out_nd;
> +	dev_set_drvdata(&vdev->dev, nvdimm_bus);
> +
> +	memset(&ndr_desc, 0, sizeof(ndr_desc));
> +	ndr_desc.res =3D &res;
> +	ndr_desc.numa_node =3D nid;
> +	set_bit(ND_REGION_PAGEMAP, &ndr_desc.flags);
> +	set_bit(ND_REGION_VIRTIO, &ndr_desc.flags);
> +
> +	if (!nvdimm_pmem_region_create(nvdimm_bus, &ndr_desc))
> +		goto out_nd;
> +
> +	virtio_device_ready(vdev);
> +	return 0;
> +
> +out_nd:
> +	nvdimm_bus_unregister(nvdimm_bus);
> +out:
> +	dev_err(&vdev->dev, "failed to register virtio pmem memory\n");
> +	vdev->config->del_vqs(vdev);
> +	return err;
> +}
> +
> +static void virtio_pmem_remove(struct virtio_device *vdev)
> +{
> +	struct nvdimm_bus *nvdimm_bus =3D dev_get_drvdata(&vdev->dev);
> +
> +	nvdimm_bus_unregister(nvdimm_bus);
> +	vdev->config->del_vqs(vdev);
> +}
> +
> +static struct virtio_driver virtio_pmem_driver =3D {
> +	.driver.name		=3D KBUILD_MODNAME,
> +	.driver.owner		=3D THIS_MODULE,
> +	.id_table		=3D id_table,
> +	.probe			=3D virtio_pmem_probe,
> +	.remove			=3D virtio_pmem_remove,
> +};
> +
> +module_virtio_driver(virtio_pmem_driver);
> +MODULE_DEVICE_TABLE(virtio, id_table);
> +MODULE_DESCRIPTION("Virtio pmem driver");
> +MODULE_LICENSE("GPL");
> diff --git a/include/linux/libnvdimm.h b/include/linux/libnvdimm.h
> index 097072c..b1b7f14 100644
> --- a/include/linux/libnvdimm.h
> +++ b/include/linux/libnvdimm.h
> @@ -58,6 +58,10 @@ enum {
>  	 * (ADR)
>  	 */
>  	ND_REGION_PERSIST_MEMCTRL =3D 2,
> +	/*
> +	 * region flag indicating to use VIRTIO flush interface for pmem
> +	 */
> +	ND_REGION_VIRTIO =3D 3,

Can you add a generic flush callback to libnvdimm instead?  That way
virtio and other drivers can hook in without hardcoding knowledge of
these drivers into libnvdimm.

> =20
>  	/* mark newly adjusted resources as requiring a label update */
>  	DPA_RESOURCE_ADJUSTED =3D 1 << 0,
> diff --git a/include/uapi/linux/virtio_ids.h b/include/uapi/linux/virtio_=
ids.h
> index 6d5c3b2..5ebd049 100644
> --- a/include/uapi/linux/virtio_ids.h
> +++ b/include/uapi/linux/virtio_ids.h
> @@ -43,5 +43,6 @@
>  #define VIRTIO_ID_INPUT        18 /* virtio input */
>  #define VIRTIO_ID_VSOCK        19 /* virtio vsock transport */
>  #define VIRTIO_ID_CRYPTO       20 /* virtio crypto */
> +#define VIRTIO_ID_PMEM         21 /* virtio pmem */
> =20
>  #endif /* _LINUX_VIRTIO_IDS_H */
> diff --git a/include/uapi/linux/virtio_pmem.h b/include/uapi/linux/virtio=
_pmem.h
> new file mode 100644
> index 0000000..2ec27cb
> --- /dev/null
> +++ b/include/uapi/linux/virtio_pmem.h
> @@ -0,0 +1,58 @@
> +/* Virtio pmem Driver
> + *
> + * Discovers persitent memory range information

s/persitent/persistent/

> + * from host and provides a virtio based flushing
> + * interface.
> + */
> +
> +#ifndef _LINUX_VIRTIO_PMEM_H
> +#define _LINUX_VIRTIO_PMEM_H
> +
> +#include <linux/types.h>
> +#include <linux/virtio_types.h>
> +#include <linux/virtio_ids.h>
> +#include <linux/virtio_config.h>
> +#include <linux/virtio_ring.h>
> +
> +
> +struct virtio_pmem_config {
> +
> +	uint64_t start;
> +	uint64_t size;
> +};
> +
> +struct virtio_pmem {
> +
> +	struct virtio_device *vdev;
> +	struct virtqueue *req_vq;
> +
> +	uint64_t start;
> +	uint64_t size;
> +} __packed;

This is a userspace API header file, it should contain definitions that
userspace programs need.  struct virtio_pmem is a kernel-internal struct
that should not be in the uapi headers.

Only define virtio spec structs in this header file (e.g. config space,
request structs, etc).

> +static struct virtio_device_id id_table[] =3D {
> +	{ VIRTIO_ID_PMEM, VIRTIO_DEV_ANY_ID },
> +	{ 0 },
> +};

Why is static variable in the header file?

> +
> +void virtio_pmem_flush(struct device *dev)

This only implements flush command submission, not completion.  Maybe
the next patch will implement that but it's a little strange to only see
half of the flush operation.

Please put the whole flush operation in one patch so it can be reviewed
easily.  At this point I don't know if you've forgotten to implement
wait for completion.

> +{

Why is this function body in the header file?

> +	struct scatterlist sg;
> +	struct virtio_device *vdev  =3D dev_to_virtio(dev->parent->parent);
> +	struct virtio_pmem   *vpmem =3D vdev->priv;
> +	char *buf =3D "FLUSH";

I'm surprised this compiles without a warning.  String literals should
be constant but the char pointer isn't constant.

> +	int err;
> +
> +	sg_init_one(&sg, buf, sizeof(buf));
> +
> +	err =3D virtqueue_add_outbuf(vpmem->req_vq, &sg, 1, buf, GFP_KERNEL);
> +
> +	if (err) {
> +		dev_err(&vdev->dev, "failed to send command to virtio pmem device\n");
> +		return;
> +	}
> +
> +	virtqueue_kick(vpmem->req_vq);

Is any locking necessary?  Two CPUs must not invoke virtio_pmem_flush()
at the same time.  Not sure if anything guarantees this, maybe you're
relying on libnvdimm but I haven't checked.

> +};
> +
> +#endif
> --=20
> 2.9.3
>=20
>=20

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJa4dBEAAoJEJykq7OBq3PIAuwIALjYiXdbG44WRjva5Fa+xquy
tYtsAwjAhrSv1zI5bjnGKbdqRvbX9kQbFjbnRp55vg455+f3P2iV1jVJ2DcA/+JA
sX6ctlLOzMttsnLSadblCZRMYax5+78hw0B0oAugFuAS7SfNt9ht7YECDK6r9Z70
L/ABjfRMFlHO5qmEEP9s6ef2jT2I7TpnrBYgPbIjTcSsr9w+8cIO/6FRogtKMj5s
0Q40ORQx4Xc5I0gRmuFDL/OOTxxmmwuMd1XNQWGfq0RdFRBsih1jIhCTWDCo1ekZ
ih2p0WB8/YJm9tv1aEARw1vtmWhMx+SJeNUVHKy0u3JEoOAP71CxalE8owINEJ8=
=sMMV
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
