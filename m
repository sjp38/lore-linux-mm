From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch 0/2] shared page table for hugetlb page - v3
Date: Mon, 2 Oct 2006 15:20:54 -0700
Message-ID: <000001c6e671$06de9060$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0609301948060.9929@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Saturday, September 30, 2006 12:09 PM
> On Fri, 29 Sep 2006, Chen, Kenneth W wrote:
> > OK, here is v3 of the patch for shared page table on hugetlb segment.
> > I believe I dealt with all the points brought up by Hugh, changes are:
> > 
> > (1) not using weak function on huge_pte_unshare(), for arches that
> >     don't do page table sharing, they now have trivial mods.
> 
> Right, thanks.  And huge_pte_share()/huge_pte_unshare() works much
> better than the pmd_share()/huge_pte_put() you had before.  (Should
> they all say pmd?  I get lost, and the i386/ia64 divergence makes it
> moot.)  But you've got the CodingStyle slightly wrong on each of them.

The i386/ia64 divergence was what make me to say "huge_pte-*", then I will
argue with myself that these functions are likely to be arch specific and
in x86 case, it is better to have "pmd" in the name. I will change that.


> > (4) Fixed locking around sharing and unsharing of page table page.  The
> >     solution I adopted is to use both i_mmap_lock and mm->mmap_sem read
> >     semaphore of source mm while finding and manipulate ref count on the
> >     page table page for sharing.  In the unshare path, the ref count and
> >     freeing is done inside either mmap_sem (which came from mprotect or
> >     munmap); or i_mmap_lock which is in the ftruncate path.
> 
> Umm, how does mm->mmap_sem for one mm manage to stabilize the count
> for sharing the page table with other mms?  In Wednesday's you were
> using i_mmap_lock throughout, with the aid of __unmap_hugepage_range:
> and taking i_mmap_lock in hugetlb_change_protection.  That approach
> appeared to be correct: I'm not overjoyed about taking the extra lock,
> but it's straightforward and you're more comfortable with that than
> atomic count manipulations, so let's let others protest about it if
> they wish, it may well be a non-issue (in the hugetlb context).

When a process unmaps a hugetlb segment, it acquires write mm->mmap_sem
semaphore, and thus blocking any other mm to find a pmd page reference to
be shared. In the page fault path, If a process successfully find a pmd
page to share while having mmap_sem read semaphore (on the source mm), it
will increment page ref count and thus prevent that page table page to be
freed by a concurrent racy unmap on the source mm. In my mind, this is the
same as it allows concurrent multiple up counting the reference, but serialize
when down counting is in progress. Given that get_page and put_page both use
atomic operation on page->_count, I initially concluded that it is safe.

But using down_read semaphore on the source mm is really undesirable and
causing more headache in the copy_hugetlb_page_range(). In the fork path,
the source mm is secured by down_write. But later in huge_pte_share(),
down_read_trylock is used and it will sure fail and won't share page table.
It's just silly ...

You brought up another point about TLB flush raciness: without a common lock,
I need to decrement the count, flush tlb, and then do a put_page on the page
table page.  I think I have enough reasons to go back to my Wednesday's mod
and not worry too much about scaling.


> If you go back to that way, I think you should BUG_ON(!vma->vm_file)
> in unmap_hugepage_range, rather than if'ing: if we're using i_mmap_lock
> for all this serialization, it's rather a problem if there's no vm_file.
> Or even better, omit the BUG_ON, we'd see the oops on NULL anyway.

It oops'ed right away on a unsuccessful mmap() due to say, no hugetlb page
available.  The error roll back path of mmap NULLs out vma->vm_file before
calling umap_region().  I suppose the generic code can re-arrange zeroing
vm_file and fput after unmap_regions() to accommodate hugetlb.  Will you
be OK with that?


> > (6) separate out simple RSS removal into a sub patch.
> 
> You've not addressed the TLB flush raciness at all: perhaps, since
> I pointed out defects already there, you felt you needn't bother:
> but it'd be good to start off with a 1/3 fixing what's already
> wrong, rather than just making it worse.

Yes, I agree.  I'm working on it and it will be part of next rev.


- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
