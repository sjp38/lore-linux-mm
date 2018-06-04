Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0436B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 01:57:02 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id p12-v6so5597370oti.6
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 22:57:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x22-v6si9509034oti.95.2018.06.03.22.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jun 2018 22:57:01 -0700 (PDT)
Date: Mon, 4 Jun 2018 01:56:55 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1227242806.39629768.1528091815515.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180601142410.5c986f13@redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180601142410.5c986f13@redhat.com>
Subject: Re: [Qemu-devel] [RFC v2 0/2] kvm "fake DAX" device flushing
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: kwolf@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, nilal@redhat.com, jack@suse.cz, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, kvm@vger.kernel.org, riel@surriel.com, linux-nvdimm@ml01.01.org, david@redhat.com, ross zwisler <ross.zwisler@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, hch@infradead.org, linux-mm@kvack.org, mst@redhat.com, stefanha@redhat.com, niteshnarayanlal@hotmail.com, marcel@redhat.com, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, lcapitulino@redhat.com


Hi Igor,

> 
> [...]
> > - Qemu virtio-pmem device
> >   It exposes a persistent memory range to KVM guest which
> >   at host side is file backed memory and works as persistent
> >   memory device. In addition to this it provides virtio
> >   device handling of flushing interface. KVM guest performs
> >   Qemu side asynchronous sync using this interface.
> a random high level question,
> Have you considered using a separate (from memory itself)
> virtio device as controller for exposing some memory, async flushing.
> And then just slaving pc-dimm devices to it with notification/ACPI
> code suppressed so that guest won't touch them?

No.

> 
> That way it might be more scale-able, you consume only 1 PCI slot
> for controller vs multiple for virtio-pmem devices.

That sounds like a good suggestion. I will note it as an
enhancement once we have other concerns related to basic working 
of 'flush' interface addressed. Then probably we can work on
things 'need to optimize' with robust core flush functionality. 

BTW any sample code doing this right now in Qemu? 

> 
> 
> > Changes from previous RFC[1]:
> > 
> > - Reuse existing 'pmem' code for registering persistent
> >   memory and other operations instead of creating an entirely
> >   new block driver.
> > - Use VIRTIO driver to register memory information with
> >   nvdimm_bus and create region_type accordingly.
> > - Call VIRTIO flush from existing pmem driver.
> > 
> > Details of project idea for 'fake DAX' flushing interface is
> > shared [2] & [3].
> > 
> > Pankaj Gupta (2):
> >    Add virtio-pmem guest driver
> >    pmem: device flush over VIRTIO
> > 
> > [1] https://marc.info/?l=linux-mm&m=150782346802290&w=2
> > [2] https://www.spinics.net/lists/kvm/msg149761.html
> > [3] https://www.spinics.net/lists/kvm/msg153095.html
> > 
> >  drivers/nvdimm/region_devs.c     |    7 ++
> >  drivers/virtio/Kconfig           |   12 +++
> >  drivers/virtio/Makefile          |    1
> >  drivers/virtio/virtio_pmem.c     |  118
> >  +++++++++++++++++++++++++++++++++++++++
> >  include/linux/libnvdimm.h        |    4 +
> >  include/uapi/linux/virtio_ids.h  |    1
> >  include/uapi/linux/virtio_pmem.h |   58 +++++++++++++++++++
> >  7 files changed, 201 insertions(+)
> > 
> 
> 
> 
