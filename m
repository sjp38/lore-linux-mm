Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4C316B033C
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:14:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 12so695085wmn.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:14:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e11si12772651wre.37.2017.06.26.05.14.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 05:14:14 -0700 (PDT)
Date: Mon, 26 Jun 2017 14:14:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170626121411.GK11534@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-3-mhocko@kernel.org>
 <db63b720-b7aa-1bd0-dde8-d324dfaa9c9b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db63b720-b7aa-1bd0-dde8-d324dfaa9c9b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 26-06-17 13:45:19, Vlastimil Babka wrote:
> On 06/23/2017 10:53 AM, Michal Hocko wrote:
[...]
> > - GFP_KERNEL - both background and direct reclaim are allowed and the
> >   _default_ page allocator behavior is used. That means that !costly
> >   allocation requests are basically nofail (unless the requesting task
> >   is killed by the OOM killer)
> 
> Should we explicitly point out that failure must be handled? After lots
> of talking about "too small to fail", people might get the wrong impression.

OK. What about the following.
"That means that !costly allocation requests are basically nofail but
there is no guarantee of thaat behavior so failures have to be checked
properly by callers (e.g. OOM killer victim is allowed to fail
currently).

> > and costly will fail early rather than
> >   cause disruptive reclaim.
> > - GFP_KERNEL | __GFP_NORETRY - overrides the default allocator behavior and
> >   all allocation requests fail early rather than cause disruptive
> >   reclaim (one round of reclaim in this implementation). The OOM killer
> >   is not invoked.
> > - GFP_KERNEL | __GFP_RETRY_MAYFAIL - overrides the default allocator behavior
> >   and all allocation requests try really hard. The request will fail if the
> >   reclaim cannot make any progress. The OOM killer won't be triggered.
> > - GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
> >   and all allocation requests will loop endlessly until they
> >   succeed. This might be really dangerous especially for larger orders.
> > 
> > Existing users of __GFP_REPEAT are changed to __GFP_RETRY_MAYFAIL because
> > they already had their semantic. No new users are added.
> > __alloc_pages_slowpath is changed to bail out for __GFP_RETRY_MAYFAIL if
> > there is no progress and we have already passed the OOM point. This
> > means that all the reclaim opportunities have been exhausted except the
> > most disruptive one (the OOM killer) and a user defined fallback
> > behavior is more sensible than keep retrying in the page allocator.
> > 
> > Changes since RFC
> > - udpate documentation wording as per Neil Brown
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> Some more minor comments below:
> 
> ...
> 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 4c6656f1fee7..6be1f836b69e 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -25,7 +25,7 @@ struct vm_area_struct;
> >  #define ___GFP_FS		0x80u
> >  #define ___GFP_COLD		0x100u
> >  #define ___GFP_NOWARN		0x200u
> > -#define ___GFP_REPEAT		0x400u
> > +#define ___GFP_RETRY_MAYFAIL		0x400u
> 
> Seems like one tab too many, the end result is off:

will fix

> (sigh, tabs are not only error prone, but also we make less money due to
> them, I heard)
> 
> #define ___GFP_NOWARN           0x200u
> #define ___GFP_RETRY_MAYFAIL            0x400u
> #define ___GFP_NOFAIL           0x800u
> 
> 
> >  #define ___GFP_NOFAIL		0x800u
> >  #define ___GFP_NORETRY		0x1000u
> >  #define ___GFP_MEMALLOC		0x2000u
> > @@ -136,26 +136,55 @@ struct vm_area_struct;
> >   *
> >   * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd reclaim.
> >   *
> > - * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
> > - *   _might_ fail.  This depends upon the particular VM implementation.
> > + * The default allocator behavior depends on the request size. We have a concept
> > + * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
> > + * !costly allocations are too essential to fail so they are implicitly
> > + * non-failing (with some exceptions like OOM victims might fail) by default while
> 
> Again, emphasize need for error handling?

the same wording as above?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
