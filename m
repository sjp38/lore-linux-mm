Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C867B6B0008
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:27:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d25-v6so4982628qtp.10
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:27:23 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id k5-v6si337158qkb.28.2018.07.27.14.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:27:23 -0700 (PDT)
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org>
 <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
 <20180727152322.GB13348@bombadil.infradead.org>
 <acdc2e32-466c-61d3-145f-80bfba2c6739@cybernetics.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <88d362b7-1d53-b430-1741-b48cbc0a7887@cybernetics.com>
Date: Fri, 27 Jul 2018 17:27:20 -0400
MIME-Version: 1.0
In-Reply-To: <acdc2e32-466c-61d3-145f-80bfba2c6739@cybernetics.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/27/2018 03:38 PM, Tony Battersby wrote:
> But the bigger problem is that my first patch adds another list_head to
> the dma_page for the avail_page_link to make allocations faster.A  I
> suppose we could make the lists singly-linked instead of doubly-linked
> to save space.
>

I managed to redo my dma_pool_alloc() patch to make avail_page_list
singly-linked instead of doubly-linked.A  But the problem with making
either list singly-linked is that it would no longer be possible to call
pool_free_page() any time other than dma_pool_destroy() without scanning
the lists to remove the page from them, which would make pruning
arbitrary free pages slower (adding back a O(n^2)).A  But the current
code doesn't do that anyway, and in fact it has a comment in
dma_pool_free() to "resist the temptation" to prune free pages.A  And yet
it seems like it might be reasonable for someone to add such code in the
future if there are a whole lot of free pages, so I am hesitant to make
it more difficult.

So my question is: when I post v2 of the patchset, should I send the
doubly-linked version or the singly-linked version, in anticipation that
someone else might want to take it further and move everything into
struct page as you suggest?
