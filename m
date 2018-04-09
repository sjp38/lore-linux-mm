Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48EEC6B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:41:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a6so5103166pfn.3
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:41:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 91-v6si368207ply.33.2018.04.09.06.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 06:41:19 -0700 (PDT)
Date: Mon, 9 Apr 2018 06:41:14 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409134114.GA30963@bombadil.infradead.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409124852.GE21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409124852.GE21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>, Minchan Kim <minchan@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 02:48:52PM +0200, Michal Hocko wrote:
> On Mon 09-04-18 20:25:06, Chao Yu wrote:
> [...]
> > diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
> > index c85cccc2e800..cc63f8c448f0 100644
> > --- a/fs/f2fs/inode.c
> > +++ b/fs/f2fs/inode.c
> > @@ -339,10 +339,10 @@ struct inode *f2fs_iget(struct super_block *sb, unsigned long ino)
> >  make_now:
> >  	if (ino == F2FS_NODE_INO(sbi)) {
> >  		inode->i_mapping->a_ops = &f2fs_node_aops;
> > -		mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > +		mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
> 
> An unrelated question. Why do you make all allocations for the mapping
> NOFS automatically? What kind of reclaim recursion problems are you
> trying to prevent?

It's worth noting that this is endemic in filesystems.

$ git grep mapping_set_gfp_mask.*FS
drivers/block/loop.c:   mapping_set_gfp_mask(mapping, lo->old_gfp_mask & ~(__GFP_IO|__GFP_FS));
fs/btrfs/disk-io.c:     mapping_set_gfp_mask(fs_info->btree_inode->i_mapping, GFP_NOFS);
fs/f2fs/inode.c:                mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
fs/f2fs/inode.c:                mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
fs/gfs2/glock.c:                mapping_set_gfp_mask(mapping, GFP_NOFS);
fs/gfs2/ops_fstype.c:   mapping_set_gfp_mask(mapping, GFP_NOFS);
fs/jfs/jfs_imap.c:      mapping_set_gfp_mask(ip->i_mapping, GFP_NOFS);
fs/jfs/super.c: mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
fs/nilfs2/gcinode.c:    mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
fs/nilfs2/page.c:       mapping_set_gfp_mask(mapping, GFP_NOFS);
fs/reiserfs/xattr.c:    mapping_set_gfp_mask(mapping, GFP_NOFS);
fs/xfs/xfs_iops.c:      mapping_set_gfp_mask(inode->i_mapping, (gfp_mask & ~(__GFP_FS)));
