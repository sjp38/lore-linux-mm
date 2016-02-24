Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E926A6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:45:14 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x65so21537709pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:45:14 -0800 (PST)
Received: from bby1mta03.pmc-sierra.bc.ca (bby1mta03.pmc-sierra.com. [216.241.235.118])
        by mx.google.com with ESMTPS id n21si8026579pfi.104.2016.02.24.15.45.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 15:45:13 -0800 (PST)
From: Stephen Bates <Stephen.Bates@pmcs.com>
Subject: RE: [RFC 0/7] Peer-direct memory
Date: Wed, 24 Feb 2016 23:45:12 +0000
Message-ID: <36F6EBABA23FEF4391AF72944D228901EB712F72@BBYEXM01.pmc-sierra.internal>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <20160212201328.GA14122@infradead.org>
 <20160212203649.GA10540@obsidianresearch.com>
 <56C09C7E.4060808@dev.mellanox.co.il>
 <36F6EBABA23FEF4391AF72944D228901EB70C102@BBYEXM01.pmc-sierra.internal>
 <56C97E13.9090101@mellanox.com>
In-Reply-To: <56C97E13.9090101@mellanox.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>, Sagi Grimberg <sagig@dev.mellanox.co.il>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@infradead.org>, "'Logan Gunthorpe' (logang@deltatee.com)" <logang@deltatee.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Leon Romanovsky <leonro@mellanox.com>, "sagig@mellanox.com" <sagig@mellanox.com>

Haggi

> I'd be happy to see your RFC when you are ready. I see in the thread of [=
3]
> that you are using write-combining. Do you think your patchset will also =
be
> suitable for uncachable memory?

Great, we hope to have the RFC soon. It will be able to accept different fl=
ags for devm_memremap() call with regards to caching. Though one question I=
 have is when does the caching flag affect Peer-2-Peer memory accesses? I c=
an see caching causing issues when performing accesses from the CPU but P2P=
 accesses should bypass any caches in the system?

> I don't think that's enough for our purposes. We have devices with rather
> small BARs (32MB) and multiple PFs that all need to expose their BAR to p=
eer
> to peer access. One can expect these PFs will be assigned adjacent addres=
ses
> and they will break the "one dev_pagemap per section" rule.

On the cards and systems I have checked even small BARs tend to be separate=
d by more than one section's worth of memory.  As I understand it the alloc=
ation of BAR addresses is very ARCH and BIOS specific. Let's discuss this o=
nce the RFC comes out and see what options exist to address your concerns.=
=20

>=20
> > 4. The out of tree patch we did allows one to register the device memor=
y as
> IO memory. However, we were only concerned with DRAM exposed on the
> BAR and so were not affected by the "i/o side effects" issues. Someone
> would need to think about how this applies to IOMEM that does have side-
> effects when accessed.
> With this RFC, we map parts of the HCA BAR that were mmapped to a
> process (both uncacheable and write-combining) and map them to a peer
> device (another HCA). As long as the kernel doesn't do anything else with
> these pages, and leaves them to be controlled by the user-space applicati=
on
> and/or the peer device, I don't see a problem with mapping IO memory with
> side effects. However, I'm not an expert here, and I'd be happy to hear w=
hat
> others think about this.

See above. I think the upcoming RFC should provide support for both caching=
 and uncashed mappings. I concur that even if the mappings are flagged as c=
achable there should be no issues as long as all accesses are from the peer=
-direct device.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
