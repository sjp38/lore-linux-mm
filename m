Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B4876B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 10:54:37 -0400 (EDT)
Subject: [RFT][PATCH] mm: Fix race in kunmap_atomic()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101027125154.GA23679@infradead.org>
References: <20101027125154.GA23679@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Oct 2010 16:54:21 +0200
Message-ID: <1288191261.15336.1953.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-10-27 at 08:51 -0400, Christoph Hellwig wrote:
> I haven't tracked it down to the kmap_atomic rework but it seems
> rather likely:
> 
> [ 2111.896469] ------------[ cut here ]------------
> [ 2111.898408] kernel BUG at /home/hch/work/linux-2.6/arch/x86/mm/highmem_32.c:46!
> [ 2111.900385] invalid opcode: 0000 [#1] SMP 
> [ 2111.900385] last sysfs file: /sys/devices/virtio-pci/virtio1/block/vdb/removable
> [ 2111.900385] Modules linked in:
> [ 2111.900385] 
> [ 2111.900385] Pid: 10286, comm: aio-stress Not tainted 2.6.36+ #32 /Bochs
> [ 2111.900385] EIP: 0060:[<c0158e5c>] EFLAGS: 00010006 CPU: 0
> [ 2111.900385] EIP is at kmap_atomic_prot+0xec/0xf0
> [ 2111.900385] EAX: f75df040 EBX: 00000001 ECX: 3c6d7163 EDX: 00000163
> [ 2111.900385] ESI: fffffffc EDI: 00000001 EBP: f6801e5c ESP: f6801e4c
> [ 2111.900385]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [ 2111.900385] Process aio-stress (pid: 10286, ti=f6800000 task=f13c8280task.ti=f1356000)
> [ 2111.900385] Stack:
> [ 2111.900385]  fffff000 f2840ef0 f20ac690 00010000 f6801e64 c0158e6e f6801e9c c024ee0d
> [ 2111.900385] <0> ffffffff 00000000 f6801eac 00000046 f13c870c 00000002 00000000 00000096
> [ 2111.900385] <0> f20ac6d8 d4c23950 00010000 00000000 f6801ed0 c0244be7 d4c23a24 00000096
> [ 2111.900385] Call Trace:
> [ 2111.900385]  [<c0158e6e>] ? __kmap_atomic+0xe/0x10
> [ 2111.900385]  [<c024ee0d>] ? aio_complete+0xdd/0x1a0
> [ 2111.900385]  [<c0244be7>] ? dio_complete+0x107/0x110
> [ 2111.900385]  [<c0244c35>] ? dio_bio_end_aio+0x45/0xa0
> [ 2111.900385]  [<c0244c5b>] ? dio_bio_end_aio+0x6b/0xa0
> [ 2111.900385]  [<c02407a5>] ? bio_endio+0x15/0x30
> [ 2111.900385]  [<c071b4c2>] ? req_bio_endio+0xa2/0x100
> [ 2111.900385]  [<c071bdfe>] ? blk_update_request+0x17e/0x420
> [ 2111.900385]  [<c071bd69>] ? blk_update_request+0xe9/0x420
> [ 2111.900385]  [<c071bdfe>] ? blk_update_request+0x17e/0x420
> [ 2111.900385]  [<c021320e>] ? kfree+0xfe/0x170
> [ 2111.900385]  [<c071c0b6>] ? blk_update_bidi_request+0x16/0x80
> [ 2111.900385]  [<c071da55>] ? __blk_end_request_all+0x25/0x50
> [ 2111.900385]  [<c07bf212>] ? blk_done+0x42/0xd0
> [ 2111.900385]  [<c0787ec4>] ? vring_interrupt+0x24/0x40
> [ 2111.900385]  [<c01ba684>] ? handle_IRQ_event+0x44/0x160
> [ 2111.900385]  [<c01bc5ac>] ? handle_edge_irq+0x9c/0x140
> [ 2111.900385]  [<c01bc5b6>] ? handle_edge_irq+0xa6/0x140
> [ 2111.900385]  [<c01bc510>] ? handle_edge_irq+0x0/0x140
> [ 2111.900385]  <IRQ> 
> [ 2111.900385]  [<c0135dd4>] ? do_IRQ+0x44/0xc0
> [ 2111.900385]  [<c017b556>] ? run_timer_softirq+0xd6/0x350
> [ 2111.900385]  [<c01739d0>] ? __do_softirq+0x0/0x1f0
> [ 2111.900385]  [<c013502e>] ? common_interrupt+0x2e/0x34
> [ 2111.900385]  [<c01367c4>] ? do_softirq+0x94/0xe0
> [ 2111.900385]  [<c01739d0>] ? __do_softirq+0x0/0x1f0
> [ 2111.900385]  [<c0173a20>] ? __do_softirq+0x50/0x1f0
> [ 2111.900385]  [<c0173a22>] ? __do_softirq+0x52/0x1f0
> [ 2111.900385]  [<c01739d0>] ? __do_softirq+0x0/0x1f0
> [ 2111.900385]  <IRQ> 
> [ 2111.900385]  [<c017384d>] ? irq_exit+0x6d/0x80
> [ 2111.900385]  [<c014b3b6>] ? smp_apic_timer_interrupt+0x56/0x90
> [ 2111.900385]  [<c0736f04>] ? trace_hardirqs_off_thunk+0xc/0x18
> [ 2111.900385]  [<c0a07167>] ? apic_timer_interrupt+0x2f/0x34
> [ 2111.900385]  [<c0153691>] ? native_set_pte_at+0x1/0x10
> [ 2111.900385]  [<c0158cc0>] ? __kunmap_atomic+0x70/0xa0
> [ 2111.900385]  [<c024e32a>] ? aio_read_evt+0xca/0xf0
> [ 2111.900385]  [<c024f16f>] ? read_events+0xcf/0x340
> [ 2111.900385]  [<c019ff0b>] ? trace_hardirqs_on+0xb/0x10
> [ 2111.900385]  [<c0153f65>] ? pvclock_clocksource_read+0xf5/0x190
> [ 2111.900385]  [<c0169660>] ? default_wake_function+0x0/0x10
> [ 2111.900385]  [<c024f423>] ? sys_io_getevents+0x43/0x90
> [ 2111.900385]  [<c0a06cdd>] ? syscall_call+0x7/0xb

Ooh, nice.. I think the below patch cures this but haven't actually
managed to install xfstest inside a qemu thing yet.

---
Subject: mm: Fix race in kunmap_atomic()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed Oct 27 16:42:10 CEST 2010

Christoph reported a nice splat which illustrated a race in the new
stack based kmap_atomic implementation.

The problem is that we pop our stack slot before we're completely done
resetting its state -- in particular clearing the PTE (sometimes that's
CONFIG_DEBUG_HIGHMEM). If an interrupt happens before we actually clear
the PTE used for the last slot, that interrupt can reuse the slot in a
dirty state, which triggers a BUG in kmap_atomic().

Fix this by introducing kmap_atomic_idx() which reports the current slot
index without actually releasing it and use that to find the PTE and
delay the _pop() until after we're completely done.

Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/mm/highmem.c              |    3 ++-
 arch/frv/mm/highmem.c              |    3 ++-
 arch/mips/mm/highmem.c             |    3 ++-
 arch/mn10300/include/asm/highmem.h |    4 +++-
 arch/powerpc/mm/highmem.c          |    4 +++-
 arch/sparc/mm/highmem.c            |    4 +++-
 arch/tile/mm/highmem.c             |    3 ++-
 arch/x86/mm/highmem_32.c           |    3 ++-
 arch/x86/mm/iomap_32.c             |    3 ++-
 include/linux/highmem.h            |    5 +++++
 10 files changed, 26 insertions(+), 9 deletions(-)

Index: linux-2.6/arch/arm/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/highmem.c
+++ linux-2.6/arch/arm/mm/highmem.c
@@ -89,7 +89,7 @@ void __kunmap_atomic(void *kvaddr)
 	int idx, type;
 
 	if (kvaddr >= (void *)FIXADDR_START) {
-		type = kmap_atomic_idx_pop();
+		type = kmap_atomic_idx();
 		idx = type + KM_TYPE_NR * smp_processor_id();
 
 		if (cache_is_vivt())
@@ -101,6 +101,7 @@ void __kunmap_atomic(void *kvaddr)
 #else
 		(void) idx;  /* to kill a warning */
 #endif
+		kmap_atomic_idx_pop();
 	} else if (vaddr >= PKMAP_ADDR(0) && vaddr < PKMAP_ADDR(LAST_PKMAP)) {
 		/* this address was obtained through kmap_high_get() */
 		kunmap_high(pte_page(pkmap_page_table[PKMAP_NR(vaddr)]));
Index: linux-2.6/arch/frv/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/highmem.c
+++ linux-2.6/arch/frv/mm/highmem.c
@@ -68,7 +68,7 @@ EXPORT_SYMBOL(__kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
-	int type = kmap_atomic_idx_pop();
+	int type = kmap_atomic_idx();
 	switch (type) {
 	case 0:		__kunmap_atomic_primary(4, 6);	break;
 	case 1:		__kunmap_atomic_primary(5, 7);	break;
@@ -83,6 +83,7 @@ void __kunmap_atomic(void *kvaddr)
 	default:
 		BUG();
 	}
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
Index: linux-2.6/arch/mips/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/highmem.c
+++ linux-2.6/arch/mips/mm/highmem.c
@@ -74,7 +74,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
 
-	type = kmap_atomic_idx_pop();
+	type = kmap_atomic_idx();
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
 		int idx = type + KM_TYPE_NR * smp_processor_id();
@@ -89,6 +89,7 @@ void __kunmap_atomic(void *kvaddr)
 		local_flush_tlb_one(vaddr);
 	}
 #endif
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
Index: linux-2.6/arch/mn10300/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/highmem.h
+++ linux-2.6/arch/mn10300/include/asm/highmem.h
@@ -101,7 +101,7 @@ static inline void __kunmap_atomic(unsig
 		return;
 	}
 
-	type = kmap_atomic_idx_pop();
+	type = kmap_atomic_idx();
 
 #if HIGHMEM_DEBUG
 	{
@@ -119,6 +119,8 @@ static inline void __kunmap_atomic(unsig
 		__flush_tlb_one(vaddr);
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 #endif /* __KERNEL__ */
Index: linux-2.6/arch/powerpc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/highmem.c
+++ linux-2.6/arch/powerpc/mm/highmem.c
@@ -62,7 +62,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
 
-	type = kmap_atomic_idx_pop();
+	type = kmap_atomic_idx();
 
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
@@ -79,6 +79,8 @@ void __kunmap_atomic(void *kvaddr)
 		local_flush_tlb_page(NULL, vaddr);
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
Index: linux-2.6/arch/sparc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/highmem.c
+++ linux-2.6/arch/sparc/mm/highmem.c
@@ -75,7 +75,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
 
-	type = kmap_atomic_idx_pop();
+	type = kmap_atomic_idx();
 
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
@@ -104,6 +104,8 @@ void __kunmap_atomic(void *kvaddr)
 #endif
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
Index: linux-2.6/arch/tile/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/tile/mm/highmem.c
+++ linux-2.6/arch/tile/mm/highmem.c
@@ -241,7 +241,7 @@ void __kunmap_atomic(void *kvaddr)
 		pte_t pteval = *pte;
 		int idx, type;
 
-		type = kmap_atomic_idx_pop();
+		type = kmap_atomic_idx();
 		idx = type + KM_TYPE_NR*smp_processor_id();
 
 		/*
@@ -252,6 +252,7 @@ void __kunmap_atomic(void *kvaddr)
 		BUG_ON(!pte_present(pteval) && !pte_migrating(pteval));
 		kmap_atomic_unregister(pte_page(pteval), vaddr);
 		kpte_clear_flush(pte, vaddr);
+		kmap_atomic_idx_pop();
 	} else {
 		/* Must be a lowmem page */
 		BUG_ON(vaddr < PAGE_OFFSET);
Index: linux-2.6/arch/x86/mm/highmem_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/highmem_32.c
+++ linux-2.6/arch/x86/mm/highmem_32.c
@@ -74,7 +74,7 @@ void __kunmap_atomic(void *kvaddr)
 	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
 		int idx, type;
 
-		type = kmap_atomic_idx_pop();
+		type = kmap_atomic_idx();
 		idx = type + KM_TYPE_NR * smp_processor_id();
 
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -87,6 +87,7 @@ void __kunmap_atomic(void *kvaddr)
 		 * attributes or becomes a protected page in a hypervisor.
 		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+		kmap_atomic_idx_pop();
 	}
 #ifdef CONFIG_DEBUG_HIGHMEM
 	else {
Index: linux-2.6/arch/x86/mm/iomap_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/iomap_32.c
+++ linux-2.6/arch/x86/mm/iomap_32.c
@@ -98,7 +98,7 @@ iounmap_atomic(void __iomem *kvaddr)
 	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
 		int idx, type;
 
-		type = kmap_atomic_idx_pop();
+		type = kmap_atomic_idx();
 		idx = type + KM_TYPE_NR * smp_processor_id();
 
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -111,6 +111,7 @@ iounmap_atomic(void __iomem *kvaddr)
 		 * attributes or becomes a protected page in a hypervisor.
 		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+		kmap_atomic_idx_pop();
 	}
 
 	pagefault_enable();
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -88,6 +88,11 @@ static inline int kmap_atomic_idx_push(v
 	return idx;
 }
 
+static inline int kmap_atomic_idx(void)
+{
+	return __get_cpu_var(__kmap_atomic_idx) - 1;
+}
+
 static inline int kmap_atomic_idx_pop(void)
 {
 	int idx = --__get_cpu_var(__kmap_atomic_idx);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
