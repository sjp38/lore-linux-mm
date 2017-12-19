Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1FE56B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:11:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 96so11033063wrk.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:11:13 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id i133si1067614wma.52.2017.12.19.03.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 03:11:12 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2] mm/vmalloc: Replace opencoded 4-level page walkers
Date: Tue, 19 Dec 2017 11:10:25 +0000
Message-Id: <20171219111025.28283-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Rather than open-code the intricacies of walking the 4-level page
tables, use the generic page table walker apply_to_page_range() instead.

The important change is that it now cleans up after an
unsuccessful insertion and propagates the correct error. The current
failure may lead to a WARN if we encounter ENOMEM in one
vmap_pte_range() and later retry with the same page range:

WARNING: CPU: 0 PID: 605 at mm/vmalloc.c:136 vmap_page_range_noflush+0x2c1/0x340
i.e. WARN_ON(!pte_none(*pte))

v2: Don't convert the vunmap code over to apply_to_page_range() as it
may try to allocate during atomic sections, such as exiting a task:

[    9.837563]  [<ffffffff810519b0>] pte_alloc_one_kernel+0x10/0x20
[    9.837568]  [<ffffffff811a7486>] __pte_alloc_kernel+0x16/0xa0
[    9.837572]  [<ffffffff811aaa76>] apply_to_page_range+0x3f6/0x460
[    9.837576]  [<ffffffff811b8888>] free_unmap_vmap_area_noflush+0x28/0x40
[    9.837579]  [<ffffffff811b9dcd>] remove_vm_area+0x4d/0x60
[    9.837582]  [<ffffffff811b9e09>] __vunmap+0x29/0x130
[    9.837585]  [<ffffffff811b9f7d>] vfree+0x3d/0x90
[    9.837589]  [<ffffffff8107ace6>] put_task_stack+0x76/0x130

and it also upsets sparc64:

[    2.530785] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,max_idle_ns: 19112604462750000 ns
[    2.532359] kernel BUG at mm/memory.c:1881!
[    2.532798]               \|/ ____ \|/
[    2.532798]               "@'/ .. \`@"
[    2.532798]               /_| \__/ |_\
[    2.532798]                  \__U_/
[    2.533250] swapper(1): Kernel bad sw trap 5 [#1]
[    2.533705] CPU: 0 PID: 1 Comm: swapper Not tainted 4.9.0-rc2+ #1
[    2.534129] task: fffff8001f0af620 task.stack: fffff8001f0b0000
[    2.534505] TSTATE: 0000004480001605 TPC: 00000000005124d8 TNPC: 00000000005124dc Y: 00000035    Not tainted
[    2.535112] TPC: <apply_to_page_range+0x2f8/0x3a0>
[    2.535469] g0: 00000000009b1548 g1: 0000000000a4a990 g2: 0000000000a4a990 g3: 0000000000b37694
[    2.535857] g4: fffff8001f0af620 g5: 0000000000000000 g6: fffff8001f0b0000 g7: 0000000000000000
[    2.536236] o0: 000000000000001f o1: 00000000009ac2c0 o2: 0000000000000759 o3: 0000000000122000
[    2.536695] o4: 0000000000000000 o5: 00000000009ac2c0 sp: fffff8001f0b2d61 ret_pc: 00000000005124d0
[    2.537086] RPC: <apply_to_page_range+0x2f0/0x3a0>
[    2.537454] l0: 0000000000000000 l1: 0000000000002000 l2: fffff8001f10b000 l3: 0000000100002000
[    2.537843] l4: 0000000000aef910 l5: 0000000000a5e7e8 l6: 0000000100001fff l7: ffffffffff800000
[    2.538229] i0: 0000000000a5e7e8 i1: 0000000100000000 i2: 0000000100002000 i3: 000000000051e5e0
[    2.538613] i4: fffff8001f0b3708 i5: fffff8001f10c000 i6: fffff8001f0b2e51 i7: 000000000051e8e0
[    2.539007] I7: <vmap_page_range_noflush+0x40/0x80>
[    2.539387] Call Trace:
[    2.539765]  [000000000051e8e0] vmap_page_range_noflush+0x40/0x80
[    2.540139]  [000000000051e970] map_vm_area+0x50/0x80
[    2.540492]  [000000000051f84c] __vmalloc_node_range+0x14c/0x260
[    2.540848]  [000000000051f98c] __vmalloc_node+0x2c/0x40
[    2.541198]  [00000000004d39cc] bpf_prog_alloc+0x2c/0xa0
[    2.541554]  [00000000008129bc] bpf_prog_create+0x3c/0xa0
[    2.541916]  [0000000000adb21c] ptp_classifier_init+0x20/0x4c
[    2.542271]  [0000000000ad9808] sock_init+0x90/0xa0
[    2.542622]  [0000000000426cb0] do_one_initcall+0x30/0x160
[    2.542978]  [0000000000aaeaec] kernel_init_freeable+0x10c/0x1b0
[    2.543332]  [00000000008e3324] kernel_init+0x4/0x100
[    2.543681]  [0000000000405f04] ret_from_fork+0x1c/0x2c

which was a BUG_ON(pmd_huge(*pmd)) and seems to be a general problem
pointed out by the generic pagewalkers that is handled by vunmap.
Perhaps we need a clear_page_range()?

Bugzilla: https://bugs.freedesktop.org/show_bug.cgi?id=98269
References: msg-id:20161028171825.GA15116@roeck-us.net
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org
---
 mm/vmalloc.c | 108 ++++++++++++++---------------------------------------------
 1 file changed, 26 insertions(+), 82 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..fef79affc4ab 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -131,80 +131,27 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	} while (pgd++, addr = next, addr != end);
 }
 
-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pte_t *pte;
-
-	/*
-	 * nr is a running index into the array which helps higher level
-	 * callers keep track of where we're up to.
-	 */
-
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		struct page *page = pages[*nr];
-
-		if (WARN_ON(!pte_none(*pte)))
-			return -EBUSY;
-		if (WARN_ON(!page))
-			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
+struct vmap_page {
+	pgprot_t prot;
+	struct page **pages;
+	unsigned long count;
+};
 
-static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_page(pte_t *pte, pgtable_t token,
+		     unsigned long addr, void *data)
 {
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
+	struct vmap_page *v = data;
+	struct page *page;
 
-static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pud_t *pud;
-	unsigned long next;
+	if (WARN_ON(!pte_none(*pte)))
+		return -EBUSY;
 
-	pud = pud_alloc(&init_mm, p4d, addr);
-	if (!pud)
+	page = v->pages[v->count];
+	if (WARN_ON(!page))
 		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
-	return 0;
-}
 
-static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	p4d_t *p4d;
-	unsigned long next;
-
-	p4d = p4d_alloc(&init_mm, pgd, addr);
-	if (!p4d)
-		return -ENOMEM;
-	do {
-		next = p4d_addr_end(addr, end);
-		if (vmap_pud_range(p4d, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (p4d++, addr = next, addr != end);
+	set_pte_at(&init_mm, addr, pte, mk_pte(page, v->prot));
+	v->count++;
 	return 0;
 }
 
@@ -217,22 +164,19 @@ static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 				   pgprot_t prot, struct page **pages)
 {
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long addr = start;
-	int err = 0;
-	int nr = 0;
+	struct vmap_page v = { prot, pages };
+	int err;
 
-	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_p4d_range(pgd, addr, next, prot, pages, &nr);
-		if (err)
-			return err;
-	} while (pgd++, addr = next, addr != end);
+	if ((end - start) >> PAGE_SHIFT > INT_MAX)
+		return -EINVAL;
+
+	err = apply_to_page_range(&init_mm, start, end - start, vmap_page, &v);
+	if (unlikely(err)) {
+		vunmap_page_range(start, start + (v.count << PAGE_SHIFT));
+		return err;
+	}
 
-	return nr;
+	return v.count;
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
