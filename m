Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C3E406B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 23:48:38 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so95951177pdb.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 20:48:38 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id xq5si6839605pab.85.2015.03.19.20.48.35
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 20:48:36 -0700 (PDT)
Date: Fri, 20 Mar 2015 14:48:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150320034820.GH28621@dastard>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150319124441.GC12466@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> On Thu 19-03-15 18:14:39, Dave Chinner wrote:
> > On Wed, Mar 18, 2015 at 03:55:28PM +0100, Michal Hocko wrote:
> > > On Wed 18-03-15 10:44:11, Rik van Riel wrote:
> > > > On 03/18/2015 10:09 AM, Michal Hocko wrote:
> > > > > page_cache_read has been historically using page_cache_alloc_cold to
> > > > > allocate a new page. This means that mapping_gfp_mask is used as the
> > > > > base for the gfp_mask. Many filesystems are setting this mask to
> > > > > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > > > > however, not called from the fs layer 
> > > > 
> > > > Is that true for filesystems that have directories in
> > > > the page cache?
> > > 
> > > I haven't found any explicit callers of filemap_fault except for ocfs2
> > > and ceph and those seem OK to me. Which filesystems you have in mind?
> > 
> > Just about every major filesystem calls filemap_fault through the
> > .fault callout.
> 
> That is right but the callback is called from the VM layer where we
> obviously do not take any fs locks (we are holding only mmap_sem
> for reading).
> Those who call filemap_fault directly (ocfs2 and ceph) and those
> who call the callback directly: qxl_ttm_fault, radeon_ttm_fault,
> kernfs_vma_fault, shm_fault seem to be safe from the reclaim recursion
> POV. radeon_ttm_fault takes a lock for reading but that one doesn't seem
> to be used from the reclaim context.
> 
> Or did I miss your point? Are you concerned about some fs overloading
> filemap_fault and do some locking before delegating to filemap_fault?

The latter:

https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b

> > GFP_KERNEL allocation for mappings is simply wrong. All mapping
> > allocations where the caller cannot pass a gfp_mask need to obey
> > the mapping_gfp_mask that is set by the mapping owner....
> 
> Hmm, I thought this is true only when the function might be called from
> the fs path.

How do you know in, say, mpage_readpages, you aren't being called
from a fs path that holds locks? e.g. we can get there from ext4
doing readdir, so it is holding an i_mutex lock at that point.

Many other paths into mpages_readpages don't hold locks, but there
are some that do, and those that do need functionals like this to
obey the mapping_gfp_mask because it is set appropriately for the
allocation context of the inode that owns the mapping....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
