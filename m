Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7U5VJ5P016817
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:31:19 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7U5VJ4i294564
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:31:19 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7U5VJbw032648
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:31:19 -0400
Date: Tue, 29 Aug 2006 22:31:34 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: libnuma interleaving oddness
Message-ID: <20060830053134.GB5195@us.ibm.com>
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com> <20060830002110.GZ5195@us.ibm.com> <20060830022621.GA5195@us.ibm.com> <Pine.LNX.4.64.0608292123230.23009@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608292123230.23009@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 29.08.2006 [21:26:58 -0700], Christoph Lameter wrote:
> On Tue, 29 Aug 2006, Nishanth Aravamudan wrote:
> 
> > If I use the default hugepage-aligned hugepage-backed malloc
> > replacement, I get the following in /proc/pid/numa_maps (excerpt):
> > 
> > 20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> > 21000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> > ...
> > 37000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> > 38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> 
> Is this with nodemask set to [0]?

nodemask was set to 0xFF, effectively, bits 0-7 set, all others cleared.
Just to make sure that I'm not misunderstanding, that's what the
interleave=0-7 also indicates, right? That the particular memory area
was specified to interleave over those nodes, if possible, and then at
the end of each line are the nodes that it actually was placed on?

> > If I change the nodemask to 1-7, I get:
> > 
> > 20000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
> > 21000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
> > 22000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
> > 23000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1
> > 24000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N5=1
> > 25000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N6=1
> > 26000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N7=1
> > ...
> > 35000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
> > 36000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
> > 37000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
> > 38000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1
> 
> So interleave has an effect.

Yup, exactly -- and that's the confusing part. I was willing to write it
off as being some sort of mistake on my part, but all I have to do is
clear any one bit between 0 and 7, and I get the interleaving I expect.
That's what leads me to conclude there is a bug, but after a lot of
looking at libnuma and the mbind() system call, I couldn't see the
problem.

> Are you using cpusets? Or are you only using memory policies? What is
> the default policy of the task you are running?

No cpusets, only memory policies. The test application that is
exhibiting this behavior is *really* simple, and doesn't specifically
set a memory policy, so I assume it's MPOL_DEFAULT?

> > If I then change our malloc implementation to (unnecessarily) mmap a
> > size aligned to 4 hugepages, rather aligned to a single hugepage,
> > but using a nodemask of 0-7, I get:
> > 
> > 20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 24000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 28000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 2c000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 30000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 34000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> > 38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=1 mapped=4 N0=1 N1=1 N2=1 N3=1
> 
> Hmm... Strange. Interleaving should continue after the last one....

"last one" being the last allocation, or the last node? My understanding
of what is happening in this case is that interleave is working, but in
a way different from the immediately previous example. Here we're
interleaving within the allocation, so each of the 4 hugepages goes on a
different node. When the next allocation comes through, we start back
over at node 0 (given the previous results, I would have thought it
would have gone N0,N1,N2,N3 then N4,N5,N6,N7 then back to N0,N1,N2,N3).

Also, note that in this last case, in case I wasn't clear before, I was
artificially inflating our consumption of hugepages per allocation, just
to see what happened.

I should also mention this is the SuSE kernel, too, so 2.6.16-ish. If
there are sufficient changes in this area between there and mainline, I
can try and get the box rebooted into 2.6.18-rc5.

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
