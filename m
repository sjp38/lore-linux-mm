Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5452D6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 13:30:23 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z136-v6so10554342itc.5
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 10:30:23 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id z196-v6si15515619itc.129.2018.10.11.10.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 10:30:22 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
References: <20181005161642.2462-1-logang@deltatee.com>
 <20181005161642.2462-6-logang@deltatee.com> <20181011133730.GB7276@lst.de>
 <8cea5ffa-5fbf-8ea2-b673-20e2d09a910d@deltatee.com>
Message-ID: <8ebf1a13-ec4e-c546-641c-f8dcb1f6c44d@deltatee.com>
Date: Thu, 11 Oct 2018 11:30:07 -0600
MIME-Version: 1.0
In-Reply-To: <8cea5ffa-5fbf-8ea2-b673-20e2d09a910d@deltatee.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Rob Herring <robh@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, linux-sh@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-kernel@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Zong Li <zong@andestech.com>, linux-mm@kvack.org, Olof Johansson <olof@lixom.net>, linux-riscv@lists.infradead.org, Michael Clark <michaeljclark@mac.com>, linux-arm-kernel@lists.infradead.org



On 2018-10-11 10:24 a.m., Logan Gunthorpe wrote:
> On 2018-10-11 7:37 a.m., Christoph Hellwig wrote:
>>> +/*
>>> + * Log2 of the upper bound of the size of a struct page. Used for sizing
>>> + * the vmemmap region only, does not affect actual memory footprint.
>>> + * We don't use sizeof(struct page) directly since taking its size here
>>> + * requires its definition to be available at this point in the inclusion
>>> + * chain, and it may not be a power of 2 in the first place.
>>> + */
>>> +#define STRUCT_PAGE_MAX_SHIFT	6
>>
>> I know this is copied from arm64, but wouldn't this be a good time
>> to move this next to the struct page defintion?
>>
>> Also this:
>>
>> arch/arm64/mm/init.c:   BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));
>>
>> should move to comment code (or would have to be duplicated for riscv)
> 
> Makes sense. Where is a good place for the BUILD_BUG_ON in common code?

Never mind. Seems like it's pretty trivial to do this:

#define STRUCT_PAGE_MAX_SHIFT \
    ilog2(roundup_pow_of_two(sizeof(struct page)))

So the BUILD_BUG_ON becomes unnecessary.

The comment saying it can't be done is really misleading as it wasn't
actually difficult.

Logan
