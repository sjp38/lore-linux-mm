Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96A226B004F
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 11:37:58 -0500 (EST)
Subject: [PATCH] x86,mm: fix pte_free()
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Fri, 23 Jan 2009 17:37:49 +0100
Message-Id: <1232728669.4826.143.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On -rt we were seeing spurious bad page states like:

Bad page state in process 'firefox'
page:c1bc2380 flags:0x40000000 mapping:c1bc2390 mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Pid: 503, comm: firefox Not tainted 2.6.26.8-rt13 #3
[<c043d0f3>] ? printk+0x14/0x19
[<c0272d4e>] bad_page+0x4e/0x79
[<c0273831>] free_hot_cold_page+0x5b/0x1d3
[<c02739f6>] free_hot_page+0xf/0x11
[<c0273a18>] __free_pages+0x20/0x2b
[<c027d170>] __pte_alloc+0x87/0x91
[<c027d25e>] handle_mm_fault+0xe4/0x733
[<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
[<c043f680>] ? rt_mutex_down_read_trylock+0x57/0x63
[<c0218875>] do_page_fault+0x36f/0x88a

This is the case where a concurrent fault already installed the PTE and
we get to free the newly allocated one.

This is due to pgtable_page_ctor() doing the spin_lock_init(&page->ptl)
which is overlaid with the {private, mapping} struct.

union {
    struct {
        unsigned long private;
        struct address_space *mapping;
    };
#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
    spinlock_t ptl;
#endif
    struct kmem_cache *slab;
    struct page *first_page;
};

Normally the spinlock is small enough to not stomp on page->mapping, but
PREEMPT_RT=y has huge 'spin'locks.

But lockdep kernels should also be able to trigger this splat, as the
lock tracking code grows the spinlock to cover page->mapping.

The obvious fix is calling pgtable_page_dtor() like the regular pte free
path __pte_free_tlb() does.

It seems all architectures except x86 and nm10300 already do this, and
nm10300 doesn't seem to use pgtable_page_ctor(), which suggests it
doesn't do SMP or simply doesnt do MMU at all or something.

Signed-off-by: Peter Zijlstra <a.p.zijlsta@chello.nl>
CC: stable@kernel.org
---
 arch/x86/include/asm/pgalloc.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index cb7c151..b99023c 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -42,6 +42,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline void pte_free(struct mm_struct *mm, struct page *pte)
 {
+	pgtable_page_dtor();
 	__free_page(pte);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
