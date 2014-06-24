Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB3F6B0074
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:33:52 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so886769wgg.13
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:33:51 -0700 (PDT)
Received: from mail-wi0-f202.google.com (mail-wi0-f202.google.com [209.85.212.202])
        by mx.google.com with ESMTPS id lr2si1761318wjb.97.2014.06.24.12.33.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 12:33:50 -0700 (PDT)
Received: by mail-wi0-f202.google.com with SMTP id hi2so140580wib.5
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:33:50 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: [PATCHv3 RESEND] mm: page_alloc: fix CMA area initialisation when pageblock > MAX_ORDER
Date: Tue, 24 Jun 2014 21:33:30 +0200
Message-Id: <1403638410-30190-1-git-send-email-mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Mark Salter <msalter@redhat.com>, David Rientjes <rientjes@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>

With a kernel configured with ARM64_64K_PAGES && !TRANSPARENT_HUGEPAGE,
the following is triggered at early boot:

  SMP: Total of 8 processors activated.
  devtmpfs: initialized
  Unable to handle kernel NULL pointer dereference at virtual address 00000008
  pgd = fffffe0000050000
  [00000008] *pgd=00000043fba00003, *pmd=00000043fba00003, *pte=00e0000078010407
  Internal error: Oops: 96000006 [#1] SMP
  Modules linked in:
  CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc864k+ #44
  task: fffffe03bc040000 ti: fffffe03bc080000 task.ti: fffffe03bc080000
  PC is at __list_add+0x10/0xd4
  LR is at free_one_page+0x270/0x638
  ...
  Call trace:
  [<fffffe00003ee970>] __list_add+0x10/0xd4
  [<fffffe000019c478>] free_one_page+0x26c/0x638
  [<fffffe000019c8c8>] __free_pages_ok.part.52+0x84/0xbc
  [<fffffe000019d5e8>] __free_pages+0x74/0xbc
  [<fffffe0000c01350>] init_cma_reserved_pageblock+0xe8/0x104
  [<fffffe0000c24de0>] cma_init_reserved_areas+0x190/0x1e4
  [<fffffe0000090418>] do_one_initcall+0xc4/0x154
  [<fffffe0000bf0a50>] kernel_init_freeable+0x204/0x2a8
  [<fffffe00007520a0>] kernel_init+0xc/0xd4

This happens because init_cma_reserved_pageblock() calls
__free_one_page() with pageblock_order as page order but it is bigger
han MAX_ORDER.  This in turn causes accesses past zone->free_list[].

Fix the problem by changing init_cma_reserved_pageblock() such that it
splits pageblock into individual MAX_ORDER pages if pageblock is
bigger than a MAX_ORDER page.

In cases where !CONFIG_HUGETLB_PAGE_SIZE_VARIABLE, which is all
architectures expect for ia64, powerpc and tile at the moment, the
a??pageblock_order > MAX_ORDERa?? condition will be optimised out since
both sides of the operator are constants.  In cases where pageblock
size is variable, the performance degradation should not be
significant anyway since init_cma_reserved_pageblock() is called
only at boot time at most MAX_CMA_AREAS times which by default is
eight.

Cc: <stable@vger.kernel.org>   # v3.5+
Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Reported-and-tested-by: Mark Salter <msalter@redhat.com>
Tested-by: Christopher Covington <cov@codeaurora.org>
---
 mm/page_alloc.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

 Resent with somehow bigger distribution including Andrew, Mel and
 linux-mm, as well as stable.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee92384..fef9614 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -816,9 +816,21 @@ void __init init_cma_reserved_pageblock(struct page *page)
 		set_page_count(p, 0);
 	} while (++p, --i);
 
-	set_page_refcounted(page);
 	set_pageblock_migratetype(page, MIGRATE_CMA);
-	__free_pages(page, pageblock_order);
+
+	if (pageblock_order >= MAX_ORDER) {
+		i = pageblock_nr_pages;
+		p = page;
+		do {
+			set_page_refcounted(p);
+			__free_pages(p, MAX_ORDER - 1);
+			p += MAX_ORDER_NR_PAGES;
+		} while (i -= MAX_ORDER_NR_PAGES);
+	} else {
+		set_page_refcounted(page);
+		__free_pages(page, pageblock_order);
+	}
+
 	adjust_managed_page_count(page, pageblock_nr_pages);
 }
 #endif
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
