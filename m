Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A520E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:12:35 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so73399354pdb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:12:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d15si2500183pdl.13.2015.03.19.04.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 04:12:34 -0700 (PDT)
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache inpage_cache_read
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
	<55098F3B.7070000@redhat.com>
	<20150318145528.GK17241@dhcp22.suse.cz>
	<20150319071439.GE28621@dastard>
In-Reply-To: <20150319071439.GE28621@dastard>
Message-Id: <201503192011.BAH65682.MVQJFOtSLOFFOH@I-love.SAKURA.ne.jp>
Date: Thu, 19 Mar 2015 20:11:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, mhocko@suse.cz
Cc: riel@redhat.com, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mgorman@suse.de, neilb@suse.de, sage@inktank.com, mfasheh@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner wrote:
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
> 
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
> 

Is there any chance to annotate which GFP flag needs to be used like
https://lkml.org/lkml/2015/3/17/507 ?

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
