Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
	 <1193672929.5035.69.camel@localhost>
	 <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
	 <1193693646.6244.51.camel@localhost>
	 <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
	 <1193762382.5039.41.camel@localhost>
	 <Pine.LNX.4.64.0710301136410.11531@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 06 Nov 2007 13:56:17 -0500
Message-Id: <1194375377.5317.42.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: AndiKleen <ak@suse.de>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-30 at 11:42 -0700, Christoph Lameter wrote:
> On Tue, 30 Oct 2007, Lee Schermerhorn wrote:
> 
> > As part of my shared policy cleanup and enhancement series, I "fixed"
> > numa_maps to display the sub-ranges of policies in a shm segment mapped
> > by a single vma. As part of this fix, I also modified mempolicy.c so
> > that it does not split vmas that support set_policy vm_ops, because
> > handling both split vmas and non-split vmas for a single shm segment
> > would have complicated the code more than I thought necessary.  This is
> > still at prototype stage--altho' it works against 23-rc8-mm2.
> 
> I have not looked at that yet. Maybe you could post another patch?
> 
> > Re:  'ref = 3' -- One reference for the rbtree--the shm segment and it's
> > policies continue to exist independent of any vma mappings--and one for
> > each attached vma.  Because the vma references are protected by the
> > respective task/mm_struct's  mmap_sem, we won't need to add an
> > additional reference during lookup, nor release it when finished with
> > the policy.  And, we won't need to mess with any other task's mm data
> > structures when installing/removing shmem policies.  Of course, munmap()
> > of a vma will need to decrement the ref count of all policies in a
> > shared policy tree, but this is not a "fast path".  Unfortunately, we
> > don't have a unmap file operation, so I'd have to add one, or otherwise
> > arrange to remove the unmapping vma's ref--perhaps via a vm_op so that
> > we only need to call it on vmas that support it--i.e., that support
> > shared policy.
> 
> Yup that sounds like it is going to be a good solution.
> 

Christoph:

After looking at this and attempting to implement it, I find that it
won't work.  The reason is that I can't tell from just vma references
whether an mempolicy in the shared policy rbtree is actually in use.  A
task is allowed to change the policies in the rbtree at any time--a
feature that I understand you have no use for and therefore don't like,
but which is fundamental to shared policy semantics.  If I try to
install a policy that completely covers/replaces an existing policy, I
need to be able to do this, regardless of how many vmas have the shared
region attached/mapped.  So, this doesn't protect any task that is
currently examining the policy for page allocation, get_mempolicy() or
show_numa_maps() without the extra ref.  Andi had probably figured this
out back when he implemented shared policies.

I have another approach that still involves adding a ref to shared
policies at lookup time, and dropping the ref when finished with the
policy.  I know you don't like the idea of taking references in the vma
policy lookup path.  However, the 'get() is already there [for shared
policies].  I just need to add the 'free() [which Mel G would like to
see renamed at mpol_put()].  I have a patch that does the unref only for
shared policies, along with the other cleanups necessary in this area.

I hope to post soon, but I've said that before.  I'll also rerun the pft
tests with and without this change when I can.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
