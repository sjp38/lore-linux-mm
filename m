Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8NJOiAR001058
	for <linux-mm@kvack.org>; Sat, 23 Sep 2006 15:24:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8NJOc0Z218240
	for <linux-mm@kvack.org>; Sat, 23 Sep 2006 15:24:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8NJOcvq005385
	for <linux-mm@kvack.org>; Sat, 23 Sep 2006 15:24:38 -0400
Subject: Re: One idea to free up page flags on NUMA
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
	 <200609231804.40348.ak@suse.de>
	 <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 23 Sep 2006 12:24:29 -0700
Message-Id: <1159039469.24331.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-09-23 at 09:39 -0700, Christoph Lameter wrote:
> On Sat, 23 Sep 2006, Andi Kleen wrote:
> > And what would we use them for?
> 
> Maybe a container number?

I have a feeling this is better done at the more coarse objects like
address_spaces and vmas.

> Anyways the scheme also would reduce the number of lookups needed and 
> thus the general footprint of the VM using sparse.
> 
> I just looked at the arch code for i386 and x86_64 and it seems that both 
> already have page tables for all of memory. It seems that a virtual memmap 
> like this would just eliminate sparse overhead and not add any additional 
> page table overhead.

I'm not sure to what sparse overhead you are referring.  Its only
storage overhead is one pointer per SECTION_SIZE bytes of memory.  The
worst case scenario is 16MB sections on ppc64 with 16TB of memory.  

2^20 sections * 2^3 bytes/pointer = 2^23 bytes of sparse overhead, which
is 8MB.  That's pretty little overhead no matter how you look at it,
cache footprint, tlb load, etc...  Add to that the fact that we get some
extra things from sparsemem like pfn_valid() and the bookkeeping for
whether or not the memory is there (before the mem_map is actually
allocated), and it doesn't look too bad.

If someone can actually demonstrate some actual, measurable performance
problem with it, then I'm all ears.  I worry that anything else is just
potential overzealous micro-optimization trying to solve problems that
don't really exist.  Remember, sparsemem slightly beats discontigmem on
x86 NUMA hardware, so it isn't much of a dog to begin with.

Sparsemem is a ~100 line patch to port to a new architecture.  That code
is virtually all #defines and hooking into the pfn_to_page() mechanisms.
There's virtually no logic in there.  That's going to be hard to beat
with any kind of vmem_map[] approach.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
