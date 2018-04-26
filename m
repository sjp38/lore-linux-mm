Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565A86B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 12:43:26 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id g67-v6so11083281otb.10
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:43:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34-v6si1776285otd.431.2018.04.26.09.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 09:43:25 -0700 (PDT)
Date: Thu, 26 Apr 2018 12:43:24 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <358601698.23011599.1524761004239.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180426132406.GC30991@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-4-pagupta@redhat.com> <20180426132406.GC30991@stefanha-x1.localdomain>
Subject: Re: [Qemu-devel] [RFC v2] qemu: Add virtio pmem device
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: jack@suse.cz, kvm@vger.kernel.org, david@redhat.com, linux-nvdimm@ml01.01.org, ross zwisler <ross.zwisler@intel.com>, qemu-devel@nongnu.org, lcapitulino@redhat.com, linux-mm@kvack.org, niteshnarayanlal@hotmail.com, mst@redhat.com, hch@infradead.org, marcel@redhat.com, nilal@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, riel@surriel.com, stefanha@redhat.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, kwolf@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, linux-kernel@vger.kernel.org, imammedo@redhat.com



> > +static void virtio_pmem_flush(VirtIODevice *vdev, VirtQueue *vq)
> > +{
> > +    VirtQueueElement *elem;
> > +    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
> > +    HostMemoryBackend *backend = MEMORY_BACKEND(pmem->memdev);
> > +    int fd = memory_region_get_fd(&backend->mr);
> > +
> > +    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
> > +    if (!elem) {
> > +        return;
> > +    }
> > +    /* flush raw backing image */
> > +    fsync(fd);
> 
> fsync(2) is a blocking syscall.  This can hang QEMU for an unbounded
> amount of time.

o.k. Main thread will block, agree.

> 
> Please do the fsync from a thread pool.  See block/file-posix.c's
> aio_worker() for an example.

Sure!

> 
> > +static void virtio_pmem_get_config(VirtIODevice *vdev, uint8_t *config)
> > +{
> > +    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
> > +    struct virtio_pmem_config *pmemcfg = (struct virtio_pmem_config *)
> > config;
> > +
> > +    pmemcfg->start = pmem->start;
> > +    pmemcfg->size  = pmem->size;
> 
> Endianness.  Please use virtio_st*_p() instead.

sure.

> 
> > +#define VIRTIO_PMEM_PLUG 0
> 
> What is this?

will remove

Thanks,
Pankaj 
