Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 26BBC6B006C
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:44 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so965731vcb.1
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cv7si4765521vcb.2.2014.10.03.10.08.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:42 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/17] mm: gup: make get_user_pages_fast and __get_user_pages_fast latency conscious
Date: Fri,  3 Oct 2014 19:07:54 +0200
Message-Id: <1412356087-16115-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This teaches gup_fast and __gup_fast to re-enable irqs and
cond_resched() if possible every BATCH_PAGES.

This must be implemented by other archs as well and it's a requirement
before converting more get_user_pages() to get_user_pages_fast() as an
optimization (instead of using get_user_pages_unlocked which would be
slower).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/gup.c | 234 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 149 insertions(+), 85 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 2ab183b..917d8c1 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -12,6 +12,12 @@
 
 #include <asm/pgtable.h>
 
+/*
+ * Keep irq disabled for no more than BATCH_PAGES pages.
+ * Matches PTRS_PER_PTE (or half in non-PAE kernels).
+ */
+#define BATCH_PAGES	512
+
 static inline pte_t gup_get_pte(pte_t *ptep)
 {
 #ifndef CONFIG_X86_PAE
@@ -250,6 +256,40 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 	return 1;
 }
 
+static inline int __get_user_pages_fast_batch(unsigned long start,
+					      unsigned long end,
+					      int write, struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long next;
+	unsigned long flags;
+	pgd_t *pgdp;
+	int nr = 0;
+
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables and pages from being freed on x86.
+	 *
+	 * So long as we atomically load page table pointers versus teardown
+	 * (which we do on x86, with the above PAE exception), we can follow the
+	 * address down to the the page and take a ref on it.
+	 */
+	local_irq_save(flags);
+	pgdp = pgd_offset(mm, start);
+	do {
+		pgd_t pgd = *pgdp;
+
+		next = pgd_addr_end(start, end);
+		if (pgd_none(pgd))
+			break;
+		if (!gup_pud_range(pgd, start, next, write, pages, &nr))
+			break;
+	} while (pgdp++, start = next, start != end);
+	local_irq_restore(flags);
+
+	return nr;
+}
+
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
@@ -257,31 +297,55 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	unsigned long flags;
-	pgd_t *pgdp;
-	int nr = 0;
+	unsigned long len, end, batch_pages;
+	int nr, ret;
 
 	start &= PAGE_MASK;
-	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
+	/*
+	 * get_user_pages() handles nr_pages == 0 gracefully, but
+	 * gup_fast starts walking the first pagetable in a do {}
+	 * while() fashion so it's not robust to handle nr_pages ==
+	 * 0. There's no point in being permissive about end < start
+	 * either. So this check verifies both nr_pages being non
+	 * zero, and that "end" didn't overflow.
+	 */
+	VM_BUG_ON(end <= start);
 	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
 					(void __user *)start, len)))
 		return 0;
 
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
+	ret = 0;
+	for (;;) {
+		batch_pages = nr_pages;
+		if (batch_pages > BATCH_PAGES && !irqs_disabled())
+			batch_pages = BATCH_PAGES;
+		len = (unsigned long) batch_pages << PAGE_SHIFT;
+		end = start + len;
+		nr = __get_user_pages_fast_batch(start, end, write, pages);
+		VM_BUG_ON(nr > batch_pages);
+		nr_pages -= nr;
+		ret += nr;
+		if (!nr_pages || nr != batch_pages)
+			break;
+		start += len;
+		pages += batch_pages;
+	}
+
+	return ret;
+}
+
+static inline int get_user_pages_fast_batch(unsigned long start,
+					    unsigned long end,
+					    int write, struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long next;
+	pgd_t *pgdp;
+	int nr = 0;
+	unsigned long orig_start = start;
+
 	/*
 	 * This doesn't prevent pagetable teardown, but does prevent
 	 * the pagetables and pages from being freed on x86.
@@ -290,18 +354,24 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * (which we do on x86, with the above PAE exception), we can follow the
 	 * address down to the the page and take a ref on it.
 	 */
-	local_irq_save(flags);
-	pgdp = pgd_offset(mm, addr);
+	local_irq_disable();
+	pgdp = pgd_offset(mm, start);
 	do {
 		pgd_t pgd = *pgdp;
 
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
+		next = pgd_addr_end(start, end);
+		if (pgd_none(pgd)) {
+			VM_BUG_ON(nr >= (end-orig_start) >> PAGE_SHIFT);
 			break;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+		}
+		if (!gup_pud_range(pgd, start, next, write, pages, &nr)) {
+			VM_BUG_ON(nr >= (end-orig_start) >> PAGE_SHIFT);
 			break;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_restore(flags);
+		}
+	} while (pgdp++, start = next, start != end);
+	local_irq_enable();
+
+	cond_resched();
 
 	return nr;
 }
@@ -326,80 +396,74 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	pgd_t *pgdp;
-	int nr = 0;
+	unsigned long len, end, batch_pages;
+	int nr, ret;
+	unsigned long orig_start;
 
 	start &= PAGE_MASK;
-	addr = start;
+	orig_start = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 
 	end = start + len;
-	if (end < start)
-		goto slow_irqon;
+	/*
+	 * get_user_pages() handles nr_pages == 0 gracefully, but
+	 * gup_fast starts walking the first pagetable in a do {}
+	 * while() fashion so it's not robust to handle nr_pages ==
+	 * 0. There's no point in being permissive about end < start
+	 * either. So this check verifies both nr_pages being non
+	 * zero, and that "end" didn't overflow.
+	 */
+	VM_BUG_ON(end <= start);
 
+	nr = ret = 0;
 #ifdef CONFIG_X86_64
 	if (end >> __VIRTUAL_MASK_SHIFT)
 		goto slow_irqon;
 #endif
+	for (;;) {
+		batch_pages = min(nr_pages, BATCH_PAGES);
+		len = (unsigned long) batch_pages << PAGE_SHIFT;
+		end = start + len;
+		nr = get_user_pages_fast_batch(start, end, write, pages);
+		VM_BUG_ON(nr > batch_pages);
+		nr_pages -= nr;
+		ret += nr;
+		if (!nr_pages)
+			break;
+		if (nr < batch_pages)
+			goto slow_irqon;
+		start += len;
+		pages += batch_pages;
+	}
 
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables and pages from being freed on x86.
-	 *
-	 * So long as we atomically load page table pointers versus teardown
-	 * (which we do on x86, with the above PAE exception), we can follow the
-	 * address down to the the page and take a ref on it.
-	 */
-	local_irq_disable();
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = *pgdp;
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			goto slow;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
-			goto slow;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_enable();
-
-	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
-	return nr;
-
-	{
-		int ret;
+	VM_BUG_ON(ret != (end - orig_start) >> PAGE_SHIFT);
+	return ret;
 
-slow:
-		local_irq_enable();
 slow_irqon:
-		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
-
-		ret = get_user_pages_unlocked(current, mm, start,
-					      (end - start) >> PAGE_SHIFT,
-					      write, 0, pages);
-
-		/* Have to be a bit careful with return values */
-		if (nr > 0) {
-			if (ret < 0)
-				ret = nr;
-			else
-				ret += nr;
-		}
+	/* Try to get the remaining pages with get_user_pages */
+	start += nr << PAGE_SHIFT;
+	pages += nr;
 
-		return ret;
+	/*
+	 * "nr" was the get_user_pages_fast_batch last retval, "ret"
+	 * was the sum of all get_user_pages_fast_batch retvals, now
+	 * "nr" becomes the sum of all get_user_pages_fast_batch
+	 * retvals and "ret" will become the get_user_pages_unlocked
+	 * retval.
+	 */
+	nr = ret;
+
+	ret = get_user_pages_unlocked(current, mm, start,
+				      (end - start) >> PAGE_SHIFT,
+				      write, 0, pages);
+
+	/* Have to be a bit careful with return values */
+	if (nr > 0) {
+		if (ret < 0)
+			ret = nr;
+		else
+			ret += nr;
 	}
+
+	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
