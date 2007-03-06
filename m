Date: Tue, 6 Mar 2007 09:36:32 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 3/5] mm: RCUify vma lookup
Message-ID: <20070306083632.GA10540@wotan.suse.de>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net> <20070306014211.293824000@taijtu.programming.kicks-ass.net> <20070306022319.GF23845@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306022319.GF23845@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 03:23:19AM +0100, Nick Piggin wrote:
> On Tue, Mar 06, 2007 at 02:38:18AM +0100, Peter Zijlstra wrote:
> > mostly lockless vma lookup using the new b+tree
> > pin the vma using an atomic refcount
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  
> > +static void lock_vma(struct vm_area_struct *vma)
> > +{
> > +	wait_event(vma->vm_mm->mm_wq, (atomic_cmpxchg(&vma->vm_count, 1, 0) == 1));
> > +}
> > +
> > +static void unlock_vma(struct vm_area_struct *vma)
> > +{
> > +	BUG_ON(atomic_read(&vma->vm_count));
> > +	atomic_set(&vma->vm_count, 1);
> > +}
> 
> This is a funny scheme you're trying to do in order to try to avoid
> rwsems. Of course it is subject to writer starvation, so please just
> use an rwsem per vma for this.
> 
> If the -rt tree cannot do them properly, then it just has to turn them
> into mutexes and take the hit itself.
> 
> There is no benefit for the -rt tree to do this anyway, because you're
> just re-introducing the fundamental problem that it has with rwsems
> anyway (ie. poor priority inheritance).
> 
> In this case I guess you still need some sort of refcount in order to force
> the lookup into the slowpath, but please don't use it for locking.

... though I must add that it seems like a very cool patchset and I hope
I can get time to go through it more thoroughly! Nice work ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
