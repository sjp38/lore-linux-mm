Date: Mon, 4 Dec 2006 14:22:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
Message-Id: <20061204142259.3cdda664.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com>
References: <20061130170746.GA11363@skynet.ie>
	<20061130173129.4ebccaa2.akpm@osdl.org>
	<Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>
	<20061201110103.08d0cf3d.akpm@osdl.org>
	<20061204140747.GA21662@skynet.ie>
	<20061204113051.4e90b249.akpm@osdl.org>
	<Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com>
	<20061204120611.4306024e.akpm@osdl.org>
	<Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com>
	<20061204131959.bdeeee41.akpm@osdl.org>
	<Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Dec 2006 13:43:44 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 4 Dec 2006, Andrew Morton wrote:
> 
> > What happens when we need to run reclaim against just a section of a zone?
> > Lumpy-reclaim could be used here; perhaps that's Mel's approach too?
> 
> Why would we run reclaim against a section of a zone?

Strange question.  Because all the pages are in use for something else.

> > We'd need new infrastructure to perform the
> > section-of-a-zone<->physical-memory-block mapping, and to track various
> > states of the section-of-a-zone.  This will be complex, and buggy.  It will
> > probably require the introduction of some sort of "sub-zone" structure.  At
> > which stage people would be justified in asking "why didn't you just use
> > zones - that's what they're for?"
> 
> Mel aready has that for anti-frag. The sections are per MAX_ORDER area 
> and the only states are movable unmovable and reclaimable. There is 
> nothing more to it. No other state information should be added. Why would 
> we need sub zones? For what purpose?

You're proposing that for memory hot-unplug, we take a single zone and by
some means subdivide that into sections which correspond to physically
hot-unpluggable memory.  That certainly does not map onto MAX_ORDER
sections.

> > > Then we should be doing some work to cut down the number of unmovable 
> > > allocations.
> > 
> > That's rather pointless.  A feature is either reliable or it is not.  We'll
> > never be able to make all kernel allocations reclaimable/moveable so we'll
> > never be reliable with this approach.  I don't see any alternative to the
> > never-allocate-kernel-objects-in-removeable-memory approach.  
> 
> What feature are you talking about?

Memory hot-unplug, of course.

> Why would all allocations need to be movable when we have a portion for 
> unmovable allocations?

So you're proposing that we take a single zone, then divide that zone up
into two sections.  One section is non-hot-unpluggable and is for
un-moveable allocations.  The other section is hot-unpluggable and only
moveable allocations may be performed there.

If so, then this will require addition of new infrastructure which will be
to some extent duplicative of zones and I see no reason to do that: it'd be
simpler to divide the physical memory arena into two separate zones.

If that is not what you are proposing then please tell us what you are
proposing, completely, and with sufficient detail for us to work out what
the heck you're trying to tell us.  Please try to avoid uninformative
rhetorical questions, for they are starting to get quite irritating. 
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
