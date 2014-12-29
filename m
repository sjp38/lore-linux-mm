Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 20E606B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 12:40:34 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so19349230wgg.25
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:40:33 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id r3si60407265wix.30.2014.12.29.09.40.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 09:40:33 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id k14so19473139wgh.1
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:40:33 -0800 (PST)
Date: Mon, 29 Dec 2014 18:40:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: get rid of radix tree gfp mask for pagecache_get_page
 (was: Re: How to handle TIF_MEMDIE stalls?)
Message-ID: <20141229174030.GD32618@dhcp22.suse.cz>
References: <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
 <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220223504.GI15665@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun 21-12-14 09:35:04, Dave Chinner wrote:
[...]
> Oh, boy.
> 
> struct page *grab_cache_page_write_begin(struct address_space *mapping,
>                                         pgoff_t index, unsigned flags)
> {
>         struct page *page;
>         int fgp_flags = FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;
> 
>         if (flags & AOP_FLAG_NOFS)
>                 fgp_flags |= FGP_NOFS;
> 
>         page = pagecache_get_page(mapping, index, fgp_flags,
>                         mapping_gfp_mask(mapping),
>                         GFP_KERNEL);
>         if (page)
>                 wait_for_stable_page(page);
> 
>         return page;
> }
> 
> There are *3* different memory allocation controls passed to
> pagecache_get_page. The first is via AOP_FLAG_NOFS, where the caller
> explicitly says this allocation is in filesystem context with locks
> held, and so all allocations need to be done in GFP_NOFS context.
> This is used to override the second and third gfp parameters.
> 
> The second is mapping_gfp_mask(mapping), which is the *default
> allocation context* the filesystem wants the page cache to use for
> allocating pages to the mapping.
> 
> The third is a hard coded GFP_KERNEL, which is used for radix tree
> node allocation.
> 
> Why are there separate allocation contexts for the radix tree nodes
> and the page cache pages when they are done under *exactly the same
> caller context*? Either we are allowed to recurse into the
> filesystem or we aren't, and the inode mapping mask defines that
> context for all page cache allocations, not just the pages
> themselves.
> 
> And to point out how many filesystems this affects,
> the loop device, btrfs, f2fs, gfs2, jfs, logfs, nil2fs, reiserfs
> and XFS all use this mapping default to clear __GFP_FS from
> page cache allocations. Only ext4 and gfs2 use AOP_FLAG_NOFS in
> their ->write_begin callouts to prevent recusrion.
> 
> IOWs, grab_cache_page_write_begin/pagecache_get_page multiple
> allocation contexts are just wrong.  It does not match the way
> filesystems are informing the page cache of allocation context to
> avoid recursion (for avoiding stack overflow and/or deadlock).
> AOP_FLAG_NOFS should go away, and all filesystems should modify the
> mapping gfp mask to set their allocation context. If should be used
> *everywhere* pages are allocated into the page cache, and for all
> allocations related to tracking those allocated pages.

I guess the following would be a first simple step to remove the bug you
are mentioning above. It would be simple enough to put into stable as
well. What do you think?
---
