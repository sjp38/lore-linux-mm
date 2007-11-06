Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0711061107450.27484@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
	 <1193672929.5035.69.camel@localhost>
	 <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
	 <1193693646.6244.51.camel@localhost>
	 <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
	 <1193762382.5039.41.camel@localhost>
	 <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
	 <1194375377.5317.42.camel@localhost>
	 <Pine.LNX.4.64.0711061107450.27484@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 06 Nov 2007 14:35:12 -0500
Message-Id: <1194377713.5317.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: AndiKleen <ak@suse.de>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-11-06 at 11:15 -0800, Christoph Lameter wrote:
> On Tue, 6 Nov 2007, Lee Schermerhorn wrote:
> 
> > After looking at this and attempting to implement it, I find that it
> > won't work.  The reason is that I can't tell from just vma references
> > whether an mempolicy in the shared policy rbtree is actually in use.  A
> > task is allowed to change the policies in the rbtree at any time--a
> > feature that I understand you have no use for and therefore don't like,
> 
> I am not sure what my dislikes have to do with anything. This needs to 
> work and be made to work in such a way that it does not negatively impact 
> the rest of the system.

We always seem to rathole on that subject.  I just hoped to head that
off...

> 
> What do you mean by in use? If a vma can potentially use a shared policy 
> in a rbtree then it is in use right?

Not really--not for shared policies.  Again, another task is allowed to
remove or replace the shared policies at any time, regardless of the
number of task's attached to the segment.  We can't differentiate
between simple attachment and current use.  We need the lookup-time
ref/unref to know that the policy is actually in use.  We can still
replace it in the tree while it's "in use".  This will remove the tree's
reference on the policy, but the policy won't be freed until the task
holding the extra ref drops it.  

I suppose we could stick any replaced mempolicy on a list associated
with the segment and keep them there until all tasks detach from the
shared segment.  Not too much of a memory leak, as long as a task
doesn't keep changing policy on a shmem segment just to be perverse.
Don't know how I'd limit that.  On top of all the other mechanism I'd
have to add to track vma refs to shared policies [and it appears to be
quite a bit], it wouldn't be all that much additional work.  But, the
entire effort didn't seem worth it when I determined that I couldn't
safely free the policies when they're removed/replaced.  That was the
purpose of the exercise...

> 
> > but which is fundamental to shared policy semantics.  If I try to
> > install a policy that completely covers/replaces an existing policy, I
> > need to be able to do this, regardless of how many vmas have the shared
> > region attached/mapped.  So, this doesn't protect any task that is
> > currently examining the policy for page allocation, get_mempolicy() or
> > show_numa_maps() without the extra ref.  Andi had probably figured this
> > out back when he implemented shared policies.
> 
> AFAICT: If you take a reference on the shared policy for each 
> vma then you can tell from the references that the policy is in use.

See above.  A vma reference does not constitute use for a shared policy.
Again, I could replace them, I just can't free the replaced ones...
Unless I can figure out some [s]rcu mechanism.  If not, I'll have to
think about how to limit a task from causing an arbitrary number of them
to be allocated w/o being freed.

>  
> > I have another approach that still involves adding a ref to shared
> > policies at lookup time, and dropping the ref when finished with the
> > policy.  I know you don't like the idea of taking references in the vma
> > policy lookup path.  However, the 'get() is already there [for shared
> > policies].  I just need to add the 'free() [which Mel G would like to
> > see renamed at mpol_put()].  I have a patch that does the unref only for
> > shared policies, along with the other cleanups necessary in this area.
> > 
> > I hope to post soon, but I've said that before.  I'll also rerun the pft
> > tests with and without this change when I can.
> 
> I am fine with this if it only affects the shmem policies and no critical 
> performance hot paths for regular anonymous and page cache allocations.

So far, that's what it looks like.  Again, I'll continue to think about
the vma refs along with some RCU mechanism for deferred freeing of the
policies.  

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
