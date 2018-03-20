Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C5F6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:54:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id y4so2245093iod.5
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:54:50 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id t26si1430026ioa.60.2018.03.20.10.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 10:54:49 -0700 (PDT)
Date: Tue, 20 Mar 2018 12:54:47 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <20180320173512.GA19669@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Tue, 20 Mar 2018, Matthew Wilcox wrote:

> On Tue, Mar 20, 2018 at 01:25:09PM -0400, Mikulas Patocka wrote:
> > The reason why we need this is that we are going to merge code that does
> > block device deduplication (it was developed separatedly and sold as a
> > commercial product), and the code uses block sizes that are not a power of
> > two (block sizes 192K, 448K, 640K, 832K are used in the wild). The slab
> > allocator rounds up the allocation to the nearest power of two, but that
> > wastes a lot of memory. Performance of the solution depends on efficient
> > memory usage, so we should minimize wasted as much as possible.
>
> The SLUB allocator also falls back to using the page (buddy) allocator
> for allocations above 8kB, so this patch is going to have no effect on
> slub.  You'd be better off using alloc_pages_exact() for this kind of
> size, or managing your own pool of pages by using something like five
> 192k blocks in a 1MB allocation.

The fallback is only effective for kmalloc caches. Manually created caches
do not follow this rule.

Note that you can already control the page orders for allocation and
the objects per slab using

	slub_min_order
	slub_max_order
	slub_min_objects

This is documented in linux/Documentation/vm/slub.txt

Maybe do the same thing for SLAB?
