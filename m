Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCBC6B038A
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:59:09 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a15so35670478wrc.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:59:09 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id q9si13385539wrc.80.2017.02.13.02.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:59:08 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id o16so23549480wra.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:59:08 -0800 (PST)
Date: Mon, 13 Feb 2017 13:59:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170213105906.GA16419@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170207141956.GA4789@node.shutemov.name>
 <5899E389.3040801@cs.rutgers.edu>
 <20170207163734.GA5578@node.shutemov.name>
 <589A0090.3050406@cs.rutgers.edu>
 <20170207174536.GC5578@node.shutemov.name>
 <44001748-05AC-49B2-88F5-371618C12AD9@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44001748-05AC-49B2-88F5-371618C12AD9@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

On Sun, Feb 12, 2017 at 06:25:09PM -0600, Zi Yan wrote:
> Hi Kirill,
> 
> >>>> The crash scenario I guess is like:
> >>>> 1. A huge page pmd entry is in the middle of being changed into either a
> >>>> pmd_protnone or a pmd_migration_entry. It is cleared to pmd_none.
> >>>>
> >>>> 2. At the same time, the application frees the vma this page belongs to.
> >>>
> >>> Em... no.
> >>>
> >>> This shouldn't be possible: your 1. must be done under down_read(mmap_sem).
> >>> And we only be able to remove vma under down_write(mmap_sem), so the
> >>> scenario should be excluded.
> >>>
> >>> What do I miss?
> >>
> >> You are right. This problem will not happen in the upstream kernel.
> >>
> >> The problem comes from my customized kernel, where I migrate pages away
> >> instead of reclaiming them when memory is under pressure. I did not take
> >> any mmap_sem when I migrate pages. So I got this error.
> >>
> >> It is a false alarm. Sorry about that. Thanks for clarifying the problem.
> >
> > I think there's still a race between MADV_DONTNEED and
> > change_huge_pmd(.prot_numa=1) resulting in skipping THP by
> > zap_pmd_range(). It need to be addressed.
> >
> > And MADV_FREE requires a fix.
> >
> > So, minus one non-bug, plus two bugs.
> >
> 
> You said a huge page pmd entry needs to be changed under down_read(mmap_sem).
> It is only true for huge pages, right?

mmap_sem is a way to make sure that the VMA will not go away under you.
Besides mmap_sem, anon_vma_lock/i_mmap_lock can be used for this.

> Since in mm/compaction.c, the kernel does not down_read(mmap_sem) during memory
> compaction. Namely, base page migrations do not hold down_read(mmap_sem),
> so in zap_pte_range(), the kernel needs to hold PTE page table locks.
> Am I right about this?
> 
> If yes. IMHO, ultimately, when we need to compact 2MB pages to form 1GB pages,
> in zap_pmd_range(), pmd locks have to be taken to make that kind of compactions
> possible.
> 
> Do you agree?

I *think* we can get away with speculative (without ptl) check in
zap_pmd_range() if we make page fault the only place that can turn
pmd_none() into something else.

It means all other sides that change pmd must not clear it intermittently
during pmd change, unless run under down_write(mmap_sem).

I found two such problematic places in kernel:

 - change_huge_pmd(.prot_numa=1);

 - madvise_free_huge_pmd();

Both clear pmd before setting up a modified version. Both under
down_read(mmap_sem).

The migration path also would need to establish migration pmd atomically
to make this work.

Once all these cases will be fixed, zap_pmd_range() would only be able to
race with page fault if it called from MADV_DONTNEED.
This case is not a problem.

Andrea, does it sound reasonable to you?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
