Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84D9F6B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:21:30 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jb2so21537040wjb.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 08:21:30 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id c135si26519661wmh.118.2016.11.28.08.21.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 08:21:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 0CB0398A72
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:21:27 +0000 (UTC)
Date: Mon, 28 Nov 2016 16:21:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161128162126.ulbqrslpahg4wdk3@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 09:39:19AM -0600, Christoph Lameter wrote:
> On Sun, 27 Nov 2016, Mel Gorman wrote:
> 
> >
> > SLUB has been the default small kernel object allocator for quite some time
> > but it is not universally used due to performance concerns and a reliance
> > on high-order pages. The high-order concerns has two major components --
> > high-order pages are not always available and high-order page allocations
> > potentially contend on the zone->lock. This patch addresses some concerns
> > about the zone lock contention by extending the per-cpu page allocator to
> > cache high-order pages. The patch makes the following modifications
> 
> Note that SLUB will only use high order pages when available and fall back
> to order 0 if memory is fragmented. This means that the effect of this
> patch is going to gradually vanish as memory becomes more and more
> fragmented.
> 

Yes, that's a problem for SLUB with or without this patch. It's always
been the case that SLUB relying on high-order pages for performance is
problematic.

> I think this patch is beneficial but we need to address long term the
> issue of memory fragmentation. That is not only a SLUB issue but an
> overall problem since we keep on having to maintain lists of 4k memory
> blocks in variuos subsystems. And as memory increases these lists are
> becoming larger and larger and more difficult to manage. Code complexity
> increases and fragility too (look at transparent hugepages). Ultimately we
> will need a clean way to manage the allocation and freeing of large
> physically contiguous pages. Reserving memory at booting (CMA, giant
> pages) is some sort of solution but this all devolves into lots of knobs
> that only insiders know how to tune and an overall fragile solution.
> 

While I agree with all of this, it's also a problem independent of this
patch.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
