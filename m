Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 94D3C6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:30:54 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so9222998pbc.30
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:30:54 -0700 (PDT)
Date: Tue, 15 Oct 2013 22:30:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Message-ID: <20131015203047.GK3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
 <20131015143407.GE3479@redhat.com>
 <20131015144827.C45DDE0090@blue.fi.intel.com>
 <alpine.LNX.2.00.1310151029040.12481@eggly.anvils>
 <20131015185510.GH3479@redhat.com>
 <1381865330-8nb86ucy-mutt-n-horiguchi@ah.jp.nec.com>
 <20131015194428.GI3479@redhat.com>
 <1381868183-6d50s9n5-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381868183-6d50s9n5-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 15, 2013 at 04:16:23PM -0400, Naoya Horiguchi wrote:
> On Tue, Oct 15, 2013 at 09:44:28PM +0200, Andrea Arcangeli wrote:
> > On Tue, Oct 15, 2013 at 03:28:50PM -0400, Naoya Horiguchi wrote:
> > > On Tue, Oct 15, 2013 at 08:55:10PM +0200, Andrea Arcangeli wrote:
> > > > On Tue, Oct 15, 2013 at 10:53:10AM -0700, Hugh Dickins wrote:
> > > > > I'm afraid Andrea's mail about concurrent madvises gives me far more
> > > > > to think about than I have time for: seems to get into problems he
> > > > > knows a lot about but I'm unfamiliar with.  If this patch looks good
> > > > > for now on its own, let's put it in; but no problem if you guys prefer
> > > > > to wait for a fuller solution of more problems, we can ride with this
> > > > > one internally for the moment.
> > > > 
> > > > I'm very happy with the patch and I think it's a correct fix for the
> > > > COW scenario which is deterministic so the looping makes a meaningful
> > > > difference for it. If we wouldn't loop, part of the copied page
> > > > wouldn't be zapped after the COW.
> > > 
> > > I like this patch, too.
> > > 
> > > If we have the loop in __split_huge_page_pmd as suggested in this patch,
> > > can we assume that the pmd is stable after __split_huge_page_pmd returns?
> > > If it's true, we can remove pmd_none_or_trans_huge_or_clear_bad check
> > > in the callers side (zap_pmd_range and some other page table walking code.)
> > 
> > We can assume it stable for the deterministic cases where the
> > looping is useful for and split_huge_page creates non-huge pmd that points to
> > a regular pte.
> > 
> > But we cannot remove pmd_none_or_trans_huge_or_clear_bad after if for
> > the other non deterministic cases that I described in previous
> > email. Looping still provides no guarantee that when the function
> > returns, the pmd in not huge. So for safety we still need to handle
> > the non deterministic case and just discard it through
> > pmd_none_or_trans_huge_or_clear_bad.
> 
> OK, this check is necessary. But pmd_none_or_trans_huge_or_clear_bad
> doesn't clear the pmd when pmd_trans_huge is true. So zap_pmd_range
> seems to do nothing on such irregular pmd_trans_huge. So it looks to
> me better that zap_pmd_range retries the loop on the same address
> instead of 'goto next'.

It may look like a bug to return with a huge pmd established, when we could
notice it after pmd_trans_huge_pmd returns.

However try to imagine to add a check there, and to keep adding checks
and loops. If you're just a bit more unlucky next time, the page fault
that converts the "unstable" pmd from "none" to "huge", may fire in
another thread running in another CPU during the iret, so while
MADV_DONTNEED completes and returns to userland.

There are not enough checks you can add even after zap_pmd_range
returns, to prevent the pmd to become established by the time
MADV_DONTNEED returns to userland.

The point is that if MADV_DONTNEED was zapping the entire pmd (not
part) userland is accessing the same memory at the same time from
another thread, the result is undefined.

> The reason why I had this kind of question is that I recently study on
> page table walker and some related code do retry in the similar situation.

There surely are other cases that give an undefined result in the
kernel. Another one in the pagetable walking code that would give
undefined result is still MADV_DONTNEED vs a 4k page fault. You don't
know who runs first, the 4k page may end up zapped or not. But in that
case there's no split_huge_page_pmd as variable of the equation.

The header definition documents it too:

/*
 * This function is meant to be used by sites walking pagetables with
 * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
 * transhuge page faults. MADV_DONTNEED can convert a transhuge pmd
 * into a null pmd and the transhuge page fault can convert a null pmd
 * into an hugepmd or into a regular pmd (if the hugepage allocation
 * fails). While holding the mmap_sem in read mode the pmd becomes
 * stable and stops changing under us only if it's not null and not a
 * transhuge pmd. When those races occurs and this function makes a
 * difference vs the standard pmd_none_or_clear_bad, the result is
 * undefined so behaving like if the pmd was none is safe (because it
 * can return none anyway). The compiler level barrier() is critically
 * important to compute the two checks atomically on the same pmdval.
 *
 * For 32bit kernels with a 64bit large pmd_t this automatically takes
 * care of reading the pmd atomically to avoid SMP race conditions
 * against pmd_populate() when the mmap_sem is hold for reading by the
 * caller (a special atomic read not done by "gcc" as in the generic
 * version above, is also needed when THP is disabled because the page
 * fault can populate the pmd from under us).
 */
static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)

The COW case cannot be threated as undefined though, that has as well
defined result that for userland must be identical to the one that
would happen on 4k pages.

This is why looping there is required. But we still need to deal with
the other scenario with undefined result too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
