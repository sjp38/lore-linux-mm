Date: Tue, 6 Nov 2007 11:43:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [NUMA] Fix memory policy refcounting
In-Reply-To: <1194377713.5317.76.camel@localhost>
Message-ID: <Pine.LNX.4.64.0711061139230.30127@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
 <1193672929.5035.69.camel@localhost>  <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
  <1193693646.6244.51.camel@localhost>  <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
  <1193762382.5039.41.camel@localhost>  <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
  <1194375377.5317.42.camel@localhost>  <Pine.LNX.4.64.0711061107450.27484@schroedinger.engr.sgi.com>
 <1194377713.5317.76.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: AndiKleen <ak@suse.de>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, Lee Schermerhorn wrote:

> We always seem to rathole on that subject.  I just hoped to head that
> off...

Well fix this and the rathole will be gone.,

> > What do you mean by in use? If a vma can potentially use a shared policy 
> > in a rbtree then it is in use right?
> 
> Not really--not for shared policies.  Again, another task is allowed to
> remove or replace the shared policies at any time, regardless of the
> number of task's attached to the segment.  We can't differentiate
> between simple attachment and current use.  We need the lookup-time
> ref/unref to know that the policy is actually in use.  We can still
> replace it in the tree while it's "in use".  This will remove the tree's
> reference on the policy, but the policy won't be freed until the task
> holding the extra ref drops it.  

Stil unclear as to why we need lookup time ref/unref. A task can replace 
the shared policy at any time you just need to update the refcounts. If 
you have a pointer to the policy in the vma then its possible to do so.

> I suppose we could stick any replaced mempolicy on a list associated
> with the segment and keep them there until all tasks detach from the
> shared segment.  Not too much of a memory leak, as long as a task

Well you have the refcount on the policy? Why keep the mempolicy around?

> > AFAICT: If you take a reference on the shared policy for each 
> > vma then you can tell from the references that the policy is in use.
> 
> See above.  A vma reference does not constitute use for a shared policy.

Why not? What does constitute "use" of a shared policy? A page that has 
used the policy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
