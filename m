Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7826B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:59:15 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r2so14187722wra.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:59:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k21si951994ede.3.2017.11.27.08.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Nov 2017 08:59:13 -0800 (PST)
Date: Mon, 27 Nov 2017 16:59:06 +0000
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm/cma: fix alloc_contig_range ret code/potential leak
Message-ID: <20171127165906.GA16092@cmpxchg.org>
References: <15cf0f39-43f9-8287-fcfe-f2502af59e8a@oracle.com>
 <20171122185214.25285-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122185214.25285-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed, Nov 22, 2017 at 10:52:14AM -0800, Mike Kravetz wrote:
> If the call __alloc_contig_migrate_range() in alloc_contig_range
> returns -EBUSY, processing continues so that test_pages_isolated()
> is called where there is a tracepoint to identify the busy pages.
> However, it is possible for busy pages to become available between
> the calls to these two routines.  In this case, the range of pages
> may be allocated.   Unfortunately, the original return code (ret
> == -EBUSY) is still set and returned to the caller.  Therefore,
> the caller believes the pages were not allocated and they are leaked.
> 
> Update comment to indicate that allocation is still possible even if
> __alloc_contig_migrate_range returns -EBUSY.  Also, clear return code
> in this case so that it is not accidentally used or returned to caller.
> 
> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
