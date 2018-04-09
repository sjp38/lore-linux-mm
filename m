Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E91526B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 15:40:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x184so3787100pfd.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 12:40:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d8si655217pgc.60.2018.04.09.12.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 12:40:47 -0700 (PDT)
Date: Mon, 9 Apr 2018 12:40:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409194044.GA15295@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <20180409183827.GD17558@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409183827.GD17558@jaegeuk-macbookpro.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 11:38:27AM -0700, Jaegeuk Kim wrote:
> On 04/09, Minchan Kim wrote:
> > On Mon, Apr 09, 2018 at 04:14:03AM -0700, Matthew Wilcox wrote:
> > > On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> > > > On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> > > > > On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> > > > > > It assumes shadow entry of radix tree relies on the init state
> > > > > > that node->private_list allocated should be list_empty state.
> > > > > > Currently, it's initailized in SLAB constructor which means
> > > > > > node of radix tree would be initialized only when *slub allocates
> > > > > > new page*, not *new object*. So, if some FS or subsystem pass
> > > > > > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> > > > > 
> > > > > Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> > > > > I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> > > > > with GFP_ZERO.
> > > > 
> > > > Look at fs/f2fs/inode.c
> > > > mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > > > 
> > > > __add_to_page_cache_locked
> > > >   radix_tree_maybe_preload
> > > > 
> > > > add_to_page_cache_lru
> > > > 
> > > > What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?
> > > 
> > > Because it's a stupid thing to do.  Pages are allocated and then filled
> > > from disk.  Zeroing them before DMAing to them is just a waste of time.
> > 
> > Every FSes do address_space to read pages from storage? I'm not sure.
> > 
> > If you're right, we need to insert WARN_ON to catch up __GFP_ZERO
> > on mapping_set_gfp_mask at the beginning and remove all of those
> > stupid thins. 
> > 
> > Jaegeuk, why do you need __GFP_ZERO? Could you explain?
> 
> Comment says "__GFP_ZERO returns a zeroed page on success."
> 
> The f2fs maintains two inodes to manage some metadata in the page cache,
> which requires zeroed data when introducing a new structure. It's not
> a big deal to avoid __GFP_ZERO for whatever performance reasons tho, does
> it only matters with f2fs?

This isn't a performance issue.

The problem is that the mapping gfp flags are used not only for allocating
pages, but also for allocating the page cache data structures that hold
the pages.  F2FS is the only filesystem that set the __GFP_ZERO bit,
so it's the first time anyone's noticed that the page cache passes the
__GFP_ZERO bit through to the radix tree allocation routines, which
causes the radix tree nodes to be zeroed instead of constructed.

I think the right solution to this is:

diff --git a/mm/filemap.c b/mm/filemap.c
index c2147682f4c3..a87a523eea8e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -785,7 +785,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	VM_BUG_ON_PAGE(!PageLocked(new), new);
 	VM_BUG_ON_PAGE(new->mapping, new);
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_preload(gfp_mask & ~(__GFP_HIGHMEM | __GFP_ZERO));
 	if (!error) {
 		struct address_space *mapping = old->mapping;
 		void (*freepage)(struct page *);
@@ -841,7 +841,8 @@ static int __add_to_page_cache_locked(struct page *page,
 			return error;
 	}
 
-	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_maybe_preload(gfp_mask &
+			~(__GFP_HIGHMEM | __GFP_ZERO));
 	if (error) {
 		if (!huge)
 			mem_cgroup_cancel_charge(page, memcg, false);
