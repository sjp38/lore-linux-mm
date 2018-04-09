Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A31516B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:36:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so313837pgt.6
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:36:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2-v6si561462plz.683.2018.04.09.08.36.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 08:36:43 -0700 (PDT)
Date: Mon, 9 Apr 2018 17:34:09 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180409153409.nqsklemu3igacgbj@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409124852.GE21835@dhcp22.suse.cz>
 <20180409134114.GA30963@bombadil.infradead.org>
 <20180409135215.GH21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409135215.GH21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Chao Yu <yuchao0@huawei.com>, Minchan Kim <minchan@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 03:52:15PM +0200, Michal Hocko wrote:
> On Mon 09-04-18 06:41:14, Matthew Wilcox wrote:
> > On Mon, Apr 09, 2018 at 02:48:52PM +0200, Michal Hocko wrote:
> > > On Mon 09-04-18 20:25:06, Chao Yu wrote:
> > > [...]
> > > > diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
> > > > index c85cccc2e800..cc63f8c448f0 100644
> > > > --- a/fs/f2fs/inode.c
> > > > +++ b/fs/f2fs/inode.c
> > > > @@ -339,10 +339,10 @@ struct inode *f2fs_iget(struct super_block *sb, unsigned long ino)
> > > >  make_now:
> > > >  	if (ino == F2FS_NODE_INO(sbi)) {
> > > >  		inode->i_mapping->a_ops = &f2fs_node_aops;
> > > > -		mapping_set_gfp_mask(inode->i_mapping, GFP_F2FS_ZERO);
> > > > +		mapping_set_gfp_mask(inode->i_mapping, GFP_NOFS);
> > > 
> > > An unrelated question. Why do you make all allocations for the mapping
> > > NOFS automatically? What kind of reclaim recursion problems are you
> > > trying to prevent?
> > 
> > It's worth noting that this is endemic in filesystems.
> 
> Yes, and I have strong suspicion that this is a mindless copy&pasting...
> Well, xfs had a good reason for it in the past - mostly to handle deep
> call stacks on complicated storage setups in the past when we used to
> trigger IO from the direct reclaim. I am not sure whether there are
> other reasons to keep the status quo except for finding somebody brave
> enough to post the patch, do all the due testing.
> 
> > $ git grep mapping_set_gfp_mask.*FS
> > drivers/block/loop.c:   mapping_set_gfp_mask(mapping, lo->old_gfp_mask & ~(__GFP_IO|__GFP_FS));
> > fs/btrfs/disk-io.c:     mapping_set_gfp_mask(fs_info->btree_inode->i_mapping, GFP_NOFS);

Thi was added in 1561deda687eef0
(https://git.kernel.org/linus/1561deda687eef0e9506) and probably after a
deadlock report.

The changelog mentions the potential recursion from fs -> allocation -> fs,
but I'm not sure if this still happens on the MM side today.

For the filesystem part, I think the key functions of the callchain are
still there.

The code was been added in 2011 and the 2nd hunk of the patch added a
code that's not present today AFAICS, so this is worth revisiting.

I still don't understand how it's related to the GFP_HIGHUSER_MOVABLE,
this patch is from time where the metadata pages were possibly allocated
from HIGHMEM but this was removed later in a65917156e345946db
(https://git.kernel.org/linus/a65917156e345946db).
