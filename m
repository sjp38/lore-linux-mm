Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D37F6B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 09:40:51 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id w20so102886033qtb.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:40:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1si7369395qkc.172.2017.02.13.06.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 06:40:50 -0800 (PST)
Date: Mon, 13 Feb 2017 15:40:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170213144042.GD25530@redhat.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170207141956.GA4789@node.shutemov.name>
 <5899E389.3040801@cs.rutgers.edu>
 <20170207163734.GA5578@node.shutemov.name>
 <589A0090.3050406@cs.rutgers.edu>
 <20170207174536.GC5578@node.shutemov.name>
 <44001748-05AC-49B2-88F5-371618C12AD9@cs.rutgers.edu>
 <20170213105906.GA16419@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213105906.GA16419@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

Hello!

On Mon, Feb 13, 2017 at 01:59:06PM +0300, Kirill A. Shutemov wrote:
> On Sun, Feb 12, 2017 at 06:25:09PM -0600, Zi Yan wrote:
> > Since in mm/compaction.c, the kernel does not down_read(mmap_sem) during memory
> > compaction. Namely, base page migrations do not hold down_read(mmap_sem),
> > so in zap_pte_range(), the kernel needs to hold PTE page table locks.
> > Am I right about this?
> > 
> > If yes. IMHO, ultimately, when we need to compact 2MB pages to form 1GB pages,
> > in zap_pmd_range(), pmd locks have to be taken to make that kind of compactions
> > possible.
> > 
> > Do you agree?

compaction skips compound pages in the LRU entirely because they're
guaranteed to be HPAGE_PMD_ORDER in size by design, so yes compaction
is not effective in helping compound page allocations of order >
HPAGE_PMD_ORDER, you need to use CMA allocation APIs for that instead
of plain alloc_pages for orders higher than HPAGE_PMD_ORDER.

That only leaves order 10 not covered, which happens to match
HPAGE_PMD_ORDER on x86 32bit non-PAE. In fact MAX_ORDER should be
trimmed to 10 for x86-64 and x86 32bit PAE mode, we're probably
wasting a bit of CPU to maintain order 10 for no good on x86-64 but
that's another issue not related to THP pmd updates.

There's no issue with x86 pmd updates in compaction because we don't
compact those in the first place and 1GB pages in THP are not feasible
regardless of MAX_ORDER being 10 or 11.

> I *think* we can get away with speculative (without ptl) check in
> zap_pmd_range() if we make page fault the only place that can turn
> pmd_none() into something else.
> 
> It means all other sides that change pmd must not clear it intermittently
> during pmd change, unless run under down_write(mmap_sem).
> 
> I found two such problematic places in kernel:
> 
>  - change_huge_pmd(.prot_numa=1);
> 
>  - madvise_free_huge_pmd();
> 
> Both clear pmd before setting up a modified version. Both under
> down_read(mmap_sem).
> 
> The migration path also would need to establish migration pmd atomically
> to make this work.

Pagetables updates are always atomic, the issue here is not the
atomicity nor the lock prefix, but just "not temporarily showing zero
pmds" if only holding the pmd_lock and mmap_sem for reading (i.e. not
hodling it for writing)

> 
> Once all these cases will be fixed, zap_pmd_range() would only be able to
> race with page fault if it called from MADV_DONTNEED.
> This case is not a problem.

Yes this case is handled fine by pmd_trans_unstable and
pmd_none_or_trans_huge_or_clear_bad, it's a controlled race with
userland undefined result when it triggers. We've just to be
consistent with the invariants and not let the kernel get confused
about it, so no problem there.

> Andrea, does it sound reasonable to you?

Yes, pmdp_invalidate does exactly that, it won't show a zero pmd,
instead it does:

	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));

the change_huge_pmd under mmap_sem for reading is a relatively newer
introduction, in the older THP code that couldn't happen ever, it was
always running under the mmap_sem for writing and it wasn't updated to
cover this race condition when it started to be taken for reading to
arm NUMA hinting faults in task work.

madvise_free_huge_pmd is also a newer addition not present in the
older THP code introduced with MADV_FREE.

Whenever the mmap_sem is taken for reading only, the pmd shouldn't be
zeroed out at any given time, instead it should do like
split_huge_page->pmdp_invalidate. It's not hard to atomically update
the pmd with a new value:

#ifndef __HAVE_ARCH_PMDP_INVALIDATE
void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
		     pmd_t *pmdp)
{
	pmd_t entry = *pmdp;
	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
}
#endif

set_pmd_at will do (it's atomic as far as C is concerned, not
guaranteed by the C standard but we always depend on gcc to be smart
and make an atomic update in all pgtable updates, nothing special
here).

Simply removing pmdp_huge_get_and_clear_full and calling set_pmd_at
directly should do the trick. The pmd can't change with the pmd_lock
hold so we've just to read it, update it, and overwrite it atomically
with set_pmd_at. It actually will speed up the code removing an
unnecessary clear.

The only reason for doing pmdp_huge_get_and_clear_full in the pte
cases is to avoid losing the dirty bit updated in hardware. That is
non issue for anon memory where all THP anon memory is always dirty as
it can't be swapped natively and it can never be freed and dropped
unless it's splitted first (in turn not being a hugepmd anymore).

The problem with the dirty bit happens in this sequence:

    pmd_t pmd = *pmdp; // dirty bit is not set in pmd
    // dirty bit is set in hardware in *pmdp
    set_pte_at(..., pmd); // dirty bit lost

pmdp_huge_get_and_clear_full prevents the above so it's preferable but
it's unusable outside of mmap_sem for writing.

tmpfs in THP should do the same as the swap API isn't capable of
natively creating large chunks natively.

If we were to track the dirty bit what we could do is to introduce a
xchg based ptep_invalidate that instead of setting the pmd to zero it
will set it to non present or to a migration entry.

In short either we'd drop pmdp_huge_get_and_clear_full entirely and we
only use set_pmd_at, because if we don't use it always like the old
THP code did, or there's no point in wasting CPU for those xchg as
there would be code paths that would eventually lose dirty bits
anyway, or we should replace it with a variant that can be called with
the mmap_sem for reading and the pmd_lock only that doesn't clear the
pmd but that still prevents the hardware to set the dirty bit while we
update it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
