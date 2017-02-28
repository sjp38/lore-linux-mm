Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5686B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 18:17:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 6so29857552pfd.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:17:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k65si1739824pfj.246.2017.02.28.15.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 15:17:51 -0800 (PST)
Date: Tue, 28 Feb 2017 15:17:33 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
Message-ID: <20170228231733.GI16328@bombadil.infradead.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Tue, Feb 28, 2017 at 03:32:12PM -0600, Christoph Lameter wrote:
> This has come up lots of times. We talked about this at linux.conf.au
> again and agreed to try to make the radix tree movable.

The radix tree is not movable given its current API.  In order to move
a node, we need to be able to lock the tree to prevent simultaneous
modification by another CPU.  But the radix tree API makes callers
responsible for their own locking -- we don't even know if it's locked
by a mutex or a spinlock, much less which lock protects this tree.

This was one of my motivations for the xarray.  The xarray handles its own
locking, so we can always lock out other CPUs from modifying the array.
We still have to take care of RCU walkers, but that's straightforward
to handle.  I have a prototype patch for the radix tree (ignoring the
locking problem), so I can port that over to the xarray and post that
for comment tomorrow.

Also the xarray doesn't use huge numbers of preallocated nodes, so
that'll reduce the pressure on the memory allocator somewhat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
