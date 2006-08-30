Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7U2Q6wl003414
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 22:26:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7U2Q6YW297380
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 20:26:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7U2Q6kF027511
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 20:26:06 -0600
Date: Tue, 29 Aug 2006 19:26:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: libnuma interleaving oddness
Message-ID: <20060830022621.GA5195@us.ibm.com>
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com> <20060830002110.GZ5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060830002110.GZ5195@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 29.08.2006 [17:21:10 -0700], Nishanth Aravamudan wrote:
> On 29.08.2006 [16:57:35 -0700], Christoph Lameter wrote:
> > On Tue, 29 Aug 2006, Nishanth Aravamudan wrote:
> > 
> > > I don't know if this is a libnuma bug (I extracted out the code from
> > > libnuma, it looked sane; and even reimplemented it in libhugetlbfs
> > > for testing purposes, but got the same results) or a NUMA kernel bug
> > > (mbind is some hairy code...) or a ppc64 bug or maybe not a bug at
> > > all.  Regardless, I'm getting somewhat inconsistent behavior. I can
> > > provide more debugging output, or whatever is requested, but I
> > > wasn't sure what to include. I'm hoping someone has heard of or seen
> > > something similar?
> > 
> > Are you setting the tasks allocation policy before the allocation or
> > do you set a vma based policy? The vma based policies will only work
> > for anonymous pages.
> 
> The order is (with necessary params filled in):
> 
> p = mmap( , newsize, RW, PRIVATE, unlinked_hugetlbfs_heap_fd, );
> 
> numa_interleave_memory(p, newsize);
> 
> mlock(p, newsize); /* causes all the hugepages to be faulted in */
> 
> munlock(p,newsize);
> 
> From what I gathered from the numa manpages, the interleave policy
> should take effect on the mlock, as that is "fault-time" in this
> context. We're forcing the fault, that is.

For some more data, I did some manipulations of libhugetlbfs and came up
with the following:

If I use the default hugepage-aligned hugepage-backed malloc
replacement, I get the following in /proc/pid/numa_maps (excerpt):

20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
21000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
...
37000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1

If I change the nodemask to 1-7, I get:

20000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
21000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
22000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
23000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1
24000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N5=1
25000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N6=1
26000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N7=1
...
35000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
36000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
37000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
38000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1

If I then change our malloc implementation to (unnecessarily) mmap a
size aligned to 4 hugepages, rather aligned to a single hugepage, but
using a nodemask of 0-7, I get:

20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
24000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
28000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
2c000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
30000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
34000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=1 mapped=4 N0=1 N1=1 N2=1 N3=1

It seems rather odd that it's this inconsistent, and that I'm the only
one seeing it as such :)

Thanks,
Nish


-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
