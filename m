Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C9C236B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 15:56:30 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id u188so118989244wmu.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 12:56:30 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id j10si40859161wje.70.2016.01.18.12.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 12:56:29 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: avoid uninitialized variable in tracepoint
Date: Mon, 18 Jan 2016 21:50:26 +0100
Message-ID: <4117363.Ys1FTDH7Wz@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, dan.carpenter@oracle.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

A newly added tracepoint in the hugepage code uses a variable in the
error handling that is not initialized at that point:

include/trace/events/huge_memory.h:81:230: error: 'isolated' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The result is relatively harmless, as the trace data will in rare
cases contain incorrect data.

This works around the problem by adding an explicit initialization.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 7d2eba0557c1 ("mm: add tracepoint for scanning pages")

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b2db98136af9..bb3b763b1829 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2320,7 +2320,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
-	int isolated, result = 0;
+	int isolated = 0, result = 0;
 	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
