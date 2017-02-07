Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04FBF6B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 12:45:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so26833215wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:45:39 -0800 (PST)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id x61si5873945wrb.295.2017.02.07.09.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 09:45:38 -0800 (PST)
Received: by mail-wr0-x241.google.com with SMTP id o16so6186770wra.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:45:38 -0800 (PST)
Date: Tue, 7 Feb 2017 20:45:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170207174536.GC5578@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170207141956.GA4789@node.shutemov.name>
 <5899E389.3040801@cs.rutgers.edu>
 <20170207163734.GA5578@node.shutemov.name>
 <589A0090.3050406@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <589A0090.3050406@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Zi Yan <zi.yan@sent.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

On Tue, Feb 07, 2017 at 11:14:56AM -0600, Zi Yan wrote:
> 
> 
> Kirill A. Shutemov wrote:
> > On Tue, Feb 07, 2017 at 09:11:05AM -0600, Zi Yan wrote:
> >>>> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.
> >>> The problem is that numabalancing calls change_huge_pmd() under
> >>> down_read(mmap_sem), not down_write(mmap_sem) as the rest of users do.
> >>> It makes numabalancing the only code path beyond page fault that can turn
> >>> pmd_none() into pmd_trans_huge() under down_read(mmap_sem).
> >>>
> >>> This can lead to race when MADV_DONTNEED miss THP. That's not critical for
> >>> pagefault vs. MADV_DONTNEED race as we will end up with clear page in that
> >>> case. Not so much for change_huge_pmd().
> >>>
> >>> Looks like we need pmdp_modify() or something to modify protection bits
> >>> inplace, without clearing pmd.
> >>>
> >>> Not sure how to get crash scenario.
> >>>
> >>> BTW, Zi, have you observed the crash? Or is it based on code inspection?
> >>> Any backtraces?
> >> The problem should be very rare in the upstream kernel. I discover the
> >> problem in my customized kernel which does very frequent page migration
> >> and uses numa_protnone.
> >>
> >> The crash scenario I guess is like:
> >> 1. A huge page pmd entry is in the middle of being changed into either a
> >> pmd_protnone or a pmd_migration_entry. It is cleared to pmd_none.
> >>
> >> 2. At the same time, the application frees the vma this page belongs to.
> > 
> > Em... no.
> > 
> > This shouldn't be possible: your 1. must be done under down_read(mmap_sem).
> > And we only be able to remove vma under down_write(mmap_sem), so the
> > scenario should be excluded.
> > 
> > What do I miss?
> 
> You are right. This problem will not happen in the upstream kernel.
> 
> The problem comes from my customized kernel, where I migrate pages away
> instead of reclaiming them when memory is under pressure. I did not take
> any mmap_sem when I migrate pages. So I got this error.
> 
> It is a false alarm. Sorry about that. Thanks for clarifying the problem.

I think there's still a race between MADV_DONTNEED and
change_huge_pmd(.prot_numa=1) resulting in skipping THP by
zap_pmd_range(). It need to be addressed.

And MADV_FREE requires a fix.

So, minus one non-bug, plus two bugs. 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
