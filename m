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
Date: Tue, 30 Oct 2007 16:18:23 -0400
Message-Id: <1193775503.5039.80.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
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

I will, when I get around to rebasing them.  For reference, you can look
at the last posting back in late June:

"Shared Policy Infrastructure 3/11 let vma policy ops handle sub-vma
policies":
	http://marc.info/?l=linux-mm&m=118280133031696&w=4

and 

Shared Policy Infrastructure 4/11 fix show_numa_maps()
	http://marc.info/?l=linux-mm&m=118280133220503&w=4

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
> > if overkill.  This involves:  1) fixing do_set_mempolicy() to hold
> > mmap_sem for write over change, 2) fixing up reference counting for
> > interleaving for both normal [forgot unref] and huge [unconditional
> > unref should be conditional] and 3) adding ref to policy in
> > shm_get_policy() to match shmem_get_policy.  All 3 of these are required
> > to be correct w/o changing any of the rest of the current ref counting.
> 
> I know about 1. I'd have to look through 2 + 3. I would suggest to fix the 
> refcounting by doing the refcounting using vmas as you explained above and 
> simply remove the problems that exist there right now.
> 
> > Then, once the vma-protected shared policy mechanism discussed above is
> > in mergable, we can back out all of the extra ref's on other task and
> > vma policies and the lookup-time ref on shared policies, along with all
> > of the matching unrefs.
> 
> Too complicated. Lets go there directly.

OK.  It's just that I predict we'll take some time to agree on the
details and I know that #3 in the previous paragraph will bug out if
anyone tries to use SHM_HUGETLB segments with non-default policy on
2.6.23.  The unconditional unref in #2 might [will?] also result in
premature freeing of an interleave policy for huge pages that can result
in a bug out on next allocation that tries to use the freed policy.

That's why I suggested a temporary minimal fix for 24 and 23-stable.
I'll go ahead and put one together, just in case.  You can ack or nack
as you see fit.

Meanwhile, my adventures in testing shared policies applied from
different tasks have, just today, uncovered another bug we can hit in
rmap.c:vma_address().  Appears to have been there back at least since
2.6.18.  I'll send out details of that in a subsequent message.  I think
my shared policy patches [non-split vma for shmem segments] fixes that.
I'll test such a kernel before I post my findings.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
