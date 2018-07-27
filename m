Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 323BF6B000A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 18:07:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g7-v6so5088969qtp.19
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:07:04 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id n57-v6si828320qtf.327.2018.07.27.15.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 15:07:03 -0700 (PDT)
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org>
 <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
 <20180727152322.GB13348@bombadil.infradead.org>
 <acdc2e32-466c-61d3-145f-80bfba2c6739@cybernetics.com>
 <88d362b7-1d53-b430-1741-b48cbc0a7887@cybernetics.com>
 <CAHp75VcjMg2RABg4F3u=wpgQvGK8qr-4wxeRNmJtfMAE2VRRAw@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <dd582095-c8f8-3103-ccd8-37bea89e7e1a@cybernetics.com>
Date: Fri, 27 Jul 2018 18:07:00 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75VcjMg2RABg4F3u=wpgQvGK8qr-4wxeRNmJtfMAE2VRRAw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/27/2018 05:35 PM, Andy Shevchenko wrote:
> On Sat, Jul 28, 2018 at 12:27 AM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> On 07/27/2018 03:38 PM, Tony Battersby wrote:
>>> But the bigger problem is that my first patch adds another list_head to
>>> the dma_page for the avail_page_link to make allocations faster.  I
>>> suppose we could make the lists singly-linked instead of doubly-linked
>>> to save space.
>>>
>> I managed to redo my dma_pool_alloc() patch to make avail_page_list
>> singly-linked instead of doubly-linked.
> Are you relying on llist.h implementation?
>
> Btw, did you see quicklist.h?
>
>
I looked over include/linux/*list* to see if there was a suitable
implementation I could use.A  llist.h makes a big deal about having a
lock-less implementation with atomic instructions, which seemed like
overkill.A  I didn't see anything else suitable, so I just went with my
own implementation.A  Singly-linked lists are simple enough.A  And a quick
"grep -i singly include/linux/*" shows precedent in bi_next, fl_next,
fa_next, etc.

Thanks for pointing out quicklist.h.A  At first I thought you were
confused since you were talking about linked list implementations and
quicklist.h sounds like a linked list implementation but isn't.A  But now
I see that it is doing simple memory allocation/free, so that is the
relevance to dmapool.A  Incidentally it looks like it is also using a
singly-linked list to store the list of free pages, but it is much
simpler because it doesn't try to sub-divide the pages into smaller
allocations.
