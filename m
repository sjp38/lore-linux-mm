Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C182B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 18:27:38 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z19so12952914qtg.21
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:27:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 62si362595qth.150.2017.10.12.15.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 15:27:38 -0700 (PDT)
Message-ID: <1507847249.21121.207.camel@redhat.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
From: Rik van Riel <riel@redhat.com>
Date: Thu, 12 Oct 2017 18:27:29 -0400
In-Reply-To: <1363955128.19944709.1507846719987.JavaMail.zimbra@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com>
	 <20171012155027.3277-3-pagupta@redhat.com>
	 <CAPcyv4i7k6aYK_y4zZtL6p8sW-E_Ft58d2HuxO=dYciqQxaoLg@mail.gmail.com>
	 <1567317495.19940236.1507843517318.JavaMail.zimbra@redhat.com>
	 <CAPcyv4gkri7t+3Unf0sc9AHMnz-v9G_qV_bJppLjUUNAn7drrQ@mail.gmail.com>
	 <1363955128.19944709.1507846719987.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Ross Zwisler <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>

On Thu, 2017-10-12 at 18:18 -0400, Pankaj Gupta wrote:
> > 
> > On Thu, Oct 12, 2017 at 2:25 PM, Pankaj Gupta <pagupta@redhat.com>
> > wrote:
> > > 
> > > > > A  This patch adds virtio-pmem driver for KVM guest.
> > > > > A  Guest reads the persistent memory range information
> > > > > A  over virtio bus from Qemu and reserves the range
> > > > > A  as persistent memory. Guest also allocates a block
> > > > > A  device corresponding to the pmem range which later
> > > > > A  can be accessed with DAX compatible file systems.
> > > > > A  Idea is to use the virtio channel between guest and
> > > > > A  host to perform the block device flush for guest pmem
> > > > > A  DAX device.
> > > > > 
> > > > > A  There is work to do including DAX file system support
> > > > > A  and other advanced features.
> > > > > 
> > > > > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > > > > ---
> > > > > A drivers/virtio/KconfigA A A A A A A A A A A |A A 10 ++
> > > > > A drivers/virtio/MakefileA A A A A A A A A A |A A A 1 +
> > > > > A drivers/virtio/virtio_pmem.cA A A A A | 322
> > > > > A +++++++++++++++++++++++++++++++++++++++
> > > > > A include/uapi/linux/virtio_pmem.h |A A 55 +++++++
> > > > > A 4 files changed, 388 insertions(+)
> > > > > A create mode 100644 drivers/virtio/virtio_pmem.c
> > > > > A create mode 100644 include/uapi/linux/virtio_pmem.h
> > > > > 
> > > > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > > > index cff773f15b7e..0192c4bda54b 100644
> > > > > --- a/drivers/virtio/Kconfig
> > > > > +++ b/drivers/virtio/Kconfig
> > > > > @@ -38,6 +38,16 @@ config VIRTIO_PCI_LEGACY
> > > > > 
> > > > > A A A A A A A A A A If unsure, say Y.
> > > > > 
> > > > > +config VIRTIO_PMEM
> > > > > +A A A A A A A tristate "Virtio pmem driver"
> > > > > +A A A A A A A depends on VIRTIO
> > > > > +A A A A A A A ---help---
> > > > > +A A A A A A A A This driver adds persistent memory range within a
> > > > > KVM guest.

With "Virtio Block Backed Pmem" we could name the config
option VIRTIO_BLOCK_PMEM

The documentation text could make it clear to people that the
image shows up as a disk image on the host, but as a pmem
memory range in the guest.

> > > > I think we need to call this something other than persistent
> > > > memory to
> > > > make it clear that this not memory where the persistence can be
> > > > managed from userspace. The persistence point always requires
> > > > 
> > So currently /proc/iomem in a guest with a pmem device attached to
> > a
> > namespace looks like this:
> > 
> > A A A A c00000000-13bfffffff : Persistent Memory
> > A A A A A A A c00000000-13bfffffff : namespace2.0
> > 
> > Can we call it "Virtio Shared Memory" to make it clear it is a
> > different beast than typical "Persistent Memory"?A A You can likely
> 
> I think somewhere we need persistent keyword 'Virtio Persistent
> Memory' orA 
> so.

Still hoping for better ideas than "Virtio Block Backed Pmem" :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
