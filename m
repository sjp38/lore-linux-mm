Date: Tue, 16 Jan 2007 16:16:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/8] Cpuset aware writeback
In-Reply-To: <20070116154054.e655f75c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701161602480.4263@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
 <20070116135325.3441f62b.akpm@osdl.org> <Pine.LNX.4.64.0701161407530.3545@schroedinger.engr.sgi.com>
 <20070116154054.e655f75c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Andrew Morton wrote:

> It's a workaround for a still-unfixed NFS problem.

No its doing proper throttling. Without this patchset there will *no* 
writeback and throttling at all. F.e. lets say we have 20 nodes of 1G each
and a cpuset that only spans one node.

Then a process runniung in that cpuset can dirty all of memory and still 
continue running without writeback continuing. background dirty ratio
is at 10% and the dirty ratio at 40%. Neither of those boundaries can ever
be reached because the process will only ever be able to dirty memory on 
one node which is 5%. There will be no throttling, no background 
writeback, no blocking for dirty pages.

At some point we run into reclaim (possibly we have ~99% of of the cpuset 
dirty) and then we trigger writeout. Okay so if the filesystem / block 
device is robust enough and does not require memory allocations then we 
likely will survive that and do slow writeback page by page from the LRU.

writback is completely hosed for that situation. This patch restores 
expected behavior in a cpuset (which is a form of system partition that 
should mirror the system as a whole). At 10% dirty we should start 
background writeback and at 40% we should block. If that is done then even 
fragile combinations of filesystem/block devices will work as they do 
without cpusets.


> > Yes we can fix these allocations by allowing processes to allocate from 
> > other nodes. But then the container function of cpusets is no longer 
> > there.
> But that's what your patch already does!

The patchset does not allow processes to allocate from other nodes than 
the current cpuset. There is no change as to the source of memory 
allocations.
 
> > NFS is okay as far as I can tell. dirty throttling works fine in non 
> > cpuset environments because we throttle if 40% of memory becomes dirty or 
> > under writeback.
> 
> Repeat: NFS shouldn't go oom.  It should fail the allocation, recover, wait
> for existing IO to complete.  Back that up with a mempool for NFS requests
> and the problem is solved, I think?

AFAIK any filesyste/block device can go oom with the current broken 
writeback it just does a few allocations. Its a matter of hitting the 
sweet spots.

> But we also can get into trouble if a *zone* is all-dirty.  Any solution to
> the cpuset problem should solve that problem too, no?

Nope. Why would a dirty zone pose a problem? The proble exist if you 
cannot allocate more memory. If a cpuset contains a single node which is a 
single zone then this patchset will also address that issue.

If we have multiple zones then other zones may still provide memory to 
continue (same as in UP).

> > Yes, but when we enter reclaim most of the pages of a zone may already be 
> > dirty/writeback so we fail.
> 
> No.  If the dirty limits become per-zone then no zone will ever have >40%
> dirty.

I am still confused as to why you would want per zone dirty limits?

Lets say we have a cpuset with 4 nodes (thus 4 zones) and we are running 
on the first node. Then we copy a large file to disk. Node local 
allocation means that we allocate from the first node. After we reach 40% 
of the node then we throttle? This is going to be a significant 
performance degradation since we can no longer use the memory of other 
nodes to buffer writeout.

> The obvious fix here is: when a zone hits 40% dirty, perform dirty-memory
> reduction in that zone, throttling the dirtying process.  I suspect this
> would work very badly in common situations with, say, typical i386 boxes.

Absolute crap. You can prototype that broken behavior with zone reclaim by 
the way. Just switch on writeback during zone reclaim and watch how memory 
on a cpuset is unused and how the system becomes slow as molasses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
