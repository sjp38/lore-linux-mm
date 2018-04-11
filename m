Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9579D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 19:56:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so2305874plm.12
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 16:56:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z100-v6si2173355plh.77.2018.04.11.16.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Apr 2018 16:56:55 -0700 (PDT)
Date: Wed, 11 Apr 2018 16:56:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
Message-ID: <20180411235652.GA28279@bombadil.infradead.org>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
 <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Wed, Apr 11, 2018 at 04:11:17PM -0500, Christopher Lameter wrote:
> On Wed, 11 Apr 2018, Matthew Wilcox wrote:
> > > Please put this in a code path that is enabled by specifying
> > >
> > > slub_debug
> > >
> > > on the kernel command line.
> >
> > I don't understand.  First, I had:
> >
> > 	if (unlikely(gfpflags & __GFP_ZERO) && object && !WARN_ON_ONCE(s->ctor))
> >
> > and you didn't like that because it was putting checking into a (semi)fast
> > path.  Now you want me to add a check for slub_debug somewhere?  I dont
> > see an existing one I can leverage that will hit on every allocation.
> > Perhaps I'm missing something.
> 
> The WARN_ON is only enabled when you configure and build the kernel with
> debugging enabled (CONFIG_VM_DEBUG). That is a compile time debugging
> feature like supported by SLAB.

Yes.  I want to have an option to check *every single* allocation.

> "slub_debug" enables kmem_cache->flags & SLAB_DEBUG and that forces all
> fastpath processing to be disabled. Thus you can check reliably in the
> slow path only for the GFP_ZERO problem.
> 
> Add the check to the other debug stuff already there. F.e. in
> alloc_debug_processing() or after
> 
> if (kmem_cache_debug(s) ...
> 
> in ____slab_alloc()

I don't see how that works ... can you explain a little more?

I see ___slab_alloc() is called from __slab_alloc().  And I see
slab_alloc_node does this:

        object = c->freelist;
        page = c->page;
        if (unlikely(!object || !node_match(page, node))) {
                object = __slab_alloc(s, gfpflags, node, addr, c);
                stat(s, ALLOC_SLOWPATH);

But I don't see how slub_debug leads to c->freelist always being NULL.
It looks like it gets repopulated from page->freelist in ___slab_alloc()
at the load_freelist label.
