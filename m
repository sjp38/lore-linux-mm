Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 094946B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 13:00:38 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id u190so36168553pfb.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 10:00:38 -0700 (PDT)
Received: from bby1mta03.pmc-sierra.bc.ca (bby1mta03.pmc-sierra.com. [216.241.235.118])
        by mx.google.com with ESMTPS id f3si1442859pas.21.2016.03.15.10.00.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Mar 2016 10:00:35 -0700 (PDT)
From: Stephen Bates <Stephen.Bates@pmcs.com>
Subject: RE: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with
 struct pages.
Date: Tue, 15 Mar 2016 17:00:34 +0000
Message-ID: <36F6EBABA23FEF4391AF72944D228901EB7280F2@BBYEXM01.pmc-sierra.internal>
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
 <20160314215708.GA7282@obsidianresearch.com> <56E78B08.8050205@deltatee.com>
In-Reply-To: <56E78B08.8050205@deltatee.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: "haggaie@mellanox.com" <haggaie@mellanox.com>, "javier@cnexlabs.com" <javier@cnexlabs.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "sagig@mellanox.com" <sagig@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "artemyko@mellanox.com" <artemyko@mellanox.com>, "hch@infradead.org" <hch@infradead.org>, "leonro@mellanox.com" <leonro@mellanox.com>

>=20
> On 14/03/16 03:57 PM, Jason Gunthorpe wrote:
> > Someone should probably explain in more detail what this is even good
> > for, DAX on PCI-E bar memory seems goofy in the general case. I was
> > under the impression the main use case involved the CPU never touching
> > these memories and just using them to route-through to another IO
> > device (eg network). So all these discussions about CPU coherency seem
> > a bit strange.
>=20
>=20
> Yes, the primary purpose is to enable P2P transactions that don't involve=
 the
> CPU at all. To enable this, we do mmap the BAR region into user space whi=
ch
> is then technically able to read/write to it using the CPU. However, you'=
re
> right, it is silly to write to the mmap'd PCI BAR for anything but debug/=
testing
> purposes -- this type of access also has horrible performance. Really, th=
e
> mmaping is just a convenient way to pass around the addresses with existi=
ng
> interfaces that expect system RAM (RDMA, O_DIRECT).
>=20
> Putting DAX on the PCI-E bar is a actually more of a curiosity at the mom=
ent
> than anything. The current plan for NVMe with CMB would not involve DAX.
> CMB buffers would be allocated perhaps by mapping the nvmeX char device
> which could then be used with O_DIRECT access on a file on the NVME
> device and also be passed to RDMA devices. In this way data could flow fr=
om
> the NVMe device to an RDMA network without using system memory to
> buffer it.
>=20
> Logan

The transfer of data between PCIe devices is the main use-case for this pro=
posed patch.

Some other applications for this include direct transfer of data between PC=
Ie SSDs (for background data movement and replication) and the movement of =
data between PCIe SSDs and GPGPU/FPGAs for accelerating applications that u=
se those types of offload engines. In some of our performance tests we have=
 seen significant reduction in residual DRAM bandwidth when all the data in=
volved in these transfers has to pass through system memory buffers. This p=
roposed patch avoids that problem.

Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
