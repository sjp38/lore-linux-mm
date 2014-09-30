Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B16CC6B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:55:10 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id mk6so4357389lab.1
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 09:55:09 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id jp10si13756063lab.19.2014.09.30.09.55.07
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 09:55:08 -0700 (PDT)
Date: Tue, 30 Sep 2014 19:54:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 2/6] mm/hugetlb: take page table lock in
 follow_huge_(addr|pmd|pud)()
Message-ID: <20140930165453.GA29843@node.dhcp.inet.fi>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1409276340-7054-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1409031243420.9023@eggly.anvils>
 <20140905052751.GA6883@nhori.redhat.com>
 <alpine.LSU.2.11.1409072307430.1298@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409072307430.1298@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Sep 08, 2014 at 12:13:16AM -0700, Hugh Dickins wrote:
> > > One subtlety to take care over: it's a long time since I've had to
> > > worry about pmd folding and pud folding (what happens when you only
> > > have 2 or 3 levels of page table instead of the full 4): macros get
> > > defined to each other, and levels get optimized out (perhaps
> > > differently on different architectures).
> > > 
> > > So although at first sight the lock to take in follow_huge_pud()
> > > would seem to be mm->page_table_lock, I am not at this point certain
> > > that that's necessarily so - sometimes pud_huge might be pmd_huge,
> > > and the size PMD_SIZE, and pmd_lockptr appropriate at what appears
> > > to be the pud level.  Maybe: needs checking through the architectures
> > > and their configs, not obvious to me.
> > 
> > I think that every architecture uses mm->page_table_lock for pud-level
> > locking at least for now, but that could be changed in the future,
> > for example when 1GB hugepages or pud-based hugepages become common and
> > someone are interested in splitting lock for pud level.
> 
> I'm not convinced by your answer, that you understand the (perhaps
> imaginary!) issue I'm referring to.  Try grep for __PAGETABLE_P.D_FOLDED.
> 
> Our infrastructure allows for 4 levels of pagetable, pgd pud pmd pte,
> but many architectures/configurations support only 2 or 3 levels.
> What pud functions and pmd functions work out to be in those
> configs is confusing, and varies from architecture to architecture.
> 
> In particular, pud and pmd may be different expressions of the same
> thing (with 1 pmd per pud, instead of say 512).  In that case PUD_SIZE
> will equal PMD_SIZE: and then at the pud level huge_pte_lockptr()
> will be using split locking instead of mm->page_table_lock.

<sorry for delay -- just back from vacation>

Look like we can't have PMD folded unless PUD is folded too:

include/asm-generic/pgtable-nopmd.h:#include <asm-generic/pgtable-nopud.h>

It means we have three cases:

- Both PMD and PUD are not folded. PUD_SIZE == PMD_SIZE can be true only
  if PUD table consits from one entry which is emm.. strange.
- PUD folded, PMD is not. In this case PUD_SIZE is equal to PGDIR_SIZE
  which is always (I believe) greater than PMD_SIZE.
- Both are folded: PMD_SIZE == PUD_SIZE == PGDIR_SIZE, but we solve it
  with ARCH_ENABLE_SPLIT_PMD_PTLOCK. It only enabled on configuration with
  where PMD is not folded. Without ARCH_ENABLE_SPLIT_PMD_PTLOCK,
  pmd_lockptr() points to mm->page_table_lock.

Does it make sense?

> Many of the hugetlb architectures have a pud_huge() which just returns
> 0, and we need not worry about those, nor the follow_huge_addr() powerpc.
> But arm64, mips, tile, x86 look more interesting.
> 
> Frankly, I find myself too dumb to be sure of the right answer for all:
> and think that when we put the proper locking into follow_huge_pud(),
> we shall have to include a PUD_SIZE == PMD_SIZE test, to let the
> compiler decide for us which is the appropriate locking to match
> huge_pte_lockptr().
> 
> Unless Kirill can illuminate: I may be afraid of complications
> where actually there are none.

I'm more worry about false-negative result of huge_page_size(h) ==
PMD_SIZE check. I can imagine that some architectures (power and ia64, i
guess) allows several page sizes on the same page table level, but only
one of them is PMD_SIZE.

It seems not a problem currently since we enable split PMD lock only on
x86 and s390.

Possible solution is to annotate each hstate with page table level it
corresponds to.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
