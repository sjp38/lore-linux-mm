Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D8ED16B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 04:07:12 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ts10so27122045obc.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 01:07:12 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0082.outbound.protection.outlook.com. [157.55.234.82])
        by mx.google.com with ESMTPS id u5si14814431obd.73.2016.02.21.01.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 21 Feb 2016 01:07:11 -0800 (PST)
Subject: Re: [RFC 0/7] Peer-direct memory
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com>
 <20160212201328.GA14122@infradead.org>
 <20160212203649.GA10540@obsidianresearch.com>
 <56C09C7E.4060808@dev.mellanox.co.il>
 <36F6EBABA23FEF4391AF72944D228901EB70C102@BBYEXM01.pmc-sierra.internal>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <56C97E13.9090101@mellanox.com>
Date: Sun, 21 Feb 2016 11:06:27 +0200
MIME-Version: 1.0
In-Reply-To: <36F6EBABA23FEF4391AF72944D228901EB70C102@BBYEXM01.pmc-sierra.internal>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <Stephen.Bates@pmcs.com>, Sagi Grimberg <sagig@dev.mellanox.co.il>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@infradead.org>, "'Logan Gunthorpe' (logang@deltatee.com)" <logang@deltatee.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Leon Romanovsky <leonro@mellanox.com>, "sagig@mellanox.com" <sagig@mellanox.com>

On 18/02/2016 16:44, Stephen Bates wrote:
> Sagi
> 
>> CC'ing sbates who played with this stuff at some point...
> 
> Thanks for inviting me to this party Sagi ;-). Here are some comments and responses based on our experiences. Apologies in advance for the list format:
> 
> 1. As it stands in 4.5-rc4 devm_memremap_pages will not work with iomem. Myself and  (mostly) Logan (cc'ed here) developed the ability to do that in an out of tree patch for memremap.c. We also developed a simple example driver for a PCIe device that exposes DRAM on the card via a BAR. We used this code to provide some feedback to Dan (e.g.  [1]-[3]). At this time we are preparing an RFC to extend devm_memremap_pages for IO memory and we hope to have that ready soon but there is no guarantee our approach is acceptable to the community. My hope is that it will be a good starting point for moving forward...
I'd be happy to see your RFC when you are ready. I see in the thread 
of [3] that you are using write-combining. Do you think your patchset 
will also be suitable for uncachable memory?

> 2. The two good things about Peer-Direct are that is works and it is here today. That said, I do think an approach based on ZONE_DEVICE is more general and a preferred way to allow IO devices to communicate with each other. The question is can we find such an approach that is acceptable to the community? As noted in point 1 I hope the coming RFC will initiate a discussion. I have also requested attendance at LSF/MM to discuss this topic (among others). 
> 
> 3. As of now the section alignment requirement is somewhat relaxed. I quote from [4]. 
> 
> "I could loosen the restriction a bit to allow one unaligned mapping
> per section.  However, if another mapping request came along that
> tried to map a free part of the section it would fail because the code
> depends on a  "1 dev_pagemap per section" relationship.  Seems an ok
> compromise to me..."
> 
> This is implemented in 4.5-rc4 (see memremap.c line 315).

I don't think that's enough for our purposes. We have devices with 
rather small BARs (32MB) and multiple PFs that all need to expose their 
BAR to peer to peer access. One can expect these PFs will be assigned 
adjacent addresses and they will break the "one dev_pagemap per 
section" rule.

> 4. The out of tree patch we did allows one to register the device memory as IO memory. However, we were only concerned with DRAM exposed on the BAR and so were not affected by the "i/o side effects" issues. Someone would need to think about how this applies to IOMEM that does have side-effects when accessed.
With this RFC, we map parts of the HCA BAR that were mmapped to a process 
(both uncacheable and write-combining) and map them to a peer device 
(another HCA). As long as the kernel doesn't do anything else with 
these pages, and leaves them to be controlled by the user-space 
application and/or the peer device, I don't see a problem with mapping
IO memory with side effects. However, I'm not an expert here, and I'd
be happy to hear what others think about this.

> 5. I concur with Sagi's comment below that one approach we can use to inform 3rd party device drives about vanishing memory regions is via mmu_notifiers. However this needs to be fleshed out and tied into the relevant driver(s).
> 
> 6. In full disclosure, my main interest in this ties in to NVM Express devices which can act as DMA masters and expose regions of IOMEM at the same time (via CMBs). I want to be able to tie these devices together with other IO devices (like RDMA NICs, FPGA and GPGPU based offload engines, other NVMe devices and storage adaptors) in a peer-2-peer fashion and may not always have a RDMA device in the mix...
I understand.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
