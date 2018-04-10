Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 449596B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:18:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b16so7071568pfi.5
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:18:23 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b5-v6si2722280ple.584.2018.04.10.08.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 08:18:22 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:18:20 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH 2/2] page cache: Mask off unwanted GFP flags
Message-ID: <20180410151820.GA69325@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180410125351.15837-1-willy@infradead.org>
 <20180410125351.15837-2-willy@infradead.org>
 <20180410134545.GA35354@rodete-laptop-imager.corp.google.com>
 <20180410140223.GE22118@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410140223.GE22118@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On 04/10, Matthew Wilcox wrote:
> On Tue, Apr 10, 2018 at 10:45:45PM +0900, Minchan Kim wrote:
> > On Tue, Apr 10, 2018 at 05:53:51AM -0700, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > The page cache has used the mapping's GFP flags for allocating
> > > radix tree nodes for a long time.  It took care to always mask off the
> > > __GFP_HIGHMEM flag, and masked off other flags in other paths, but the
> > > __GFP_ZERO flag was still able to sneak through.  The __GFP_DMA and
> > > __GFP_DMA32 flags would also have been able to sneak through if they
> > > were ever used.  Fix them all by using GFP_RECLAIM_MASK at the innermost
> > > location, and remove it from earlier in the callchain.
> > > 
> > > Fixes: 19f99cee206c ("f2fs: add core inode operations")
> > 
> > Why this patch fix 19f99cee206c instead of 449dd6984d0e?
> > F2FS doesn't have any problem before introducing 449dd6984d0e?
> 
> Well, there's the problem.  This bug is the combination of three different
> things:
> 
> 1. The working set code relying on list_empty.
> 2. The page cache not filtering out the bad flags.
> 3. F2FS specifying a flag nobody had ever specified before.
> 
> So what single patch does this patch fix?  I don't think it really matters.

Hope there'd be someone who does care about patch description though, IMHO,
this fixes the MM regression introduced by:
449dd6984d0e ("mm: keep page cache radix tree nodes in check") merged in v3.15,
2014.

19f99cee206c ("f2fs: add core inode operations) merged in v3.8, 2012, just
revealed this out. In fact, I've never hit this bug in old kernels.

>From the user viewpoint, may I suggest to describe what kind of symptom we're
able to see due to this bug?

Something like:

[ 7858.792946] [<ffffff80086f4de0>] __list_del_entry+0x30/0xd0
[ 7858.792951] [<ffffff8008362018>] list_lru_del+0xac/0x1ac
[ 7858.792957] [<ffffff800830f04c>] page_cache_tree_insert+0xd8/0x110
[ 7858.792962] [<ffffff8008310188>] __add_to_page_cache_locked+0xf8/0x4e0
[ 7858.792967] [<ffffff800830ff34>] add_to_page_cache_lru+0x50/0x1ac
[ 7858.792972] [<ffffff800830fdd0>] pagecache_get_page+0x468/0x57c
[ 7858.792979] [<ffffff80085d081c>] __get_node_page+0x84/0x764
[ 7858.792986] [<ffffff800859cd94>] f2fs_iget+0x264/0xdc8
[ 7858.792991] [<ffffff800859ee00>] f2fs_lookup+0x3b4/0x660
[ 7858.792998] [<ffffff80083d2540>] lookup_slow+0x1e4/0x348
[ 7858.793003] [<ffffff80083d0eb8>] walk_component+0x21c/0x320
[ 7858.793008] [<ffffff80083d0010>] path_lookupat+0x90/0x1bc
[ 7858.793013] [<ffffff80083cfe6c>] filename_lookup+0x8c/0x1a0
[ 7858.793018] [<ffffff80083c52d0>] vfs_fstatat+0x84/0x10c
[ 7858.793023] [<ffffff80083c5b00>] SyS_newfstatat+0x28/0x64

Thanks,
