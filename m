Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9D06B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 16:22:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so221544080pga.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 13:22:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si20179060ple.182.2017.03.06.13.22.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 13:22:15 -0800 (PST)
Date: Mon, 6 Mar 2017 13:22:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] mm: introduce memalloc_nofs_{save,restore} API
Message-Id: <20170306132214.1769368301d9e671e1bc68be@linux-foundation.org>
In-Reply-To: <20170306131408.9828-5-mhocko@kernel.org>
References: <20170306131408.9828-1-mhocko@kernel.org>
	<20170306131408.9828-5-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon,  6 Mar 2017 14:14:05 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> GFP_NOFS context is used for the following 5 reasons currently
> 	- to prevent from deadlocks when the lock held by the allocation
> 	  context would be needed during the memory reclaim
> 	- to prevent from stack overflows during the reclaim because
> 	  the allocation is performed from a deep context already
> 	- to prevent lockups when the allocation context depends on
> 	  other reclaimers to make a forward progress indirectly
> 	- just in case because this would be safe from the fs POV
> 	- silence lockdep false positives
> 
> Unfortunately overuse of this allocation context brings some problems
> to the MM. Memory reclaim is much weaker (especially during heavy FS
> metadata workloads), OOM killer cannot be invoked because the MM layer
> doesn't have enough information about how much memory is freeable by the
> FS layer.
> 
> In many cases it is far from clear why the weaker context is even used
> and so it might be used unnecessarily. We would like to get rid of
> those as much as possible. One way to do that is to use the flag in
> scopes rather than isolated cases. Such a scope is declared when really
> necessary, tracked per task and all the allocation requests from within
> the context will simply inherit the GFP_NOFS semantic.
> 
> Not only this is easier to understand and maintain because there are
> much less problematic contexts than specific allocation requests, this
> also helps code paths where FS layer interacts with other layers (e.g.
> crypto, security modules, MM etc...) and there is no easy way to convey
> the allocation context between the layers.
> 
> Introduce memalloc_nofs_{save,restore} API to control the scope
> of GFP_NOFS allocation context. This is basically copying
> memalloc_noio_{save,restore} API we have for other restricted allocation
> context GFP_NOIO. The PF_MEMALLOC_NOFS flag already exists and it is
> just an alias for PF_FSTRANS which has been xfs specific until recently.
> There are no more PF_FSTRANS users anymore so let's just drop it.
> 
> PF_MEMALLOC_NOFS is now checked in the MM layer and drops __GFP_FS
> implicitly same as PF_MEMALLOC_NOIO drops __GFP_IO. memalloc_noio_flags
> is renamed to current_gfp_context because it now cares about both
> PF_MEMALLOC_NOFS and PF_MEMALLOC_NOIO contexts. Xfs code paths preserve
> their semantic. kmem_flags_convert() doesn't need to evaluate the flag
> anymore.
> 
> This patch shouldn't introduce any functional changes.
> 
> Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
> usage as much as possible and only use a properly documented
> memalloc_nofs_{save,restore} checkpoints where they are appropriate.
> 
> ....
>
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -210,8 +210,16 @@ struct vm_area_struct;
>   *
>   * GFP_NOIO will use direct reclaim to discard clean pages or slab pages
>   *   that do not require the starting of any physical IO.
> + *   Please try to avoid using this flag directly and instead use
> + *   memalloc_noio_{save,restore} to mark the whole scope which cannot
> + *   perform any IO with a short explanation why. All allocation requests
> + *   will inherit GFP_NOIO implicitly.
>   *
>   * GFP_NOFS will use direct reclaim but will not use any filesystem interfaces.
> + *   Please try to avoid using this flag directly and instead use
> + *   memalloc_nofs_{save,restore} to mark the whole scope which cannot/shouldn't
> + *   recurse into the FS layer with a short explanation why. All allocation
> + *   requests will inherit GFP_NOFS implicitly.

I wonder if these are worth a checkpatch rule.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
