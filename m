Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F86D6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 10:33:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e15-v6so1320078wmh.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 07:33:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189-v6sor1337365wmu.47.2018.05.24.07.33.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 07:33:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180524114341.1101-1-mhocko@kernel.org>
References: <20180424183536.GF30619@thunk.org> <20180524114341.1101-1-mhocko@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 24 May 2018 07:33:39 -0700
Message-ID: <CALvZod6CmkNgkYkSchFXsPefnuNUDjOEhPXtEUOJaeuSiXCUKg@mail.gmail.com>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu, May 24, 2018 at 4:43 AM, Michal Hocko <mhocko@kernel.org> wrote:
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

Is resp. == respectively? Why not use the full word (here and below)?

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
> +
> +What about __vmalloc(GFP_NOFS)
> +==============================
> +
> +vmalloc doesn't support GFP_NOFS semantic because there are hardcoded
> +GFP_KERNEL allocations deep inside the allocator which are quite non-trivial
> +to fix up. That means that calling ``vmalloc`` with GFP_NOFS/GFP_NOIO is
> +almost always a bug. The good news is that the NOFS/NOIO semantic can be
> +achieved by the scope api.
> +
> +In the ideal world, upper layers should already mark dangerous contexts
> +and so no special care is required and vmalloc should be called without
> +any problems. Sometimes if the context is not really clear or there are
> +layering violations then the recommended way around that is to wrap ``vmalloc``
> +by the scope API with a comment explaining the problem.
> --
> 2.17.0
>
