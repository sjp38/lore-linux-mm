Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0445B6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 22:39:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so8303814pla.18
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 19:39:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor750290pld.86.2018.04.09.19.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 19:39:17 -0700 (PDT)
Date: Tue, 10 Apr 2018 11:39:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410023910.GC214542@rodete-desktop-imager.corp.google.com>
References: <20180409024925.GA21889@bombadil.infradead.org>
 <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
 <20180409152032.GB11756@bombadil.infradead.org>
 <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
 <20180410011211.GA31282@bombadil.infradead.org>
 <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Tue, Apr 10, 2018 at 11:33:39AM +0900, Minchan Kim wrote:
> On Mon, Apr 09, 2018 at 06:12:11PM -0700, Matthew Wilcox wrote:
> > On Tue, Apr 10, 2018 at 08:04:09AM +0900, Minchan Kim wrote:
> > > On Mon, Apr 09, 2018 at 08:20:32AM -0700, Matthew Wilcox wrote:
> > > > I don't think this is something the radix tree should know about.
> > > 
> > > Because shadow entry implementation is hidden by radix tree implemetation.
> > > IOW, radix tree user cannot know how it works.
> > 
> > I have no idea what you mean.
> > 
> > > > SLAB should be checking for it (the patch I posted earlier in this
> > > 
> > > I don't think it's right approach. SLAB constructor can initialize
> > > some metadata for slab page populated as well as page zeroing.
> > > However, __GFP_ZERO means only clearing pages, not metadata.
> > > So it's different semantic. No need to mix out.
> > 
> > No, __GFP_ZERO is specified to clear the allocated memory whether
> > you're allocating from alloc_pages or from slab.  What makes no sense
> > is allocating an object from slab with a constructor *and* __GFP_ZERO.
> > They're in conflict, and slab can't fulfill both of those requirements.
> 
> It's a stable material. If you really think it does make sense,
> please submit patch separately.
> 
> > 
> > > > thread), but the right place to filter this out is in the caller of
> > > > radix_tree_maybe_preload -- it's already filtering out HIGHMEM pages,
> > > > and should filter out GFP_ZERO too.
> > > 
> > > radix_tree_[maybe]_preload is exported API, which are error-prone
> > > for out of modules or upcoming customers.
> > > 
> > > More proper place is __radix_tree_preload.
> > 
> > I could not disagree with you more.  It is the responsibility of the
> > callers of radix_tree_preload to avoid calling it with nonsense flags
> > like __GFP_DMA, __GFP_HIGHMEM or __GFP_ZERO.
> 
> How about this?
> 
> It would fix current problem and warn potential bugs as well.
> radix_tree_preload already has done such warning and
> radix_tree_maybe_preload has skipping for misbehaivor gfp.
> 
> From 27ecf7a009d3570d1155c528c7f08040ede68ed3 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 10 Apr 2018 11:20:11 +0900
> Subject: [PATCH v2] mm: workingset: fix NULL ptr dereference
> 
> It assumes shadow entries of radix tree rely on the init state
> that node->private_list allocated newly is list_empty state
> for the working. Currently, it's initailized in SLAB constructor
> which means node of radix tree would be initialized only when
> *slub allocates new page*, not *slub alloctes new object*.
> 
> If some FS or subsystem pass gfp_mask to __GFP_ZERO, that means
> newly allocated node can have !list_empty(node->private_list)
> by memset of slab allocator. It ends up calling NULL deference
> at workingset_update_node by failing list_empty check.
> 
> This patch fixes it.
> 
> Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: Chao Yu <yuchao0@huawei.com>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: linux-fsdevel@vger.kernel.org
> Reported-by: Chris Fries <cfries@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  lib/radix-tree.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index da9e10c827df..9d68f2a7888e 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -511,6 +511,16 @@ int radix_tree_preload(gfp_t gfp_mask)
>  {
>  	/* Warn on non-sensical use... */
>  	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
> +	/*
> +	 * New allocate node must have node->private_list as INIT_LIST_HEAD
> +	 * state by workingset shadow memory implementation.
> +	 * If user pass  __GFP_ZERO by mistake, slab allocator will clear
> +	 * node->private_list, which makes a BUG. Rather than going Oops,
> +	 * just fix and warn about it.
> +	 */
> +	if (WARN_ON(gfp_mask & __GFP_ZERO))
> +		gfp_mask &= ~GFP_ZERO
 
Build fail.

If others are okay for this patch, I will resend fixed patch with stable mark.
I will wait feedback from others.

Thanks.
