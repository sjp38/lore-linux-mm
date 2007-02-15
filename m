Date: Thu, 15 Feb 2007 01:07:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: NUMA replicated pagecache
Message-ID: <20070215000709.GA29797@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de> <Pine.LNX.4.64.0702141052350.975@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702141052350.975@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 14, 2007 at 10:57:00AM -0800, Christoph Lameter wrote:
> On Tue, 13 Feb 2007, Nick Piggin wrote:
> 
> > Just tinkering around with this and got something working, so I'll see
> > if anyone else wants to try it.
> > 
> > Not proposing for inclusion, but I'd be interested in comments or results.
> 
> We would be very interested in such a feature. We have another hack that 
> shows up to 40% performance improvements.
> 
> > At the moment the code is a bit ugly, but it won't take much to make it a
> > completely standalone ~400 line module with just a handful of hooks into
> > the core mm. So if anyone really wants it, it could be quite realistic to
> > get into an includable form.
> 
> Would be great but I am a bit skeptical regarding the locking and the 
> additonal overhead moving back and forth between replications and non 
> replicated page state.

Locking is obviously ugly now. It can get better.

Replicating at any possible opportunity is probably not a good idea for
a real system. We need hints from userspace and/or kernelspace heuristics.
I'm just trying to get the mechanism working, though.

> 
> > At some point I did take a look at Dave Hansen's page replication patch for
> > ideas, but didn't get far because he was doing a per-inode scheme and I was
> > doing per-page. No judgments on which approach is better, but I feel this
> > per-page patch is quite neat.
> 
> Definitely looks better.
> 
> > - Would be nice to transfer master on reclaim. This should be quite easy,
> >   must transfer relevant flags, and only if !PagePrivate (which reclaim
> >   takes care of).
> 
> Transfer master? Meaning you need to remove the replicated pages? Removing 
> of replicated pages should transfer reference bit?

Yeah, I want to keep a master page so that we can replicate pages with
priviate filesystem data. But in the case that the master is !PagePrivate,
we should be able to reclaim it without collapsing the replication.

> > - Should go nicely with lockless pagecache, but haven't merged them yet.
> 
> When is that going to happen? Soon I hope?

I'll submit it again and see what happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
