Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E1E856B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 18:51:44 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so121312766pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:51:44 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id p9si11503410pdi.204.2015.03.20.15.51.42
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 15:51:44 -0700 (PDT)
Date: Sat, 21 Mar 2015 09:51:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150320225139.GL28621@dastard>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150320131453.GA4821@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320131453.GA4821@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 20, 2015 at 02:14:53PM +0100, Michal Hocko wrote:
> On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> > On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> > > > allocations where the caller cannot pass a gfp_mask need to obey
> > > > the mapping_gfp_mask that is set by the mapping owner....
> > > 
> > > Hmm, I thought this is true only when the function might be called from
> > > the fs path.
> > 
> > How do you know in, say, mpage_readpages, you aren't being called
> > from a fs path that holds locks? e.g. we can get there from ext4
> > doing readdir, so it is holding an i_mutex lock at that point.
> > 
> > Many other paths into mpages_readpages don't hold locks, but there
> > are some that do, and those that do need functionals like this to
> > obey the mapping_gfp_mask because it is set appropriately for the
> > allocation context of the inode that owns the mapping....
> 
> What about the following?
> ---
> From 5d905cb291138d61bbab056845d6e53bc4451ec8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 19 Mar 2015 14:56:56 +0100
> Subject: [PATCH 1/2] mm: do not ignore mapping_gfp_mask in page cache
>  allocation paths

Looks reasonable, though I though there were more places that that
in the mapping paths that need to be careful...

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
