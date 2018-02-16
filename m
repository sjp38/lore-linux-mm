Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0216F6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 19:45:06 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id v134so1945851ith.1
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 16:45:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v189sor4204493iod.329.2018.02.15.16.45.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 16:45:05 -0800 (PST)
Date: Thu, 15 Feb 2018 16:45:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180215204817.GB22948@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.10.1802151638510.50948@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz> <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com> <20180215144525.GG7275@dhcp22.suse.cz> <20180215151129.GB12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake> <20180215204817.GB22948@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, 15 Feb 2018, Matthew Wilcox wrote:

> What I was proposing was an intermediate page allocator where slab would
> request 2MB for its own uses all at once, then allocate pages from that to
> individual slabs, so allocating a kmalloc-32 object and a dentry object
> would result in 510 pages of memory still being available for any slab
> that needed it.
> 

A type of memory arena built between the page allocator and slab 
allocator.

The issue that I see with this is eventually there's going to be low on 
memory situations where memory needs to be reclaimed from these arena 
pages.  We can free individual pages back to the buddy allocator, but have 
no control over whether an entire pageblock can be freed back.  So now we 
have MIGRATE_MOVABLE or MIGRATE_UNMOVABLE pageblocks with some user pages 
and some slab pages, and we've reached the same fragmentation issue in a 
different way.  After that, it will become more difficult for the slab 
allocator to request a page of pageblock_order.

Other than the stranding issue of MIGRATE_UNMOVABLE pages on pcps, the 
page allocator currently does well in falling back to other migratetypes 
but there isn't any type of slab reclaim or defragmentation done in the 
background to try to free up as much memory from that 
now-MIGRATE_UNMOVABLE pageblock as possible.  We have patches that do 
that, but as I mentioned before it can affect the performance of the page 
allocator because it drains pcps on fallback and it does kcompactd 
compaction in the background even if you don't need order-9 memory later 
(or you've defragmented needlessly when more slab is just going to be 
allocated anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
