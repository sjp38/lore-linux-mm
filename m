Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA0726B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 08:44:45 -0400 (EDT)
Received: by wetk59 with SMTP id k59so56239376wet.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 05:44:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eo8si2181478wjd.58.2015.03.19.05.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 05:44:43 -0700 (PDT)
Date: Thu, 19 Mar 2015 13:44:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150319124441.GC12466@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150319071439.GE28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-03-15 18:14:39, Dave Chinner wrote:
> On Wed, Mar 18, 2015 at 03:55:28PM +0100, Michal Hocko wrote:
> > On Wed 18-03-15 10:44:11, Rik van Riel wrote:
> > > On 03/18/2015 10:09 AM, Michal Hocko wrote:
> > > > page_cache_read has been historically using page_cache_alloc_cold to
> > > > allocate a new page. This means that mapping_gfp_mask is used as the
> > > > base for the gfp_mask. Many filesystems are setting this mask to
> > > > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > > > however, not called from the fs layer 
> > > 
> > > Is that true for filesystems that have directories in
> > > the page cache?
> > 
> > I haven't found any explicit callers of filemap_fault except for ocfs2
> > and ceph and those seem OK to me. Which filesystems you have in mind?
> 
> Just about every major filesystem calls filemap_fault through the
> .fault callout.

That is right but the callback is called from the VM layer where we
obviously do not take any fs locks (we are holding only mmap_sem
for reading).
Those who call filemap_fault directly (ocfs2 and ceph) and those
who call the callback directly: qxl_ttm_fault, radeon_ttm_fault,
kernfs_vma_fault, shm_fault seem to be safe from the reclaim recursion
POV. radeon_ttm_fault takes a lock for reading but that one doesn't seem
to be used from the reclaim context.

Or did I miss your point? Are you concerned about some fs overloading
filemap_fault and do some locking before delegating to filemap_fault?

> C symbol: filemap_fault
> 
>   File           Function            Line
>   0 9p/vfs_file.c  <global>             831 .fault = filemap_fault,
>   1 9p/vfs_file.c  <global>             838 .fault = filemap_fault,
>   2 btrfs/file.c   <global>            2081 .fault = filemap_fault,
>   3 cifs/file.c    <global>            3242 .fault = filemap_fault,
>   4 ext4/file.c    <global>             215 .fault = filemap_fault,
>   5 f2fs/file.c    <global>              93 .fault = filemap_fault,
>   6 fuse/file.c    <global>            2062 .fault = filemap_fault,
>   7 gfs2/file.c    <global>             498 .fault = filemap_fault,
>   8 nfs/file.c     <global>             653 .fault = filemap_fault,
>   9 nilfs2/file.c  <global>             128 .fault = filemap_fault,
>   a ubifs/file.c   <global>            1536 .fault = filemap_fault,
>   b xfs/xfs_file.c <global>            1420 .fault = filemap_fault,
> 
> 
> > Btw. how would that work as we already have GFP_KERNEL allocation few
> > lines below?
> 
> GFP_KERNEL allocation for mappings is simply wrong. All mapping
> allocations where the caller cannot pass a gfp_mask need to obey
> the mapping_gfp_mask that is set by the mapping owner....

Hmm, I thought this is true only when the function might be called from
the fs path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
