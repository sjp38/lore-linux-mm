Date: Sat, 30 Sep 2006 20:08:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 0/2] shared page table for hugetlb page - v3
In-Reply-To: <000001c6e427$84352250$ff0da8c0@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0609301948060.9929@blonde.wat.veritas.com>
References: <000001c6e427$84352250$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2006, Chen, Kenneth W wrote:
> OK, here is v3 of the patch for shared page table on hugetlb segment.
> I believe I dealt with all the points brought up by Hugh, changes are:
> 
> (1) not using weak function on huge_pte_unshare(), for arches that
>     don't do page table sharing, they now have trivial mods.

Right, thanks.  And huge_pte_share()/huge_pte_unshare() works much
better than the pmd_share()/huge_pte_put() you had before.  (Should
they all say pmd?  I get lost, and the i386/ia64 divergence makes it
moot.)  But you've got the CodingStyle slightly wrong on each of them.

> 
> (2) fixing bug on not checking vm_pgoff with sharing vma. This version
>     performs real criteria on sharing page table page: it checks faulting
>     file page offset and faulting virtual addresses, along with vm_flags
>     and page table alignment.  A down_read_trylock() is added on the
>     source mm->mmap_sem to secure vm_flags. It also allows proper locking
>     for ref counting the shared page table page.

Improvements there, but not yet correct.

> 
> (3) checks VM_MAYSHARE as one of the sharing requirement.

Yup.

> 
> (4) Fixed locking around sharing and unsharing of page table page.  The
>     solution I adopted is to use both i_mmap_lock and mm->mmap_sem read
>     semaphore of source mm while finding and manipulate ref count on the
>     page table page for sharing.  In the unshare path, the ref count and
>     freeing is done inside either mmap_sem (which came from mprotect or
>     munmap); or i_mmap_lock which is in the ftruncate path.

Umm, how does mm->mmap_sem for one mm manage to stabilize the count
for sharing the page table with other mms?  In Wednesday's you were
using i_mmap_lock throughout, with the aid of __unmap_hugepage_range:
and taking i_mmap_lock in hugetlb_change_protection.  That approach
appeared to be correct: I'm not overjoyed about taking the extra lock,
but it's straightforward and you're more comfortable with that than
atomic count manipulations, so let's let others protest about it if
they wish, it may well be a non-issue (in the hugetlb context).

If you go back to that way, I think you should BUG_ON(!vma->vm_file)
in unmap_hugepage_range, rather than if'ing: if we're using i_mmap_lock
for all this serialization, it's rather a problem if there's no vm_file.
Or even better, omit the BUG_ON, we'd see the oops on NULL anyway.

> 
> (5) changed argument in function huge_pte_share(). In order to find out a
>     potential page table to share, it is necessary to get the faulting vma's
>     page permission and flags to match with all the vma found in the priority
>     tree.  However, vma pointer was not passed from higher level caller where
>     parent caller already has that vma pointer.  The complication arises from
>     two incompatible call sites: one in the fault path where a vma pointer is
>     readily available, however, in the copy_hugetlb_page_range(), the
>     destination vma is not available and we have to perform a vma lookup.  It
>     can be argued that it is better to incur the cost of find_vma in the fork
>     path where copy_hugetlb_page_range is used rather than in the fault path
>     which occurs a lot more often. Though neither is desirable.  I took a
>     third route to only look up the vma if pmd page is not already established.
>     This should cut down the amount of find_vma significantly in most cases.

Hmm, okay, not quite what I was suggesting, but that avoids wider change,
and you're right that it cuts down the find_vma calls almost enough to
not bother about the issue any further (I'll suggest a further avoidance
when commenting on your 1/2).  And in the hugepage_copy_range case, any
succession of find_vmas should be quick, hitting mmap_cache.  Fair enough.

> 
> (6) separate out simple RSS removal into a sub patch.

Thanks, yes - though you need to move lots of comment from 1/2 to 2/2.

You've not addressed the TLB flush raciness at all: perhaps, since
I pointed out defects already there, you felt you needn't bother:
but it'd be good to start off with a 1/3 fixing what's already
wrong, rather than just making it worse.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
