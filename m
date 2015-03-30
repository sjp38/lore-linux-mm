Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D1BD76B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 04:22:23 -0400 (EDT)
Received: by wixm2 with SMTP id m2so80173003wix.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 01:22:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si16763365wju.8.2015.03.30.01.22.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 01:22:22 -0700 (PDT)
Date: Mon, 30 Mar 2015 10:22:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150330082218.GA3909@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150326095302.GA15257@dhcp22.suse.cz>
 <20150326214354.GG28129@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326214354.GG28129@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 27-03-15 08:43:54, Dave Chinner wrote:
> On Thu, Mar 26, 2015 at 10:53:02AM +0100, Michal Hocko wrote:
> > On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> > > On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> > [...]
> > > > Or did I miss your point? Are you concerned about some fs overloading
> > > > filemap_fault and do some locking before delegating to filemap_fault?
> > > 
> > > The latter:
> > > 
> > > https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b
> > 
> > Hmm. I am completely unfamiliar with the xfs code but my reading of
> > 964aa8d9e4d3..723cac484733 is that the newly introduced lock should be
> > OK from the reclaim recursion POV. It protects against truncate and
> > punch hole, right? Or are there any internal paths which I am missing
> > and would cause problems if we do GFP_FS with XFS_MMAPLOCK_SHARED held?
> 
> It might be OK, but you're only looking at the example I gave you,
> not the fundamental issue it demonstrates. That is: filesystems may
> have *internal dependencies that are unknown to the page cache or mm
> subsystem*. Hence the page cache or mm allocations cannot
> arbitrarily ignore allocation constraints the filesystem assigns to
> mapping operations....

I fully understand that. I am just trying to understand what are the
real requirements from filesystems wrt filemap_fault. mapping gfp mask is
not usable much for that because e.g. xfs has GFP_NOFS set for the whole
inode life AFAICS. And it seems that this context is not really required
even after the recent code changes.
We can add gfp_mask into struct vm_fault and initialize it to
mapping_gfp_mask | GFP_IOFS and .fault() callback might overwrite it. This
would be cleaner than unconditional gfp manipulation (the patch below).

But we are in a really hard position if the GFP_NOFS context is really
required here. We shouldn't really trigger OOM killer because that could
be premature and way too disruptive. We can retry the page fault or the
allocation but that both sound suboptimal to me.

Do you have any other suggestions?

This hasn't been tested yet it just shows the idea mentioned above.
---
