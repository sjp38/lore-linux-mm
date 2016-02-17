Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE01D6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 23:44:47 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id l127so22241079iof.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:44:47 -0800 (PST)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id j100si2104838ioo.150.2016.02.16.20.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 20:44:47 -0800 (PST)
Date: Tue, 16 Feb 2016 21:44:17 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 0/7] Peer-direct memory
Message-ID: <20160217044417.GA25049@obsidianresearch.com>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <56C08EC8.10207@mellanox.com>
 <20160216182212.GA21071@obsidianresearch.com>
 <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
 <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davide rossetti <davide.rossetti@gmail.com>
Cc: Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

On Tue, Feb 16, 2016 at 08:13:58PM -0800, davide rossetti wrote:

> Bottom line is, BAR mappings are not like plain memory.

As I understand it the actual use of this in fact when user space
manages to map BAR memory into it's address space and attempts to do DMA
from it. So, I'm not sure I agree at all with this assement.

ie I gather with NVMe the desire is this could happen through the
filesystem with the right open/mmap flags.

So, saying this has nothing to do with core kernel code, or with mm,
is a really big leap.

> 2) Instead, I see appropriate that two sophisticated devices, like an
> IB NIC and a storage/accelerator device, can freely target each
> other

There is nothing special about IB, and no 'sophistication' of the
DMA'ing device is required.

All other DMA devices should be able to target BAR memory. eg TCP TSO,
or storage-to-storage copies from BAR to SCSI immediately come to
mind.

> for I/O, i.e. exchanging peer-to-peer PCIe transactions. And as long
> as the existing sophisticated initiators are confined to the RDMA
> subsystem, that is where this support belongs to.

I would not object to this stuff living in the PCI subsystem, but
living in rdma and having this narrrow focus that it should only
work with IB is not good.

> On a different note, this reminds me that the current patch set may be
> missing a way to disable the use of platform PCIe atomics when the
> target is the BAR of a peer device.

There is a general open question with all PCI peer to peer
transactions on how to negotiate all the relevant PCI
parameters. Supported vendor extensions and supported standardized
features seems like just one piece of a larger problem. Again well
outside the scope of IB.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
