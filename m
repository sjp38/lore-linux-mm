Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8E16B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 07:14:07 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w9-v6so6864562plp.0
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 04:14:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h10si77684pgc.308.2018.04.09.04.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 04:14:05 -0700 (PDT)
Date: Mon, 9 Apr 2018 04:14:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409111403.GA31652@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> > On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> > > It assumes shadow entry of radix tree relies on the init state
> > > that node->private_list allocated should be list_empty state.
> > > Currently, it's initailized in SLAB constructor which means
> > > node of radix tree would be initialized only when *slub allocates
> > > new page*, not *new object*. So, if some FS or subsystem pass
> > > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> > 
> > Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> > I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> > with GFP_ZERO.
> 
> Look at fs/f2fs/inode.c
> mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> 
> __add_to_page_cache_locked
>   radix_tree_maybe_preload
> 
> add_to_page_cache_lru
> 
> What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?

Because it's a stupid thing to do.  Pages are allocated and then filled
from disk.  Zeroing them before DMAing to them is just a waste of time.
