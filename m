Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A09A86B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:44:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f21so4095901wmh.5
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:44:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15sor3214289wmu.12.2018.04.26.06.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 06:44:21 -0700 (PDT)
Date: Thu, 26 Apr 2018 14:24:06 +0100
From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [RFC v2] qemu: Add virtio pmem device
Message-ID: <20180426132406.GC30991@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180425112415.12327-4-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fig2xvG2VGoz8o/s"
Content-Disposition: inline
In-Reply-To: <20180425112415.12327-4-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@surriel.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, hch@infradead.org, marcel@redhat.com, mst@redhat.com, niteshnarayanlal@hotmail.com, imammedo@redhat.com, lcapitulino@redhat.com


--Fig2xvG2VGoz8o/s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 25, 2018 at 04:54:15PM +0530, Pankaj Gupta wrote:
> +static void virtio_pmem_flush(VirtIODevice *vdev, VirtQueue *vq)
> +{
> +    VirtQueueElement *elem;
> +    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
> +    HostMemoryBackend *backend = MEMORY_BACKEND(pmem->memdev);
> +    int fd = memory_region_get_fd(&backend->mr);
> +
> +    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
> +    if (!elem) {
> +        return;
> +    }
> +    /* flush raw backing image */
> +    fsync(fd);

fsync(2) is a blocking syscall.  This can hang QEMU for an unbounded
amount of time.

Please do the fsync from a thread pool.  See block/file-posix.c's
aio_worker() for an example.

> +static void virtio_pmem_get_config(VirtIODevice *vdev, uint8_t *config)
> +{
> +    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
> +    struct virtio_pmem_config *pmemcfg = (struct virtio_pmem_config *) config;
> +
> +    pmemcfg->start = pmem->start;
> +    pmemcfg->size  = pmem->size;

Endianness.  Please use virtio_st*_p() instead.

> +#define VIRTIO_PMEM_PLUG 0

What is this?

--Fig2xvG2VGoz8o/s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJa4dL2AAoJEJykq7OBq3PIp2cH/04ij3qJX2uJVEfJckUXj9lJ
fjMJsmgdYmJatxT52TPw12puheCukYnuCbsWspRls4Q2Lr0sKRZ1vQ9nObO8yTUT
jtsRUwuiezUPUwih88GHt0Rud52SZtq9fCtkYf3mupjxn22n9x2xeFVMqgKvKZoJ
QdfS/K5FrrD+wBAptUjTMWt7Kf0mTANUDUUfHj5zgQwT6nwHbFyImF3etC4I98Yf
MSjPFw3V5mF4TYV5ZoPHXQmE6tjVj2G17SJiKfa5x53RNUMDTYD4DJaLQnCeRLLa
7ka5Z4SDUlBvZkLDEAx5VQ7rWHPjCpoddcqqXAhiDGDBb6zZAKtY7i/WUV9kxaE=
=NyIA
-----END PGP SIGNATURE-----

--Fig2xvG2VGoz8o/s--
