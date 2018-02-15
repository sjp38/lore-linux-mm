Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1246B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:11:35 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id o2so13332127pls.10
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:11:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bh4-v6si111423plb.14.2018.02.15.07.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 07:11:33 -0800 (PST)
Date: Thu, 15 Feb 2018 07:11:29 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-ID: <20180215151129.GB12360@bombadil.infradead.org>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
 <20180214095911.GB28460@dhcp22.suse.cz>
 <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
 <20180215144525.GG7275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215144525.GG7275@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, Feb 15, 2018 at 03:45:25PM +0100, Michal Hocko wrote:
> > When the amount of kernel 
> > memory is well bounded for certain systems, it is better to aggressively 
> > reclaim from existing MIGRATE_UNMOVABLE pageblocks rather than eagerly 
> > fallback to others.
> > 
> > We have additional patches that help with this fragmentation if you're 
> > interested, specifically kcompactd compaction of MIGRATE_UNMOVABLE 
> > pageblocks triggered by fallback of non-__GFP_MOVABLE allocations and 
> > draining of pcp lists back to the zone free area to prevent stranding.
> 
> Yes, I think we need a proper fix. (Ab)using zone_movable for this
> usecase is just sad.

What if ... on startup, slab allocated a MAX_ORDER page for itself.
It would then satisfy its own page allocation requests from this giant
page.  If we start to run low on memory in the rest of the system, slab
can be induced to return some of it via its shrinker.  If slab runs low
on memory, it tries to allocate another MAX_ORDER page for itself.

I think even this should reduce fragmentation.  We could enhance the
fragmentation reduction by noticing when somebody else releases a page
that was previously part of a slab MAX_ORDER page and handing that page
back to slab.  When slab notices that it has an entire MAX_ORDER page free
(and sufficient other memory on hand that it's unlikely to need it soon),
it can hand that MAX_ORDER page back to the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
