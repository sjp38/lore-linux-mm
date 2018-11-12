Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1B246B02B6
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 12:06:12 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n68so24800725qkn.8
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:06:12 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id z1si2256873qtc.127.2018.11.12.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 09:06:11 -0800 (PST)
Subject: Re: [PATCH v4 2/9] dmapool: remove checks for dev == NULL
References: <df529b6e-6744-b1af-01ce-a1b691fbcf0d@cybernetics.com>
 <5a32095b-4626-9967-784b-9becac303994@huawei.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <0c364366-fe92-0ff8-4fdf-a2c597ed0fa8@cybernetics.com>
Date: Mon, 12 Nov 2018 12:06:08 -0500
MIME-Version: 1.0
In-Reply-To: <5a32095b-4626-9967-784b-9becac303994@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Garry <john.garry@huawei.com>, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On 11/12/18 11:32 AM, John Garry wrote:
> On 12/11/2018 15:42, Tony Battersby wrote:
>> dmapool originally tried to support pools without a device because
>> dma_alloc_coherent() supports allocations without a device.  But nobody
>> ended up using dma pools without a device, so the current checks in
>> dmapool.c for pool->dev == NULL are both insufficient and causing bloat.
>> Remove them.
>>
> As an aside, is it right that dma_pool_create() does not actually reject 
> dev==NULL and would crash from a NULL-pointer dereference?
>
> Thanks,
> John
>
When passed a NULL dev, dma_pool_create() will already crash with a
NULL-pointer dereference before this patch series, because it checks for
dev == NULL in some places but not others.A  Specifically, it will crash
in one of these two places in dma_pool_create():

	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
-or-
	if (list_empty(&dev->dma_pools))

So removing the checks for dev == NULL will not make previously-working
code to start crashing suddenly.A  And since passing dev == NULL would be
an API misuse error and not a runtime error, I would rather not add a
new check to reject it.

Tony
