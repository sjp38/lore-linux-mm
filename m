Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E252D6B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 10:04:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so5322721qka.6
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 07:04:48 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id f59-v6si4414130qva.48.2018.08.03.07.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 07:04:46 -0700 (PDT)
Subject: Re: [PATCH v2 8/9] dmapool: reduce footprint in struct page
References: <0ccfd31b-0a3f-9ae8-85c8-e176cd5453a9@cybernetics.com>
 <20180802235626.GA5773@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <37abe59f-70cb-d125-b87f-49f63de6ece7@cybernetics.com>
Date: Fri, 3 Aug 2018 10:04:44 -0400
MIME-Version: 1.0
In-Reply-To: <20180802235626.GA5773@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

On 08/02/2018 07:56 PM, Matthew Wilcox wrote:
>
>> One of the nice things about this is that dma_pool_free() can do some
>> additional sanity checks:
>> *) Check that the offset of the passed-in address corresponds to a valid
>> block offset.
> Can't we do that already?  Subtract the base address of the page from
> the passed-in vaddr and check it's a multiple of pool->size?
The gaps caused by 'boundary' make it a lot more complicated than that.A 
See pool_offset_to_blk_idx().A  Your suggestion is the fast-path top part
of pool_offset_to_blk_idx() where dma_pool_create() set
blks_per_boundary to 0 to get a speed boost.A  The ugly slow case to take
the boundary into account is the bottom part of pool_offset_to_blk_idx().
