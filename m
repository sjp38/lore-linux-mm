Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70438900118
	for <linux-mm@kvack.org>; Tue, 10 May 2011 13:17:32 -0400 (EDT)
Date: Tue, 10 May 2011 18:17:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110510171726.GE4146@suse.de>
References: <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
 <20110506080728.GC6591@suse.de>
 <1304964980.4865.53.camel@mulgrave.site>
 <20110510102141.GA4149@novell.com>
 <1305036064.6737.8.camel@mulgrave.site>
 <20110510143509.GD4146@suse.de>
 <1305041397.6737.12.camel@mulgrave.site>
 <1305043052.6737.17.camel@mulgrave.site>
 <1305047154.6737.22.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1305047154.6737.22.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, May 10, 2011 at 12:05:54PM -0500, James Bottomley wrote:
> On Tue, 2011-05-10 at 15:57 +0000, James Bottomley wrote:
> > On Tue, 2011-05-10 at 10:29 -0500, James Bottomley wrote:
> > > On Tue, 2011-05-10 at 15:35 +0100, Mel Gorman wrote:
> > > > On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
> > > > > On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> > > > > > I really would like to hear if the fix makes a big difference or
> > > > > > if we need to consider forcing SLUB high-order allocations bailing
> > > > > > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> > > > > > allocate_slab). Even with the fix applied, kswapd might be waking up
> > > > > > less but processes will still be getting stalled in direct compaction
> > > > > > and direct reclaim so it would still be jittery.
> > > > > 
> > > > > "the fix" being this
> > > > > 
> > > > > https://lkml.org/lkml/2011/3/5/121
> > > > > 
> > > > 
> > > > Drop this for the moment. It was a long shot at best and there is little
> > > > evidence the problem is in this area.
> > > > 
> > > > I'm attaching two patches. The first is the NO_KSWAPD one to stop
> > > > kswapd being woken up by SLUB using speculative high-orders. The second
> > > > one is more drastic and prevents slub entering direct reclaim or
> > > > compaction. It applies on top of patch 1. These are both untested and
> > > > afraid are a bit rushed as well :(
> > > 
> > > Preliminary results with both patches applied still show kswapd
> > > periodically going up to 99% but it doesn't stay there, it comes back
> > > down again (and, obviously, the system doesn't hang).
> > 
> > This is a second run with the watch highorders.
> > 
> > At the end of the run, the system hung temporarily and now comes back
> > with CPU3 spinning in all system time at kswapd shrink_slab
> 
> Here's a trace in the same situation with the ftrace stack entries
> bumped to 16 as requested on IRC.  There was no hang for this one.
> 

Ok, so the bulk of the high-order allocs are coming from

> 140162 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
>  => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
>  => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
>  => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
>  => new_slab+0x50/0x199 <ffffffff8110dc48>
>  => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
>  => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
>  => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
>  => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
>  => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
>  => bio_alloc+0x15/0x24 <ffffffff81144ef5>
>  => submit_bh+0x6d/0x105 <ffffffff811409f6>
>  => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>
>  => block_write_full_page_endio+0x8a/0x97 <ffffffff81143671>
>  => block_write_full_page+0x15/0x17 <ffffffff81143693>
>  => mpage_da_submit_io+0x31a/0x395 <ffffffff811935d8>
>  => mpage_da_map_and_submit+0x2ca/0x2e0 <ffffffff81196e88>
> 

That at least is in line with the large untar and absolves i915
from being the main cause of trouble. The lack of the hang implies
that SLUB doing high order allocations is stressing the system too
much and needs to be more willing to fall back to order-0 although
it does not adequately explain why it hung as opposed to just being
incredible slow.

I'm also still concerned with the reports of getting stuck in a heavy
loop on the i915 shrinker so will try again reproducing this locally
with a greater focus on something X related happening at the same time.

One thing at a time though, SLUB needs to be less aggressive so I'll
prepare a series in the morning, have another go at generating data
and see what shakes out.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
