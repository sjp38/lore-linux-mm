Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27E1F6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 18:52:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b15so3519713qkg.23
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:52:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b29si3492548qtk.59.2017.10.12.15.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 15:52:54 -0700 (PDT)
Date: Thu, 12 Oct 2017 18:52:45 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1111804283.19946669.1507848765955.JavaMail.zimbra@redhat.com>
In-Reply-To: <1507847249.21121.207.camel@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com> <CAPcyv4i7k6aYK_y4zZtL6p8sW-E_Ft58d2HuxO=dYciqQxaoLg@mail.gmail.com> <1567317495.19940236.1507843517318.JavaMail.zimbra@redhat.com> <CAPcyv4gkri7t+3Unf0sc9AHMnz-v9G_qV_bJppLjUUNAn7drrQ@mail.gmail.com> <1363955128.19944709.1507846719987.JavaMail.zimbra@redhat.com> <1507847249.21121.207.camel@redhat.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Ross Zwisler <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>


> > > wrote:
> > > >=20
> > > > > > =C2=A0 This patch adds virtio-pmem driver for KVM guest.
> > > > > > =C2=A0 Guest reads the persistent memory range information
> > > > > > =C2=A0 over virtio bus from Qemu and reserves the range
> > > > > > =C2=A0 as persistent memory. Guest also allocates a block
> > > > > > =C2=A0 device corresponding to the pmem range which later
> > > > > > =C2=A0 can be accessed with DAX compatible file systems.
> > > > > > =C2=A0 Idea is to use the virtio channel between guest and
> > > > > > =C2=A0 host to perform the block device flush for guest pmem
> > > > > > =C2=A0 DAX device.
> > > > > >=20
> > > > > > =C2=A0 There is work to do including DAX file system support
> > > > > > =C2=A0 and other advanced features.
> > > > > >=20
> > > > > > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > > > > > ---
> > > > > > =C2=A0drivers/virtio/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A010 ++
> > > > > > =C2=A0drivers/virtio/Makefile=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A01 +
> > > > > > =C2=A0drivers/virtio/virtio_pmem.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0| 322
> > > > > > =C2=A0+++++++++++++++++++++++++++++++++++++++
> > > > > > =C2=A0include/uapi/linux/virtio_pmem.h |=C2=A0=C2=A055 +++++++
> > > > > > =C2=A04 files changed, 388 insertions(+)
> > > > > > =C2=A0create mode 100644 drivers/virtio/virtio_pmem.c
> > > > > > =C2=A0create mode 100644 include/uapi/linux/virtio_pmem.h
> > > > > >=20
> > > > > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > > > > index cff773f15b7e..0192c4bda54b 100644
> > > > > > --- a/drivers/virtio/Kconfig
> > > > > > +++ b/drivers/virtio/Kconfig
> > > > > > @@ -38,6 +38,16 @@ config VIRTIO_PCI_LEGACY
> > > > > >=20
> > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0If =
unsure, say Y.
> > > > > >=20
> > > > > > +config VIRTIO_PMEM
> > > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tristate "Virtio pme=
m driver"
> > > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0depends on VIRTIO
> > > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0---help---
> > > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0This driver ad=
ds persistent memory range within a
> > > > > > KVM guest.
>=20
> With "Virtio Block Backed Pmem" we could name the config
> option VIRTIO_BLOCK_PMEM
>=20
> The documentation text could make it clear to people that the
> image shows up as a disk image on the host, but as a pmem
> memory range in the guest.
>=20
> > > > > I think we need to call this something other than persistent
> > > > > memory to
> > > > > make it clear that this not memory where the persistence can be
> > > > > managed from userspace. The persistence point always requires
> > > > >=20
> > > So currently /proc/iomem in a guest with a pmem device attached to
> > > a
> > > namespace looks like this:
> > >=20
> > > =C2=A0=C2=A0=C2=A0=C2=A0c00000000-13bfffffff : Persistent Memory
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c00000000-13bfffffff : name=
space2.0
> > >=20
> > > Can we call it "Virtio Shared Memory" to make it clear it is a
> > > different beast than typical "Persistent Memory"?=C2=A0=C2=A0You can =
likely
> >=20
> > I think somewhere we need persistent keyword 'Virtio Persistent
> > Memory' or
> > so.
>=20
> Still hoping for better ideas than "Virtio Block Backed Pmem" :)
>=20

Dan,

I have a query regarding below patch [*]. My assumption is its halted
because of memory hotplug restructuring work? Anything I am missing=20
here?

[*] https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg02978.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
