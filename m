Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0711061139230.30127@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
	 <1193672929.5035.69.camel@localhost>
	 <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
	 <1193693646.6244.51.camel@localhost>
	 <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
	 <1193762382.5039.41.camel@localhost>
	 <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
	 <1194375377.5317.42.camel@localhost>
	 <Pine.LNX.4.64.0711061107450.27484@schroedinger.engr.sgi.com>
	 <1194377713.5317.76.camel@localhost>
	 <Pine.LNX.4.64.0711061139230.30127@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 06 Nov 2007 15:08:11 -0500
Message-Id: <1194379691.5317.101.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-11-06 at 11:43 -0800, Christoph Lameter wrote:
> On Tue, 6 Nov 2007, Lee Schermerhorn wrote:
> 
> > We always seem to rathole on that subject.  I just hoped to head that
> > off...
> 
> Well fix this and the rathole will be gone.,

I'll hold you to that! :-)

> 
> > > What do you mean by in use? If a vma can potentially use a shared policy 
> > > in a rbtree then it is in use right?
> > 
> > Not really--not for shared policies.  Again, another task is allowed to
> > remove or replace the shared policies at any time, regardless of the
> > number of task's attached to the segment.  We can't differentiate
> > between simple attachment and current use.  We need the lookup-time
> > ref/unref to know that the policy is actually in use.  We can still
> > replace it in the tree while it's "in use".  This will remove the tree's
> > reference on the policy, but the policy won't be freed until the task
> > holding the extra ref drops it.  
> 
> Stil unclear as to why we need lookup time ref/unref. A task can replace 
> the shared policy at any time you just need to update the refcounts. If 
> you have a pointer to the policy in the vma then its possible to do so.

A pointer in the vma won't work.  Different tasks could apply policies
on different ranges and shared policy semantics dictate that all tasks
see the same policy for a particular offset in the region--modulo
set/get races.  The only way we could keep a pointer in the vma would be
to split the vmas in every task that has the shared region attached
whenever any task changes the policy of a range of the region, so that
all tasks have the same set of vma's all pointing to the same set of
policies in the tree.  I don't think we can be changing other task's
address space externally like this.  And it still wouldn't work, I
think, for shared policy semantics--again, except maybe with some sort
of rcu mechanism.  More below on what constitutes actual "use".

> 
> > I suppose we could stick any replaced mempolicy on a list associated
> > with the segment and keep them there until all tasks detach from the
> > shared segment.  Not too much of a memory leak, as long as a task
> 
> Well you have the refcount on the policy? Why keep the mempolicy around?

A non-zero ref count is what keeps the policy around.  It implies that
some structure has a pointer to the policy, or some task is actively
examining the policy and will drop the reference when finsished with it.
[The latter is what's NOT happening now for shared policy.]  

> 
> > > AFAICT: If you take a reference on the shared policy for each 
> > > vma then you can tell from the references that the policy is in use.
> > 
> > See above.  A vma reference does not constitute use for a shared policy.
> 
> Why not? What does constitute "use" of a shared policy? A page that has 
> used the policy?

Currently, when you lookup the policy [based on offset] in the rbtree
under spin_lock, the lookup function does an mpol_get() before dropping
the lock.  Now, you can use the policy to allocate a page or to report
via get_mempolicy(MPOL_F_ADDR) or show_numa_maps()/mpol_to_str().   When
you're finished with the policy, you mpol_free() to release the
reference.  While you're holding this ref, another task that has the
shared region attached can replace/delete the policy, removing it from
the rbtree and dropping the rbtree's reference via mpol_free().  Now,
the only reference to the policy is any reference held by a task that
has looked it up, but not yet mpol_free()ed it.  When the last task
holding such a reference releases it, we'll free it back to the kmem
cache.

This is the type of use that I can't infer from vma counts or even vma
pointer refs.  I should be able to replace the vma pointer/ref at any
time when the shared policy changes, and mpol_free() the policy for each
such vma pointer/ref.  That leaves no ref to hold the policy should it
be in use [as discussed above].

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
