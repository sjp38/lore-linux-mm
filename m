Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90F956B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:02:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t1-v6so9614039plb.5
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:02:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x21si2136593pfn.155.2018.04.10.07.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 07:02:25 -0700 (PDT)
Date: Tue, 10 Apr 2018 07:02:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] page cache: Mask off unwanted GFP flags
Message-ID: <20180410140223.GE22118@bombadil.infradead.org>
References: <20180410125351.15837-1-willy@infradead.org>
 <20180410125351.15837-2-willy@infradead.org>
 <20180410134545.GA35354@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410134545.GA35354@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org, jaegeuk@kernel.org

On Tue, Apr 10, 2018 at 10:45:45PM +0900, Minchan Kim wrote:
> On Tue, Apr 10, 2018 at 05:53:51AM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > The page cache has used the mapping's GFP flags for allocating
> > radix tree nodes for a long time.  It took care to always mask off the
> > __GFP_HIGHMEM flag, and masked off other flags in other paths, but the
> > __GFP_ZERO flag was still able to sneak through.  The __GFP_DMA and
> > __GFP_DMA32 flags would also have been able to sneak through if they
> > were ever used.  Fix them all by using GFP_RECLAIM_MASK at the innermost
> > location, and remove it from earlier in the callchain.
> > 
> > Fixes: 19f99cee206c ("f2fs: add core inode operations")
> 
> Why this patch fix 19f99cee206c instead of 449dd6984d0e?
> F2FS doesn't have any problem before introducing 449dd6984d0e?

Well, there's the problem.  This bug is the combination of three different
things:

1. The working set code relying on list_empty.
2. The page cache not filtering out the bad flags.
3. F2FS specifying a flag nobody had ever specified before.

So what single patch does this patch fix?  I don't think it really matters.
