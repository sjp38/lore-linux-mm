Date: Fri, 31 Mar 2006 16:00:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-Id: <20060331160032.6e437226.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
	<20060331150120.21fad488.akpm@osdl.org>
	<Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
	<20060331153235.754deb0c.akpm@osdl.org>
	<Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Fri, 31 Mar 2006, Andrew Morton wrote:
> 
> > > System sluggish in general. cscope takes 20 minutes to start etc. Dropping 
> > > the caches restored performance.
> > 
> > OK.  What sort of system was it, and what was the workload?  FIlesystem types?
> 
> A build server. Lots of scripts running, compilers etc etc.

Interesting.    Many CPUs?

> > It's been like that for an awful long time.  Can you think why this has
> > only just now been noticed?
> 
> Testing has reached new level of thoroughness because of the new releases 
> that are due soon...
> 
> > > We just noticed general sluggishness and took some stackdumps to see what 
> > > the system was up to.
> > 
> > OK.  But was it D-state sleep (semaphore lock contention) or what?
> 
> Yes, lots of processes waiting on semaphores in 
> shrink_slab->shrink_icache_memory. Need to look at this in more detail it 
> seems.

Please.  Or at least suggest a means-of-reproducing.

A plain old sysrq-T would be great.  That'll tell us who owns iprune_sem,
and what he's up to while holding it.  Actually five-odd sysrq-T's would be
better.

If the lock holder is stuck on disk I/O or a congested queue or something
then that's very different from the lock holder being in a
pointlessly-burn-CPU-scanning-stuff condition.

> I looked at the old release that worked. Seems that it did the same thing 
> in terms of slab shrinking. Concurrent slab shrinking was no problem. So 
> you may be right. Its something unrelated to the code in vmscan.c. Maybe 
> Nick knows something about this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
