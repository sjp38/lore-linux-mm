Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11A4F6B0010
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:04:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s15-v6so812813pgv.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:04:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 14-v6sor16435785pfs.60.2018.10.09.06.04.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 06:04:27 -0700 (PDT)
Date: Tue, 9 Oct 2018 16:04:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Message-ID: <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu, will.deacon@arm.com

On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
> A normal mapped THP page at PMD level should be correctly differentiated
> from a PMD migration entry while walking the page table. A mapped THP would
> additionally check positive for pmd_present() along with pmd_trans_huge()
> as compared to a PMD migration entry. This just adds a new conditional test
> differentiating the two while walking the page table.
> 
> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
> exclusive which makes the current conditional block work for both mapped
> and migration entries. This is not same with arm64 where pmd_trans_huge()
> returns positive for both mapped and migration entries. Could some one
> please explain why pmd_trans_huge() has to return false for migration
> entries which just install swap bits and its still a PMD ?

I guess it's just a design choice. Any reason why arm64 cannot do the
same?

> Nonetheless pmd_present() seems to be a better check to distinguish
> between mapped and (non-mapped non-present) migration entries without
> any ambiguity.

Can we instead reverse order of check:

if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
	pvmw->ptl = pmd_lock(mm, pvmw->pmd);
	if (!pmd_present(*pvmw->pmd)) {
		...
	} else if (likely(pmd_trans_huge(*pvmw->pmd))) {
		...
	} else {
		...
	}
...

This should cover both imeplementations of pmd_trans_huge().

-- 
 Kirill A. Shutemov
