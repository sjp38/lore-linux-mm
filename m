Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A48D6B000E
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 17:18:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 17-v6so6512042qkz.15
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 14:18:29 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id w2-v6si4605670qkw.399.2018.08.03.14.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 14:18:28 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org>
 <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
 <f0762902-8f28-82eb-b871-337c2da290cf@cybernetics.com>
 <20180803210745.GB9329@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <4ed8f094-ae62-65c1-ec46-0d39b594abba@cybernetics.com>
Date: Fri, 3 Aug 2018 17:18:25 -0400
MIME-Version: 1.0
In-Reply-To: <20180803210745.GB9329@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 05:07 PM, Matthew Wilcox wrote:
> On Fri, Aug 03, 2018 at 02:43:07PM -0400, Tony Battersby wrote:
>> Out of curiosity, I just tried to create a dmapool with a NULL dev and
>> it crashed on this:
>>
>> static inline int dev_to_node(struct device *dev)
>> {
>> 	return dev->numa_node;
>> }
>>
>> struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>> 				 size_t size, size_t align, size_t boundary)
>> {
>> 	...
>> 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
>> 	...
>> }
>>
>> So either it needs more special cases for supporting a NULL dev, or the
>> special cases can be removed since no one does that anyway.
> Actually, it's worse.  dev_to_node() works with a NULL dev ... unless
> CONFIG_NUMA is set.  So we're leaving a timebomb by pretending to
> allow it.  Let's just 'if (!dev) return NULL;' early in create.
>
>
Looking further down it does stuff with dev->dma_pools unconditionally
that doesn't depend on the config.A  So it would blow up on non-NUMA
also.A  So no timebomb, just an immediate kaboom.
