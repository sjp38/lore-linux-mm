Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 22AFB6B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 00:09:57 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id u190so10038684pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 21:09:57 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id ml8si7941851pab.228.2016.03.14.21.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 21:09:55 -0700 (PDT)
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
 <20160314215708.GA7282@obsidianresearch.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <56E78B08.8050205@deltatee.com>
Date: Mon, 14 Mar 2016 22:09:44 -0600
MIME-Version: 1.0
In-Reply-To: <20160314215708.GA7282@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with struct
 pages.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Stephen Bates <stephen.bates@pmcs.com>, haggaie@mellanox.com, javier@cnexlabs.com, linux-rdma@vger.kernel.org, linux-nvdimm@ml01.01.org, sagig@mellanox.com, linux-mm@kvack.org, artemyko@mellanox.com, hch@infradead.org, leonro@mellanox.com



On 14/03/16 03:57 PM, Jason Gunthorpe wrote:
> Someone should probably explain in more detail what this is even good
> for, DAX on PCI-E bar memory seems goofy in the general case. I was
> under the impression the main use case involved the CPU never touching
> these memories and just using them to route-through to another IO
> device (eg network). So all these discussions about CPU coherency seem
> a bit strange.


Yes, the primary purpose is to enable P2P transactions that don't 
involve the CPU at all. To enable this, we do mmap the BAR region into 
user space which is then technically able to read/write to it using the 
CPU. However, you're right, it is silly to write to the mmap'd PCI BAR 
for anything but debug/testing purposes -- this type of access also has 
horrible performance. Really, the mmaping is just a convenient way to 
pass around the addresses with existing interfaces that expect system 
RAM (RDMA, O_DIRECT).

Putting DAX on the PCI-E bar is a actually more of a curiosity at the 
moment than anything. The current plan for NVMe with CMB would not 
involve DAX. CMB buffers would be allocated perhaps by mapping the nvmeX 
char device which could then be used with O_DIRECT access on a file on 
the NVME device and also be passed to RDMA devices. In this way data 
could flow from the NVMe device to an RDMA network without using system 
memory to buffer it.

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
