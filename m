Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0A436B0005
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 07:25:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v19so3316227pfn.7
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 04:25:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor48454pla.80.2018.04.09.04.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 04:25:24 -0700 (PDT)
Date: Mon, 9 Apr 2018 20:25:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409111403.GA31652@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 04:14:03AM -0700, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> > On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> > > On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> > > > It assumes shadow entry of radix tree relies on the init state
> > > > that node->private_list allocated should be list_empty state.
> > > > Currently, it's initailized in SLAB constructor which means
> > > > node of radix tree would be initialized only when *slub allocates
> > > > new page*, not *new object*. So, if some FS or subsystem pass
> > > > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> > > 
> > > Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> > > I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> > > with GFP_ZERO.
> > 
> > Look at fs/f2fs/inode.c
> > mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > 
> > __add_to_page_cache_locked
> >   radix_tree_maybe_preload
> > 
> > add_to_page_cache_lru
> > 
> > What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?
> 
> Because it's a stupid thing to do.  Pages are allocated and then filled
> from disk.  Zeroing them before DMAing to them is just a waste of time.

Every FSes do address_space to read pages from storage? I'm not sure.

If you're right, we need to insert WARN_ON to catch up __GFP_ZERO
on mapping_set_gfp_mask at the beginning and remove all of those
stupid thins. 

Jaegeuk, why do you need __GFP_ZERO? Could you explain?
