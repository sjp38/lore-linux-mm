Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C7C6B6B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 11:53:55 -0400 (EDT)
Received: from localhost.localdomain ([127.0.0.1]:50149 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S1903293Ab2ISPxy (ORCPT <rfc822;linux-mm@kvack.org>);
        Wed, 19 Sep 2012 17:53:54 +0200
Date: Wed, 19 Sep 2012 17:53:46 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 2/3] mm: thp: Fix the update_mmu_cache() last argument
 passing in mm/huge_memory.c
Message-ID: <20120919155346.GB32398@linux-mips.org>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-3-git-send-email-will.deacon@arm.com>
 <20120915133833.GA32398@linux-mips.org>
 <20120918123331.6ca5833c.akpm@linux-foundation.org>
 <CAHkRjk7uCZZvA_Ubq7vgkAV2r-vMNHxs+hZmvf+99ks+4v7isA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHkRjk7uCZZvA_Ubq7vgkAV2r-vMNHxs+hZmvf+99ks+4v7isA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>

On Wed, Sep 19, 2012 at 10:12:28AM +0100, Catalin Marinas wrote:

> >> 5) void update_mmu_cache(struct vm_area_struct *vma,
> >>                          unsigned long address, pte_t *ptep)
> >
> > Yes please.
> 
> Should we just use a generic (void *) for the last argument or force a
> cast in mm/huge_memory.c?
> 
> Ralf's point is that transparent huge page code calls update_mmu_cache
> with a (pmd_t *) as the last argument. This could make sense for THP
> as it assumes that huge pages can only be created at the pmd level.
> But that's unlike mm/hugetlb.c which casts huge page types to pte_t,
> even though on ARM they are implemented at the pmd level.
> 
> On ARM (with VIPT caches) update_mmu_cache() is empty like on x86,
> though a static inline rather than macro.

It's even worse - mm/huge_memory.c is passing a pmd_t, not a pointer so
changing the type of update_mmu_cache's 3rd argument alone won't cut it.

This went unnoticed so far because all existing architectures supporting
transparent huge pages implement update_mmu_cache() as do { } while (0).

MIPS uses update_mmu_cache() as the hook to deal with cache aliases and
pre-faulting a TLB entry.  But aliases don't affect small pages and having
a separate variant of update_mmu_cache for huge pages will allow some other
optimizations.  That's minor but it's the argument types that really need
to be fixed and because MIPS also implements huge pages at PMD level I'd
be happy if we settle on pte_t * for mm/huge_memory.c.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
