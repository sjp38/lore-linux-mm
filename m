Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC49D6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:20:36 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w9-v6so7212082plp.0
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:20:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k8si369788pgp.268.2018.04.09.08.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:20:35 -0700 (PDT)
Date: Mon, 9 Apr 2018 08:20:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409152032.GB11756@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 11:49:58PM +0900, Minchan Kim wrote:
> On Mon, Apr 09, 2018 at 08:25:06PM +0800, Chao Yu wrote:
> > On 2018/4/9 19:25, Minchan Kim wrote:
> > > On Mon, Apr 09, 2018 at 04:14:03AM -0700, Matthew Wilcox wrote:
> > >> On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> > >>> Look at fs/f2fs/inode.c
> > >>> mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > >>>
> > >>> __add_to_page_cache_locked
> > >>>   radix_tree_maybe_preload
> > >>>
> > >>> add_to_page_cache_lru
> > 
> > No, sometimes, we need to write meta data to new allocated block address,
> > then we will allocate a zeroed page in inner inode's address space, and
> > fill partial data in it, and leave other place with zero value which means
> > some fields are initial status.
> 
> Thanks for the explaining.
> 
> > There are two inner inodes (meta inode and node inode) setting __GFP_ZERO,
> > I have just checked them, for both of them, we can avoid using __GFP_ZERO,
> > and do initialization by ourselves to avoid unneeded/redundant zeroing
> > from mm.
> 
> Yub, it would be desirable for f2fs. Please go ahead for f2fs side.
> However, I think current problem is orthgonal. Now, the problem is
> radix_tree_node allocation is bind to page cache allocation.
> Why does FS cannot allocate page cache with __GFP_ZERO?
> I agree if the concern is only performance matter as Matthew mentioned.
> But it is beyond that because it shouldn't do due to limitation
> of workingset shadow entry implementation. I think such coupling is
> not a good idea.
> 
> I think right approach to abstract shadow entry in radix_tree is
> to mask off __GFP_ZERO in radix_tree's allocation APIs.

I don't think this is something the radix tree should know about.
SLAB should be checking for it (the patch I posted earlier in this
thread), but the right place to filter this out is in the caller of
radix_tree_maybe_preload -- it's already filtering out HIGHMEM pages,
and should filter out GFP_ZERO too.

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
