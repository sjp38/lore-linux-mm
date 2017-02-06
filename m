Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED4A6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 16:18:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so21669553wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 13:18:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n49si2367056wrn.256.2017.02.06.13.18.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 13:18:03 -0800 (PST)
Date: Mon, 6 Feb 2017 22:18:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20170206211759.GC20731@dhcp22.suse.cz>
References: <20170206140718.16222-1-mhocko@kernel.org>
 <20170206140718.16222-5-mhocko@kernel.org>
 <20170206153923.GL2267@bombadil.infradead.org>
 <20170206174415.GA20731@dhcp22.suse.cz>
 <20170206183237.GE3580@birch.djwong.org>
 <20170206184743.GB20731@dhcp22.suse.cz>
 <20170206195111.GH3580@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206195111.GH3580@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 06-02-17 11:51:11, Darrick J. Wong wrote:
> On Mon, Feb 06, 2017 at 07:47:43PM +0100, Michal Hocko wrote:
> > On Mon 06-02-17 10:32:37, Darrick J. Wong wrote:
> > > On Mon, Feb 06, 2017 at 06:44:15PM +0100, Michal Hocko wrote:
> > > > On Mon 06-02-17 07:39:23, Matthew Wilcox wrote:
> > > > > On Mon, Feb 06, 2017 at 03:07:16PM +0100, Michal Hocko wrote:
> > > > > > +++ b/fs/xfs/xfs_buf.c
> > > > > > @@ -442,17 +442,17 @@ _xfs_buf_map_pages(
> > > > > >  		bp->b_addr = NULL;
> > > > > >  	} else {
> > > > > >  		int retried = 0;
> > > > > > -		unsigned noio_flag;
> > > > > > +		unsigned nofs_flag;
> > > > > >  
> > > > > >  		/*
> > > > > >  		 * vm_map_ram() will allocate auxillary structures (e.g.
> > > > > >  		 * pagetables) with GFP_KERNEL, yet we are likely to be under
> > > > > >  		 * GFP_NOFS context here. Hence we need to tell memory reclaim
> > > > > > -		 * that we are in such a context via PF_MEMALLOC_NOIO to prevent
> > > > > > +		 * that we are in such a context via PF_MEMALLOC_NOFS to prevent
> > > > > >  		 * memory reclaim re-entering the filesystem here and
> > > > > >  		 * potentially deadlocking.
> > > > > >  		 */
> > > > > 
> > > > > This comment feels out of date ... how about:
> > > > 
> > > > which part is out of date?
> > > > 
> > > > > 
> > > > > 		/*
> > > > > 		 * vm_map_ram will allocate auxiliary structures (eg page
> > > > > 		 * tables) with GFP_KERNEL.  If that tries to reclaim memory
> > > > > 		 * by calling back into this filesystem, we may deadlock.
> > > > > 		 * Prevent that by setting the NOFS flag.
> > > > > 		 */
> > > > 
> > > > dunno, the previous wording seems clear enough to me. Maybe little bit
> > > > more chatty than yours but I am not sure this is worth changing.
> > > 
> > > I prefer to keep the "...yet we are likely to be under GFP_NOFS..."
> > > wording of the old comment because it captures the uncertainty of
> > > whether or not we actually are already under NOFS.  If someone actually
> > > has audited this code well enough to know for sure then yes let's change
> > > the comment, but I haven't gone that far.
> 
> Ugh, /me hands himself another cup of coffee...
> 
> Somehow I mixed up _xfs_buf_map_pages and kmem_zalloc_large in this
> discussion.  Probably because they have similar code snippets with very
> similar comments to two totally different parts of xfs.
> 
> The _xfs_buf_map_pages can be called inside or outside of
> transaction context, so I think we still have to memalloc_nofs_save for
> that to avoid the lockdep complaints and deadlocks referenced in the
> commit that added all that (to _xfs_buf_map_pages) in the first place.
> ae687e58b3 ("xfs: use NOIO contexts for vm_map_ram")

Yes, and that memalloc_nofs_save would start with the transaction
context so this (_xfs_buf_map_pages) call would be already covered so
additional memalloc_nofs_save would be unnecessary. Right now I am not
sure whether this is always the case so I have kept this "just to be
sure" measure. Checking that would be in the next step when I would like
to remove other KM_NOFS usage so that we would always rely on the scope
inside the transaction or other potentially dangerous (e.g. from the
stack usage POV and who knows what else) contexts.

Does that make more sense now?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
