Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCDB96B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:54:54 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so12154069wjd.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:54:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b195si15025681wmg.134.2017.01.16.23.54.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 23:54:53 -0800 (PST)
Date: Tue, 17 Jan 2017 08:54:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] Revert "ext4: avoid deadlocks in the writeback path
 by using sb_getblk_gfp"
Message-ID: <20170117075450.GC19699@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-8-mhocko@kernel.org>
 <20170117030118.727jqyamjhojzajb@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117030118.727jqyamjhojzajb@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 16-01-17 22:01:18, Theodore Ts'o wrote:
> On Fri, Jan 06, 2017 at 03:11:06PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > This reverts commit c45653c341f5c8a0ce19c8f0ad4678640849cb86 because
> > sb_getblk_gfp is not really needed as
> > sb_getblk
> >   __getblk_gfp
> >     __getblk_slow
> >       grow_buffers
> >         grow_dev_page
> > 	  gfp_mask = mapping_gfp_constraint(inode->i_mapping, ~__GFP_FS) | gfp
> > 
> > so __GFP_FS is cleared unconditionally and therefore the above commit
> > didn't have any real effect in fact.
> > 
> > This patch should not introduce any functional change. The main point
> > of this change is to reduce explicit GFP_NOFS usage inside ext4 code to
> > make the review of the remaining usage easier.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Jan Kara <jack@suse.cz>
> 
> If I'm not mistaken, this patch is not dependent on any of the other
> patches in this series (and the other patches are not dependent on
> this one).  Hence, I could take this patch via the ext4 tree, correct?

Yes, that is correct

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
