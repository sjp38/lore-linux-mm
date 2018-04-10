Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E23D6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 11:54:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so9813056plf.6
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:54:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id az2-v6si2751316plb.263.2018.04.10.08.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 08:54:45 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:54:42 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
Message-ID: <20180410155442.GA3614@bombadil.infradead.org>
References: <20180410125351.15837-1-willy@infradead.org>
 <alpine.DEB.2.20.1804100920110.27333@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804100920110.27333@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, Apr 10, 2018 at 09:21:20AM -0500, Christopher Lameter wrote:
> On Tue, 10 Apr 2018, Matthew Wilcox wrote:
> 
> > __GFP_ZERO requests that the object be initialised to all-zeroes,
> > while the purpose of a constructor is to initialise an object to a
> > particular pattern.  We cannot do both.  Add a warning to catch any
> > users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> > a constructor.
> 
> Can we move this check out of the critical paths and check for
> a ctor and GFP_ZERO when calling the page allocator? F.e. in
> allocate_slab()?

Are you willing to have this kind of bug go uncaught for a while?
In this specific case, __GFP_ZERO was only being passed on a few of the
calls to kmem_cache_alloc.  So we'd happily trash the constructed object
any time we didn't allocate a page.

I appreciate it's a tradeoff, and we don't want to clutter the critical
path unnecessarily.
