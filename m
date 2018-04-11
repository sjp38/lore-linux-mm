Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44C2D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 17:12:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n5so2230757qtl.13
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 14:12:20 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [69.252.207.41])
        by mx.google.com with ESMTPS id p17si2686014qtb.139.2018.04.11.14.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 14:12:19 -0700 (PDT)
Date: Wed, 11 Apr 2018 16:11:17 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180411192448.GD22494@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org> <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake> <20180411192448.GD22494@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Wed, 11 Apr 2018, Matthew Wilcox wrote:

> > >  	slab_post_alloc_hook(s, gfpflags, 1, &object);
> >
> > Please put this in a code path that is enabled by specifying
> >
> > slub_debug
> >
> > on the kernel command line.
>
> I don't understand.  First, I had:
>
> 	if (unlikely(gfpflags & __GFP_ZERO) && object && !WARN_ON_ONCE(s->ctor))
>
> and you didn't like that because it was putting checking into a (semi)fast
> path.  Now you want me to add a check for slub_debug somewhere?  I dont
> see an existing one I can leverage that will hit on every allocation.
> Perhaps I'm missing something.

The WARN_ON is only enabled when you configure and build the kernel with
debugging enabled (CONFIG_VM_DEBUG). That is a compile time debugging
feature like supported by SLAB.

SLUB debugging is different because we had problems isolating memory
corruption bugs in the production kernels for years. The debug code is
always included in the build but kept out of the hotpaths.


The debug can be enabled when needed to find memory corruption errors
without the need to rebuild a kernel for a prod environment (which may
change race conditions etc) because we only then need to add a kernel
parameter.

"slub_debug" enables kmem_cache->flags & SLAB_DEBUG and that forces all
fastpath processing to be disabled. Thus you can check reliably in the
slow path only for the GFP_ZERO problem.

Add the check to the other debug stuff already there. F.e. in
alloc_debug_processing() or after

if (kmem_cache_debug(s) ...

in ____slab_alloc()
