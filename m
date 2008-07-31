From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Date: Thu, 31 Jul 2008 16:26:15 +1000
References: <cover.1216928613.git.ebmunson@us.ibm.com> <200807311604.14349.nickpiggin@yahoo.com.au> <20080730231428.a7bdcfa7.akpm@linux-foundation.org>
In-Reply-To: <20080730231428.a7bdcfa7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807311626.15709.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thursday 31 July 2008 16:14, Andrew Morton wrote:
> On Thu, 31 Jul 2008 16:04:14 +1000 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > > Do we expect that this change will be replicated in other
> > > memory-intensive apps?  (I do).
> >
> > Such as what? It would be nice to see some numbers with some HPC or java
> > or DBMS workload using this. Not that I dispute it will help some cases,
> > but 10% (or 20% for ppc) I guess is getting toward the best case, short
> > of a specifically written TLB thrasher.
>
> I didn't realise the STREAM is using vast amounts of automatic memory.
> I'd assumed that it was using sane amounts of stack, but the stack TLB
> slots were getting zapped by all the heap-memory activity.  Oh well.

An easy mistake to make because that's probabably how STREAM would normally
work. I think what Mel had done is to modify the stream kernel so as to
have it operate on arrays of stack memory.


> I guess that effect is still there, but smaller.

I imagine it should be, unless you're using a CPU with seperate TLBs for
small and huge pages, and your large data set is mapped with huge pages,
in which case you might now introduce *new* TLB contention between the
stack and the dataset :)

Also, interestingly I have actually seen some CPUs whos memory operations
get significantly slower when operating on large pages than small (in the
case when there is full TLB coverage for both sizes). This would make
sense if the CPU only implements a fast L1 TLB for small pages.

So for the vast majority of workloads, where stacks are relatively small
(or slowly changing), and relatively hot, I suspect this could easily have
no benefit at best and slowdowns at worst.

But I'm not saying that as a reason not to merge it -- this is no
different from any other hugepage allocations and as usual they have to be
used selectively where they help.... I just wonder exactly where huge
stacks will help.


> I agree that few real-world apps are likely to see gains of this
> order.  More benchmarks, please :)

Would be nice, if just out of morbid curiosity :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
