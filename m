Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEE6A6B02F4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:25:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so13744746pfj.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:25:59 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id n18si5273603pgd.449.2017.08.30.16.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:25:58 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id r62so23322787pfj.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:25:58 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170830212514.GI13559@redhat.com>
Date: Wed, 30 Aug 2017 16:25:54 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <75825BFF-8ACC-4CAB-93EB-AD9673747518@gmail.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <003685D9-4DA9-42DC-AF46-7A9F8A43E61F@gmail.com>
 <20170830212514.GI13559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, iommu <iommu@lists.linux-foundation.org>

[cc=E2=80=99ing IOMMU people, which for some reason are not cc=E2=80=99d]

Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Aug 30, 2017 at 11:00:32AM -0700, Nadav Amit wrote:
>> It is not trivial to flush TLBs (primary or secondary) without =
holding the
>> page-table lock, and as we recently encountered this resulted in =
several
>> bugs [1]. The main problem is that even if you perform the TLB flush
>> immediately after the PT-lock is released, you cause a situation in =
which
>> other threads may make decisions based on the updated PTE value, =
without
>> being aware that a TLB flush is needed.
>>=20
>> For example, we recently encountered a Linux bug when two threads run
>> MADV_DONTNEED concurrently on the same address range [2]. One of the =
threads
>> may update a PTE, setting it as non-present, and then deferring the =
TLB
>> flush (for batching). As a result, however, it would cause the second
>> thread, which also changes the PTEs to assume that the PTE is already
>> non-present and TLB flush is not necessary. As a result the second =
core may
>> still hold stale PTEs in its TLB following MADV_DONTNEED.
>=20
> The source of those complex races that requires taking into account
> nested tlb gather to solve it, originates from skipping primary MMU
> tlb flushes depending on the value of the pagetables (as an
> optimization).
>=20
> For mmu_notifier_invalidate_range_end we always ignore the value of
> the pagetables and mmu_notifier_invalidate_range_end always runs
> unconditionally invalidating the secondary MMU for the whole range
> under consideration. There are no optimizations that attempts to skip
> mmu_notifier_invalidate_range_end depending on the pagetable value and
> there's no TLB gather for secondary MMUs either. That is to keep it
> simple of course.
>=20
> As long as those mmu_notifier_invalidate_range_end stay unconditional,
> I don't see how those races you linked, can be possibly relevant in
> evaluating if ->invalidate_range (again only for iommuv2 and
> intel-svm) has to run inside the PT lock or not.

Thanks for the clarifications. It now makes much more sense.

>=20
>> There is a swarm of such problems, and some are not too trivial. =
Deferring
>> TLB flushes needs to be done in a very careful manner.
>=20
> I agree it's not trivial, but I don't think any complexity comes from
> above.
>=20
> The only complexity is about, what if the page is copied to some other
> page and replaced, because the copy is the only case where coherency
> could be retained by the primary MMU. What if the primary MMU starts
> working on the new page in between PT lock release and
> mmu_notifier_invalidate_range_end, while the secondary MMU is stuck on
> the old page? That is the only problem we deal with here, the copy to
> other page and replace. Any other case that doesn't involve the copy
> seems non coherent by definition, and you couldn't measure it.
>=20
> I can't think of a scenario that requires the explicit
> mmu_notifier_invalidate_range call before releasing the PT lock, at
> least for try_to_unmap_one.
>=20
> Could you think of a scenario where calling ->invalidate_range inside
> mmu_notifier_invalidate_range_end post PT lock breaks iommuv2 or
> intel-svm? Those two are the only ones requiring
> ->invalidate_range calls, all other mmu notifier users are safe
> without running mmu_notifier_invalidate_range_end under PT lock thanks
> to mmu_notifier_invalidate_range_start blocking the secondary MMU.
>=20
> Could you post a tangible scenario that invalidates my theory that
> those mmu_notifier_invalidate_range calls inside PT lock would be
> superfluous?
>=20
> Some of the scenarios under consideration:
>=20
> 1) migration entry -> migration_entry_wait -> page lock, plus
>   migrate_pages taking the lock so it can't race with try_to_unmap
>   from other places
> 2) swap entry -> lookup_swap_cache -> page lock (page not really =
replaced)
> 3) CoW -> do_wp_page -> page lock on old page
> 4) KSM -> replace_page -> page lock on old page
> 5) if the pte is zapped as in MADV_DONTNEED, no coherency possible so
>   it's not measurable that we let the guest run a bit longer on the
>   old page past PT lock release

For both CoW and KSM, the correctness is maintained by calling
ptep_clear_flush_notify(). If you defer the secondary MMU invalidation
(i.e., replacing ptep_clear_flush_notify() with ptep_clear_flush() ), =
you
will cause memory corruption, and page-lock would not be enough.

BTW: I see some calls to ptep_clear_flush_notify() which are followed
immediately after by set_pte_at_notify(). I do not understand why it =
makes
sense, as both notifications end up doing the same thing - invalidating =
the
secondary MMU. The set_pte_at_notify() in these cases can be changed to
set_pte(). No?

> If you could post a multi CPU trace that shows how iommuv2 or
> intel-svm are broken if ->invalidate_range is run inside
> mmu_notifier_invalidate_range_end post PT lock in try_to_unmap_one it
> would help.
>=20
> Of course if we run mmu_notifier_invalidate_range inside PT lock and
> we remove ->invalidate_range from mmu_notifier_invalidate_range_stop
> all will be obviously safe, so we could just do it to avoid thinking
> about the above, but the resulting code will be uglier and less
> optimal (even when disarmed there will be dummy branches I wouldn't
> love) and I currently can't see why it wouldn't be safe.
>=20
> Replacing a page completely without any relation to the old page
> content allows no coherency anyway, so even if it breaks you cannot
> measure it because it's undefined.
>=20
> If the page has a relation with the old contents and coherency has to
> be provided for both primary MMU and secondary MMUs, this relation
> between old and new page during the replacement, is enforced by some
> other mean besides the PT lock, migration entry on locked old page
> with migration_entry_wait and page lock in migrate_pages etc..

I think that basically you are correct, and assuming that you always
notify/invalidate unconditionally any PTE range you read/write, you are
safe. Yet, I want to have another look at the code. Anyhow, just =
deferring
all the TLB flushes, including those of set_pte_at_notify(), is likely =
to
result in errors.

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
