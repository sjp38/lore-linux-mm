Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8026B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:35:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p10so1310661pfl.22
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:35:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q15si1489285pgc.367.2018.03.20.10.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Mar 2018 10:35:19 -0700 (PDT)
Date: Tue, 20 Mar 2018 10:35:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
Message-ID: <20180320173512.GA19669@bombadil.infradead.org>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Tue, Mar 20, 2018 at 01:25:09PM -0400, Mikulas Patocka wrote:
> The reason why we need this is that we are going to merge code that does 
> block device deduplication (it was developed separatedly and sold as a 
> commercial product), and the code uses block sizes that are not a power of 
> two (block sizes 192K, 448K, 640K, 832K are used in the wild). The slab 
> allocator rounds up the allocation to the nearest power of two, but that 
> wastes a lot of memory. Performance of the solution depends on efficient 
> memory usage, so we should minimize wasted as much as possible.

The SLUB allocator also falls back to using the page (buddy) allocator
for allocations above 8kB, so this patch is going to have no effect on
slub.  You'd be better off using alloc_pages_exact() for this kind of
size, or managing your own pool of pages by using something like five
192k blocks in a 1MB allocation.
