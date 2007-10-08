Subject: Re: VMA lookup with RCU
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200710071747.23252.nickpiggin@yahoo.com.au>
References: <46F01289.7040106@linux.vnet.ibm.com>
	 <470509F5.4010902@linux.vnet.ibm.com> <1191518486.5574.24.camel@lappy>
	 <200710071747.23252.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 08 Oct 2007 09:51:54 +0200
Message-Id: <1191829915.22357.95.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-10-07 at 17:47 +1000, Nick Piggin wrote:
> On Friday 05 October 2007 03:21, Peter Zijlstra wrote:
> > On Thu, 2007-10-04 at 21:12 +0530, Vaidyanathan Srinivasan wrote:
> 
> > > Per CPU last vma cache:  Currently we have the last vma referenced in a
> > > one entry cache in mm_struct.  Can we have this cache per CPU or per node
> > > so that a multi threaded application can have node/cpu local cache of
> > > last vma referenced.  This may reduce btree/rbtree traversal.  Let the
> > > hardware cache maintain the corresponding VMA object and its coherency.
> > >
> > > Please let me know your comment and thoughts.
> >
> > Nick Piggin (and I think Eric Dumazet) had nice patches for this. I
> > think they were posted in the private futex thread.
> 
> All they need is testing and some results to show they help. I actually
> don't really have a realistic workload where vma lookup contention is
> a problem, since the malloc fixes and private futexes went in.
> 
> Actually -- there is one thing, apparently oprofile does lots of find_vmas,
> which trashes the vma cache. Either it should have its own cache, or at
> least use a "nontemporal" lookup.
> 
> What I implemented was a per-thread cache. Per-CPU I guess would be
> equally possible and might be preferable in some cases (although worse
> in others). Still, the per-thread cache should be fine for basic performance
> testing.

Apparently our IBM friends on this thread have a workload where mmap_sem
does hurt, and I suspect its a massively threaded Java app on a somewhat
larger box (8-16 cpus), which does a bit of faulting around.

But I'll let them tell about it :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
