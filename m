Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCC4A6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:54:04 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 90so161968716ios.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:54:04 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 103si8612731ioq.109.2017.03.06.06.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 06:54:03 -0800 (PST)
Date: Mon, 6 Mar 2017 08:53:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
In-Reply-To: <20170303203920.GR16328@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1703060850470.22803@east.gentwo.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org> <20170228231733.GI16328@bombadil.infradead.org> <20170302041238.GM16328@bombadil.infradead.org> <alpine.DEB.2.20.1703021111350.31249@east.gentwo.org> <20170302205540.GQ16328@bombadil.infradead.org>
 <alpine.DEB.2.20.1703030915170.16721@east.gentwo.org> <20170303203920.GR16328@bombadil.infradead.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Fri, 3 Mar 2017, Matthew Wilcox wrote:

> OK.  So how about we have the following functions:
>
> bool can_free(void **objects, unsigned int nr);
> void reclaim(void **objects, unsigned int nr);
>
> The callee can take references or whetever else is useful to mark
> objects as being targetted for reclaim in 'can_free', but may not sleep,
> and should not take a long time to execute (because we're potentially
> delaying somebody in irq context).
>
> In reclaim, anything goes, no locks are held by slab, kmem_cache_alloc
> can be called.  When reclaim() returns, slab will evaluate the state
> of the page and free it back to the page allocator if everything is
> freed.

Ok. That is pretty much how it works (aside from the naming, the
refcounting is just what is commonly done to provide existence
guarantees, you can do something else).

The old patchset is available at https://lwn.net/Articles/371892/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
