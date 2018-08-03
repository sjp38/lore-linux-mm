Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6ECB6B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 14:43:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v65-v6so5985045qka.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 11:43:12 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id o63-v6si5592833qkh.329.2018.08.03.11.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 11:43:11 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org>
 <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <f0762902-8f28-82eb-b871-337c2da290cf@cybernetics.com>
Date: Fri, 3 Aug 2018 14:43:07 -0400
MIME-Version: 1.0
In-Reply-To: <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 01:03 PM, Tony Battersby wrote:
> On 08/03/2018 12:22 PM, Matthew Wilcox wrote:
>> On Fri, Aug 03, 2018 at 06:59:20PM +0300, Andy Shevchenko wrote:
>>>>>> I'm pretty sure this was created in an order to avoid bad looking (and
>>>>>> in some cases frightening) "NULL device *" part.
>>> JFYI: git log --no-merges --grep 'NULL device \*'
>> I think those commits actually argue in favour of Tony's patch to remove
>> the special casing.  Is it really useful to create dma pools with a NULL
>> device?
>>
>>
> dma_alloc_coherent() does appear to support a NULL dev, so it might make
> sense in theory.A  But I can't find any in-tree callers that actually
> pass a NULL dev to dma_pool_create().A  So for one of the dreaded (NULL
> device *) messages to show up, it would take both a new caller that
> passes a NULL dev to dma_pool_create() and a bug to cause the message to
> be printed.A  Is that worth the special casing?
>

Out of curiosity, I just tried to create a dmapool with a NULL dev and
it crashed on this:

static inline int dev_to_node(struct device *dev)
{
	return dev->numa_node;
}

struct dma_pool *dma_pool_create(const char *name, struct device *dev,
				 size_t size, size_t align, size_t boundary)
{
	...
	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
	...
}

So either it needs more special cases for supporting a NULL dev, or the
special cases can be removed since no one does that anyway.
