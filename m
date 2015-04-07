Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id F220C6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 08:16:12 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so53953426wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 05:16:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id em6si12558037wib.17.2015.04.07.05.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 05:16:11 -0700 (PDT)
Date: Tue, 7 Apr 2015 14:16:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150407121607.GD7935@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <55098F3B.7070000@redhat.com>
 <20150318145528.GK17241@dhcp22.suse.cz>
 <20150319071439.GE28621@dastard>
 <20150319124441.GC12466@dhcp22.suse.cz>
 <20150320034820.GH28621@dastard>
 <20150326095302.GA15257@dhcp22.suse.cz>
 <20150326214354.GG28129@dastard>
 <20150330082218.GA3909@dhcp22.suse.cz>
 <20150331214651.GB8465@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150331214651.GB8465@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 01-04-15 08:46:51, Dave Chinner wrote:
[...]
> GFP_NOFS has also been required in the mapping mask in the past
> because reclaim from page cache allocation points had a nasty habit
> of blowing the stack.

Yeah I remember some scary traces but we are talking about the page
fault path and we definitely have to handle GFP_IOFS allocations
there. We cannot use GFP_NOFS as a workaround e.g. for anonymous pages.

[...]
> > From 292cfcbbe18b2afc8d2bc0cf568ca4c5842d4c8f Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Fri, 27 Mar 2015 13:33:51 +0100
> > Subject: [PATCH] mm: Allow GFP_IOFS for page_cache_read page cache allocation
> > 
> > page_cache_read has been historically using page_cache_alloc_cold to
> > allocate a new page. This means that mapping_gfp_mask is used as the
> > base for the gfp_mask. Many filesystems are setting this mask to
> > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > however, not called from the fs layera directly so it doesn't need this
> > protection normally.
> 
> It can be called from a page fault while copying into or out of a
> user buffer from a read()/write() system call. Hence the page fault
> can be nested inside filesystem locks.

As pointed above, the user buffer might be an anonymous memory as well
and so we have to be able to handle GFP_IOFS allocations from the page
fault without recalaim deadlocks. Besides that we are allocating page
tables which are GFP_KERNEL and probably some more. So either we are
broken by definition or GFP_IOFS is safe from under i_mutex lock. My
code inspection suggests the later but the code is really hard to follow
and dependencies might be not direct.
I remember that nfs_release_page would be prone to i_mutex deadlock
when server and client are on the same machine. But this shouldn't be a
problem anymore because the amount of time client waits for the server is
limited (9590544694bec).
I might be missing other places of course but to me it sounds that
GFP_IOFS must be safe under _some_ FS locks and i_mutex is one of them.

> Indeed, the canonical reason
> for why we can't take the i_mutex in the page fault path is exactly
> this. i.e. the user buffer might be a mmap()d region of the same
> file and so we have mmap_sem/i_mutex inversion issues.
>
> This is the same case - we can be taking page faults with filesystem
> locks held, and that means we've got problems if the page fault then
> recurses back into the filesystem and trips over those locks...

Yeah, I am familiar with the generic meaning of GFP_NOFS flags. I just
think that it is used as a too big of a hammer here (all FS locks is
just too broad).
The page fault is not GFP_NOFS safe now and it never has been (anonymous
pages are not GFP_NOFS, page tables etc...). And I am afraid we cannot
simply change it to use GFP_NOFS all over. Are there any other fs locks
(except for i_mutex) which might be held while doing {get,put}_user or
get_user_pages? I haven't found many instances in the fs/ but there is a
lot of done via indirection.

That being said I think the patch should be safe and an improvement over
the current state. Unless I am missing something obvious or there are
other objections I will repost it along with the other clean up patch
later this week.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
