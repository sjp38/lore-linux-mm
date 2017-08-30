Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAF3C6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:00:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r62so12681905pfj.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:00:38 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id g3si4974007plk.263.2017.08.30.11.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 11:00:36 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id b8so21915509pgn.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:00:36 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170830172747.GE13559@redhat.com>
Date: Wed, 30 Aug 2017 11:00:32 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <003685D9-4DA9-42DC-AF46-7A9F8A43E61F@gmail.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Aug 29, 2017 at 07:46:07PM -0700, Nadav Amit wrote:
>> Therefore, IIUC, try_to_umap_one() should only call
>> mmu_notifier_invalidate_range() after ptep_get_and_clear() and
> 
> That would trigger an unnecessarily double call to
> ->invalidate_range() both from mmu_notifier_invalidate_range() after
> ptep_get_and_clear() and later at the end in
> mmu_notifier_invalidate_range_end().
> 
> The only advantage of adding a mmu_notifier_invalidate_range() after
> ptep_get_and_clear() is to flush the secondary MMU TLBs (keep in mind
> the pagetables have to be shared with the primary MMU in order to use
> the ->invalidate_range()) inside the PT lock.
> 
> So if mmu_notifier_invalidate_range() after ptep_get_and_clear() is
> needed or not, again boils down to the issue if the old code calling
> ->invalidate_page outside the PT lock was always broken before or
> not. I don't see why exactly it was broken, we even hold the page lock
> there so I don't see a migration race possible either. Of course the
> constraint to be safe is that the put_page in try_to_unmap_one cannot
> be the last one, and that had to be enforced by the caller taking an
> additional reference on it.
> 
> One can wonder if the primary MMU TLB flush in ptep_clear_flush
> (should_defer_flush returning false) could be put after releasing the
> PT lock too (because that's not different from deferring the secondary
> MMU notifier TLB flush in ->invalidate_range down to
> mmu_notifier_invalidate_range_end) even if TTU_BATCH_FLUSH isn't set,
> which may be safe too for the same reasons.
> 
> When should_defer_flush returns true we already defer the primary MMU
> TLB flush to much later to even mmu_notifier_invalidate_range_end, not
> just after the PT lock release so at least when should_defer_flush is
> true, it looks obviously safe to defer the secondary MMU TLB flush to
> mmu_notifier_invalidate_range_end for the drivers implementing
> ->invalidate_range.

Agreed. It just seems as an enhancement and not directly a bug fix.

> 
> If I'm wrong and all TLB flushes must happen inside the PT lock, then
> we should at least reconsider the implicit call to ->invalidate_range
> method from mmu_notifier_invalidate_range_end or we would call it
> twice unnecessarily which doesn't look optimal. Either ways this
> doesn't look optimal. We would need to introduce a
> mmu_notifier_invalidate_range_end_full that calls also
> ->invalidate_range in such case so we skip the ->invalidate_range call
> in mmu_notifier_invalidate_range_end if we put an explicit
> mmu_notifier_invalidate_range() after ptep_get_and_clear inside the PT
> lock like you suggested above.

It is not trivial to flush TLBs (primary or secondary) without holding the
page-table lock, and as we recently encountered this resulted in several
bugs [1]. The main problem is that even if you perform the TLB flush
immediately after the PT-lock is released, you cause a situation in which
other threads may make decisions based on the updated PTE value, without
being aware that a TLB flush is needed.

For example, we recently encountered a Linux bug when two threads run
MADV_DONTNEED concurrently on the same address range [2]. One of the threads
may update a PTE, setting it as non-present, and then deferring the TLB
flush (for batching). As a result, however, it would cause the second
thread, which also changes the PTEs to assume that the PTE is already
non-present and TLB flush is not necessary. As a result the second core may
still hold stale PTEs in its TLB following MADV_DONTNEED.

There is a swarm of such problems, and some are not too trivial. Deferring
TLB flushes needs to be done in a very careful manner.


[1] https://marc.info/?t=149973438800002&r=1
[2] http://www.spinics.net/lists/linux-mm/msg131525.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
