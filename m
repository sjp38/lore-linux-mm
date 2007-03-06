Subject: Re: [RFC][PATCH 3/5] mm: RCUify vma lookup
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1173184309.6374.110.camel@twins>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net>
	 <20070306014211.293824000@taijtu.programming.kicks-ass.net>
	 <20070306022319.GF23845@wotan.suse.de>  <1173184309.6374.110.camel@twins>
Content-Type: text/plain
Date: Tue, 06 Mar 2007 13:35:02 +0100
Message-Id: <1173184502.6374.112.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-03-06 at 13:31 +0100, Peter Zijlstra wrote:
> On Tue, 2007-03-06 at 03:23 +0100, Nick Piggin wrote:
> > On Tue, Mar 06, 2007 at 02:38:18AM +0100, Peter Zijlstra wrote:
> 
> > > +static void lock_vma(struct vm_area_struct *vma)
> > > +{
> > > +	wait_event(vma->vm_mm->mm_wq, (atomic_cmpxchg(&vma->vm_count, 1, 0) == 1));
> > > +}
> > > +
> > > +static void unlock_vma(struct vm_area_struct *vma)
> > > +{
> > > +	BUG_ON(atomic_read(&vma->vm_count));
> > > +	atomic_set(&vma->vm_count, 1);
> > > +}
> > 
> > This is a funny scheme you're trying to do in order to try to avoid
> > rwsems. Of course it is subject to writer starvation, so please just
> > use an rwsem per vma for this.
> 
> [damn, he spotted it :-)]
> 
> Yeah, I know :-(
> 
> > If the -rt tree cannot do them properly, then it just has to turn them
> > into mutexes and take the hit itself.
> 
> That is, unfortunately, still not acceptable. Take futexes for example,
> many threads 1 vma.
> 
> > There is no benefit for the -rt tree to do this anyway, because you're
> > just re-introducing the fundamental problem that it has with rwsems
> > anyway (ie. poor priority inheritance).
> 
> The thing is, we cannot make the whole VM realtime, that is just plain
> impossible. What we do try to do is to carve a niche where RT operation
> is possible. Like a preallocated mlocked arena. So mmap and all the
> other vma modifiers would fall outside, but faults and futexes would
                             minor faults -----^

major faults are obviously a big no no for a rt_task.

> need to be inside the RT scope.
> 
> Ingo, any ideas? perhaps just introduce a raw rwlock in -rt and somehow
> warn whenever an rt_task does a write lock?
> 
> Full vma RCUification is hindered by the serialisation requirements; one
> cannot have two inconsistent views of the mm.
> 
> > In this case I guess you still need some sort of refcount in order to force
> > the lookup into the slowpath, but please don't use it for locking.
> 
> down_read_trylock on the vma rw lock would work I guess.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
