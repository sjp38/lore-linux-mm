Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 398816B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:25:09 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w11so99116306oia.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:25:09 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0050.outbound.protection.outlook.com. [104.47.2.50])
        by mx.google.com with ESMTPS id u14si797463oia.213.2016.10.26.01.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 01:25:08 -0700 (PDT)
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <a5418089-2615-8c04-aca8-50ceb43978f1@mellanox.com>
Date: Wed, 26 Oct 2016 11:24:51 +0300
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Stephen Bates <sbates@raithlin.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew
 Wilcox <willy@linux.intel.com>, jgunthorpe@obsidianresearch.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On 10/19/2016 6:51 AM, Dan Williams wrote:
> On Tue, Oct 18, 2016 at 2:42 PM, Stephen Bates <sbates@raithlin.com> wrote:
>> 1. Address Translation. Suggestions have been made that in certain
>> architectures and topologies the dma_addr_t passed to the DMA master
>> in a peer-2-peer transfer will not correctly route to the IO memory
>> intended. However in our testing to date we have not seen this to be
>> an issue, even in systems with IOMMUs and PCIe switches. It is our
>> understanding that an IOMMU only maps system memory and would not
>> interfere with device memory regions.
I'm not sure that's the case. I think it works because with ZONE_DEVICE,
the iommu driver will simply treat a dma_map_page call as any other PFN,
and create a mapping as it does for any memory page.

>> (It certainly has no opportunity
>> to do so if the transfer gets routed through a switch).
It can still go through the IOMMU if you enable ACS upstream forwarding.

> There may still be platforms where peer-to-peer cycles are routed up
> through the root bridge and then back down to target device, but we
> can address that when / if it happens.
I agree.

> I wonder if we could (ab)use a
> software-defined 'pasid' as the requester id for a peer-to-peer
> mapping that needs address translation.
Why would you need that? Isn't it enough to map the peer-to-peer
addresses correctly in the iommu driver?

Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
