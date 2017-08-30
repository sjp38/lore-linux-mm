Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEA76B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:40:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k3so12856410pfc.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:40:13 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id t14si4777359pfk.431.2017.08.30.11.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 11:40:11 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id 63so22131761pgc.2
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:40:11 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170830182013.GD2386@redhat.com>
Date: Wed, 30 Aug 2017 11:40:08 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com> <20170830182013.GD2386@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Jerome Glisse <jglisse@redhat.com> wrote:

> On Wed, Aug 30, 2017 at 07:27:47PM +0200, Andrea Arcangeli wrote:
>> On Tue, Aug 29, 2017 at 07:46:07PM -0700, Nadav Amit wrote:
>>> Therefore, IIUC, try_to_umap_one() should only call
>>> mmu_notifier_invalidate_range() after ptep_get_and_clear() and
>>=20
>> That would trigger an unnecessarily double call to
>> ->invalidate_range() both from mmu_notifier_invalidate_range() after
>> ptep_get_and_clear() and later at the end in
>> mmu_notifier_invalidate_range_end().
>>=20
>> The only advantage of adding a mmu_notifier_invalidate_range() after
>> ptep_get_and_clear() is to flush the secondary MMU TLBs (keep in mind
>> the pagetables have to be shared with the primary MMU in order to use
>> the ->invalidate_range()) inside the PT lock.
>>=20
>> So if mmu_notifier_invalidate_range() after ptep_get_and_clear() is
>> needed or not, again boils down to the issue if the old code calling
>> ->invalidate_page outside the PT lock was always broken before or
>> not. I don't see why exactly it was broken, we even hold the page =
lock
>> there so I don't see a migration race possible either. Of course the
>> constraint to be safe is that the put_page in try_to_unmap_one cannot
>> be the last one, and that had to be enforced by the caller taking an
>> additional reference on it.
>>=20
>> One can wonder if the primary MMU TLB flush in ptep_clear_flush
>> (should_defer_flush returning false) could be put after releasing the
>> PT lock too (because that's not different from deferring the =
secondary
>> MMU notifier TLB flush in ->invalidate_range down to
>> mmu_notifier_invalidate_range_end) even if TTU_BATCH_FLUSH isn't set,
>> which may be safe too for the same reasons.
>>=20
>> When should_defer_flush returns true we already defer the primary MMU
>> TLB flush to much later to even mmu_notifier_invalidate_range_end, =
not
>> just after the PT lock release so at least when should_defer_flush is
>> true, it looks obviously safe to defer the secondary MMU TLB flush to
>> mmu_notifier_invalidate_range_end for the drivers implementing
>> ->invalidate_range.
>>=20
>> If I'm wrong and all TLB flushes must happen inside the PT lock, then
>> we should at least reconsider the implicit call to ->invalidate_range
>> method from mmu_notifier_invalidate_range_end or we would call it
>> twice unnecessarily which doesn't look optimal. Either ways this
>> doesn't look optimal. We would need to introduce a
>> mmu_notifier_invalidate_range_end_full that calls also
>> ->invalidate_range in such case so we skip the ->invalidate_range =
call
>> in mmu_notifier_invalidate_range_end if we put an explicit
>> mmu_notifier_invalidate_range() after ptep_get_and_clear inside the =
PT
>> lock like you suggested above.
>=20
> So i went over call to try_to_unmap() (try_to_munlock() is fine as it
> does not clear the CPU page table entry). I believe they are 2 cases
> where you can get a new pte entry after we release spinlock and before
> we call mmu_notifier_invalidate_range_end()
>=20
> First case is :
> if (unlikely(PageSwapBacked(page) !=3D PageSwapCache(page))) {
>  ...
>  break;
> }
>=20
> The pte is clear, there was an error condition and this should never
> happen but a racing thread might install a new pte in the meantime.
> Maybe we should restore the pte value here. Anyway when this happens
> bad things are going on.
>=20
> The second case is non dirty anonymous page and MADV_FREE. But here
> the application is telling us that no one should care about that
> virtual address any more. So i am not sure how much we should care.
>=20
>=20
> If we ignore this 2 cases than the CPU pte can never be replace by
> something else between the time we release the spinlock and the time
> we call mmu_notifier_invalidate_range_end() so not invalidating the
> devices tlb is ok here. Do we want this kind of optimization ?

The mmu_notifier users would have to be aware that invalidations may be
deferred. If they perform their ``invalidations=E2=80=99=E2=80=99 =
unconditionally, it may be
ok. If the notifier users avoid invalidations based on the PTE in the
secondary page-table, it can be a problem.

On another note, you may want to consider combining the secondary =
page-table
mechanisms with the existing TLB-flush mechanisms. Right now, it is
partially done: tlb_flush_mmu_tlbonly(), for example, calls
mmu_notifier_invalidate_range(). However, tlb_gather_mmu() does not call
mmu_notifier_invalidate_range_start().

This can also prevent all kind of inconsistencies, and potential bugs. =
For
instance, clear_refs_write() calls =
mmu_notifier_invalidate_range_start/end()
but in between there is no call for mmu_notifier_invalidate_range().

Regards,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
