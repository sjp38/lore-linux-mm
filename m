Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE6C6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:14:57 -0400 (EDT)
Received: by wegp1 with SMTP id p1so81846456weg.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 06:14:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he10si6963659wjc.188.2015.03.20.06.14.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 06:14:55 -0700 (PDT)
Date: Fri, 20 Mar 2015 14:14:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150320131453.GA4821@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320034820.GH28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> > On Thu 19-03-15 18:14:39, Dave Chinner wrote:
> > > On Wed, Mar 18, 2015 at 03:55:28PM +0100, Michal Hocko wrote:
> > > > On Wed 18-03-15 10:44:11, Rik van Riel wrote:
> > > > > On 03/18/2015 10:09 AM, Michal Hocko wrote:
> > > > > > page_cache_read has been historically using page_cache_alloc_cold to
> > > > > > allocate a new page. This means that mapping_gfp_mask is used as the
> > > > > > base for the gfp_mask. Many filesystems are setting this mask to
> > > > > > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > > > > > however, not called from the fs layer 
> > > > > 
> > > > > Is that true for filesystems that have directories in
> > > > > the page cache?
> > > > 
> > > > I haven't found any explicit callers of filemap_fault except for ocfs2
> > > > and ceph and those seem OK to me. Which filesystems you have in mind?
> > > 
> > > Just about every major filesystem calls filemap_fault through the
> > > .fault callout.
> > 
> > That is right but the callback is called from the VM layer where we
> > obviously do not take any fs locks (we are holding only mmap_sem
> > for reading).
> > Those who call filemap_fault directly (ocfs2 and ceph) and those
> > who call the callback directly: qxl_ttm_fault, radeon_ttm_fault,
> > kernfs_vma_fault, shm_fault seem to be safe from the reclaim recursion
> > POV. radeon_ttm_fault takes a lock for reading but that one doesn't seem
> > to be used from the reclaim context.
> > 
> > Or did I miss your point? Are you concerned about some fs overloading
> > filemap_fault and do some locking before delegating to filemap_fault?
> 
> The latter:
> 
> https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b

I will have a look at the code to see what we can do about it.
 
> > > GFP_KERNEL allocation for mappings is simply wrong. All mapping
> > > allocations where the caller cannot pass a gfp_mask need to obey
> > > the mapping_gfp_mask that is set by the mapping owner....
> > 
> > Hmm, I thought this is true only when the function might be called from
> > the fs path.
> 
> How do you know in, say, mpage_readpages, you aren't being called
> from a fs path that holds locks? e.g. we can get there from ext4
> doing readdir, so it is holding an i_mutex lock at that point.
> 
> Many other paths into mpages_readpages don't hold locks, but there
> are some that do, and those that do need functionals like this to
> obey the mapping_gfp_mask because it is set appropriately for the
> allocation context of the inode that owns the mapping....

What about the following?
---
