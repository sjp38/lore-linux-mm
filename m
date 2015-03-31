Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C702F6B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 17:46:56 -0400 (EDT)
Received: by pddn5 with SMTP id n5so33330143pdd.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 14:46:56 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id e4si21076921pdp.245.2015.03.31.14.46.54
        for <linux-mm@kvack.org>;
        Tue, 31 Mar 2015 14:46:55 -0700 (PDT)
Date: Wed, 1 Apr 2015 08:46:51 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150331214651.GB8465@dastard>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150326095302.GA15257@dhcp22.suse.cz>
 <20150326214354.GG28129@dastard>
 <20150330082218.GA3909@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330082218.GA3909@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 30, 2015 at 10:22:18AM +0200, Michal Hocko wrote:
> On Fri 27-03-15 08:43:54, Dave Chinner wrote:
> > On Thu, Mar 26, 2015 at 10:53:02AM +0100, Michal Hocko wrote:
> > > On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> > > > On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > Or did I miss your point? Are you concerned about some fs overloading
> > > > > filemap_fault and do some locking before delegating to filemap_fault?
> > > > 
> > > > The latter:
> > > > 
> > > > https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b
> > > 
> > > Hmm. I am completely unfamiliar with the xfs code but my reading of
> > > 964aa8d9e4d3..723cac484733 is that the newly introduced lock should be
> > > OK from the reclaim recursion POV. It protects against truncate and
> > > punch hole, right? Or are there any internal paths which I am missing
> > > and would cause problems if we do GFP_FS with XFS_MMAPLOCK_SHARED held?
> > 
> > It might be OK, but you're only looking at the example I gave you,
> > not the fundamental issue it demonstrates. That is: filesystems may
> > have *internal dependencies that are unknown to the page cache or mm
> > subsystem*. Hence the page cache or mm allocations cannot
> > arbitrarily ignore allocation constraints the filesystem assigns to
> > mapping operations....
> 
> I fully understand that. I am just trying to understand what are the
> real requirements from filesystems wrt filemap_fault. mapping gfp mask is
> not usable much for that because e.g. xfs has GFP_NOFS set for the whole
> inode life AFAICS. And it seems that this context is not really required
> even after the recent code changes.
> We can add gfp_mask into struct vm_fault and initialize it to
> mapping_gfp_mask | GFP_IOFS and .fault() callback might overwrite it. This
> would be cleaner than unconditional gfp manipulation (the patch below).
> 
> But we are in a really hard position if the GFP_NOFS context is really
> required here. We shouldn't really trigger OOM killer because that could
> be premature and way too disruptive. We can retry the page fault or the
> allocation but that both sound suboptimal to me.

GFP_NOFS has also been required in the mapping mask in the past
because reclaim from page cache allocation points had a nasty habit
of blowing the stack. In XFS, we replaced AOP_FLAG_NOFS calls with
the GFP_NOFS mapping mask because the AOP_FLAG_NOFS didn't give us
the coverage needed on mapping allocation calls to prevent the
problems being reported.

Yes, we now have a larger stack, but as I've said in the past,
GFP_NOFS is used for several different reasons by subsystems -
recursion can be bad in more ways than one, and GFP_NOFS is the only
hammer we have...

> This hasn't been tested yet it just shows the idea mentioned above.
> ---
> From 292cfcbbe18b2afc8d2bc0cf568ca4c5842d4c8f Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 27 Mar 2015 13:33:51 +0100
> Subject: [PATCH] mm: Allow GFP_IOFS for page_cache_read page cache allocation
> 
> page_cache_read has been historically using page_cache_alloc_cold to
> allocate a new page. This means that mapping_gfp_mask is used as the
> base for the gfp_mask. Many filesystems are setting this mask to
> GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> however, not called from the fs layera directly so it doesn't need this
> protection normally.

It can be called from a page fault while copying into or out of a
user buffer from a read()/write() system call. Hence the page fault
can be nested inside filesystem locks. Indeed, the canonical reason
for why we can't take the i_mutex in the page fault path is exactly
this. i.e. the user buffer might be a mmap()d region of the same
file and so we have mmap_sem/i_mutex inversion issues.

This is the same case - we can be taking page faults with filesystem
locks held, and that means we've got problems if the page fault then
recurses back into the filesystem and trips over those locks...

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
