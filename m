Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 306326B0073
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:02:07 -0400 (EDT)
Received: by wixw10 with SMTP id w10so34425893wix.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:02:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj3si1151744wjd.98.2015.03.23.06.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 06:02:05 -0700 (PDT)
Date: Mon, 23 Mar 2015 14:02:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150323130201.GB29084@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150320131453.GA4821@dhcp22.suse.cz>
 <20150320225139.GL28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320225139.GL28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 21-03-15 09:51:39, Dave Chinner wrote:
> On Fri, Mar 20, 2015 at 02:14:53PM +0100, Michal Hocko wrote:
> > On Fri 20-03-15 14:48:20, Dave Chinner wrote:
> > > On Thu, Mar 19, 2015 at 01:44:41PM +0100, Michal Hocko wrote:
> > > > > allocations where the caller cannot pass a gfp_mask need to obey
> > > > > the mapping_gfp_mask that is set by the mapping owner....
> > > > 
> > > > Hmm, I thought this is true only when the function might be called from
> > > > the fs path.
> > > 
> > > How do you know in, say, mpage_readpages, you aren't being called
> > > from a fs path that holds locks? e.g. we can get there from ext4
> > > doing readdir, so it is holding an i_mutex lock at that point.
> > > 
> > > Many other paths into mpages_readpages don't hold locks, but there
> > > are some that do, and those that do need functionals like this to
> > > obey the mapping_gfp_mask because it is set appropriately for the
> > > allocation context of the inode that owns the mapping....
> > 
> > What about the following?
> > ---
> > From 5d905cb291138d61bbab056845d6e53bc4451ec8 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Thu, 19 Mar 2015 14:56:56 +0100
> > Subject: [PATCH 1/2] mm: do not ignore mapping_gfp_mask in page cache
> >  allocation paths
> 
> Looks reasonable, though I though there were more places that that
> in the mapping paths that need to be careful...

I have focused on those which involve page cache allocation because
those are obvious. We might need others but I do not see them right now.

I will include this patch for the next submit after I manage to wrap my
head around up-coming xfs changes and come up with something for
page_cache_read vs OOM killer issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
