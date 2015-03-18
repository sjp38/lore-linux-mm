Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id DB72B6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:43:06 -0400 (EDT)
Received: by wixw10 with SMTP id w10so65070571wix.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:43:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ca6si29094773wjc.38.2015.03.18.07.43.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:43:05 -0700 (PDT)
Date: Wed, 18 Mar 2015 15:43:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150318144304.GJ17241@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
 <20150318143847.GC3087@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150318143847.GC3087@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-03-15 14:38:47, Mel Gorman wrote:
> On Wed, Mar 18, 2015 at 03:09:26PM +0100, Michal Hocko wrote:
> > page_cache_read has been historically using page_cache_alloc_cold to
> > allocate a new page. This means that mapping_gfp_mask is used as the
> > base for the gfp_mask. Many filesystems are setting this mask to
> > GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> > however, not called from the fs layer so it doesn't need this
> > protection. Even ceph and ocfs2 which call filemap_fault from their
> > fault handlers seem to be OK because they are not taking any fs lock
> > before invoking generic implementation.
> > 
> > The protection might be even harmful. There is a strong push to fail
> > GFP_NOFS allocations rather than loop within allocator indefinitely with
> > a very limited reclaim ability. Once we start failing those requests
> > the OOM killer might be triggered prematurely because the page cache
> > allocation failure is propagated up the page fault path and end up in
> > pagefault_out_of_memory.
> > 
> > Use GFP_KERNEL mask instead because it is safe from the reclaim
> > recursion POV. We are already doing GFP_KERNEL allocations down
> > add_to_page_cache_lru path.
> > 
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> I'm very far behind after LSF/MM so do not know where this came out of
> but it loses addressing restriction hints from the driver such as
> 
> drivers/gpu/drm/gma500/gem.c: mapping_set_gfp_mask(r->gem.filp->f_mapping, GFP_KERNEL | __GFP_DMA32);

OK, I have missed these drivers. Scratch the patch for now I will think
about it more.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
