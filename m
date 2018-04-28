Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1C26B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 06:48:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s84-v6so2578703oig.17
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 03:48:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x142-v6si1119387oia.376.2018.04.28.03.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Apr 2018 03:48:43 -0700 (PDT)
Date: Sat, 28 Apr 2018 06:48:41 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1266554822.23475618.1524912521209.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180427133146.GB11150@stefanha-x1.localdomain>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-2-pagupta@redhat.com> <20180426131236.GA30991@stefanha-x1.localdomain> <197910974.22984070.1524757499459.JavaMail.zimbra@redhat.com> <20180427133146.GB11150@stefanha-x1.localdomain>
Subject: Re: [Qemu-devel] [RFC v2 1/2] virtio: add pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: jack@suse.cz, kvm@vger.kernel.org, david@redhat.com, linux-nvdimm@ml01.01.org, ross zwisler <ross.zwisler@intel.com>, qemu-devel@nongnu.org, lcapitulino@redhat.com, linux-mm@kvack.org, niteshnarayanlal@hotmail.com, mst@redhat.com, hch@infradead.org, Stefan Hajnoczi <stefanha@gmail.com>, marcel@redhat.com, nilal@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, riel@surriel.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, kwolf@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, linux-kernel@vger.kernel.org, imammedo@redhat.com


> > > > +        int err;
> > > > +
> > > > +        sg_init_one(&sg, buf, sizeof(buf));
> > > > +
> > > > +        err = virtqueue_add_outbuf(vpmem->req_vq, &sg, 1, buf, GFP_KERNEL);
> > > > +
> > > > +        if (err) {
> > > > +                dev_err(&vdev->dev, "failed to send command to virtio pmem
> > > > device\n");
> > > > +                return;
> > > > +        }
> > > > +
> > > > +        virtqueue_kick(vpmem->req_vq);
> > > 
> > > Is any locking necessary?  Two CPUs must not invoke virtio_pmem_flush()
> > > at the same time.  Not sure if anything guarantees this, maybe you're
> > > relying on libnvdimm but I haven't checked.
> > 
> > I thought about it to some extent, and wanted to go ahead with simple
> > version first:
> > 
> > - I think file 'inode -> locking' sill is there for request on single file.
> > - For multiple files, our aim is to just flush the backend block image.
> > - Even there is collision for virt queue read/write entry it should just
> > trigger a Qemu fsync.
> >   We just want most recent flush to assure guest writes are synced
> >   properly.
> > 
> > Important point here: We are doing entire block fsync for guest virtual
> > disk.
> 
> I don't understand your answer.  Is locking necessary or not?

It will be required with other changes.

> 
> From the virtqueue_add_outbuf() documentation:
> 
>  * Caller must ensure we don't call this with other virtqueue operations
>  * at the same time (except where noted).

Yes, I also saw it. But thought if can avoid it with current functionality. :)


Thanks,
Pankaj
