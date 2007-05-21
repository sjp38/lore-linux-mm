Date: Mon, 21 May 2007 13:32:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179778127.7019.48.camel@twins>
Message-ID: <Pine.LNX.4.64.0705211326290.28504@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>  <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
  <20070517175327.GX11115@waste.org>  <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
  <1179429499.2925.26.camel@lappy>  <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
  <1179437209.2925.29.camel@lappy>  <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
  <1179482054.2925.52.camel@lappy>  <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
  <1179650384.7019.33.camel@twins>  <Pine.LNX.4.64.0705210932500.25871@schroedinger.engr.sgi.com>
  <1179776038.5735.39.camel@lappy>  <Pine.LNX.4.64.0705211239300.27622@schroedinger.engr.sgi.com>
 <1179778127.7019.48.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Jackson <pj@sgi.com>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 21 May 2007, Peter Zijlstra wrote:

> > This means we will disobey cpuset and memory policy constraints?
> 
> >From what I can make of it, yes. Although I'm a bit hazy on the
> mempolicy code.

In an interrupt context we do not have a process context. But there is
no exemption from memory policy constraints.

> > > > No the gfp zone flags are not uniform and placement of page allocator 
> > > > allocs through SLUB do not always have the same allocation constraints.
> > > 
> > > It has to; since it can serve the allocation from a pre-existing slab
> > > allocation. Hence any page allocation must be valid for all other users.
> > 
> > Why does it have to? This is not true.
> 
> Say the slab gets allocated by an allocation from interrupt context; no
> cpuset, no policy. This same slab must be valid for whatever allocation
> comes next, right? Regardless of whatever policy or GFP_ flags are in
> effect for that allocation.

Yes sure if we do not have a context then no restrictions originating 
there can be enforced. So you want to restrict the logic now to
interrupt allocs? I.e. GFP_ATOMIC?

> > The constraints come from the context of memory policies and cpusets. See
> > get_any_partial().
> 
> but get_partial() will only be called if the cpu_slab is full, up until
> that point you have to do with whatever is there.

Correct. That is an optimization but it may be called anytime from the 
perspective of an execution thread and that may cause problems with your 
approach.

> > > As far as I can see there cannot be a hard constraint here, because
> > > allocations form interrupt context are at best node local. And node
> > > affine zone lists still have all zones, just ordered on locality.
> > 
> > Interrupt context is something different. If we do not have a process 
> > context then no cpuset and memory policy constraints can apply since we
> > have no way of determining that. If you restrict your use of the reserve 
> > cpuset to only interrupt allocs then we may indeed be fine.
> 
> No, what I'm saying is that if the slab gets refilled from interrupt
> context the next process context alloc will have to work with whatever
> the interrupt left behind. Hence there is no hard constraint.

It will work with whatever was left behind in the case of SLUB and a 
kmalloc alloc (optimization there). It wont if its SLAB (which is 
stricter) or a kmalloc_node alloc. A kmalloc_node alloc will remove the 
current cpuslab if its not on the right now.


> > > >From what I can see, it takes pretty much any page it can get once you
> > > hit it with PF_MEMALLOC. If the page allocation doesn't use ALLOC_CPUSET
> > > the page can come from pretty much anywhere.
> > 
> > No it cannot. One the current cpuslab is exhaused (which can be anytime) 
> > it will enforce the contextual allocation constraints. See 
> > get_any_partial() in slub.c.
> 
> If it finds no partial slabs it goes back to the page allocator; and
> when you allocate a page under PF_MEMALLOC and the normal allocations
> are exhausted it takes a page from pretty much anywhere.

If it finds no partial slab then it will go to the page allocator which 
will allocate given the current contextual alloc constraints. In the case 
of a memory policy we may have limited the allocations to a single node 
where there is no escape (the zonelist does *not* contain zones of other 
nodes). The only chance to bypass this is by only dealing with allocations 
during interrupt that have no allocation context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
