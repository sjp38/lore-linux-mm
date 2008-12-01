Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1GMN3b015117
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:22:23 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1GMjE9172334
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:22:45 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1HMsOw010267
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 12:22:54 -0500
Date: Mon, 1 Dec 2008 08:22:44 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
Message-ID: <20081201162244.GA10922@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1227886959.4454.4421.camel@twins> <Pine.LNX.4.64.0812010747100.11954@quilx.com> <1228142895.7140.43.camel@twins> <Pine.LNX.4.64.0812010857040.15331@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812010857040.15331@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 09:06:10AM -0600, Christoph Lameter wrote:
> On Mon, 1 Dec 2008, Peter Zijlstra wrote:
> > > srcu may have too much of an overhead for this.
> >
> > Then we need to fix that ;-) But surely SRCU is cheaper than mmap_sem.
> 
> Holding off frees for a long time (sleeping???) is usually bad for cache
> hot behavior. It introduces cacheline refetches. Avoid if possible.

This is a classic tradeoff.  Cache misses from mmap_sem vs. cache misses
from accessing newly allocated memory that was freed via RCU (and thus
was ejected from the CPU cache).

This is one reason why RCU is specialized for read-mostly situations.
In read-mostly situations, the savings due to avoiding cache-thrashy
locking primitives can outweigh the cache-cold effects due to memory
waiting for an RCU grace period to elapse.  Plus RCU does not suffer
so much from lock contention (for exclusive locks or write-acquisitions
of reader-writer locks) or cache thrashing (for locks in general and
also most atomic operations).

Your mileage may vary, so use the best tool for the job.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
