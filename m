Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 718E06B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 04:53:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so83224031wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 01:53:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si17518469wje.195.2015.11.12.01.53.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Nov 2015 01:53:05 -0800 (PST)
Date: Thu, 12 Nov 2015 10:53:01 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Allow GFP_IOFS for page_cache_read page cache
 allocation
Message-ID: <20151112095301.GA25265@quack.suse.cz>
References: <1447251233-14449-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447251233-14449-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com, ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed 11-11-15 15:13:53, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> page_cache_read has been historically using page_cache_alloc_cold to
> allocate a new page. This means that mapping_gfp_mask is used as the
> base for the gfp_mask. Many filesystems are setting this mask to
> GFP_NOFS to prevent from fs recursion issues. page_cache_read is
> called from the vm_operations_struct::fault() context during the page
> fault. This context doesn't need the reclaim protection normally.
> 
> ceph and ocfs2 which call filemap_fault from their fault handlers
> seem to be OK because they are not taking any fs lock before invoking
> generic implementation. xfs which takes XFS_MMAPLOCK_SHARED is safe
> from the reclaim recursion POV because this lock serializes truncate
> and punch hole with the page faults and it doesn't get involved in the
> reclaim.
> 
> There is simply no reason to deliberately use a weaker allocation
> context when a __GFP_FS | __GFP_IO can be used. The GFP_NOFS
> protection might be even harmful. There is a push to fail GFP_NOFS
> allocations rather than loop within allocator indefinitely with a
> very limited reclaim ability. Once we start failing those requests
> the OOM killer might be triggered prematurely because the page cache
> allocation failure is propagated up the page fault path and end up in
> pagefault_out_of_memory.
> 
> We cannot play with mapping_gfp_mask directly because that would be racy
> wrt. parallel page faults and it might interfere with other users who
> really rely on NOFS semantic from the stored gfp_mask. The mask is also
> inode proper so it would even be a layering violation. What we can do
> instead is to push the gfp_mask into struct vm_fault and allow fs layer
> to overwrite it should the callback need to be called with a different
> allocation context.
> 
> Initialize the default to (mapping_gfp_mask | __GFP_FS | __GFP_IO)
> because this should be safe from the page fault path normally. Why do we
> care about mapping_gfp_mask at all then? Because this doesn't hold only
> reclaim protection flags but it also might contain zone and movability
> restrictions (GFP_DMA32, __GFP_MOVABLE and others) so we have to respect
> those.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this has been posted previously as a part of larger GFP_NOFS related
> patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
> but I think it makes sense to discuss it even out of that scope.
> 
> I would like to hear FS and other MM people about the proposed interface.
> Using mapping_gfp_mask blindly doesn't sound good to me and vm_fault
> looks like a proper channel to communicate between MM and FS layers.
> 
> Comments? Are there any better ideas?

Makes sense to me and the filesystems I know should be fine with this
(famous last words ;). Feel free to add:

Acked-by: Jan Kara <jack@suse.com>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
