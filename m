Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id ED03C6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 13:54:59 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id y9so69564863qgd.3
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:54:59 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id s51si4606504qge.104.2016.02.19.10.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 10:54:59 -0800 (PST)
Received: by mail-qg0-x233.google.com with SMTP id b35so68516645qge.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:54:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C490DF.1090100@mellanox.com>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
	<20160211191838.GA23675@obsidianresearch.com>
	<56C08EC8.10207@mellanox.com>
	<20160216182212.GA21071@obsidianresearch.com>
	<CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
	<CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
	<20160217084412.GA13616@infradead.org>
	<56C490DF.1090100@mellanox.com>
Date: Fri, 19 Feb 2016 10:54:58 -0800
Message-ID: <CAA9_cmfSixFu6roxjQ7z6N7tgDKgK2oEYrwb=7=MmjgnxOhEkA@mail.gmail.com>
Subject: Re: [RFC 0/7] Peer-direct memory
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>, davide rossetti <davide.rossetti@gmail.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Leon Romanovsky <leonro@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Wed, Feb 17, 2016 at 7:25 AM, Haggai Eran <haggaie@mellanox.com> wrote:
> On 17/02/2016 10:44, Christoph Hellwig wrote:
>> That doesn't change how the are managed.  We've always suppored mapping
>> BARs to userspace in various drivers, and the only real news with things
>> like the pmem driver with DAX or some of the things people want to do
>> with the NVMe controller memoery buffer is that there are much bigger
>> quantities of it, and:
>>
>>  a) people want to be able  have cachable mappings of various kinds
>>     instead of the old uncachable default.
> What if we do want an uncachable mapping for our device's BAR. Can we still
> expose it under ZONE_DEVICE?
>
>>  b) we want to be able to DMA (including RDMA) to the regions in the
>>     BARs.
>>
>> a) is something that needs smaller amounts in all kinds of areas to be
>> done properly, but in principle GPU drivers have been doing this forever
>> using all kinds of hacks.
>>
>> b) is the real issue.  The Linux DMA support code doesn't really operate
>> on just physical addresses, but on page structures, and we don't
>> allocate for BARs.  We investigated two ways to address this:  1) allow
>> DMA operations without struct page and 2) create struct page structures
>> for BARs that we want to be able to use DMA operations on.  For various
>> reasons version 2) was favored and this is how we ended up with
>> ZONE_DEVICE.  Read the linux-mm and linux-nvdimm lists for the lenghty
>> discussions how we ended up here.
>
> I was wondering what are your thoughts regarding the other questions we raised
> about ZONE_DEVICE.
>
> How can we overcome the section-alignment requirement in the current code? Our
> HCA's BARs are usually smaller than 128MB.

This may not help, but note that the section-alignment only bites when
trying to have 2 mappings with different lifetimes in a single
section.  It's otherwise fine to map a full section for a smaller
single range, you'll just end up with pages that won't be used.
However, this assumes that you are fine with everything in that
section being mapped cacheable, you couldn't mix uncacheable mappings
in that same range.

> Sagi also asked how should a peer device who got a ZONE_DEVICE page know it
> should stop using it (the CMB example).

ZONE_DEVICE pages come with a per-cpu reference counter via
page->pgmap.  See get_dev_pagemap(), get_zone_device_page(), and
put_zone_device_page().

However this gets confusing quickly when a 'pfn' and a 'page' start
referencing mmio space instead of host memory.  It seems like we need
new data types because a dma_addr_t does not necessarily reflect the
peer-to-peer address as seen by the device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
