From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: Hugetlb pt sharing - v4 changelog
Date: Tue, 3 Oct 2006 03:28:37 -0700
Message-ID: <000301c6e6d6$b0566680$bb80030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Short description of v4 changelog (only major items):

(1) went back to earlier mods using i_mmap_lock for locking pmd
    sharing and unsharing.  I dropped down_read_trylock() in the
    huge_pmd_share().  I think it is safe to do so with just
    i_mmap_lock: even if one mm (call it P1) is performing mprotect,
    changing vm_flags while race with another mm (call it P2) in the
    fault path.  P2 picks up old P1's vm_flags and decided it can
    share, increment ref count on the page table page.  P1 in the
    mean time changes vm_flags, get to hugetlb_change_protection and
    it will detect the page is shared and P1 will simply drop the pmd
    link.  P1 will fault again on the address range that unshared with
    correct protection set in its page table.

    The new unmap_hugepage_range() has to check vma->vm_file, it is
    undesirable.  I hope Hugh is OK with a change in the generic code
    to rearrange the order of unmap and vm_file freeing.

(2) rearranged condition check on shareable page table.  I've now break
    it out into two parts: one to check faulting vma's shareable criteria
    for efficiency reason. Once that is satisfied, we then walk the priority
    tree to search for a suitable target vma (or page table to be precise)
    for sharing.

(3) double checked on the radix and heap index used for searching priority
    tree.  It is sad that there are inconsistency in the page offset used
    by the two trees. The page cache radix tree uses HPAGE_SIZE as one unit
    while priority tree uses normal page size throughout, regardless whether
    it is a hugetlb or normal vma.  Oh well, no big deal.

(4) tested on x86_64.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
