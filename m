Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709131128050.9546@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <20070905114242.GA19938@wotan.suse.de>
	 <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
	 <1189594373.21778.114.camel@twins>
	 <Pine.LNX.4.64.0709121540370.4067@schroedinger.engr.sgi.com>
	 <1189671552.21778.158.camel@twins>
	 <Pine.LNX.4.64.0709131128050.9546@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 21:24:33 +0200
Message-Id: <1189711473.5643.18.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 11:32 -0700, Christoph Lameter wrote:
> On Thu, 13 Sep 2007, Peter Zijlstra wrote:
> 
> > 
> > > > Every user of memory relies on the VM, and we only get into trouble if
> > > > the VM in turn relies on one of these users. Traditionally that has only
> > > > been the block layer, and we special cased that using mempools and
> > > > PF_MEMALLOC.
> > > > 
> > > > Why do you object to me doing a similar thing for networking?
> > > 
> > > I have not seen you using mempools for the networking layer. I would not 
> > > object to such a solution. It already exists for other subsystems.
> > 
> > Dude, listen, how often do I have to say this: I cannot use mempools for
> > the network subsystem because its build on kmalloc! What I've done is
> > build a replacement for mempools - a reserve system - that does work
> > similar to mempools but also provides the flexibility of kmalloc.
> > 
> > That is all, no more, no less.
> 
> Its different since it becomes a privileged player that can suck all 
> the available memory out of the page allocator.

No, each reserve user comes with a bean-counter that will limit the
usage.

> > I'm confused by this, I've never claimed part of, or such a thing. All
> > I'm saying is that because of the circular dependency between the VM and
> > the IO subsystem used for swap (not file backed paging [*], just swap)
> > you have to do something special to avoid deadlocks.
> 
> How are dirty file backed pages different? They may also be written out 
> by the VM during reclaim.

when you have dirty file backed pages, the rest of the memory can only
consists of clean file pages and or anonymous pages - due to the dirty
limit. If you can guarantee that swap doesn't use memory (well, it does,
but its PF_MEMALLOC memory that cannot be used by others) then you can
always free memory by dropping clean pages or swapping out. And thus
make progress for file based writeback.

This is why the dirty page tracking made mmap over NFS useable.

> > > Replacing the mempools for the block layer sounds pretty good. But how do 
> > > these various subsystems that may live in different portions of the system 
> > > for various devices avoid global serialization and livelock through your 
> > > system? 
> > 
> > The reserves are spread over all kernel mapped zones, the slab allocator
> > is still per cpu, the page allocator tries to get pages from the nearest
> > node.
> 
> But it seems that you have unbounded allocations with PF_MEMALLOC now for 
> the networking case? So networking can exhaust all reserves?

No, networking will beancount all PF_MEMALLOC memory it receives, and
stop allocating once it hits it limit. It knows that when it has than
much memory outstanding its guaranteed memory will be freed soon.

> > > And how is fairness addresses? I may want to run a fileserver on 
> > > some nodes and a HPC application that relies on a fiberchannel connection 
> > > on other nodes. How do we guarantee that the HPC application is not 
> > > impacted if the network services of the fileserver flood the system with 
> > > messages and exhaust memory?
> > 
> > The network system reserves A pages, the block layer reserves B pages,
> > once they start getting pages from the reserves they go bean counting,
> > once they reach their respective limit they stop.
> 
> That sounds good.

Ok, so next time I'll post the whole series again - I know some people
found it too much - but that way you can see the bean counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
