Date: Tue, 5 Dec 2006 12:48:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: la la la la ... swappiness
Message-Id: <20061205124859.333d980d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612051207240.18863@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
	<Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
	<20061205085914.b8f7f48d.akpm@osdl.org>
	<f353cb6c194d4.194d4f353cb6c@texas.rr.com>
	<Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
	<Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
	<20061205120256.b1db9887.akpm@osdl.org>
	<Pine.LNX.4.64.0612051207240.18863@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 12:15:46 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 5 Dec 2006, Andrew Morton wrote:
> 
> > But otoh, it's a very common scenario, and nobody has observed it before. 
> 
> This is the same scenario as mlocked memory.

Not quite - mlocked pages are on the page LRU and hence contribute to the
arithmetic in there.   The hugetlb pages are simply gone.

> Kame-san has recently posted 
> an occurence in ZONE_DMA. I have 3 customers where I have seen similar VM 
> behavior with a special shared memory thingy locking down lots of 
> memory.

I expect the mechanisms are different.  The mlocked shared-memory segment
will fill the LRU with unreclaimable pages and the machine will do lots of
scanning.  That's inefficient, but it is unexpected that this will lead to
fals declaration of OOM.

> In fact in the NUMA case with cpusets the limits being off is a very 
> common problem. F.e. the dirty balancing logic does not take into account 
> that the application can just run on a subset of the machine.

Yup.

> So if a 
> cpuset is just 1/10th of the whole machine then we will never be able to 
> reach the dirty limits, all the nodes of a cpuset may be filled up with 
> dirty pages. A simple cp of a large file will bring the machine into a 
> continual reclaim on all nodes.

It shouldn't be continual and it shouldn't be on all nodes.  What _should_
happen in this situation is that the dirty pages in those zones are written
back off the LRU by the vm scanner.

That's less efficient from an IO scheduling POV than writing them back via
the inodes, but it should work OK and it shouldn't affect other zones.

If the activity is really "continual" and "on all nodes" then we have some
bugs to fix.

> I am working on a solution for the dirty throttling but we have similar 
> issues for the other limits. I wonder if we should not account for 
> unreclaimable memory per zone and recalculate the limits if they change 
> significantly. A series of huge page allocations would then retune the 
> limits.

We should fix the existing code before even thinking about this sort of
thing.  Or at least, gain a full understanding of why it is failing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
