Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5486B0069
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 13:47:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x4so21115311wme.3
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 10:47:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y64si9074981wmy.110.2017.02.06.10.47.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 10:47:47 -0800 (PST)
Date: Mon, 6 Feb 2017 19:47:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20170206184743.GB20731@dhcp22.suse.cz>
References: <20170206140718.16222-1-mhocko@kernel.org>
 <20170206140718.16222-5-mhocko@kernel.org>
 <20170206153923.GL2267@bombadil.infradead.org>
 <20170206174415.GA20731@dhcp22.suse.cz>
 <20170206183237.GE3580@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206183237.GE3580@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 06-02-17 10:32:37, Darrick J. Wong wrote:
> On Mon, Feb 06, 2017 at 06:44:15PM +0100, Michal Hocko wrote:
> > On Mon 06-02-17 07:39:23, Matthew Wilcox wrote:
> > > On Mon, Feb 06, 2017 at 03:07:16PM +0100, Michal Hocko wrote:
> > > > +++ b/fs/xfs/xfs_buf.c
> > > > @@ -442,17 +442,17 @@ _xfs_buf_map_pages(
> > > >  		bp->b_addr = NULL;
> > > >  	} else {
> > > >  		int retried = 0;
> > > > -		unsigned noio_flag;
> > > > +		unsigned nofs_flag;
> > > >  
> > > >  		/*
> > > >  		 * vm_map_ram() will allocate auxillary structures (e.g.
> > > >  		 * pagetables) with GFP_KERNEL, yet we are likely to be under
> > > >  		 * GFP_NOFS context here. Hence we need to tell memory reclaim
> > > > -		 * that we are in such a context via PF_MEMALLOC_NOIO to prevent
> > > > +		 * that we are in such a context via PF_MEMALLOC_NOFS to prevent
> > > >  		 * memory reclaim re-entering the filesystem here and
> > > >  		 * potentially deadlocking.
> > > >  		 */
> > > 
> > > This comment feels out of date ... how about:
> > 
> > which part is out of date?
> > 
> > > 
> > > 		/*
> > > 		 * vm_map_ram will allocate auxiliary structures (eg page
> > > 		 * tables) with GFP_KERNEL.  If that tries to reclaim memory
> > > 		 * by calling back into this filesystem, we may deadlock.
> > > 		 * Prevent that by setting the NOFS flag.
> > > 		 */
> > 
> > dunno, the previous wording seems clear enough to me. Maybe little bit
> > more chatty than yours but I am not sure this is worth changing.
> 
> I prefer to keep the "...yet we are likely to be under GFP_NOFS..."
> wording of the old comment because it captures the uncertainty of
> whether or not we actually are already under NOFS.  If someone actually
> has audited this code well enough to know for sure then yes let's change
> the comment, but I haven't gone that far.

I believe we can drop the memalloc_nofs_save then as well because either
we are called from a potentially dangerous context and thus we are in
the nofs scope we we do not need the protection at all.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
