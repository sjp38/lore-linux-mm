Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id E5D9E6B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:25:30 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id wb13so18890226obb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 07:25:30 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0095.outbound.protection.outlook.com. [157.56.112.95])
        by mx.google.com with ESMTPS id z199si2124123oia.86.2016.02.17.07.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 07:25:30 -0800 (PST)
Subject: Re: [RFC 0/7] Peer-direct memory
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com> <56C08EC8.10207@mellanox.com>
 <20160216182212.GA21071@obsidianresearch.com>
 <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
 <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
 <20160217084412.GA13616@infradead.org>
From: Haggai Eran <haggaie@mellanox.com>
Message-ID: <56C490DF.1090100@mellanox.com>
Date: Wed, 17 Feb 2016 17:25:19 +0200
MIME-Version: 1.0
In-Reply-To: <20160217084412.GA13616@infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, davide rossetti <davide.rossetti@gmail.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Leon Romanovsky <leonro@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On 17/02/2016 10:44, Christoph Hellwig wrote:
> That doesn't change how the are managed.  We've always suppored mapping
> BARs to userspace in various drivers, and the only real news with things
> like the pmem driver with DAX or some of the things people want to do
> with the NVMe controller memoery buffer is that there are much bigger
> quantities of it, and:
> 
>  a) people want to be able  have cachable mappings of various kinds
>     instead of the old uncachable default.
What if we do want an uncachable mapping for our device's BAR. Can we still 
expose it under ZONE_DEVICE?

>  b) we want to be able to DMA (including RDMA) to the regions in the
>     BARs.
> 
> a) is something that needs smaller amounts in all kinds of areas to be
> done properly, but in principle GPU drivers have been doing this forever
> using all kinds of hacks.
> 
> b) is the real issue.  The Linux DMA support code doesn't really operate
> on just physical addresses, but on page structures, and we don't
> allocate for BARs.  We investigated two ways to address this:  1) allow
> DMA operations without struct page and 2) create struct page structures
> for BARs that we want to be able to use DMA operations on.  For various
> reasons version 2) was favored and this is how we ended up with
> ZONE_DEVICE.  Read the linux-mm and linux-nvdimm lists for the lenghty
> discussions how we ended up here.

I was wondering what are your thoughts regarding the other questions we raised
about ZONE_DEVICE.

How can we overcome the section-alignment requirement in the current code? Our 
HCA's BARs are usually smaller than 128MB.

Sagi also asked how should a peer device who got a ZONE_DEVICE page know it 
should stop using it (the CMB example).

Regards,
Haggai



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
