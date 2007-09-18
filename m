Subject: Re: [PATCH/RFC 1/14] Reclaim Scalability:  Convert anon_vma lock
	to read/write lock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070917110234.GF25706@skynet.ie>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205405.6536.37532.sendpatchset@localhost>
	 <20070917110234.GF25706@skynet.ie>
Content-Type: text/plain
Date: Tue, 18 Sep 2007 16:17:21 -0400
Message-Id: <1190146641.5035.80.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 12:02 +0100, Mel Gorman wrote:
> On (14/09/07 16:54), Lee Schermerhorn didst pronounce:
> > [PATCH/RFC] 01/14 Reclaim Scalability:  Convert anon_vma list lock a read/write lock
> > 
> > Against 2.6.23-rc4-mm1
> > 
> > Make the anon_vma list lock a read/write lock.  Heaviest use of this
> > lock is in the page_referenced()/try_to_unmap() calls from vmscan
> > [shrink_page_list()].  These functions can use a read lock to allow
> > some parallelism for different cpus trying to reclaim pages mapped
> > via the same set of vmas.
> > 
> > This change should not change the footprint of the anon_vma in the
> > non-debug case.
> > 
> > Note:  I have seen systems livelock with all cpus in reclaim, down
> > in page_referenced_anon() or try_to_unmap_anon() spinning on the
> > anon_vma lock.  I have only seen this with the AIM7 benchmark with
> > workloads of 10s of thousands of tasks.  All of these tasks are
> > children of a single ancestor, so they all share the same anon_vma
> > for each vm area in their respective mm's.  I'm told that Apache
> > can fork thousands of children to handle incoming connections, and
> > I've seen similar livelocks--albeit on the i_mmap_lock [next patch]
> > running 1000s of Oracle users on a large ia64 platform.
> > 
> > With this patch [along with Rik van Riel's split LRU patch] we were
> > able to see the AIM7 workload start swapping, instead of hanging,
> > for the first time.  Same workload DID hang with just Rik's patch,
> > so this patch is apparently useful.
> > 
> 
> In light of what Peter and Linus said about rw-locks being more expensive
> than spinlocks, we'll need to measure this with some benchmark. The plus
> side is that this patch can be handled in isolation because it's either a
> scalability fix or it isn't. It's worth investigating because you say it
> fixed a real problem where under load the job was able to complete with
> this patch and live-locked without it.
> 
> kernbench is unlikely to show up anything useful here although it might be
> worth running anyway just in case. brk_test from aim9 might be useful as it's
> a micro-benchmark that uses brk() which is a path affected by this patch. As
> aim7 is exercising this path, it would be interesting to see does it show
> performance differences in the normal non-stressed case. Other suggestions?

As Mel predicted, kernel builds don't seem to be affected by this patch,
nor the i_mmap_lock rw_lock patch.  Below I've included results for an
old ia64 system that I have pretty much exclusive access to.  I can't
get 23-rc4-mm1 nor rc6-mm1 to boot on an x86_64 [AMD-based] right
now--still trying to capture stack trace [not easy from a remote
console :-(].  

I don't have access to the large server with storage for testing Oracle
and AIM right now.  When I get it back, I will try both of these patches
both for any added overhead and to verify that they alleviate the
problem they're trying to solve.  [I do have evidence that the anon_vma
rw lock improves the situation with AIM7 on a ~21-rcx kernel earlier
this year].

These times are the average [+ std dev'n] of 10 consecutive runs after
reboot of a '-j32' build of ia64 defconfig.

23-rc4-mm1 - no rmap rw_lock -- i.e., spinlocks
	 Real	  User	 System
	101.94	1205.10	  92.85 
	  0.56	   1.04	  0.73

23-rc4-mm1 w/ anon_vma rw_lock
	 Real	  User	 System
	101.64	1205.36	  91.83
	  0.65	   0.59	   0.67

23-rc4-mm1 w/ i_mmap_lock rw_lock
	 Real	  User	 System
	101.70	1204.57	  92.20
	  0.51	   0.73	  0.39

This is a NUMA system, so the differences are more like the result of
differences in locality--roll of the dice--than the lock types.

More data later, when I get it...

Lee

	





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
