Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E77696B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:44:10 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so75053738pdb.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:44:10 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ma14si22081pbc.200.2015.03.26.14.44.08
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 14:44:09 -0700 (PDT)
Date: Fri, 27 Mar 2015 08:43:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150326214354.GG28129@dastard>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150326095302.GA15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326095302.GA15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 26, 2015 at 10:53:02AM +0100, Michal Hocko wrote:
> On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> > On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> [...]
> > > Or did I miss your point? Are you concerned about some fs overloading
> > > filemap_fault and do some locking before delegating to filemap_fault?
> > 
> > The latter:
> > 
> > https://git.kernel.org/cgit/linux/kernel/git/dgc/linux-xfs.git/commit/?h=xfs-mmap-lock&id=de0e8c20ba3a65b0f15040aabbefdc1999876e6b
> 
> Hmm. I am completely unfamiliar with the xfs code but my reading of
> 964aa8d9e4d3..723cac484733 is that the newly introduced lock should be
> OK from the reclaim recursion POV. It protects against truncate and
> punch hole, right? Or are there any internal paths which I am missing
> and would cause problems if we do GFP_FS with XFS_MMAPLOCK_SHARED held?

It might be OK, but you're only looking at the example I gave you,
not the fundamental issue it demonstrates. That is: filesystems may
have *internal dependencies that are unknown to the page cache or mm
subsystem*. Hence the page cache or mm allocations cannot
arbitrarily ignore allocation constraints the filesystem assigns to
mapping operations....

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
