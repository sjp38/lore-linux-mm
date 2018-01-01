Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B605F6B0289
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 16:20:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p89so21369007pfk.5
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 13:20:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f89si32914580plb.110.2018.01.01.13.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Jan 2018 13:20:45 -0800 (PST)
Date: Mon, 1 Jan 2018 13:20:39 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 3/8] slub: Add isolate() and migrate() methods
Message-ID: <20180101212039.GA13116@bombadil.infradead.org>
References: <20171227220636.361857279@linux.com>
 <20171227220652.402842142@linux.com>
 <20171230064246.GC27959@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171230064246.GC27959@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Fri, Dec 29, 2017 at 10:42:46PM -0800, Matthew Wilcox wrote:
> Is this the right approach?  I could imagine there being more ops in
> the future.  I suspect we should bite the bullet now and do:

I thought of a cute additional slab operation we could define, print().
We could do something like this ...

        struct page *page = virt_to_head_page(ptr);
        if (!PageSlab(page))
                return false;
        slab = page->slab_cache;
        if (!(slab->flags & SLAB_FLAGS_OPS) || !slab->ops->print)
                return false;
        slab->ops->print(ptr);
        return true;

and get nice debugging output like we have for VM_BUG_ON_PAGE, only
for any type that's implemented a slab operations vec.  Of course, this
won't replace VM_BUG_ON_PAGE because struct pages aren't slab-allocated
(but could we pretend they are?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
