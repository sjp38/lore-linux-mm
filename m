Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0F4D6B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 22:09:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 17-v6so26203043qkj.19
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 19:09:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4-v6si2482859qkl.131.2018.10.16.19.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 19:09:32 -0700 (PDT)
Date: Tue, 16 Oct 2018 22:09:30 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Message-ID: <20181017020930.GN30832@redhat.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hello Zi,

On Sun, Oct 14, 2018 at 08:53:55PM -0400, Zi Yan wrote:
> Hi Andrea, what is the purpose/benefit of making x86a??s pmd_present() returns true
> for a THP under splitting? Does it cause problems when ARM64a??s pmd_present()
> returns false in the same situation?

!pmd_present means it's a migration entry or swap entry and doesn't
point to RAM. It means if you do pmd_to_page(*pmd) it will return you
an undefined result.

During splitting the physical page is still very well pointed by the
pmd as long as pmd_trans_huge returns true and you hold the
pmd_lock.

pmd_trans_huge must be true at all times for a transhuge pmd that
points to a hugepage, or all VM fast paths won't serialize with the
pmd_lock, that is the only reason why, and it's a very good reason
because it avoids to take the pmd_lock when walking over non transhuge
pmds (i.e. when there are no THP allocated).

Now if we've to keep _PAGE_PSE set and return true in pmd_trans_huge
at all times, why would you want to make pmd_present return false? How
could it help if pmd_trans_huge returns true, but pmd_present returns
false despite pmd_to_page works fine and the pmd is really still
pointing to the page?

When userland faults on such pmd !pmd_present it will make the page
fault take a swap or migration path, but that's the wrong path if the
pmd points to RAM.

What we need to do during split is an invalidate of the huge TLB.
There's no pmd_trans_splitting anymore, so we only clear the present
bit in the PTE despite pmd_present still returns true (just like
PROT_NONE, nothing new in this respect). pmd_present never meant the
real present bit in the pte was set, it just means the pmd points to
RAM. It means it doesn't point to swap or migration entry and you can
do pmd_to_page and it works fine.

We need to invalidate the TLB by clearing the present bit and by
flushing the TLB before overwriting the transhuge pmd with the regular
pte (i.e. to make it non huge). That is actually required by an errata
(l1 cache aliasing of the same mapping through two different TLB of
two different sizes broke some old CPU and triggered machine checks).
It's not something fundamentally necessary from a common code point of
view. It's more risky from an hardware (not software) standpoint and
before you can get rid of the pmd you need to do a TLB flush anyway to
be sure CPUs stops using it, so better clear the present bit before
doing the real costly thing (the tlb flush with IPIs). Clearing the
present bit during the TLB flush is a cost that gets lost in the noise.

The clear of the real present bit during pmd (virtual) splitting is
done with pmdp_invalidate, that is created specifically to keeps
pmd_trans_huge=true, pmd_present=true despite the present bit is not
set. So you could imagine _PAGE_PSE as the real present bit.

Before the physical split was deferred and decoupled from the virtual
memory pmd split, pmd_trans_splitting allowed to wait the split to
finish and to keep all gup_fast at bay during it (while the page was
still mapped readable and writable in userland by other CPUs). Now the
physical split is deferred so you just split the pmd locally and only
a physical split invoked on the page (not the virtual split invoked on
the pmd with split_huge_pmd) has to keep gup at bay, and it does so by
freezing the refcount so all gup_fast fail with the
page_cache_get_speculative during the freeze. This removed the need of
the pmd_splitting flag in gup_fast (when pmd_splitting was set gup
fast had to go through the non-fast gup), but it means that now a
hugepage cannot be physically splitted if it's gup pinned. The main
difference is that freezing the refcount can fail, so the code must
learn to cope with such failure and defer it. Decoupling the physical
and virtual splits introduced the need of tracking the doublemap case
with a new PG_double_map flag too. It makes the refcounting of
hugepages trivial in comparison (identical to hugetlbfs in fact), but
it requires total_mapcount to account for all those huge and non huge
mappings. It primarily pays off to add THP to tmpfs where the physical
split may have to be deferred for pagecache reasons anyway.

Thanks,
Andrea
