Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C99C76B005A
	for <linux-mm@kvack.org>; Sun, 25 Oct 2009 15:12:57 -0400 (EDT)
Date: Sun, 25 Oct 2009 07:30:40 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 02/31] swap over network documentation
Message-ID: <20091025063040.GB1480@ucw.cz>
References: <1254405891-15724-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1254405891-15724-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi!

> From: Neil Brown <neilb@suse.de>
> 
> Document describing the problem and proposed solution

> +Problem:
> +   When Linux needs to allocate memory it may find that there is
> +   insufficient free memory so it needs to reclaim space that is in
> +   use but not needed at the moment.  There are several options:
...
> +   3/ Write out some dirty page-cache pages so that they become clean.
> +      The VM limits the number of dirty page-cache pages to e.g. 40%
> +      of available memory so that (among other reasons) a "sync" will
> +      not take excessively long.  So there should never be excessive
> +      amounts of dirty pagecache.

I'd say "So it is not common to have excessive...". Yes, we try to
limit it, but IIRC malicious users would still be able to dirty
arbitrary ammounts...

....
> +      So anon pages tend to be left until last to be cleaned, and may
> +      be the only cleanable pages while there are still some dirty
> +      page-cache pages (which are waiting on a GFP_NOFS allocation).

Are you sure? Because this is saying 'Linux is broken without swap'
(and swap-less configs are more and more common). 

> +  For memory allocated using slab/slub: If a page that is added to a
> +  kmem_cache is found to have page->reserve set, then a  s->reserve
> +  flag is set for the whole kmem_cache.  Further allocations will only
> +  be returned from that page (or any other page in the cache) if they
> +  are emergency allocation (i.e. PF_MEMALLOC or GFP_MEMALLOC is set).
> +  Non-emergency allocations will block in alloc_page until a
> +  non-reserve page is available.  Once a non-reserve page has been
> +  added to the cache, the s->reserve flag on the cache is removed.

Does this greatly increase probability of GFP_ATOMIC allocations
failing?

> +  Similarly, if an skb is ever queued for delivery to user-space for
> +  example by netfilter, the ->emergency flag is tested and the skb is
> +  released if ->emergency is set. (so obviously the storage route may
> +  not pass through a userspace helper, otherwise the packets will never
> +  arrive and we'll deadlock)

(So -- .)

> +  pages_emergency can be changed dynamically based on need.  When
> +  swapout over the network is required, pages_emergency is increased
> +  to cover the maximum expected load.  When network swapout is
> +  disabled, pages_emergency is decreased.

Hmm, increasing pages_emergency is pretty interesting
operation.... right?

> +Thanks for reading this far.  I hope it made sense :-)
> +
> +Neil Brown (with updates from Peter Zijlstra)

Well, some warnings are misssing.

For example... swap over nfs over openvpn will do bad bad things,
right? ... and I guess that should be documented.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
