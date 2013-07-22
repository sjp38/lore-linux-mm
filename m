Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 717986B0033
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 11:38:10 -0400 (EDT)
Date: Mon, 22 Jul 2013 09:38:07 -0600
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH RFC] lib: Make radix_tree_node_alloc() irq safe
Message-ID: <20130722153807.GR32755@kernel.dk>
References: <1373994390-5479-1-git-send-email-jack@suse.cz>
 <20130717161200.40a97074623be2685beb8156@linux-foundation.org>
 <20130718130932.GA10419@quack.suse.cz>
 <51E85E73.608@kernel.dk>
 <20130722152137.GH23658@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130722152137.GH23658@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jul 22 2013, Jan Kara wrote:
> On Thu 18-07-13 15:30:27, Jens Axboe wrote:
> > On 07/18/2013 07:09 AM, Jan Kara wrote:
> > > On Wed 17-07-13 16:12:00, Andrew Morton wrote:
> > >> On Tue, 16 Jul 2013 19:06:30 +0200 Jan Kara <jack@suse.cz> wrote:
> > >>
> > >>> With users of radix_tree_preload() run from interrupt (CFQ is one such
> > >>> possible user), the following race can happen:
> > >>>
> > >>> radix_tree_preload()
> > >>> ...
> > >>> radix_tree_insert()
> > >>>   radix_tree_node_alloc()
> > >>>     if (rtp->nr) {
> > >>>       ret = rtp->nodes[rtp->nr - 1];
> > >>> <interrupt>
> > >>> ...
> > >>> radix_tree_preload()
> > >>> ...
> > >>> radix_tree_insert()
> > >>>   radix_tree_node_alloc()
> > >>>     if (rtp->nr) {
> > >>>       ret = rtp->nodes[rtp->nr - 1];
> > >>>
> > >>> And we give out one radix tree node twice. That clearly results in radix
> > >>> tree corruption with different results (usually OOPS) depending on which
> > >>> two users of radix tree race.
> > >>>
> > >>> Fix the problem by disabling interrupts when working with rtp variable.
> > >>> In-interrupt user can still deplete our preloaded nodes but at least we
> > >>> won't corrupt radix trees.
> > >>>
> > >>> ...
> > >>>
> > >>>   There are some questions regarding this patch:
> > >>> Do we really want to allow in-interrupt users of radix_tree_preload()?  CFQ
> > >>> could certainly do this in older kernels but that particular call site where I
> > >>> saw the bug hit isn't there anymore so I'm not sure this can really happen with
> > >>> recent kernels.
> > >>
> > >> Well, it was never anticipated that interrupt-time code would run
> > >> radix_tree_preload().  The whole point in the preloading was to be able
> > >> to perform GFP_KERNEL allocations before entering the spinlocked region
> > >> which needs to allocate memory.
> > >>
> > >> Doing all that from within an interrupt is daft, because the interrupt code
> > >> can't use GFP_KERNEL anyway.
> > >   Fully agreed here.
> > > 
> > >>> Also it is actually harmful to do preloading if you are in interrupt context
> > >>> anyway. The disadvantage of disallowing radix_tree_preload() in interrupt is
> > >>> that we would need to tweak radix_tree_node_alloc() to somehow recognize
> > >>> whether the caller wants it to use preloaded nodes or not and that callers
> > >>> would have to get it right (although maybe some magic in radix_tree_preload()
> > >>> could handle that).
> > >>>
> > >>> Opinions?
> > >>
> > >> BUG_ON(in_interrupt()) :)
> > >   Or maybe WARN_ON()... But it's not so easy :) Currently radix tree code
> > > assumes that if gfp_mask doesn't have __GFP_WAIT set caller has performed
> > > radix_tree_preload(). Clearly this will stop working for in-interrupt users
> > > of radix tree. So how do we propagate the information from the caller of
> > > radix_tree_insert() down to radix_tree_node_alloc() whether the preload has
> > > been performed or not? Will we rely on in_interrupt() or use some special
> > > gfp_mask bit?
> > 
> > Should have read the full thread... in_interrupt() is ugly to base
> > decisions on, imho. I'd say just use __GFP_WAIT to signal this.
>   Yeah, probably that would be nicer and doable in radix_tree_preload().
> But in radix_tree_node_alloc() we get gfp_mask as set for the radix tree
> and thus it's always going to be GFP_ATOMIC in case of ioc radix tree. So
> there we have to have something different if we don't want in interrupt
> users to use preallocated nodes. As Andrew suggests maybe that's not
> necessary but then my original patch is what you end up with.

At least for the ioc functions, failure can be tolerated (and is
handled). So for this specific case, we don't need to do anything futher
than just the GFP_ATOMIC set in the tree. If that fails, we just don't
link the ioc this time.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
