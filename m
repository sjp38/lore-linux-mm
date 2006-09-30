From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch 0/2] shared page table for hugetlb page - v3
Date: Fri, 29 Sep 2006 17:29:39 -0700
Message-ID: <000001c6e427$84352250$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OK, here is v3 of the patch for shared page table on hugetlb segment.
I believe I dealt with all the points brought up by Hugh, changes are:

(1) not using weak function on huge_pte_unshare(), for arches that
    don't do page table sharing, they now have trivial mods.

(2) fixing bug on not checking vm_pgoff with sharing vma. This version
    performs real criteria on sharing page table page: it checks faulting
    file page offset and faulting virtual addresses, along with vm_flags
    and page table alignment.  A down_read_trylock() is added on the
    source mm->mmap_sem to secure vm_flags. It also allows proper locking
    for ref counting the shared page table page.

(3) checks VM_MAYSHARE as one of the sharing requirement.

(4) Fixed locking around sharing and unsharing of page table page.  The
    solution I adopted is to use both i_mmap_lock and mm->mmap_sem read
    semaphore of source mm while finding and manipulate ref count on the
    page table page for sharing.  In the unshare path, the ref count and
    freeing is done inside either mmap_sem (which came from mprotect or
    munmap); or i_mmap_lock which is in the ftruncate path.

(5) changed argument in function huge_pte_share(). In order to find out a
    potential page table to share, it is necessary to get the faulting vma's
    page permission and flags to match with all the vma found in the priority
    tree.  However, vma pointer was not passed from higher level caller where
    parent caller already has that vma pointer.  The complication arises from
    two incompatible call sites: one in the fault path where a vma pointer is
    readily available, however, in the copy_hugetlb_page_range(), the
    destination vma is not available and we have to perform a vma lookup.  It
    can be argued that it is better to incur the cost of find_vma in the fork
    path where copy_hugetlb_page_range is used rather than in the fault path
    which occurs a lot more often. Though neither is desirable.  I took a
    third route to only look up the vma if pmd page is not already established.
    This should cut down the amount of find_vma significantly in most cases.

(6) separate out simple RSS removal into a sub patch.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
