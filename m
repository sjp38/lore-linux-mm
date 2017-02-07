Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8F086B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:19:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v67so2953087wrb.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:19:59 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id s26si12363142wma.12.2017.02.07.06.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 06:19:58 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id 89so5731746wrr.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:19:58 -0800 (PST)
Date: Tue, 7 Feb 2017 17:19:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170207141956.GA4789@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170205161252.85004-4-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
> 
> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
> This can cause pmd_protnone entry not being freed.
> 
> Because there are two steps in changing a pmd entry to a pmd_protnone
> entry. First, the pmd entry is cleared to a pmd_none entry, then,
> the pmd_none entry is changed into a pmd_protnone entry.
> The racy check, even with barrier, might only see the pmd_none entry
> in zap_pmd_range(), thus, the mapping is neither split nor zapped.

Okay, this only can happen to MADV_DONTNEED as we hold
down_write(mmap_sem) for the rest of zap_pmd_range() and whoever modifies
page tables has to hold at least down_read(mmap_sem) or exclude parallel
modification in other ways.

See 1a5a9906d4e8 ("mm: thp: fix pmd_bad() triggering in code paths holding
mmap_sem read mode") for more details.

+Andrea.

> Later, in free_pmd_range(), pmd_none_or_clear() will see the
> pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
> since the pmd_protnone entry is not properly freed, the corresponding
> deposited pte page table is not freed either.

free_pmd_range() should be fine: we only free page tables after vmas gone
(under down_write(mmap_sem() in exit_mmap() and unmap_region()) or after
pagetables moved (under down_write(mmap_sem) in shift_arg_pages()).

> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.

The problem is that numabalancing calls change_huge_pmd() under
down_read(mmap_sem), not down_write(mmap_sem) as the rest of users do.
It makes numabalancing the only code path beyond page fault that can turn
pmd_none() into pmd_trans_huge() under down_read(mmap_sem).

This can lead to race when MADV_DONTNEED miss THP. That's not critical for
pagefault vs. MADV_DONTNEED race as we will end up with clear page in that
case. Not so much for change_huge_pmd().

Looks like we need pmdp_modify() or something to modify protection bits
inplace, without clearing pmd.

Not sure how to get crash scenario.

BTW, Zi, have you observed the crash? Or is it based on code inspection?
Any backtraces?

Ouch! madvise_free_huge_pmd() is broken too. We shouldn't clear pmd in the
middle of it as we only hold down_read(mmap_sem). I guess we need a helper
to clear both access and dirty bits.
Minchan, could you look into it?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
