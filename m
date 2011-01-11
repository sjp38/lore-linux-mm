Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B4626B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 09:04:26 -0500 (EST)
Date: Tue, 11 Jan 2011 15:04:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
Message-ID: <20110111140421.GM9506@random.random>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
 <20110111015742.GL9506@random.random>
 <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 06:29:29PM -0800, Hugh Dickins wrote:
> On Mon, Jan 10, 2011 at 5:57 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Mon, Jan 10, 2011 at 04:55:53PM -0800, Hugh Dickins wrote:
> >> If you configure THP in addition to HUGETLB_PAGE on x86_32 without PAE,
> >> the p?d-folding works out that munlock_vma_pages_range() can crash to
> >> follow_page()'s pud_huge() BUG_ON(flags & FOLL_GET): it needs the same
> >> VM_HUGETLB check already there on the pmd_huge() line.  Conveniently,
> >> openSUSE provides a "blogd" which tests this out at startup!
> >
> > How is THP related to this? pud_trans_huge doesn't exist, if pud_huge
> > is true, vma is already guaranteed to belong to hugetlbfs without
> > requiring the additional check.
> 
> THP puts in pmds that are huge.  In this configuration the "folding" is
> such that the puds are the pmds.  So the pud_huge test passes and
> the BUG_ON hits.  I hope I've explained that correctly, agreed that
> it's confusing!
> 
> >
> > I added the check to pmd_huge already, there it is needed, but for
> > pud_huge it isn't as far as I can tell.
> 
> Crashing on that BUG_ON suggests otherwise ;)

I think I see what you mean, pgd=pud=pmd with 2 levels only, but if
pud_huge can return 1 on x86_32 without PAE, that sounds like an
architectural bug to me. Why can't pud_huge simply return 0 for
x86_32? Any other place dealing with hugepages and calling pud_huge on
x86 noPAE would be at risk, otherwise, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
