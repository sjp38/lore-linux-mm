Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D10066B025E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:44:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so20724194wmg.4
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:44:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j140si8906444wmg.23.2017.02.06.09.44.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 09:44:19 -0800 (PST)
Date: Mon, 6 Feb 2017 18:44:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20170206174415.GA20731@dhcp22.suse.cz>
References: <20170206140718.16222-1-mhocko@kernel.org>
 <20170206140718.16222-5-mhocko@kernel.org>
 <20170206153923.GL2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206153923.GL2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 06-02-17 07:39:23, Matthew Wilcox wrote:
> On Mon, Feb 06, 2017 at 03:07:16PM +0100, Michal Hocko wrote:
> > +++ b/fs/xfs/xfs_buf.c
> > @@ -442,17 +442,17 @@ _xfs_buf_map_pages(
> >  		bp->b_addr = NULL;
> >  	} else {
> >  		int retried = 0;
> > -		unsigned noio_flag;
> > +		unsigned nofs_flag;
> >  
> >  		/*
> >  		 * vm_map_ram() will allocate auxillary structures (e.g.
> >  		 * pagetables) with GFP_KERNEL, yet we are likely to be under
> >  		 * GFP_NOFS context here. Hence we need to tell memory reclaim
> > -		 * that we are in such a context via PF_MEMALLOC_NOIO to prevent
> > +		 * that we are in such a context via PF_MEMALLOC_NOFS to prevent
> >  		 * memory reclaim re-entering the filesystem here and
> >  		 * potentially deadlocking.
> >  		 */
> 
> This comment feels out of date ... how about:

which part is out of date?

> 
> 		/*
> 		 * vm_map_ram will allocate auxiliary structures (eg page
> 		 * tables) with GFP_KERNEL.  If that tries to reclaim memory
> 		 * by calling back into this filesystem, we may deadlock.
> 		 * Prevent that by setting the NOFS flag.
> 		 */

dunno, the previous wording seems clear enough to me. Maybe little bit
more chatty than yours but I am not sure this is worth changing.

> 
> > -		noio_flag = memalloc_noio_save();
> > +		nofs_flag = memalloc_nofs_save();
> >  		do {
> >  			bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> >  						-1, PAGE_KERNEL);
> 
> Also, I think it shows that this is the wrong place in XFS to be calling
> memalloc_nofs_save().  I'm not arguing against including this patch;
> it's a step towards where we want to be.  I also don't know XFS well
> enough to know where to set that flag ;-)  Presumably when we start a
> transaction ... ?

Yes that is what I would like to achieve longterm. And the reason why I
didn't want to mimic this pattern in kvmalloc as some have suggested.
It just takes much more time to get there from the past experience and
we should really start somewhere.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
