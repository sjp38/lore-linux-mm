Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44E0E6B0271
	for <linux-mm@kvack.org>; Thu, 24 May 2018 18:17:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x21-v6so1668746pfn.23
        for <linux-mm@kvack.org>; Thu, 24 May 2018 15:17:21 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id f6-v6si17844454pgc.262.2018.05.24.15.17.17
        for <linux-mm@kvack.org>;
        Thu, 24 May 2018 15:17:19 -0700 (PDT)
Date: Fri, 25 May 2018 08:17:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180524221715.GY10363@dastard>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524114341.1101-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Although the api is documented in the source code Ted has pointed out
> that there is no mention in the core-api Documentation and there are
> people looking there to find answers how to use a specific API.
> 
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: David Sterba <dsterba@suse.cz>
> Requested-by: "Theodore Y. Ts'o" <tytso@mit.edu>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yay, Documentation! :)

> ---
> 
> Hi Johnatan,
> Ted has proposed this at LSFMM and then we discussed that briefly on the
> mailing list [1]. I received some useful feedback from Darrick and Dave
> which has been (hopefully) integrated. Then the thing fall off my radar
> rediscovering it now when doing some cleanup. Could you take the patch
> please?
> 
> [1] http://lkml.kernel.org/r/20180424183536.GF30619@thunk.org
>  .../core-api/gfp_mask-from-fs-io.rst          | 55 +++++++++++++++++++
>  1 file changed, 55 insertions(+)
>  create mode 100644 Documentation/core-api/gfp_mask-from-fs-io.rst
> 
> diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
> new file mode 100644
> index 000000000000..e8b2678e959b
> --- /dev/null
> +++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
> @@ -0,0 +1,55 @@
> +=================================
> +GFP masks used from FS/IO context
> +=================================
> +
> +:Date: Mapy, 2018
> +:Author: Michal Hocko <mhocko@kernel.org>
> +
> +Introduction
> +============
> +
> +Code paths in the filesystem and IO stacks must be careful when
> +allocating memory to prevent recursion deadlocks caused by direct
> +memory reclaim calling back into the FS or IO paths and blocking on
> +already held resources (e.g. locks - most commonly those used for the
> +transaction context).
> +
> +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> +resp. __GFP_IO (note the later implies clearing the first as well) in
> +the gfp mask when calling an allocator. GFP_NOFS resp. GFP_NOIO can be
> +used as shortcut. It turned out though that above approach has led to
> +abuses when the restricted gfp mask is used "just in case" without a
> +deeper consideration which leads to problems because an excessive use
> +of GFP_NOFS/GFP_NOIO can lead to memory over-reclaim or other memory
> +reclaim issues.
> +
> +New API
> +========
> +
> +Since 4.12 we do have a generic scope API for both NOFS and NOIO context
> +``memalloc_nofs_save``, ``memalloc_nofs_restore`` resp. ``memalloc_noio_save``,
> +``memalloc_noio_restore`` which allow to mark a scope to be a critical
> +section from the memory reclaim recursion into FS/IO POV. Any allocation
> +from that scope will inherently drop __GFP_FS resp. __GFP_IO from the given
> +mask so no memory allocation can recurse back in the FS/IO.
> +
> +FS/IO code then simply calls the appropriate save function right at the
> +layer where a lock taken from the reclaim context (e.g. shrinker) and
> +the corresponding restore function when the lock is released. All that
> +ideally along with an explanation what is the reclaim context for easier
> +maintenance.

This paragraph doesn't make much sense to me. I think you're trying
to say that we should call the appropriate save function "before
locks are taken that a reclaim context (e.g a shrinker) might
require access to."

I think it's also worth making a note about recursive/nested
save/restore stacking, because it's not clear from this description
that this is allowed and will work as long as inner save/restore
calls are fully nested inside outer save/restore contexts.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
