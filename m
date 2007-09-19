Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709171241290.28361@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1190055637.5460.105.camel@localhost>
	 <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
	 <1190057885.5460.134.camel@localhost>
	 <Pine.LNX.4.64.0709171241290.28361@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 19 Sep 2007 18:03:41 -0400
Message-Id: <1190239421.5301.72.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 12:43 -0700, Christoph Lameter wrote:
> On Mon, 17 Sep 2007, Lee Schermerhorn wrote:
> 
> > Yeah, I'll have to write a custom, multithreaded test for this, or
> > enhance memtoy to attach shm segments by id and run lots of them
> > together.  I'll try to get to it asap.  
> 
> Maybe my old pft.c tool would help:
> 
> http://lkml.org/lkml/2006/8/29/294


Christoph:

pft did help.  It didn't do exactly what I needed so I cloned it and
hacked the copy.  What I wanted it to do is:

* allocate a single large, page aligned mem area:  valloc()'d [was
malloc()] or shmem.  [maybe later use mmap(_ANONYMOUS)]

* optionally apply a vma policy to the region via mbind().  I want to be
able to test faulting with system default policy, task policy [via
numactl] and vma policy using mbind().

* fork off a single child so that we can collect rusage [fault count]
using RUSAGE_CHILDREN.  Your version created multiple children, but I
only need a single task with multiple threads to test vma policy
reference counting.  

* create multiple threads to touch and fault in different ranges of the
test memory region.  Pretty much what your pft already did.

I made a few more changes to allocate the memory region and do as much
setup outside the measurement interval as I could.

At some point, I might want to add back multiple tasks to test shmem
policy ref counting.  However, we always added a ref count to shmem on
allocation--we just never released it.  So the fix does add an extra
write to release the policy.  But, the biggest change is the taking of a
reference for vma policy, so this is what I wanted to test.

I've placed a tarball containing the original and modified pft, a
Makefile and a wrapper script to invoke pft with from 1 to <nr_cpus-1>
threads at:

	http://free.linux.hp.com/~lts/Tools/pft-0.01.tar.gz

I ran this modified version on my 16-cpu numa platform--therefore the
runs go from 1 to 15 threads each.  I ran for both valloc()d memory and
shmem [8GB each] with system default and vma policy, on an unpatched
2.6.24-rc4-mm1 and same with the ref counting patch.  Raw results and a
plot of the vmalloc()ed runs can be found at:

	http://free.linux.hp.com/~lts/Mempolicy/

I'll place a plot of the shmem runs there tomorrow.

Bottom line:  the run to run variability seems greater than the
difference between 23-rc4-mm1 with and without the patch.  Also, it
appears that the contention on the page table, and perhaps the
radix-tree in the shmem case, overshadow any differences due to the
reference counting.  Take a look and see what you think.

Perhaps you could grab the modified version and have it run on a larger
altix system.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
