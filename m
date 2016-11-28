Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5A96B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:39:11 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r94so248459678ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:39:11 -0800 (PST)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id 9si40887485iob.44.2016.11.28.07.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 07:39:10 -0800 (PST)
Date: Mon, 28 Nov 2016 09:39:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
In-Reply-To: <20161127131954.10026-1-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Sun, 27 Nov 2016, Mel Gorman wrote:

>
> SLUB has been the default small kernel object allocator for quite some time
> but it is not universally used due to performance concerns and a reliance
> on high-order pages. The high-order concerns has two major components --
> high-order pages are not always available and high-order page allocations
> potentially contend on the zone->lock. This patch addresses some concerns
> about the zone lock contention by extending the per-cpu page allocator to
> cache high-order pages. The patch makes the following modifications

Note that SLUB will only use high order pages when available and fall back
to order 0 if memory is fragmented. This means that the effect of this
patch is going to gradually vanish as memory becomes more and more
fragmented.

I think this patch is beneficial but we need to address long term the
issue of memory fragmentation. That is not only a SLUB issue but an
overall problem since we keep on having to maintain lists of 4k memory
blocks in variuos subsystems. And as memory increases these lists are
becoming larger and larger and more difficult to manage. Code complexity
increases and fragility too (look at transparent hugepages). Ultimately we
will need a clean way to manage the allocation and freeing of large
physically contiguous pages. Reserving memory at booting (CMA, giant
pages) is some sort of solution but this all devolves into lots of knobs
that only insiders know how to tune and an overall fragile solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
