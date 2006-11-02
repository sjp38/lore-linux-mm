Date: Wed, 1 Nov 2006 16:22:21 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061101162221.f110b56a.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611011522370.16073@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<20061027190452.6ff86cae.akpm@osdl.org>
	<Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	<20061027192429.42bb4be4.akpm@osdl.org>
	<Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
	<20061027214324.4f80e992.akpm@osdl.org>
	<Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
	<20061028180402.7c3e6ad8.akpm@osdl.org>
	<Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
	<4544914F.3000502@yahoo.com.au>
	<20061101182605.GC27386@skynet.ie>
	<20061101123451.3fd6cfa4.akpm@osdl.org>
	<Pine.LNX.4.64.0611011255070.14406@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611012210290.29614@skynet.skynet.ie>
	<Pine.LNX.4.64.0611011522370.16073@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Nov 2006 15:29:11 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 1 Nov 2006, Mel Gorman wrote:
> 
> > > I still think that we need to generalize the approach to be
> > > able to cover as much memory as possible. Remapping can solve some of the
> > > issues, for others we could add additional ways to make things movable.
> > > F.e. one could make page table pages movable by adding a back pointer to
> > > the mm, reclaimable slab pages by adding a move function, driver
> > > allocations could have a backpointer to the driver that would be able to
> > > move its memory.
> > 
> > I got the impression that we wouldn't be allowed to introduce such a mechanism
> > because driver writers would get it wrong. It was why proper defragmentation
> > was never really implemented.
> 
> I think that choice is better than fiddling with the VM by adding 
> additional zones which will introduce lots of other problems.

What lots of other problems?  64x64MB zones works good.

> The ability to move memory in general is beneficial for many purposes. 
> Defragmentation is certainly one of them. If all memory would be movable 
> then you would not need the separate list in the zone either.
> 
> Maybe we can have special mempools for unreclaimable 
> allocations for starters and with that have the rest of memory be 
> movable? Then we can gradually reduce the need for unreclaimable memory. 
> Maybe we can keep unmovable memory completely out of the page allocator?
> 
> With that approach we would not break the NUMA layer because we can keep 
> the one zone per node approach for memory policies. The special 
> unreclaimable memory would not obey memory policies (which makes sense 
> since device driverws do not want user space policies applied to their 
> allocations anyways. Device drivers need memory near the device).
> 
> > > Hmm.... Maybe generally a way to provide a
> > > function to move data in the page struct for kernel allocations?
> > > 
> > As devices are able to get physical addresses which then get pinned for IO, it
> > gets messy.
> 
> Right. So the device needs to disengage and then move its structures.

I don't think we have a snowball's chance of making all kernel memory
relocatable.  Or even a useful amount of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
