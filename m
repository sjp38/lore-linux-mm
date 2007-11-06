Date: Tue, 6 Nov 2007 12:19:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [NUMA] Fix memory policy refcounting
In-Reply-To: <1194379691.5317.101.camel@localhost>
Message-ID: <Pine.LNX.4.64.0711061212330.32539@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
 <1193672929.5035.69.camel@localhost>  <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
  <1193693646.6244.51.camel@localhost>  <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
  <1193762382.5039.41.camel@localhost>  <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
  <1194375377.5317.42.camel@localhost>  <Pine.LNX.4.64.0711061107450.27484@schroedinger.engr.sgi.com>
  <1194377713.5317.76.camel@localhost>  <Pine.LNX.4.64.0711061139230.30127@schroedinger.engr.sgi.com>
 <1194379691.5317.101.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, Lee Schermerhorn wrote:

> > Stil unclear as to why we need lookup time ref/unref. A task can replace 
> > the shared policy at any time you just need to update the refcounts. If 
> > you have a pointer to the policy in the vma then its possible to do so.
> 
> A pointer in the vma won't work.  Different tasks could apply policies
> on different ranges and shared policy semantics dictate that all tasks
> see the same policy for a particular offset in the region--modulo
> set/get races.  The only way we could keep a pointer in the vma would be
> to split the vmas in every task that has the shared region attached
> whenever any task changes the policy of a range of the region, so that
> all tasks have the same set of vma's all pointing to the same set of
> policies in the tree.  I don't think we can be changing other task's
> address space externally like this.  And it still wouldn't work, I
> think, for shared policy semantics--again, except maybe with some sort
> of rcu mechanism.  More below on what constitutes actual "use".

You can split vmas by holding a writelock on mmap_sem. But we have 
discussed that before. If different policies are in effect for ranges of a 
shared mapping (that is what you are talking about?) then vmas need to 
correspond to these ranges and contain a pointer to the shard policy.

> > > I suppose we could stick any replaced mempolicy on a list associated
> > > with the segment and keep them there until all tasks detach from the
> > > shared segment.  Not too much of a memory leak, as long as a task
> > 
> > Well you have the refcount on the policy? Why keep the mempolicy around?
> 
> A non-zero ref count is what keeps the policy around.  It implies that
> some structure has a pointer to the policy, or some task is actively
> examining the policy and will drop the reference when finsished with it.
> [The latter is what's NOT happening now for shared policy.]  

The shared policy has one refcount because it is in the rbtree. The others 
are currently temporary.

With establishment of references via vmas you have 3 types of references 
that are taken on a policy

1. Rbtree

2. vma

3. temporary (is this really needed?)

If the refcount of a shared policy becomes one then you can remove a 
policy from the rbtree and free it.

The role of the rbtree is drastically reduced if you put the pointer into 
the vma because lookups in the tree are only needed when the vma is 
established. shmem operations will be faster because of the vma policy 
pointer.

> > Why not? What does constitute "use" of a shared policy? A page that has 
> > used the policy?
> 
> Currently, when you lookup the policy [based on offset] in the rbtree
> under spin_lock, the lookup function does an mpol_get() before dropping
> the lock.  Now, you can use the policy to allocate a page or to report
> via get_mempolicy(MPOL_F_ADDR) or show_numa_maps()/mpol_to_str().   When
> you're finished with the policy, you mpol_free() to release the
> reference.  While you're holding this ref, another task that has the
> shared region attached can replace/delete the policy, removing it from
> the rbtree and dropping the rbtree's reference via mpol_free().  Now,
> the only reference to the policy is any reference held by a task that

The policy can be removed while holding a refcount?

You can do the same then with the refcounts via vma. Drop the policy from
the rbtree and then go through the vmas to drop the refs. At some point 
the refcount reaches zero and the policy vanished.

> This is the type of use that I can't infer from vma counts or even vma
> pointer refs.  I should be able to replace the vma pointer/ref at any
> time when the shared policy changes, and mpol_free() the policy for each
> such vma pointer/ref.  That leaves no ref to hold the policy should it
> be in use [as discussed above].

AFAICT you are able to do all that you need. If a policy is in use then it 
has a refcount. You need to take the mmap_sem writelock to change 
policies. At that point you are guaranteed that no fault is in progress 
thus no user of the policy exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
