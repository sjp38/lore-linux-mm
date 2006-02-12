Date: Sat, 11 Feb 2006 23:53:33 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211235333.71f48a66.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0602112225190.26166@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
	<20060211013255.20832152.akpm@osdl.org>
	<20060211014649.7cb3b9e2.akpm@osdl.org>
	<43EEAC93.3000803@yahoo.com.au>
	<Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
	<43EEB4DA.6030501@yahoo.com.au>
	<Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
	<43EEC136.5060609@yahoo.com.au>
	<20060211211437.0633dfdb.akpm@osdl.org>
	<20060211213707.0ef39582.akpm@osdl.org>
	<Pine.LNX.4.62.0602112225190.26166@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Sat, 11 Feb 2006, Andrew Morton wrote:
> 
> > Andrew Morton <akpm@osdl.org> wrote:
> > >
> > >  Returning nr_reclaimed up and down the stack makes sense too - I'll try that.
> > 
> > wtf does this, in zone_reclaim() do?
> > 
> > 		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */
> 
> The number of pages returned from slab_reclaim is global and not per zone. 
> (we need to find a way to fix that if we want to enable per zone slab 
> reclaim during zone reclaim operations by defaut... and if we had zoned vm 
> counters we could also avoid this situation)
>  
> So the number of reclaimed slab pages cannot be used to determine if we 
> should go off node. sc.nr_reclaimed has some weird value after shrink_slab
> is through.

?  sc.nr_reclaimed doesn't have anything to do with shrink_slab()?

Do you mean reclaim_state.reclaimed_slab?  If so, why does it have a weird
value?  What's wrong with it?

> Hmmm. Setting this to one means that we will rescan and shrink the slab
> for each allocation if we are out of zone memory and RECLAIM_SLAB is set.
> Plus if we do an order 0 allocation we do not go off node as intended.
>
> We better set this to zero. This means the allocation will go offnode
> despite us having potentially freed lots of memory on the zone.
> Future allocations can then again be done from this zone.

uh, OK, if you say so.

zone_reclaim() is pretty obscure and could do with some comments.  What's
it _really_ trying to do, and how does it do it?  What is that timer there
for and how is it supposed to work?  Why on earth does it set PF_MEMALLOC,
things like that.

I'd have thought that looking at the zone's free_pages thingies would give
a pretty good approximation to "how much memory did shrink_slab() give us".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
