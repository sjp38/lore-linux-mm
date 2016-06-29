Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1495828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 16:55:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so127542950pfa.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:55:57 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id o81si220900pfa.34.2016.06.29.13.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 13:55:56 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id t190so21644824pfb.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:55:56 -0700 (PDT)
Date: Wed, 29 Jun 2016 13:55:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't persistently
 expensive
In-Reply-To: <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
Message-ID: <alpine.DEB.2.10.1606291349320.145590@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com> <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Jun 2016, Vlastimil Babka wrote:

> On 06/29/2016 03:39 AM, David Rientjes wrote:
> > It's possible that the freeing scanner can be consistently expensive if
> > memory is well compacted toward the end of the zone with few free pages
> > available in that area.
> > 
> > If all zone memory is synchronously compacted, say with
> > /proc/sys/vm/compact_memory, and thp is faulted, it is possible to
> > iterate a massive amount of memory even with the per-zone cached free
> > position.
> > 
> > For example, after compacting all memory and faulting thp for heap, it
> > was observed that compact_free_scanned increased as much as 892518911 4KB
> > pages while compact_stall only increased by 171.  The freeing scanner
> > iterated ~20GB of memory for each compaction stall.
> > 
> > To address this, if too much memory is spanned on the freeing scanner's
> > freelist when releasing back to the system, return the low pfn rather than
> > the high pfn.  It's declared that the freeing scanner will become too
> > expensive if the high pfn is used, so use the low pfn instead.
> > 
> > The amount of memory declared as too expensive to iterate is subjectively
> > chosen at COMPACT_CLUSTER_MAX << PAGE_SHIFT, which is 512MB with 4KB
> > pages.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Hmm, I don't know. Seems it only works around one corner case of a larger
> issue. The cost for the scanning was already paid, the patch prevents it from
> being paid again, but only until the scanners are reset.
> 

The only point of the per-zone cached pfn positions is to avoid doing the 
same work again unnecessarily.  Having the last 16GB of memory at the end 
of a zone being completely unfree is the same as a single page in the last 
pageblock free.  The number of PageBuddy pages in that amount of memory 
can be irrelevant up to COMPACT_CLUSTER_MAX.  We simply can't afford to 
scan 16GB of memory looking for free pages.

> Note also that THP's no longer do direct compaction by default in recent
> kernels.
> 
> To fully solve the freepage scanning issue, we should probably pick and finish
> one of the proposed reworks from Joonsoo or myself, or the approach that
> replaces free scanner with direct freelist allocations.
> 

Feel free to post the patches, but I believe this simple change makes 
release_freepages() exceedingly better and can better target memory for 
the freeing scanner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
