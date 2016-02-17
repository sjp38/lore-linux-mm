Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA37D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 03:44:38 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fl4so7764842pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 00:44:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tw5si486356pac.131.2016.02.17.00.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 00:44:38 -0800 (PST)
Date: Wed, 17 Feb 2016 00:44:12 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/7] Peer-direct memory
Message-ID: <20160217084412.GA13616@infradead.org>
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
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

[disclaimer: I've been involved with ZONE_DEVICE support and the pmem
 driver and wrote parts of the code and discussed a lot of the tradeoffs
 on how we handle I/O to memory in BARs]

On Tue, Feb 16, 2016 at 08:13:58PM -0800, davide rossetti wrote:
> 1) I see mm as appropriate for real memory, i.e. something that
> user-space apps can pass around.

mm is memory management, and this clearly falls under the umbrella,
so it absolutely needs to be under mm/ and reviewed by the linux-mm
crowd.

> This is not totally true for BAR
> memory, for instance:
>  a) as long as CPU initiated atomic ops are not supported on BAR space
> of PCIe devices.
>  b) OTOT, CPU reading from BAR is awful (BW being abysmal,~10MB/s),
> while high BW writing requires use of vector instructions (at least on
> x86_64).
> Bottom line is, BAR mappings are not like plain memory.

That doesn't change how the are managed.  We've always suppored mapping
BARs to userspace in various drivers, and the only real news with things
like the pmem driver with DAX or some of the things people want to do
with the NVMe controller memoery buffer is that there are much bigger
quantities of it, and:

 a) people want to be able  have cachable mappings of various kinds
    instead of the old uncachable default.
 b) we want to be able to DMA (including RDMA) to the regions in the
    BARs.

a) is something that needs smaller amounts in all kinds of areas to be
done properly, but in principle GPU drivers have been doing this forever
using all kinds of hacks.

b) is the real issue.  The Linux DMA support code doesn't really operate
on just physical addresses, but on page structures, and we don't
allocate for BARs.  We investigated two ways to address this:  1) allow
DMA operations without struct page and 2) create struct page structures
for BARs that we want to be able to use DMA operations on.  For various
reasons version 2) was favored and this is how we ended up with
ZONE_DEVICE.  Read the linux-mm and linux-nvdimm lists for the lenghty
discussions how we ended up here.

Additional issues like which instructions to use for access build on top
of these basic building blocks.

> 2) Instead, I see appropriate that two sophisticated devices, like an
> IB NIC and a storage/accelerator device, can freely target each other
> for I/O, i.e. exchanging peer-to-peer PCIe transactions. And as long
> as the existing sophisticated initiators are confined to the RDMA
> subsystem, that is where this support belongs to.

It doesn't.  There is absolutely nothing RDMA specific here - please
work with the overall community to do the right thing here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
