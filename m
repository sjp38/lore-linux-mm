Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A91B390010E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:21:47 -0400 (EDT)
Date: Tue, 10 May 2011 11:21:41 +0100
From: Mel Gorman <mgorman@novell.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110510102141.GA4149@novell.com>
References: <20110428192104.GA4658@suse.de>
 <1304020767.2598.21.camel@mulgrave.site>
 <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
 <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
 <20110506080728.GC6591@suse.de>
 <1304964980.4865.53.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1304964980.4865.53.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Mon, May 09, 2011 at 01:16:20PM -0500, James Bottomley wrote:
> On Fri, 2011-05-06 at 09:07 +0100, Mel Gorman wrote:
> > On Fri, May 06, 2011 at 08:42:24AM +0100, Mel Gorman wrote:
> > > 1. High-order allocations? You machine is using i915 and RPC, something
> > >    neither of my test machine uses. i915 is potentially a source for
> > >    high-order allocations. I'm attaching a perl script. Please run it as
> > >    ./watch-highorder.pl --output /tmp/highorders.txt
> > >    while you are running tar. When kswapd is running for about 30
> > >    seconds, interrupt it with ctrl+c twice in quick succession and
> > >    post /tmp/highorders.txt
> > > 
> > 
> > Attached this time :/
> 
> Here's the output (loaded with tar, evolution and firefox).  The top
> trace is different this time because your perl script perturbs the
> system quite a bit.  This was with your slub allocation fix applied.
> 

I note that certain flags like __GFP_NO_KSWAPD are not recognised by
tracing which might explain why they are missing from the script output.
I regret the script perturbs the system quite a bit. It's possible it
can be made better by filtering events but it's not high on the list of
things to do.

How does the output compare without the fix? I can't find a similar
report in my inbox.

Does the fix help the system when the perl script is not running?

> 177 instances order=2 normal gfp_flags=GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => radix_tree_preload+0x31/0x81 <ffffffff81229399>
>  => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d5>
> 

Ouch.

> 46 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => prepare_creds+0x26/0xae <ffffffff81074d4b>
>  => sys_faccessat+0x37/0x162 <ffffffff8111d255>
> 

Less ouch, but still.

> 252 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => radix_tree_preload+0x31/0x81 <ffffffff81229399>
>  => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d5>
> 

Ouch again.

> 593 instances order=3 normal gfp_flags=GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f498>
>  => alloc_inode+0x1d/0x78 <ffffffff811317e5>
> 

Again, filesystem-related calls are hitting high-order paths quite a
bit.

> 781 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => kmalloc_large_node+0x56/0x95 <ffffffff8146a55d>
>  => __kmalloc_node_track_caller+0x31/0x131 <ffffffff8110ff08>
>  => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
>  => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b238a>
>  => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25c2>
>  => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d217>
>  => __sock_sendmsg+0x69/0x76 <ffffffff813af778>
> 

A number of network paths are also being hit although this is the worst.

> 501 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => get_empty_filp+0x7a/0x141 <ffffffff8111f2d1>
>  => do_filp_open+0xe7/0x60a <ffffffff81129bcf>
> 

More filesystem impairment.

> 1370 instances order=1 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => d_alloc+0x26/0x18d <ffffffff8112e4c5>
>  => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d0e>
> 

*cries*

> 140358 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
>  => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
>  => new_slab+0x50/0x199 <ffffffff8110dc24>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
>  => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
>  => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

Wonder which pool this is!

It goes on. A number of filesystem and network paths are being hit
with high-order allocs. i915 was a red herring, it's present but not
in massive numbers. The filesystem, network and mempool allocations
are likely to be kicking kswapd awake frequently and hurting overall
system performance as a result.

I really would like to hear if the fix makes a big difference or
if we need to consider forcing SLUB high-order allocations bailing
at the first sign of trouble (e.g. by masking out __GFP_WAIT in
allocate_slab). Even with the fix applied, kswapd might be waking up
less but processes will still be getting stalled in direct compaction
and direct reclaim so it would still be jittery.

> High-order normal allocations: 145450
> High-order atomic allocations: 927
>  

I bet a shiny penny that the high-order allocations for SLAB are lower
than this

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
