Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.0811301123320.24125@nehalem.linux-foundation.org>
References: <1227886959.4454.4421.camel@twins>
	 <alpine.LFD.2.00.0811301123320.24125@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Sun, 30 Nov 2008 20:42:04 +0100
Message-Id: <1228074124.24749.26.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-11-30 at 11:27 -0800, Linus Torvalds wrote:
> 
> On Fri, 28 Nov 2008, Peter Zijlstra wrote:
> > 
> > While pondering the page_fault retry stuff, I came up with the following
> > idea.
> 
> I don't know if your idea is any good, but this part of your patch is 
> utter crap:
> 
> 	-       if (!down_read_trylock(&mm->mmap_sem)) {
> 	-               if ((error_code & PF_USER) == 0 &&
> 	-                   !search_exception_tables(regs->ip))
> 	-                       goto bad_area_nosemaphore;
> 	-               down_read(&mm->mmap_sem);
> 	-       }
> 	-
> 	+       down_read(&mm->mmap_sem);
> 
> because the reason we do a down_read_trylock() is not because of any lock 
> order issue or anything like that, but really really fundamental: we want 
> to be able to print an oops, instead of deadlocking, if we take a page 
> fault in kernel code while holding/waiting-for the mmap_sem for writing.
> 
> .... and I don't even see the reason why you did tht change anyway, since 
> it seems to be totally independent of all the other locking changes.

Yes, the patch sucks, and you replying to it in such detail makes me
think I should have never attached it..

I know why we do trylock, and the only reason I did that change is to
place the down/up right around the find_vma(), if you'd read the changed
comment you'd see I'd intended that to become rcu_read_{,un}lock()
however we currently cannot since RB trees are not compatible with
lockless lookups (due to the tree rotations).

Please consider the idea of lockless vma lookup and synchronizing
against the PTE lock.

If that primary idea seems feasible, I'll continue working on it and try
to tackle further obstacles.

One non trivial issue is splitting/merging vmas against this lockless
lookup - I do have a solution, but I;m not particularly fond of it. 

Other issues include replacing the RB tree with something that is suited
for lockless lookups (B+ trees for example) and extending SRCU to suit
the new requirements.

Anyway, please don't take the patch too serious (and again, yes, its
utter shite), but consider the idea of getting rid of the mmap_sem usage
in the regular fault path as outlined (currently I'm still not sure on
how to get rid of it in the stack extend case).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
