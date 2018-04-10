Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB9376B0268
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:28:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g61-v6so9530350plb.10
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:28:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64sor652829pgc.323.2018.04.10.06.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 06:28:31 -0700 (PDT)
Date: Tue, 10 Apr 2018 22:28:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410132822.GA32026@rodete-laptop-imager.corp.google.com>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <20180409183827.GD17558@jaegeuk-macbookpro.roam.corp.google.com>
 <20180409194044.GA15295@bombadil.infradead.org>
 <20180410082643.GX21835@dhcp22.suse.cz>
 <20180410120528.GB22118@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410120528.GB22118@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Tue, Apr 10, 2018 at 05:05:28AM -0700, Matthew Wilcox wrote:
> On Tue, Apr 10, 2018 at 10:26:43AM +0200, Michal Hocko wrote:
> > On Mon 09-04-18 12:40:44, Matthew Wilcox wrote:
> > > The problem is that the mapping gfp flags are used not only for allocating
> > > pages, but also for allocating the page cache data structures that hold
> > > the pages.  F2FS is the only filesystem that set the __GFP_ZERO bit,
> > > so it's the first time anyone's noticed that the page cache passes the
> > > __GFP_ZERO bit through to the radix tree allocation routines, which
> > > causes the radix tree nodes to be zeroed instead of constructed.
> > > 
> > > I think the right solution to this is:
> > 
> > This just hides the underlying problem that the node is not fully and
> > properly initialized. Relying on the previous released state is just too
> > subtle.
> 
> That's the fundamental design of slab-with-constructors.  The user provides
> a constructor, so all newly allocagted objects are initialised to a known
> state, then the user will restore the object to that state when it frees
> the object to slab.
> 
> > Are you going to blacklist all potential gfp flags that come
> > from the mapping? This is just unmaintainable! If anything this should
> > be an explicit & with the allowed set of allowed flags.
> 
> Oh, I agree that using the set of flags used to allocate the page
> in order to allocate the radix tree nodes is a pretty horrible idea.
> 
> Your suggestion, then, is:
> 
> -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> +	error = radix_tree_preload(gfp_mask & GFP_RECLAIM_MASK);
> 
> correct?
> 

Looks much better.

Finally, it seems everyone agree on this. However, I won't include
warning part of slab allocator because I think it's improve stuff
not bug fix so it could be separted.
If anyone really want to include it in this stable patch,
please discuss with slub maintainers before.

Thanks for the reivew, Matthew, Michal, Jan and Johannes.
