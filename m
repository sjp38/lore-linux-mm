Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5DBE56B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 09:50:12 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so177776074wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 06:50:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si3813382wix.25.2015.08.11.06.50.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 06:50:10 -0700 (PDT)
Date: Tue, 11 Aug 2015 15:50:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
Message-ID: <20150811135004.GC2659@quack.suse.cz>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150811081909.GD2650@quack.suse.cz>
 <20150811093708.GB906@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150811093708.GB906@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Tue 11-08-15 19:37:08, Dave Chinner wrote:
> > > The patch below tries to recover some scalability for DAX by introducing
> > > per-mapping range lock.
> > 
> > So this grows noticeably (3 longs if I'm right) struct address_space and
> > thus struct inode just for DAX. That looks like a waste but I don't see an
> > easy solution.
> > 
> > OTOH filesystems in normal mode might want to use the range lock as well to
> > provide truncate / punch hole vs page fault exclusion (XFS already has a
> > private rwsem for this and ext4 needs something as well) and at that point
> > growing generic struct inode would be acceptable for me.
> 
> It sounds to me like the way DAX has tried to solve this race is the
> wrong direction. We really need to drive the truncate/page fault
> serialisation higher up the stack towards the filesystem, not deeper
> into the mm subsystem where locking is greatly limited.
> 
> As Jan mentions, we already have this serialisation in XFS, and I
> think it would be better first step to replicate that locking model
> in each filesystem that is supports DAX. I think this is a better
> direction because it moves towards solving a whole class of problems
> fileystem face with page fault serialisation, not just for DAX.

Well, but at least in XFS you take XFS_MMAPLOCK in shared mode for the
fault / page_mkwrite callback so it doesn't provide the exclusion necessary
for DAX which needs exclusive access to the page given range in the page
cache. And replacing i_mmap_lock with fs-private mmap rwsem is a moot
excercise (at least from DAX POV).

So regardless whether the lock will be a fs-private one or in
address_space, DAX needs something like the range lock Kirill suggested.
Having the range lock in fs-private part of inode has the advantage that
only filesystems supporting DAX / punch hole will pay the memory overhead.
OTOH most major filesystems need it so the savings would be IMO noticeable
only for tiny systems using special fs etc. So I'm undecided whether
putting the lock in address_space and doing the locking in generic
pagefault / truncate helpers is a better choice or not.
 
								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
