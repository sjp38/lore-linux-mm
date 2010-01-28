Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 16C0D6B00C5
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:20:59 -0500 (EST)
Date: Thu, 28 Jan 2010 16:20:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100128152048.GA1217@random.random>
References: <20100125174556.GA23003@sgi.com>
 <20100125190052.GF5756@random.random>
 <20100125211033.GA24272@sgi.com>
 <20100125211615.GH5756@random.random>
 <20100126212904.GE6653@sgi.com>
 <20100126213853.GY30452@random.random>
 <20100128031841.GG6616@sgi.com>
 <20100128034943.GH6616@sgi.com>
 <20100128100327.GF24242@random.random>
 <20100128132503.GJ6616@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128132503.GJ6616@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, cl@linux-foundation.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 07:25:03AM -0600, Robin Holt wrote:
> The GRU is using a hardware TLB of 2MB page size when the
> is_vm_hugetlb_page() indicates it is a 2MB vma.  From my reading of it,
> your callout to mmu_notifier_invalidate_page() will work for gru and I
> think it will work for XPMEM as well, but I am not certain of that yet.
> I am certain that it can be made to work for XPMEM.  I think using the
> range callouts are actually worse because now we are mixing the conceptual
> uses of page and range.

KVM also will obviously be fine, the whole point of transparent
hugepage support is to allow mapping 2M tlb and 2M shadow pages in the
spmd... In fact I'm already calling the 4k callout for the 2M
pmdp_flush_clear_young_notify... because worst case that won't cash
but only swap less smart. However at the moment start/stop is just
safer... and gives more peace of mind and they can't schedule
anyway... but I surely would prefer a single call too, if nothing else
for performance reasons. Said that it's definitely not a fast path
worth worrying about for KVM.

Even the tlb_flush of pmdp_*flush on x86 is a range flush in
transparent huegepage support because I found errata that invlpg isn't
ok to flush PSE tlb on some cpus but then I didn't check the details,
I just wanted less risk right now, later it can be optimized (worst
case dependent on cpuid).

Note also that pmdp_splitting_flush_notify probably can drop the
_notify part. As long as there is symmetry with the "pages" returned
by gup and their respective put_page and you only use the "page" to do
put_page and get its physical address, there is no need to be notified
about a split_huge_page. At the moment it seems just a little more
paranoid but again not a requirement by design because hugepages are
stable, and only thing that can require an invalidate is a physical
relocation that only happens during swap (or similar). split_huge_page
doesn't affect _physical_ at all, and in turn there is in theory no
need to modify the secondary mmu mappings, when the primary mmu
mappings are altered. One of the reasons of altering the primary mmu
mappings is to avoid confusing the code that can't handle huge pmd
natively and would crash on them, so we virtually split the page to
show to that code an environment it won't find itself lost.

> I must be missing something key here.  I thought unmap_mapping_range_vma
> would percolate down to calling mmu_notifier_invalidate_page() which
> xpmem can sleep in.  Based upon that assumption, I don't see the
> need for the other patches.

unmap_mapping_range takes i_mmap_lock (spinlock) and then calls
zap_page_range that calls unmap_vmas under spinlock, that leads to
mmu_notifier_invalidate_range_start under i_mmap_lock. That only
happens for truncate... That was also the reason that Christioph's
first patchset had a sleep parameter in its version of
mmu_notifier_invalidate_something(sleep) (and sleep=0 was passed when
it was called inside truncate IIRC).

> I don't see the mandatory part here.  Maybe it is your broken english

Eheh, my english so bad ah... :(. And my writing is probably better
than my pronunciation ;)

> combined with my ignorance, but I do not see what the statement
> "i_mmap_lock side is mandatory" is based upon.  It looks to me like

Tried to explain again above, hope it is clearer this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
