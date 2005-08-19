Date: Fri, 19 Aug 2005 09:06:50 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Concept for delayed counter updates in mm_struct
In-Reply-To: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508190905270.14957@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Linus Torvalds wrote:

> On Thu, 18 Aug 2005, Andrew Morton wrote:
> > Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > > What is missing in this patch are points were mm_counter_catchup can be called.
> > > These points must be code where the page table lock is held. One way of providing
> > > these would be to call mm_counter_catchup when a task is in the scheduler.
> > That sounds sane.
> 
> But that patch doesn't work.
> 
> There's no locking around the scheduler. It's all per-CPU, and the only 
> exclusivity is in the per-rq locking.
> 
> So if you gather the mm counters in the scheduler, you'd need to do it all 
> with atomic ops. But you're still using the non-atomic add_mm_counter..

We can check the deltas and if they are nonzero take the page table lock 
and update the counters. If this is too much effort then we need to find 
out some other place hwere the page table lock is already taken.

> So you need to make those mm counters really atomic now. 

Thats what we are trying to avoid.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
