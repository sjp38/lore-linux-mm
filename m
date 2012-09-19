Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9D10D6B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 05:12:54 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so748705qcs.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 02:12:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120918123331.6ca5833c.akpm@linux-foundation.org>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-3-git-send-email-will.deacon@arm.com> <20120915133833.GA32398@linux-mips.org>
 <20120918123331.6ca5833c.akpm@linux-foundation.org>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 19 Sep 2012 10:12:28 +0100
Message-ID: <CAHkRjk7uCZZvA_Ubq7vgkAV2r-vMNHxs+hZmvf+99ks+4v7isA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: thp: Fix the update_mmu_cache() last argument
 passing in mm/huge_memory.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralf Baechle <ralf@linux-mips.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>

On 18 September 2012 20:33, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sat, 15 Sep 2012 15:38:33 +0200
> Ralf Baechle <ralf@linux-mips.org> wrote:
>> On Tue, Sep 11, 2012 at 05:47:15PM +0100, Will Deacon wrote:
>> > The update_mmu_cache() takes a pointer (to pte_t by default) as the last
>> > argument but the huge_memory.c passes a pmd_t value. The patch changes
>> > the argument to the pmd_t * pointer.
>> >
>> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>> > Signed-off-by: Steve Capper <steve.capper@arm.com>
>> > Signed-off-by: Will Deacon <will.deacon@arm.com>
>> > ---
>> >  mm/huge_memory.c |    6 +++---
>> >  1 files changed, 3 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> > index 57c4b93..4aa6d02 100644
>> > --- a/mm/huge_memory.c
>> > +++ b/mm/huge_memory.c
>> > @@ -934,7 +934,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>> >             entry = pmd_mkyoung(orig_pmd);
>> >             entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>> >             if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
>> > -                   update_mmu_cache(vma, address, entry);
>> > +                   update_mmu_cache(vma, address, pmd);
>>
>> Documentation/cachetlb.txt will need an update as well.  Currently it says:
>>
>> 5) void update_mmu_cache(struct vm_area_struct *vma,
>>                          unsigned long address, pte_t *ptep)
>
> Yes please.

Should we just use a generic (void *) for the last argument or force a
cast in mm/huge_memory.c?

Ralf's point is that transparent huge page code calls update_mmu_cache
with a (pmd_t *) as the last argument. This could make sense for THP
as it assumes that huge pages can only be created at the pmd level.
But that's unlike mm/hugetlb.c which casts huge page types to pte_t,
even though on ARM they are implemented at the pmd level.

On ARM (with VIPT caches) update_mmu_cache() is empty like on x86,
though a static inline rather than macro.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
