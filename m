MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18410.62354.643308.84737@cargo.ozlabs.ibm.com>
Date: Thu, 27 Mar 2008 12:08:34 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: larger default page sizes...
In-Reply-To: <alpine.LFD.1.00.0803260854350.2775@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<87wsnrgg9q.fsf@basil.nowhere.org>
	<18409.56843.909298.717089@cargo.ozlabs.ibm.com>
	<alpine.LFD.1.00.0803260854350.2775@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds writes:

> On Wed, 26 Mar 2008, Paul Mackerras wrote:
> > 
> > So the improvement in the user time is almost all due to the reduced
> > TLB misses (as one would expect).  For the system time, using 64k
> > pages in the VM reduces it by about 21%, and using 64k hardware pages
> > reduces it by another 30%.  So the reduction in kernel overhead is
> > significant but not as large as the impact of reducing TLB misses.
> 
> I realize that getting the POWER people to accept that they have been 
> total morons when it comes to VM for the last three decades is hard, but 
> somebody in the POWER hardware design camp should (a) be told and (b) be 
> really ashamed of themselves.
> 
> Is this a POWER6 or what? Becasue 21% overhead from TLB handling on 
> something like gcc shows that some piece of hardware is absolute crap. 

You have misunderstood the 21% number.  That number has *nothing* to
do with hardware TLB miss handling, and everything to do with how long
the generic Linux virtual memory code spends doing its thing (page
faults, setting up and tearing down Linux page tables, etc.).  It
doesn't even have anything to do with the hash table (hardware page
table), because both cases are using 4k hardware pages.  Thus in both
cases the TLB misses and hash-table misses would have been the same.

The *only* difference between the cases is the page size that the
generic Linux virtual memory code is using.  With the 64k page size
our architecture-independent kernel code runs 21% faster.

Thus the 21% is not about the TLB or any hardware thing at all, it's
about the larger per-byte overhead of our kernel code when using the
smaller page size.

The thing you were ranting about -- hardware TLB handling overhead --
comes in at 5%, comparing 4k hardware pages to 64k hardware pages (444
seconds vs. 420 seconds user time for the kernel compile).  And yes,
it's a POWER6.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
