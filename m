Date: Sat, 11 Feb 2006 01:32:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211013255.20832152.akpm@osdl.org>
In-Reply-To: <20060211045355.GA3318@dmt.cnet>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: clameter@engr.sgi.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> 
> Hi Christoph,
> 
> On Thu, Feb 09, 2006 at 09:02:00PM -0800, Christoph Lameter wrote:
> > This is done through a variety of measures:
> > 
> > 1. nr_reclaimed is the return value of functions and each function
> >    does the summing of the reclaimed pages on its own.
> > 
> > 2. nr_scanned is passed as a reference parameter (sigh... the only leftover)
> > 
> > 3. nr_mapped is calculated on each invocation of refill_inactive_list. 
> >    This is not that optimal but then swapping is not that performance 
> >    critical.
> 
> But refill_inactive_list() is not used for swapping only. All evicted 
> pages go through that path - it can be _very_ hot.

A bit hot.  I guess it's worth fixing.

> > 4. gfp_mask is passed as a parameter. OR flags to gfp_mask for may_swap 
> >    and may_writepage.
> > 
> > 5. Pass swap_cluster_max as a parameter
> > 
> > Most of the parameters passed through scan_control become local variables.
> > Therefore the compilers are able to generate better code.
> > 
> > And we do no longer have the problem of initializing scan control the
> > right way.
> 
> I don't think its worth doing that - do you have any performance
> measurement and analysis of the generated code? Is the current code a
> bottleneck for any of your applications?

This patch isn't a performance thing.  I found that scan_control wasn't
really a success.  We had one bug due to failing to initialise something in
it, and we're fiddling with fields all over the place.  It just seemed to
obfuscate the code, make it harder to work with, harder to check that
everything was correct.

Kind of like global variables, really.

> One very nice thing about "scan_control" is that it aggregates all
> parameters related to reclaim procedure instances, making the code
> much clearer, easier to understand, and elegant. Moreover it allows
> expandability: new parameters can be contained within the structure.

Well yes, it allows for expansion.  But my experience was the exact
opposite of what you're saying.

scan_control was modelled on writeback_control.  But writeback_control
works, and scan_control doesn't.  I think this is because a)
writeback_control instances are always initialised at the declaration site
and b) writeback_control is just a lot simpler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
