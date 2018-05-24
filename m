Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 087006B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 16:52:42 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so1627593pld.23
        for <linux-mm@kvack.org>; Thu, 24 May 2018 13:52:41 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id t4-v6si22000620plb.313.2018.05.24.13.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 13:52:40 -0700 (PDT)
Date: Thu, 24 May 2018 14:52:02 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180524145202.7d5a55c3@lwn.net>
In-Reply-To: <20180524114341.1101-1-mhocko@kernel.org>
References: <20180424183536.GF30619@thunk.org>
	<20180524114341.1101-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu, 24 May 2018 13:43:41 +0200
Michal Hocko <mhocko@kernel.org> wrote:

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

So you create the rst file, but don't add it in index.rst; that means it
won't be a part of the docs build and Sphinx will complain.

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

Ah...the wonderful month of Mapy....:)

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

"resp." is indeed a bit terse.  Even spelled out as "respectively", though,
I'm not sure what the word is intended to mean here.  Did you mean "or"?

> +the gfp mask when calling an allocator. GFP_NOFS resp. GFP_NOIO can be

Here too.

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

"from a filesystem or I/O point of view" ?

> +from that scope will inherently drop __GFP_FS resp. __GFP_IO from the given
> +mask so no memory allocation can recurse back in the FS/IO.

Wouldn't it be nice if those functions had kerneldoc comments that could be
pulled in here! :)

> +FS/IO code then simply calls the appropriate save function right at the
> +layer where a lock taken from the reclaim context (e.g. shrinker) and

where a lock *is* taken ?

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

Agree with others on "API"

> +In the ideal world, upper layers should already mark dangerous contexts
> +and so no special care is required and vmalloc should be called without
> +any problems. Sometimes if the context is not really clear or there are
> +layering violations then the recommended way around that is to wrap ``vmalloc``
> +by the scope API with a comment explaining the problem.

Thanks,

jon
