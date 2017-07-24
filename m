Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 041976B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:45:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so5415621wmh.9
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:45:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e70si626551wme.194.2017.07.24.02.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 02:45:55 -0700 (PDT)
Date: Mon, 24 Jul 2017 10:45:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Always flush VMA ranges affected by zap_page_range
Message-ID: <20170724094553.zf6jq3yjvkn5mfcr@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Nadav Amit report zap_page_range only specifies that the caller protect
the VMA list but does not specify whether it is held for read or write
with callers using either. madvise holds mmap_sem for read meaning that a
parallel zap operation can unmap PTEs which are then potentially skipped
by madvise which potentially returns with stale TLB entries present. While
the API could be extended, it would be a difficult API to use. This patch
causes zap_page_range() to always consider flushing the full affected
range. For small ranges or sparsely populated mappings, this may result
in one additional spurious TLB flush. For larger ranges, it is possible
that the TLB has already been flushed and the overhead is negligible.
Either way, this approach is safer overall and avoids stale entries being
present when madvise returns.

This can be illustrated with the following, slightly modified, program
provided by Nadav Amit. With the patch applied, it has an exit code of 0
indicating a stale TLB entry did not leak to userspace.

---8<---

volatile int sync_step = 0;
volatile char *p;

static inline unsigned long rdtsc()
{
	unsigned long hi, lo;
	__asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
	 return lo | (hi << 32);
}

static inline void wait_rdtsc(unsigned long cycles)
{
	unsigned long tsc = rdtsc();

	while (rdtsc() - tsc < cycles);
}

void *big_madvise_thread(void *ign)
{
	sync_step = 1;
	while (sync_step != 2);
	madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_DONTNEED);
}

int main(void)
{
	pthread_t aux_thread;

	p = mmap(0, PAGE_SIZE * N_PAGES, PROT_READ|PROT_WRITE,
		 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);

	memset((void*)p, 8, PAGE_SIZE * N_PAGES);

	pthread_create(&aux_thread, NULL, big_madvise_thread, NULL);
	while (sync_step != 1);

	*p = 8;		// Cache in TLB
	sync_step = 2;
	wait_rdtsc(100000);
	madvise((void*)p, PAGE_SIZE, MADV_DONTNEED);
	printf("data: %d (%s)\n", *p, (*p == 8 ? "stale, broken" : "cleared, fine"));
	return *p == 8 ? -1 : 0;
}
---8<---

Reported-by: Nadav Amit <nadav.amit@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index bb11c474857e..b93b51f56ee4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1483,8 +1483,20 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	tlb_gather_mmu(&tlb, mm, start, end);
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
+	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
 		unmap_single_vma(&tlb, vma, start, end, NULL);
+
+		/*
+		 * zap_page_range does not specify whether mmap_sem should be
+		 * held for read or write. That allows parallel zap_page_range
+		 * operations to unmap a PTE and defer a flush meaning that
+		 * this call observes pte_none and fails to flush the TLB.
+		 * Rather than adding a complex API, ensure that no stale
+		 * TLB entries exist when this call returns.
+		 */
+		__tlb_adjust_range(&tlb, start, end);
+	}
+
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
