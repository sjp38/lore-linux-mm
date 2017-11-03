Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F78C6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 16:37:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i38so11121561iod.10
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 13:37:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e194sor1729617itb.76.2017.11.03.13.37.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 13:37:22 -0700 (PDT)
Date: Fri, 3 Nov 2017 13:37:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm, compaction: extend pageblock_skip_persistent()
 to all compound pages
In-Reply-To: <20171102121706.21504-1-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1711031335350.29847@chino.kir.corp.google.com>
References: <20171102121706.21504-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 2 Nov 2017, Vlastimil Babka wrote:

> The pageblock_skip_persistent() function checks for HugeTLB pages of pageblock
> order. When clearing pageblock skip bits for compaction, the bits are not
> cleared for such pageblocks, because they cannot contain base pages suitable
> for migration, nor free pages to use as migration targets.
> 
> This optimization can be simply extended to all compound pages of order equal
> or larger than pageblock order, because migrating such pages (if they support
> it) cannot help sub-pageblock fragmentation. This includes THP's and also
> gigantic HugeTLB pages, which the current implementation doesn't persistently
> skip due to a strict pageblock_order equality check and not recognizing tail
> pages.
> 
> While THP pages are generally less "persistent" than HugeTLB, we can still
> expect that if a THP exists at the point of __reset_isolation_suitable(), it
> will exist also during the subsequent compaction run. The time difference here
> could be actually smaller than between a compaction run that sets a
> (non-persistent) skip bit on a THP, and the next compaction run that observes
> it.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

This was originally done only for hugetlb because it was considered to be 
more persistent than thp, but with the presence of the deferred split 
shrinker I think this is fine.  It might be helpful to mention that the 
compound page is not synchronously split like it was prior to the thp 
refcounting patchset, however.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
