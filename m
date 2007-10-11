Subject: Re: [PATCH/RFC 2/2] Mem Policy: Fixup Shm and Interleave Policy
	Reference Counting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710101415470.32488@schroedinger.engr.sgi.com>
References: <20071010205837.7230.42818.sendpatchset@localhost>
	 <20071010205849.7230.81877.sendpatchset@localhost>
	 <Pine.LNX.4.64.0710101415470.32488@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 11 Oct 2007 09:41:00 -0400
Message-Id: <1192110060.5036.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, ak@suse.de, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-10 at 14:22 -0700, Christoph Lameter wrote:
> On Wed, 10 Oct 2007, Lee Schermerhorn wrote:
> 
> > * get_vma_policy() assumes that shared policies are referenced by
> >   the get_policy() vm_op, if any.  This is true for shmem_get_policy()
> >   but not for shm_get_policy() when the "backing file" does not
> >   support a get_policy() vm_op.  The latter is the case for SHM_HUGETLB
> >   segments.  Because get_vma_policy() expects the get_policy() op to
> >   have added a ref, it doesn't do so itself.  This results in 
> >   premature freeing of the policy.  Add the mpol_get() to the 
> >   shm_get_policy() op when the backing file doesn't support shared
> >   policies.
> 
> Could you add support for SHM_HUGETLB segments instead to make this 
> consistent so that shared policies always use a get_policy function?

I have patches that do this as part of my shared policy series that is
currently "on hold" while we sort these other things out.  SHM_HUGETLB
segments do use the shm_get_policy() vm_op.  However, it detects that
the hugetlb shm segment does not support get_policy(), so it just uses
the vma policy at that address.  You should like this behavior! :-).  My
patches implement shared policy for SHM_HUGETLB, which you don't like.
So, I think we should leave this as is...  for now.

> 
> > * Further, shm_get_policy() was falling back to current task's task
> >   policy if the backing file did not support get_policy() vm_op and
> >   the vma policy was null.  This is not valid when get_vma_policy() is
> >   called from show_numa_map() as task != current.  Also, this did
> >   not match the behavior of the shmem_get_policy() vm_op which did
> >   NOT fall back to task policy.  So, modify shm_get_policy() NOT to
> >   fall back to current->mempolicy.
> 
> Hmmm..... The show_numa_map issue is special. Maybe fix that one instead?
> 
> > Index: Linux/include/linux/mempolicy.h
> > ===================================================================
> > --- Linux.orig/include/linux/mempolicy.h	2007-10-10 13:36:44.000000000 -0400
> > +++ Linux/include/linux/mempolicy.h	2007-10-10 14:20:28.000000000 -0400
> > @@ -2,6 +2,7 @@
> >  #define _LINUX_MEMPOLICY_H 1
> >  
> >  #include <linux/errno.h>
> > +#include <linux/mm.h>
> 
> I think we tried to avoid a heavy include here. mm.h is huge and draws in 
> lots of other include files. The additional include is only needed for the 
> VM_BUG_ON it seems? BUG_ON would also work.

Yeah, I know.  However, I like the idea of having a separately
configurable VM debug check.  I will remove the include and the
VM_BUG_ON for now.   But, what would [any one else?] think about moving
VM_BUG_ON() to asm-generic/bug.h in a separate patch?

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
