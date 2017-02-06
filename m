Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52D0F6B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:35:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so20776635wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:35:28 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 17si8863117wmv.65.2017.02.06.09.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 09:35:27 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id v77so23148094wmv.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:35:26 -0800 (PST)
Date: Mon, 6 Feb 2017 20:35:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170206173524.GB29962@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170206160751.GA29962@node.shutemov.name>
 <1D482D89-0504-4E98-9931-B160BAEB3D75@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1D482D89-0504-4E98-9931-B160BAEB3D75@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: mgorman@techsingularity.net, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

On Mon, Feb 06, 2017 at 10:32:10AM -0600, Zi Yan wrote:
> On 6 Feb 2017, at 10:07, Kirill A. Shutemov wrote:
> 
> > On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
> >> From: Zi Yan <ziy@nvidia.com>
> >>
> >> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
> >> This can cause pmd_protnone entry not being freed.
> >>
> >> Because there are two steps in changing a pmd entry to a pmd_protnone
> >> entry. First, the pmd entry is cleared to a pmd_none entry, then,
> >> the pmd_none entry is changed into a pmd_protnone entry.
> >> The racy check, even with barrier, might only see the pmd_none entry
> >> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
> >
> > That's definately a good catch.
> >
> > But I don't agree with the solution. Taking pmd lock on each
> > zap_pmd_range() is a significant hit by scalability of the code path.
> > Yes, split ptl lock helps, but it would be nice to avoid the lock in first
> > place.
> >
> > Can we fix change_huge_pmd() instead? Is there a reason why we cannot
> > setup the pmd_protnone() atomically?
> 
> If you want to setup the pmd_protnone() atomically, we need a new way of
> changing pmds, like pmdp_huge_cmp_exchange_and_clear(). Otherwise, due to
> the nature of racy check of pmd in zap_pmd_range(), it is impossible to
> eliminate the chance of catching this bug if pmd_protnone() is setup
> in two steps: first, clear it, second, set it.
> 
> However, if we use pmdp_huge_cmp_exchange_and_clear() to change pmds from now on,
> instead of current two-step approach, it will eliminate the possibility of
> using batched TLB shootdown optimization (introduced by Mel Gorman for base page swapping)
> when THP is swappable in the future. Maybe other optimizations?

I'll think about this more.

> Why do you think holding pmd lock is bad?

Each additional atomic operation in fast-path hurts scalability.
Cost of atomic operations rises fast as machine gets bigger.

> In zap_pte_range(), pte lock is also held when each PTE is zapped.

It's necessary evil for pte. Not so much for pmd so far.

> BTW, I am following Naoya's suggestion and going to take pmd lock inside
> the loop. So pmd lock is held when each pmd is being checked and it will be released
> when the pmd entry is zapped, split, or pointed to a page table.
> Does it still hurt much on performance?

Naoya's suggestion is not correct: pmd_lock() can be different not for
each pmd entry, but for each pmd table. So taking it outside of the loop
is correct.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
