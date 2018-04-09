Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5200D6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 14:38:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c85so5394056pfb.12
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 11:38:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 4-v6si816621pld.371.2018.04.09.11.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 11:38:28 -0700 (PDT)
Date: Mon, 9 Apr 2018 11:38:27 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409183827.GD17558@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On 04/09, Minchan Kim wrote:
> On Mon, Apr 09, 2018 at 04:14:03AM -0700, Matthew Wilcox wrote:
> > On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> > > On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> > > > On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> > > > > It assumes shadow entry of radix tree relies on the init state
> > > > > that node->private_list allocated should be list_empty state.
> > > > > Currently, it's initailized in SLAB constructor which means
> > > > > node of radix tree would be initialized only when *slub allocates
> > > > > new page*, not *new object*. So, if some FS or subsystem pass
> > > > > gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> > > > 
> > > > Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> > > > I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> > > > with GFP_ZERO.
> > > 
> > > Look at fs/f2fs/inode.c
> > > mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > > 
> > > __add_to_page_cache_locked
> > >   radix_tree_maybe_preload
> > > 
> > > add_to_page_cache_lru
> > > 
> > > What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?
> > 
> > Because it's a stupid thing to do.  Pages are allocated and then filled
> > from disk.  Zeroing them before DMAing to them is just a waste of time.
> 
> Every FSes do address_space to read pages from storage? I'm not sure.
> 
> If you're right, we need to insert WARN_ON to catch up __GFP_ZERO
> on mapping_set_gfp_mask at the beginning and remove all of those
> stupid thins. 
> 
> Jaegeuk, why do you need __GFP_ZERO? Could you explain?

Comment says "__GFP_ZERO returns a zeroed page on success."

The f2fs maintains two inodes to manage some metadata in the page cache,
which requires zeroed data when introducing a new structure. It's not
a big deal to avoid __GFP_ZERO for whatever performance reasons tho, does
it only matters with f2fs?

Thanks,
