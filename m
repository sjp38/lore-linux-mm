Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A27126B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 10:50:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so2767678plb.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 07:50:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10-v6sor234036plz.30.2018.04.09.07.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 07:50:06 -0700 (PDT)
Date: Mon, 9 Apr 2018 23:49:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Yu <yuchao0@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 08:25:06PM +0800, Chao Yu wrote:
> On 2018/4/9 19:25, Minchan Kim wrote:
> > On Mon, Apr 09, 2018 at 04:14:03AM -0700, Matthew Wilcox wrote:
> >> On Mon, Apr 09, 2018 at 12:09:30PM +0900, Minchan Kim wrote:
> >>> On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> >>>> On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> >>>>> It assumes shadow entry of radix tree relies on the init state
> >>>>> that node->private_list allocated should be list_empty state.
> >>>>> Currently, it's initailized in SLAB constructor which means
> >>>>> node of radix tree would be initialized only when *slub allocates
> >>>>> new page*, not *new object*. So, if some FS or subsystem pass
> >>>>> gfp_mask to __GFP_ZERO, slub allocator will do memset blindly.
> >>>>
> >>>> Wait, what?  Who's declaring their radix tree with GFP_ZERO flags?
> >>>> I don't see anyone using INIT_RADIX_TREE or RADIX_TREE or RADIX_TREE_INIT
> >>>> with GFP_ZERO.
> >>>
> >>> Look at fs/f2fs/inode.c
> >>> mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> >>>
> >>> __add_to_page_cache_locked
> >>>   radix_tree_maybe_preload
> >>>
> >>> add_to_page_cache_lru
> >>>
> >>> What's the wrong with setting __GFP_ZERO with mapping->gfp_mask?
> >>
> >> Because it's a stupid thing to do.  Pages are allocated and then filled
> >> from disk.  Zeroing them before DMAing to them is just a waste of time.
> > 
> > Every FSes do address_space to read pages from storage? I'm not sure.
> 
> No, sometimes, we need to write meta data to new allocated block address,
> then we will allocate a zeroed page in inner inode's address space, and
> fill partial data in it, and leave other place with zero value which means
> some fields are initial status.

Thanks for the explaining.

> 
> There are two inner inodes (meta inode and node inode) setting __GFP_ZERO,
> I have just checked them, for both of them, we can avoid using __GFP_ZERO,
> and do initialization by ourselves to avoid unneeded/redundant zeroing
> from mm.

Yub, it would be desirable for f2fs. Please go ahead for f2fs side.
However, I think current problem is orthgonal. Now, the problem is
radix_tree_node allocation is bind to page cache allocation.
Why does FS cannot allocate page cache with __GFP_ZERO?
I agree if the concern is only performance matter as Matthew mentioned.
But it is beyond that because it shouldn't do due to limitation
of workingset shadow entry implementation. I think such coupling is
not a good idea.

I think right approach to abstract shadow entry in radix_tree is
to mask off __GFP_ZERO in radix_tree's allocation APIs.

> 
> To Jaegeuk, if I missed something, please let me know.
> 
> ---
>  fs/f2fs/inode.c | 4 ++--
>  fs/f2fs/node.c  | 2 ++
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
> index c85cccc2e800..cc63f8c448f0 100644
> --- a/fs/f2fs/inode.c
> +++ b/fs/f2fs/inode.c
> @@ -339,10 +339,10 @@ struct inode *f2fs_iget(struct super_block *sb, unsigned long ino)
>  make_now:
>  	if (ino == F2FS_NODE_INO(sbi)) {
>  		inode->i_mapping->a_ops = &f2fs_node_aops;
> -		mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> +		mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
>  	} else if (ino == F2FS_META_INO(sbi)) {
>  		inode->i_mapping->a_ops = &f2fs_meta_aops;
> -		mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> +		mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
>  	} else if (S_ISREG(inode->i_mode)) {
>  		inode->i_op = &f2fs_file_inode_operations;
>  		inode->i_fop = &f2fs_file_operations;
> diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
> index 9dedd4b5e077..31e5ecf98ffd 100644
> --- a/fs/f2fs/node.c
> +++ b/fs/f2fs/node.c
> @@ -1078,6 +1078,7 @@ struct page *new_node_page(struct dnode_of_data *dn, unsigned int ofs)
>  	set_node_addr(sbi, &new_ni, NEW_ADDR, false);
> 
>  	f2fs_wait_on_page_writeback(page, NODE, true);
> +	memset(F2FS_NODE(page), 0, PAGE_SIZE);
>  	fill_node_footer(page, dn->nid, dn->inode->i_ino, ofs, true);
>  	set_cold_node(page, S_ISDIR(dn->inode->i_mode));
>  	if (!PageUptodate(page))
> @@ -2321,6 +2322,7 @@ int recover_inode_page(struct f2fs_sb_info *sbi, struct page *page)
> 
>  	if (!PageUptodate(ipage))
>  		SetPageUptodate(ipage);
> +	memset(F2FS_NODE(page), 0, PAGE_SIZE);
>  	fill_node_footer(ipage, ino, ino, 0, true);
>  	set_cold_node(page, false);
> 
> -- 
> 
> > 
> > If you're right, we need to insert WARN_ON to catch up __GFP_ZERO
> > on mapping_set_gfp_mask at the beginning and remove all of those
> > stupid thins. 
> > 
> > Jaegeuk, why do you need __GFP_ZERO? Could you explain?
> > 
> > .
> > 
> 
