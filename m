Date: Mon, 21 May 2007 14:04:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179780873.7019.65.camel@twins>
Message-ID: <Pine.LNX.4.64.0705211358210.28867@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>  <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
  <20070517175327.GX11115@waste.org>  <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
  <1179429499.2925.26.camel@lappy>  <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
  <1179437209.2925.29.camel@lappy>  <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
  <1179482054.2925.52.camel@lappy>  <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
  <1179650384.7019.33.camel@twins>  <Pine.LNX.4.64.0705210932500.25871@schroedinger.engr.sgi.com>
  <1179776038.5735.39.camel@lappy>  <Pine.LNX.4.64.0705211239300.27622@schroedinger.engr.sgi.com>
  <1179778127.7019.48.camel@twins>  <Pine.LNX.4.64.0705211326290.28504@schroedinger.engr.sgi.com>
 <1179780873.7019.65.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Jackson <pj@sgi.com>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 21 May 2007, Peter Zijlstra wrote:

> > Yes sure if we do not have a context then no restrictions originating 
> > there can be enforced. So you want to restrict the logic now to
> > interrupt allocs? I.e. GFP_ATOMIC?
> 
> No, any kernel alloc.

Then we have the problem again.

> > Correct. That is an optimization but it may be called anytime from the 
> > perspective of an execution thread and that may cause problems with your 
> > approach.
> 
> I'm not seeing how this would interfere; if the alloc can be handled
> from a partial slab, that is fine.

There is no guarantee that a partial slab is available.
 
> > In the case 
> > of a memory policy we may have limited the allocations to a single node 
> > where there is no escape (the zonelist does *not* contain zones of other 
> > nodes). 
> 
> Ah, this is the point I was missing; I assumed each zonelist would
> always include all zones, but would just continue/break the loop using
> things like cpuset_zone_allwed_*().
> 
> This might indeed foil the game.
> 
> I could 'fix' this by doing the PF_MEMALLOC allocation from the regular
> node zonelist instead of from the one handed down....

I wonder if this makes any sense at all given that the only point of 
what you are doing is to help to decide which alloc should fail...

> /me thinks out loud.. since direct reclaim runs in whatever process
> context was handed out we're stuck with whatever policy we started from;
> but since the allocations are kernel allocs - not userspace allocs, and
> we're in dire straights, it makes sense to violate the tasks restraints
> in order to keep the machine up.

The memory policy constraints may have been setup to cage in an 
application. It was setup to *stop* the application from using memory on 
other nodes. If you now allow that then the semantics of memory policies
are significantly changed. The cpuset constraints are sometimes not that 
hard but I better let Paul speak for them.

> memory policies are the only ones with 'short' zonelists, right? CPU
> sets are on top of whatever zonelist is handed out, and the normal
> zonelists include all nodes - ordered by distance

GFP_THISNODE can have a similar effect.

> > The only chance to bypass this is by only dealing with allocations 
> > during interrupt that have no allocation context.
> 
> But you just said that interrupts are not exempt from memory policies,
> and policies are the only ones that have 'short' zonelists. /me
> confused.

No I said that in an interrupt allocation we have no process context and 
therefore no cpuset or memory policy context. Thus no policies or cpusets
are applied to an allocation. You can allocate without restrictions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
