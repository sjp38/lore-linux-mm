Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47BAE6B026D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:18:07 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 36so982807ott.22
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:18:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u107si592747otb.295.2018.10.09.06.18.05
        for <linux-mm@kvack.org>;
        Tue, 09 Oct 2018 06:18:05 -0700 (PDT)
Date: Tue, 9 Oct 2018 14:18:04 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Message-ID: <20181009131803.GH6248@arm.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu

On Tue, Oct 09, 2018 at 04:04:21PM +0300, Kirill A. Shutemov wrote:
> On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
> > A normal mapped THP page at PMD level should be correctly differentiated
> > from a PMD migration entry while walking the page table. A mapped THP would
> > additionally check positive for pmd_present() along with pmd_trans_huge()
> > as compared to a PMD migration entry. This just adds a new conditional test
> > differentiating the two while walking the page table.
> > 
> > Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> > ---
> > On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
> > exclusive which makes the current conditional block work for both mapped
> > and migration entries. This is not same with arm64 where pmd_trans_huge()
> > returns positive for both mapped and migration entries. Could some one
> > please explain why pmd_trans_huge() has to return false for migration
> > entries which just install swap bits and its still a PMD ?
> 
> I guess it's just a design choice. Any reason why arm64 cannot do the
> same?

Anshuman, would it work to:

#define pmd_trans_huge(pmd)     (pmd_present(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))

?

> > Nonetheless pmd_present() seems to be a better check to distinguish
> > between mapped and (non-mapped non-present) migration entries without
> > any ambiguity.
> 
> Can we instead reverse order of check:
> 
> if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
> 	pvmw->ptl = pmd_lock(mm, pvmw->pmd);
> 	if (!pmd_present(*pvmw->pmd)) {
> 		...
> 	} else if (likely(pmd_trans_huge(*pvmw->pmd))) {
> 		...
> 	} else {
> 		...
> 	}
> ...
> 
> This should cover both imeplementations of pmd_trans_huge().

I'd much rather have portable semantics for pmd_trans_huge(), if we can
achieve that efficiently. But that would be fast /and/ correct, so perhaps
I'm being too hopeful :)

Will
