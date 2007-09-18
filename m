Subject: Re: [PATCH/RFC 1/14] Reclaim Scalability:  Convert anon_vma lock
	to read/write lock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070918114142.abbd5421.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205405.6536.37532.sendpatchset@localhost>
	 <20070917110234.GF25706@skynet.ie>
	 <20070918114142.abbd5421.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 18 Sep 2007 11:37:23 -0400
Message-Id: <1190129844.5035.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-18 at 11:41 +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 17 Sep 2007 12:02:35 +0100
> mel@skynet.ie (Mel Gorman) wrote:
> 
> > On (14/09/07 16:54), Lee Schermerhorn didst pronounce:
> > > [PATCH/RFC] 01/14 Reclaim Scalability:  Convert anon_vma list lock a read/write lock
> > > 
> > > Against 2.6.23-rc4-mm1
> > > 
> > > Make the anon_vma list lock a read/write lock.  Heaviest use of this
> > > lock is in the page_referenced()/try_to_unmap() calls from vmscan
> > > [shrink_page_list()].  These functions can use a read lock to allow
> > > some parallelism for different cpus trying to reclaim pages mapped
> > > via the same set of vmas.
> <snip>
> > In light of what Peter and Linus said about rw-locks being more expensive
> > than spinlocks, we'll need to measure this with some benchmark. The plus
> > side is that this patch can be handled in isolation because it's either a
> > scalability fix or it isn't. It's worth investigating because you say it
> > fixed a real problem where under load the job was able to complete with
> > this patch and live-locked without it.
> >
> > When you decide on a test-case, I can test just this patch and see what
> > results I find.
> > 
> 
> One of the case I can imagine is..
> ==
> 1. Use NUMA.
> 2. create *large* anon_vma and use it with MPOL_INTERLEAVE
> 3. When memory is exhausted (on several nodes), all kswapd on nodes will
>    see one anon_vma->lock.
> ==
> Maybe the worst case.

Actually, if you only have one mm/vma mapping the area, it won't be that
bad.  You'll still have contention on the spinlock, but with only one
vma mapping it, page_referenced_anon() and try_to_unmap_anon() will be
relatively fast.  The problem we've seen is when you have lots [10s of
thousands] of vmas referencing the same anon_vma.  This occurs when the
tasks are all descendants of a single original parent w/o exec()ing. 

I've only seen this with the AIM7 benchmark.  This is the workload that
was able to make progress with this patch, but the system hung
indefinitely without it.  But, AIM7 is not necessarily something we want
to optimize for.  However, I've been told that Apache can exhibit
similar behavior with thousands of in-coming connections.  Anyone know
if this is true?

I HAVE seen similar behavior in a high-user count Oracle OLTP workload,
but on the file rmap--the i_mmap_lock--in page_referenced_file(), etc.
That's probably worth fixing.

I'm in the process of running a series of parallel kernel builds on
kernels without the rmap rw_lock patches, and then with each one
individually.  This load doesn't exhibit the problem these patches are
intended to address, but kernel builds do fork a lot of children that
should result in a lot of vma linking/unlinking [but maybe not if using
vfork()].  Similar for the i_mmap_lock.  This lock is also used to
protect the truncate_count, so it must be taken for write in this
context--mostly in unmap_mapping_range*().  

I'll post the results as soon as I have them for both ia64 and x86_64.
Later today.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
